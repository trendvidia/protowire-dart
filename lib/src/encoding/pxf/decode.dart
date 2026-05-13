// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'dart:convert';
import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';
import 'ast.dart';
import 'brace_scan.dart';
import 'duration.dart';
import 'errors.dart';
import 'lexer.dart';
import 'options.dart';
import 'result.dart';
import 'schema.dart';
import 'token.dart';
import 'wellknown.dart';

/// Caches the proto-name → FieldInfo lookup per [BuilderInfo]. Built once
/// per message type and reused across decode calls — `BuilderInfo` instances
/// are static-final per generated class, so the [Expando] never holds onto
/// per-message state.
final Expando<Map<String, FieldInfo>> _byProtoNameCache = Expando('pxfByProto');

/// HARDENING.md § Recursion. Decoder rejects past this many nested message
/// blocks. The cross-port contract is 100; raising it here would diverge.
const int _maxNestingDepth = 100;

class DirectDecoder {
  final Lexer lex;
  late Token current;
  final TypeRegistry typeRegistry;
  final bool discardUnknown;
  Result? result;
  GeneratedMessage? rootMsg;
  FieldInfo? nullMaskFi;
  String pathPrefix = '';
  int _depth = 0;

  DirectDecoder(
    String input, {
    this.typeRegistry = const TypeRegistry.empty(),
    this.discardUnknown = false,
    this.result,
    this.rootMsg,
  }) : lex = Lexer(input) {
    if (rootMsg != null) {
      nullMaskFi = _findNullMaskField(rootMsg!.info_);
    }
    _advance();
  }

  void _advance() {
    while (true) {
      current = lex.next();
      if (current.kind == TokenKind.comment ||
          current.kind == TokenKind.newline) {
        continue;
      }
      // Surface lexer-level rejections (UTF-8 violations, MaxNumericLiteralDigits,
      // bad escapes, ...) as proper decoder errors. The illegal token carries
      // the human-readable reason in its `value` field.
      if (current.kind == TokenKind.illegal) {
        throw PxfError(current.pos, current.value);
      }
      return;
    }
  }

  FieldInfo? _findNullMaskField(BuilderInfo info) {
    var fi = info.byName['_null'];
    if (fi == null) return null;
    if (fi.type == PbFieldType.OM &&
        fi.subBuilder != null &&
        fi.subBuilder!().info_.qualifiedMessageName ==
            'google.protobuf.FieldMask') {
      return fi;
    }
    return null;
  }

  void decodeDocument(GeneratedMessage msg) {
    _consumeDirectives();
    _decodeFields(msg, false);
  }

  /// Drains any leading `@type` / `@<name>` / `@dataset` / `@proto`
  /// directives at document root. The AST-aware accessors land on
  /// [result] when running under `unmarshalFull`; otherwise the
  /// directives are simply consumed. Enforces the @dataset standalone
  /// constraint (draft §3.4.4).
  void _consumeDirectives() {
    bool sawType = false;
    bool hasDataset = false;
    Position? firstDatasetPos;
    while (true) {
      switch (current.kind) {
        case TokenKind.atType:
          if (hasDataset) {
            throw PxfError(current.pos,
                '@dataset directive cannot coexist with @type (draft §3.4.4)');
          }
          sawType = true;
          _advance();
          if (current.kind != TokenKind.ident) {
            throw PxfError(current.pos,
                'expected type name after @type, got ${current.kind.name}');
          }
          _advance();
          continue;
        case TokenKind.atDirective:
          final dir = _consumeDirective();
          result?.addDirective(dir);
          continue;
        case TokenKind.atDataset:
          if (sawType) {
            throw PxfError(current.pos,
                '@dataset directive cannot coexist with @type (draft §3.4.4)');
          }
          final ds = _consumeDatasetDirective();
          if (!hasDataset) {
            firstDatasetPos = ds.pos;
            hasDataset = true;
          }
          result?.addDataset(ds);
          continue;
        case TokenKind.atProto:
          final pd = _consumeProtoDirective();
          result?.addProto(pd);
          continue;
        default:
          break;
      }
      if (hasDataset && current.kind != TokenKind.eof) {
        throw PxfError(firstDatasetPos!,
            '@dataset directive cannot coexist with top-level field entries (draft §3.4.4)');
      }
      return;
    }
  }

  /// Mirrors Parser._parseDirective for the streaming decode path.
  Directive _consumeDirective() {
    final atPos = current.pos;
    final name = current.value;
    if (isFutureReservedDirective(name)) {
      throw PxfError(atPos,
          '@$name is a spec-reserved directive name with no v1 semantics (draft §3.4.6)');
    }
    final prefixes = <String>[];
    _advance();
    while (current.kind == TokenKind.ident) {
      final pk = _peekKind();
      if (pk == TokenKind.equals || pk == TokenKind.colon) break;
      prefixes.add(current.value);
      _advance();
    }
    List<int>? body;
    if (current.kind == TokenKind.lbrace) {
      final open = lex.pos - 1;
      final close = findMatchingBrace(lex.input, open);
      if (close < 0) {
        throw PxfError(atPos, 'directive @$name: unmatched "{"');
      }
      body =
          Uint8List.fromList(utf8.encode(lex.input.substring(open + 1, close)));
      lex.repositionTo(close + 1);
      _advance();
    }
    final typeField = prefixes.length == 1 ? prefixes[0] : '';
    return Directive(
      pos: atPos,
      name: name,
      prefixes: prefixes,
      type: typeField,
      body: body,
    );
  }

  /// Mirrors Parser._parseDatasetDirective for the streaming path.
  DatasetDirective _consumeDatasetDirective() {
    final atPos = current.pos;
    _advance();
    var type = '';
    if (current.kind == TokenKind.ident) {
      type = current.value;
      _advance();
    }
    if (current.kind != TokenKind.lparen) {
      throw PxfError(current.pos,
          'expected "(" to start @dataset column list, got ${current.kind.name}');
    }
    _advance();
    if (current.kind != TokenKind.ident) {
      throw PxfError(current.pos,
          '@dataset column list must contain at least one field name, got ${current.kind.name}');
    }
    final columns = <String>[];
    while (true) {
      if (current.kind != TokenKind.ident) {
        throw PxfError(current.pos,
            'expected column field name, got ${current.kind.name}');
      }
      final colName = current.value;
      if (colName.contains('.')) {
        throw PxfError(current.pos,
            '@dataset column "$colName": dotted column paths are not supported in v1 (draft §3.4.4)');
      }
      columns.add(colName);
      _advance();
      if (current.kind == TokenKind.comma) {
        _advance();
        continue;
      }
      if (current.kind == TokenKind.rparen) break;
      throw PxfError(current.pos,
          'expected "," or ")" in @dataset column list, got ${current.kind.name}');
    }
    _advance();

    final rows = <DatasetRow>[];
    while (current.kind == TokenKind.lparen) {
      final rowPos = current.pos;
      _advance();
      final cells = <Value?>[];
      cells.add(_consumeRowCell());
      while (current.kind == TokenKind.comma) {
        _advance();
        cells.add(_consumeRowCell());
      }
      if (current.kind != TokenKind.rparen) {
        throw PxfError(current.pos,
            'expected "," or ")" in @dataset row, got ${current.kind.name}');
      }
      _advance();
      if (cells.length != columns.length) {
        throw PxfError(rowPos,
            '@dataset row has ${cells.length} cells, expected ${columns.length} (column count)');
      }
      rows.add(DatasetRow(pos: rowPos, cells: cells));
    }
    return DatasetDirective(
      pos: atPos,
      type: type,
      columns: columns,
      rows: rows,
    );
  }

  /// Consumes one cell of a @dataset row. Returns null for an empty
  /// cell. Rejects list and block values per v1 cell-grammar.
  Value? _consumeRowCell() {
    switch (current.kind) {
      case TokenKind.comma:
      case TokenKind.rparen:
        return null;
      case TokenKind.lbracket:
        throw PxfError(current.pos,
            '@dataset cells cannot contain list values in v1 (draft §3.4.4)');
      case TokenKind.lbrace:
        throw PxfError(current.pos,
            '@dataset cells cannot contain block values in v1 (draft §3.4.4)');
      default:
        // Match Parser._parseValue subset used by row cells. Wrap as a
        // minimal Value; we only need pos + null detection downstream.
        final pos = current.pos;
        switch (current.kind) {
          case TokenKind.string:
            final v = StringVal(pos, current.value);
            _advance();
            return v;
          case TokenKind.int:
            final v = IntVal(pos, current.value);
            _advance();
            return v;
          case TokenKind.float:
            final v = FloatVal(pos, current.value);
            _advance();
            return v;
          case TokenKind.bool:
            final v = BoolVal(pos, current.value == 'true');
            _advance();
            return v;
          case TokenKind.bytes:
            final decoded = base64.decode(current.value);
            final v = BytesVal(pos, decoded);
            _advance();
            return v;
          case TokenKind.timestamp:
            final t = DateTime.parse(current.value);
            final v = TimestampVal(pos, t, current.value);
            _advance();
            return v;
          case TokenKind.duration:
            final d = parseGoDuration(current.value);
            final v = DurationVal(pos, d, current.value);
            _advance();
            return v;
          case TokenKind.null_:
            final v = NullVal(pos);
            _advance();
            return v;
          case TokenKind.ident:
            final v = IdentVal(pos, current.value);
            _advance();
            return v;
          default:
            throw PxfError(pos,
                'expected value, got ${current.kind.name} ("${current.value}")');
        }
    }
  }

  /// Mirrors Parser._parseProtoDirective for the streaming path.
  ProtoDirective _consumeProtoDirective() {
    final atPos = current.pos;
    _advance();
    switch (current.kind) {
      case TokenKind.lbrace:
        final body = _captureBraceBody('@proto (anonymous form)');
        return ProtoDirective(
            pos: atPos, shape: ProtoShape.anonymous, body: body);
      case TokenKind.ident:
        final typeName = current.value;
        _advance();
        if (current.kind != TokenKind.lbrace) {
          throw PxfError(current.pos,
              'expected "{" after @proto $typeName, got ${current.kind.name}');
        }
        final body = _captureBraceBody('@proto $typeName');
        return ProtoDirective(
          pos: atPos,
          shape: ProtoShape.named,
          typeName: typeName,
          body: body,
        );
      case TokenKind.string:
        final bytes = Uint8List.fromList(utf8.encode(current.value));
        _advance();
        return ProtoDirective(
            pos: atPos, shape: ProtoShape.source, body: bytes);
      case TokenKind.bytes:
        final raw = current.value;
        List<int> decoded;
        try {
          decoded = base64.decode(raw);
        } on FormatException {
          try {
            decoded = base64Url.decode(raw);
          } on FormatException {
            var padded = raw;
            final rem = padded.length % 4;
            if (rem != 0) padded = padded + ('=' * (4 - rem));
            try {
              decoded = base64Url.decode(padded);
            } on FormatException {
              throw PxfError(
                  current.pos, '@proto descriptor body: invalid base64');
            }
          }
        }
        _advance();
        return ProtoDirective(
            pos: atPos, shape: ProtoShape.descriptor, body: decoded);
      default:
        throw PxfError(current.pos,
            'expected "{", dotted identifier, triple-quoted string, or b"..." after @proto, got ${current.kind.name}');
    }
  }

  List<int> _captureBraceBody(String label) {
    final open = lex.pos - 1;
    final close = findMatchingBrace(lex.input, open);
    if (close < 0) {
      throw PxfError(current.pos, '$label: unmatched "{"');
    }
    final body =
        Uint8List.fromList(utf8.encode(lex.input.substring(open + 1, close)));
    lex.repositionTo(close + 1);
    _advance();
    return body;
  }

  /// One-token lookahead with full state restore.
  TokenKind _peekKind() {
    final state = lex.save();
    final savedCurrent = current;
    _advance();
    final peeked = current.kind;
    lex.restore(state);
    current = savedCurrent;
    return peeked;
  }

  void _decodeFields(GeneratedMessage msg, bool inBlock) {
    if (_depth >= _maxNestingDepth) {
      throw PxfError(current.pos,
          'message nesting exceeds MaxNestingDepth=$_maxNestingDepth');
    }
    _depth++;
    try {
      _decodeFieldsInner(msg, inBlock);
    } finally {
      _depth--;
    }
  }

  void _decodeFieldsInner(GeneratedMessage msg, bool inBlock) {
    var info = msg.info_;
    var setOneofs = <int, String>{}; // oneofIndex -> fieldName

    while (true) {
      if (inBlock && current.kind == TokenKind.rbrace) {
        _advance();
        return;
      }
      if (current.kind == TokenKind.eof) {
        if (inBlock) {
          throw PxfError(current.pos, 'expected "}", got EOF');
        }
        return;
      }

      var pos = current.pos;
      if (current.kind != TokenKind.ident &&
          current.kind != TokenKind.string &&
          current.kind != TokenKind.int) {
        throw PxfError(pos,
            'expected identifier, string, or integer, got ${current.kind.name} ("${current.value}")');
      }
      var key = current.value;
      _advance();

      switch (current.kind) {
        case TokenKind.equals:
          _advance();
          var fi = info.byName[key];
          if (fi == null) {
            if (discardUnknown) {
              _skipValue();
              continue;
            }
            throw PxfError(
                pos, 'unknown field "$key" in ${info.qualifiedMessageName}');
          }
          _checkOneof(info, fi, setOneofs, pos);

          if (current.kind == TokenKind.null_) {
            if (result != null) {
              var path = pathPrefix + fi.name;
              result!.markNull(path);
              if (nullMaskFi != null) {
                _addToNullMask(rootMsg!, nullMaskFi!, path);
              }
            }
            _advance();
            continue;
          }

          if (result != null) {
            result!.markPresent(pathPrefix + fi.name);
          }
          _decodeFieldValue(msg, fi);
          break;

        case TokenKind.lbrace:
          _advance();
          var fi = info.byName[key];
          if (fi == null) {
            if (discardUnknown) {
              _skipBraced();
              continue;
            }
            throw PxfError(
                pos, 'unknown field "$key" in ${info.qualifiedMessageName}');
          }

          // Any sugar handling: name { @type = "..." ... }
          if (isAny(fi.subBuilder!().info_) &&
              current.kind == TokenKind.atType) {
            _checkOneof(info, fi, setOneofs, pos);
            if (result != null) {
              result!.markPresent(pathPrefix + fi.name);
            }
            _decodeAnyInner(msg, fi);
            continue;
          }

          if (fi.type != PbFieldType.OM && fi.type != PbFieldType.PM) {
            throw PxfError(pos,
                'field "$key" is not a message type, cannot use block syntax');
          }
          _checkOneof(info, fi, setOneofs, pos);

          if (result != null) {
            result!.markPresent(pathPrefix + fi.name);
          }

          if (fi.isRepeated) {
            var list = msg.getField(fi.tagNumber) as List;
            var sub = fi.subBuilder!();
            var oldPrefix = pathPrefix;
            pathPrefix = '$oldPrefix${fi.name}.';
            _decodeFields(sub, true);
            pathPrefix = oldPrefix;
            list.add(sub);
          } else {
            GeneratedMessage sub;
            if (!msg.hasField(fi.tagNumber)) {
              sub = fi.subBuilder!();
              msg.setField(fi.tagNumber, sub);
            } else {
              sub = msg.getField(fi.tagNumber) as GeneratedMessage;
            }
            var oldPrefix = pathPrefix;
            pathPrefix = '$oldPrefix${fi.name}.';
            _decodeFields(sub, true);
            pathPrefix = oldPrefix;
          }
          break;

        default:
          throw PxfError(current.pos,
              'expected "=" or "{" after "$key", got ${current.kind.name}');
      }
    }
  }

  void _checkOneof(BuilderInfo info, FieldInfo fi, Map<int, String> setOneofs,
      Position pos) {
    var oneofIndex = info.oneofs[fi.tagNumber];
    if (oneofIndex != null) {
      if (setOneofs.containsKey(oneofIndex)) {
        throw PxfError(pos,
            'field "${fi.name}" conflicts with already-set field "${setOneofs[oneofIndex]}" in the same oneof');
      }
      setOneofs[oneofIndex] = fi.name;
    }
  }

  void _decodeFieldValue(GeneratedMessage msg, FieldInfo fi) {
    if (fi.isRepeated) {
      if (current.kind == TokenKind.lbracket) {
        _decodeList(msg, fi);
      } else {
        throw PxfError(
            current.pos, 'expected "[" for repeated field "${fi.name}"');
      }
    } else if (fi.isMapField) {
      if (current.kind == TokenKind.lbrace) {
        _decodeMap(msg, fi);
      } else {
        throw PxfError(current.pos, 'expected "{" for map field "${fi.name}"');
      }
    } else if (fi.type == PbFieldType.OM) {
      _decodeMessageValue(msg, fi);
    } else {
      var val = _consumeScalar(fi);
      msg.setField(fi.tagNumber, val);
    }
  }

  void _decodeMessageValue(GeneratedMessage msg, FieldInfo fi) {
    var subBuilder = fi.subBuilder!;
    var subInfo = subBuilder().info_;

    if (isTimestamp(subInfo) && current.kind == TokenKind.timestamp) {
      var t = DateTime.parse(current.value);
      var sub = subBuilder();
      setTimestampFields(sub, t);
      msg.setField(fi.tagNumber, sub);
      _advance();
      return;
    }
    if (isDuration(subInfo) && current.kind == TokenKind.duration) {
      var dur = parseGoDuration(current.value);
      var sub = subBuilder();
      setDurationFields(sub, dur);
      msg.setField(fi.tagNumber, sub);
      _advance();
      return;
    }
    if (isWrapperType(subInfo) && current.kind != TokenKind.lbrace) {
      var valueFi = subInfo.fieldInfo[1]!;
      var val = _consumeScalar(valueFi);
      var sub = subBuilder();
      sub.setField(1, val);
      msg.setField(fi.tagNumber, sub);
      return;
    }

    if (isBigInt(subInfo) && current.kind == TokenKind.int) {
      var sub = subBuilder();
      setBigIntFields(sub, current.value);
      msg.setField(fi.tagNumber, sub);
      _advance();
      return;
    }
    if (isDecimal(subInfo) &&
        (current.kind == TokenKind.float || current.kind == TokenKind.int)) {
      var sub = subBuilder();
      setDecimalFields(sub, current.value);
      msg.setField(fi.tagNumber, sub);
      _advance();
      return;
    }

    // Any sugar: name = { @type = "..." ... }
    if (isAny(subInfo) && current.kind == TokenKind.lbrace) {
      var saved = lex.pos;
      var savedLine = lex.line;
      var savedCol = lex.col;
      var savedTok = current;

      _advance(); // consume {
      if (current.kind == TokenKind.atType) {
        _decodeAnyInner(msg, fi);
        return;
      }

      // Rollback if not Any sugar
      lex.pos = saved;
      lex.line = savedLine;
      lex.col = savedCol;
      current = savedTok;
    }

    if (current.kind != TokenKind.lbrace) {
      throw PxfError(
          current.pos, 'expected "{" for message field "${fi.name}"');
    }
    _advance();
    GeneratedMessage sub;
    if (!msg.hasField(fi.tagNumber)) {
      sub = subBuilder();
      msg.setField(fi.tagNumber, sub);
    } else {
      sub = msg.getField(fi.tagNumber) as GeneratedMessage;
    }
    var oldPrefix = pathPrefix;
    pathPrefix = '$oldPrefix${fi.name}.';
    _decodeFields(sub, true);
    pathPrefix = oldPrefix;
  }

  void _decodeAnyInner(GeneratedMessage msg, FieldInfo fi) {
    if (current.kind != TokenKind.atType) {
      _advance(); // consume {
    }
    _advance(); // consume @type

    if (current.kind != TokenKind.equals) {
      throw PxfError(current.pos, 'expected "=" after @type');
    }
    _advance();

    if (current.kind != TokenKind.string && current.kind != TokenKind.ident) {
      throw PxfError(
          current.pos, 'expected type URL string or identifier after @type');
    }
    var typeUrl = current.value;
    _advance();

    var typeName = typeUrl;
    if (typeName.contains('/')) {
      typeName = typeName.substring(typeName.lastIndexOf('/') + 1);
    }
    var innerInfo = typeRegistry.lookup(typeName);
    if (innerInfo == null) {
      throw PxfError(current.pos, 'unknown type "$typeUrl" in TypeRegistry');
    }

    var innerMsg = innerInfo.createEmptyInstance!();
    var oldPrefix = pathPrefix;
    pathPrefix = '$oldPrefix${fi.name}.';
    _decodeFields(innerMsg, true);
    pathPrefix = oldPrefix;

    var anyMsg = fi.subBuilder!();
    anyMsg.setField(1, typeUrl);
    anyMsg.setField(2, innerMsg.writeToBuffer());
    msg.setField(fi.tagNumber, anyMsg);
  }

  void _decodeList(GeneratedMessage msg, FieldInfo fi) {
    _advance(); // consume [
    var list = msg.getField(fi.tagNumber) as List;
    while (
        current.kind != TokenKind.rbracket && current.kind != TokenKind.eof) {
      if (current.kind == TokenKind.null_) {
        throw PxfError(
            current.pos, 'null is not allowed in repeated field "${fi.name}"');
      }
      if (fi.type == PbFieldType.PM || fi.type == PbFieldType.OM) {
        var sub = fi.subBuilder!();
        if (current.kind == TokenKind.lbrace) {
          _advance();
          _decodeFields(sub, true);
          list.add(sub);
        } else {
          var subInfo = sub.info_;
          if (isTimestamp(subInfo) && current.kind == TokenKind.timestamp) {
            setTimestampFields(sub, DateTime.parse(current.value));
            list.add(sub);
            _advance();
          } else if (isDuration(subInfo) &&
              current.kind == TokenKind.duration) {
            setDurationFields(sub, parseGoDuration(current.value));
            list.add(sub);
            _advance();
          } else if (isWrapperType(subInfo)) {
            var valueFi = subInfo.fieldInfo[1]!;
            var val = _consumeScalar(valueFi);
            sub.setField(1, val);
            list.add(sub);
          } else {
            throw PxfError(
                current.pos, 'expected "{" for message element in list');
          }
        }
      } else if (fi.type == PbFieldType.PE || fi.type == PbFieldType.OE) {
        var val = _consumeEnum(fi);
        list.add(val);
      } else {
        var val = _consumeScalar(fi);
        list.add(val);
      }

      if (current.kind == TokenKind.comma) {
        _advance();
      }
    }
    if (current.kind != TokenKind.rbracket) {
      throw PxfError(current.pos, 'expected "]", got ${current.kind.name}');
    }
    _advance();
  }

  void _decodeMap(GeneratedMessage msg, FieldInfo fi) {
    _advance(); // consume {
    var map = msg.getField(fi.tagNumber) as Map;

    while (current.kind != TokenKind.rbrace && current.kind != TokenKind.eof) {
      var pos = current.pos;
      if (current.kind != TokenKind.ident &&
          current.kind != TokenKind.string &&
          current.kind != TokenKind.int) {
        throw PxfError(pos, 'expected map key, got ${current.kind.name}');
      }
      var keyStr = current.value;
      _advance();

      if (current.kind == TokenKind.colon) {
        _advance();
      } else if (current.kind == TokenKind.equals) {
        throw PxfError(
            current.pos, 'unexpected "=" in map, use ":" for map entries');
      } else {
        throw PxfError(current.pos,
            'expected ":" after map key, got ${current.kind.name}');
      }

      Object key = keyStr;

      if (current.kind == TokenKind.null_) {
        throw PxfError(current.pos,
            'null is not allowed as map value in field "${fi.name}"');
      }

      _skipValue();

      if (current.kind == TokenKind.comma) {
        _advance();
      }
    }
    if (current.kind != TokenKind.rbrace) {
      throw PxfError(current.pos, 'expected "}", got ${current.kind.name}');
    }
    _advance();
  }

  Object _consumeScalar(FieldInfo fi) {
    var pos = current.pos;
    var t = fi.type;
    if (t == PbFieldType.OS || t == PbFieldType.PS || t == PbFieldType.QS) {
      if (current.kind != TokenKind.string) {
        throw PxfError(pos, 'expected string for field "${fi.name}"');
      }
      var v = current.value;
      _advance();
      return v;
    }
    if (t == PbFieldType.OB || t == PbFieldType.PB || t == PbFieldType.QB) {
      if (current.kind != TokenKind.bool) {
        throw PxfError(pos, 'expected bool for field "${fi.name}"');
      }
      var v = current.value == 'true';
      _advance();
      return v;
    }
    if (t == PbFieldType.O3 ||
        t == PbFieldType.P3 ||
        t == PbFieldType.Q3 ||
        t == PbFieldType.OS3 ||
        t == PbFieldType.PS3 ||
        t == PbFieldType.QS3 ||
        t == PbFieldType.OSF3 ||
        t == PbFieldType.PSF3 ||
        t == PbFieldType.QSF3) {
      if (current.kind != TokenKind.int) {
        throw PxfError(pos, 'expected integer for field "${fi.name}"');
      }
      var v = int.parse(current.value);
      _advance();
      return v;
    }
    if (t == PbFieldType.O6 ||
        t == PbFieldType.P6 ||
        t == PbFieldType.Q6 ||
        t == PbFieldType.OS6 ||
        t == PbFieldType.PS6 ||
        t == PbFieldType.QS6 ||
        t == PbFieldType.OSF6 ||
        t == PbFieldType.PSF6 ||
        t == PbFieldType.QSF6) {
      if (current.kind != TokenKind.int) {
        throw PxfError(pos, 'expected integer for field "${fi.name}"');
      }
      var v = Int64.parseInt(current.value);
      _advance();
      return v;
    }
    if (t == PbFieldType.OU3 ||
        t == PbFieldType.PU3 ||
        t == PbFieldType.QU3 ||
        t == PbFieldType.OF3 ||
        t == PbFieldType.PF3 ||
        t == PbFieldType.QF3) {
      if (current.kind != TokenKind.int) {
        throw PxfError(pos, 'expected integer for field "${fi.name}"');
      }
      var v = int.parse(current.value);
      _advance();
      return v;
    }
    if (t == PbFieldType.OU6 ||
        t == PbFieldType.PU6 ||
        t == PbFieldType.QU6 ||
        t == PbFieldType.OF6 ||
        t == PbFieldType.PF6 ||
        t == PbFieldType.QF6) {
      if (current.kind != TokenKind.int) {
        throw PxfError(pos, 'expected integer for field "${fi.name}"');
      }
      var v = Int64.parseInt(current.value);
      _advance();
      return v;
    }

    if (t == PbFieldType.OF || t == PbFieldType.PF || t == PbFieldType.QF) {
      if (current.kind != TokenKind.float && current.kind != TokenKind.int) {
        throw PxfError(pos, 'expected number for field "${fi.name}"');
      }
      var v = double.parse(current.value);
      _advance();
      return v;
    }
    if (t == PbFieldType.OD || t == PbFieldType.PD || t == PbFieldType.QD) {
      if (current.kind != TokenKind.float && current.kind != TokenKind.int) {
        throw PxfError(pos, 'expected number for field "${fi.name}"');
      }
      var v = double.parse(current.value);
      _advance();
      return v;
    }
    if (t == PbFieldType.OY || t == PbFieldType.PY || t == PbFieldType.QY) {
      if (current.kind != TokenKind.bytes) {
        throw PxfError(pos, 'expected bytes for field "${fi.name}"');
      }
      var v = base64.decode(current.value);
      _advance();
      return v;
    }
    if (t == PbFieldType.OE || t == PbFieldType.PE || t == PbFieldType.QE) {
      return _consumeEnum(fi);
    }
    throw PxfError(pos, 'unsupported type ${fi.type} for field "${fi.name}"');
  }

  int _consumeEnum(FieldInfo fi) {
    var pos = current.pos;
    if (current.kind == TokenKind.ident) {
      throw PxfError(
          pos, 'enum lookup by name not yet implemented in Dart port');
    } else if (current.kind == TokenKind.int) {
      var v = int.parse(current.value);
      _advance();
      return v;
    } else {
      throw PxfError(
          pos, 'expected enum name or number for field "${fi.name}"');
    }
  }

  void _skipValue() {
    switch (current.kind) {
      case TokenKind.lbrace:
        _advance();
        _skipBraced();
        break;
      case TokenKind.lbracket:
        _advance();
        _skipBracketed();
        break;
      default:
        _advance();
    }
  }

  void _skipBraced() {
    int depth = 1;
    while (depth > 0 && current.kind != TokenKind.eof) {
      if (current.kind == TokenKind.lbrace) {
        depth++;
      } else if (current.kind == TokenKind.rbrace) {
        depth--;
      }
      _advance();
    }
  }

  void _skipBracketed() {
    int depth = 1;
    while (depth > 0 && current.kind != TokenKind.eof) {
      if (current.kind == TokenKind.lbracket) {
        depth++;
      } else if (current.kind == TokenKind.rbracket) {
        depth--;
      }
      _advance();
    }
  }

  void _addToNullMask(
      GeneratedMessage rootMsg, FieldInfo nullMaskFi, String path) {
    var fm = rootMsg.getField(nullMaskFi.tagNumber) as GeneratedMessage;
    var paths = fm.getField(1) as List<String>;
    paths.add(path);
  }
}

/// Unmarshals PXF text from [input] into the provided [msg].
///
/// Options can be provided via [options] to customize the unmarshaling process.
void unmarshal(String input, GeneratedMessage msg,
    {UnmarshalOptions? options}) {
  var d = DirectDecoder(
    input,
    typeRegistry: options?.typeRegistry ?? const TypeRegistry.empty(),
    discardUnknown: options?.discardUnknown ?? false,
  );
  d.decodeDocument(msg);
}
