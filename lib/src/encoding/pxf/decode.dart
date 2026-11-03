// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'dart:convert';
import 'dart:typed_data';
import '../../limits.dart';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';
import 'annotations.dart';
import 'ast.dart';
import 'bigfloat.dart';
import 'brace_scan.dart';
import 'dataset.dart' show columnPathError;
import 'errors.dart';
import 'format.dart' show quotePxfString;
import 'keyed.dart';
import 'lexer.dart';
import 'options.dart';
import 'parser.dart' show Parser;
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

/// A packed repeated type as the unpacked one: an element reads the same.
const Map<int, int> _packedAsRepeated = {
  PbFieldType.KB: PbFieldType.PB,
  PbFieldType.KE: PbFieldType.PE,
  PbFieldType.KF: PbFieldType.PF,
  PbFieldType.KD: PbFieldType.PD,
  PbFieldType.K3: PbFieldType.P3,
  PbFieldType.KU3: PbFieldType.PU3,
  PbFieldType.KS3: PbFieldType.PS3,
  PbFieldType.KF3: PbFieldType.PF3,
  PbFieldType.KSF3: PbFieldType.PSF3,
  PbFieldType.K6: PbFieldType.P6,
  PbFieldType.KU6: PbFieldType.PU6,
  PbFieldType.KS6: PbFieldType.PS6,
  PbFieldType.KF6: PbFieldType.PF6,
  PbFieldType.KSF6: PbFieldType.PSF6,
};

class DirectDecoder {
  final Lexer lex;
  late Token current;
  final TypeRegistry typeRegistry;
  final bool discardUnknown;

  /// The per-call limits.
  final DecodeLimits limits;

  /// The schema's `(pxf.key)` options. Without them no field is keyed.
  final PxfAnnotations? annotations;
  Result? result;
  GeneratedMessage? rootMsg;
  FieldInfo? nullMaskFi;
  String pathPrefix = '';
  int _depth = 0;

  /// Applies to exactly the next message body: the immediate entries of
  /// one element of a keyed repeated field.
  KeyedElemState? _keyedElem;

  /// How many list elements or map values enclose the current entry. A
  /// `_null` mask path names fields, not those, so a null in here stays out
  /// of it.
  int _elemDepth = 0;

  /// The keys each map field has bound in this decode, by message. It records
  /// what the document bound rather than asking the map, which may hold
  /// entries the caller set before decoding into it. Keyed by identity: a
  /// message's own hash follows its contents.
  final Map<GeneratedMessage, Map<int, Set<Object>>> _mapKeys = Map.identity();

  DirectDecoder(
    String input, {
    this.typeRegistry = const TypeRegistry.empty(),
    this.discardUnknown = false,
    this.annotations,
    this.result,
    this.rootMsg,
    this.limits = const DecodeLimits(),
  }) : lex = Lexer(input, maxBytesLiteralLength: limits.maxBytesLiteralLength) {
    final tooBig =
        limits.checkSize(utf8LengthUpTo(input, limits.maxMessageSize));
    if (tooBig != null) throw PxfError(Position(1, 1), tooBig);
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
    final positions = <Position>[];
    while (true) {
      if (current.kind != TokenKind.ident) {
        throw PxfError(current.pos,
            'expected column field name, got ${current.kind.name}');
      }
      columns.add(current.value);
      positions.add(current.pos);
      _advance();
      if (current.kind == TokenKind.comma) {
        _advance();
        continue;
      }
      if (current.kind == TokenKind.rparen) break;
      throw PxfError(current.pos,
          'expected "," or ")" in @dataset column list, got ${current.kind.name}');
    }
    final headerError = columnPathError(columns);
    if (headerError != null) {
      throw PxfError(positions[headerError.$1], headerError.$2);
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

  /// Consumes one cell of a @dataset row, null for an empty one. The value
  /// goes through the AST parser on this decoder's own lexer, so a cell
  /// parses exactly as it does under `parse`, lists and blocks included.
  Value? _consumeRowCell() {
    if (current.kind == TokenKind.comma || current.kind == TokenKind.rparen) {
      return null;
    }
    final parser = Parser.resume(lex, current, limits);
    final value = parser.parseCell();
    current = parser.current;
    // The parser passes over comments and newlines as this decoder does, but
    // leaves a lexer rejection for its caller.
    if (current.kind == TokenKind.illegal) {
      throw PxfError(current.pos, current.value);
    }
    return value;
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

  /// Counts one descent, HARDENING.md § Recursion: every `{` or `[` is one,
  /// and a document exactly [_maxNestingDepth] deep is accepted. The caller
  /// undoes it with `_depth--` once the block or list is read.
  void _enterNesting() {
    if (_depth >= _maxNestingDepth) {
      throw PxfError(current.pos,
          'message nesting exceeds MaxNestingDepth=$_maxNestingDepth');
    }
    _depth++;
  }

  void _decodeFields(GeneratedMessage msg, bool inBlock) {
    // The root message has no `{` of its own: it is depth 0.
    if (!inBlock) {
      _decodeFieldsInner(msg, false);
      return;
    }
    _enterNesting();
    try {
      _decodeFieldsInner(msg, true);
    } finally {
      _depth--;
    }
  }

  void _decodeFieldsInner(GeneratedMessage msg, bool inBlock) {
    var info = msg.info_;
    var setOneofs = <int, String>{}; // oneofIndex -> fieldName
    // A singular field is bound at most once in one body (draft -01 § Entries
    // and Keys, protowire#347); each body has a set of its own.
    final bound = <int>{};
    final keyedElem = _keyedElem;
    _keyedElem = null; // nested bodies must not inherit the key checks

    // A block bound to Any may open with a type entry, wherever a body is
    // written: a singular field, a list element, a map value.
    if (inBlock && current.kind == TokenKind.atType && isAny(info)) {
      _decodeAnyBody(msg);
      return;
    }

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
      if (current.kind == TokenKind.atType) {
        throw PxfError(pos, typeEntryMisplaced);
      }
      if (current.kind != TokenKind.ident &&
          current.kind != TokenKind.string &&
          current.kind != TokenKind.int &&
          current.kind != TokenKind.bool) {
        throw PxfError(pos,
            'expected identifier, string, integer, or bool, got ${current.kind.name} ("${current.value}")');
      }
      var key = current.value;
      final keyKind = current.kind;
      final keyQuoted = keyKind == TokenKind.string;
      _advance();

      switch (current.kind) {
        case TokenKind.equals:
          if (keyKind == TokenKind.int || keyKind == TokenKind.bool) {
            throw nonNameAssignError(pos, keyKind, key);
          }
          _advance();
          // The grammar takes a string here everywhere. In message context
          // it never names a field; keyed blocks have their own loop.
          if (keyQuoted) throw quotedNameUnkeyedError(pos, key);
          var fi = fieldNamed(info, key);
          if (fi == null) {
            if (discardUnknown) {
              _skipValue();
              continue;
            }
            throw PxfError(
                pos, 'unknown field "$key" in ${info.qualifiedMessageName}');
          }
          keyedElem?.checkBinding(info, fi,
              isNull: current.kind == TokenKind.null_, pos: pos);
          _checkOneof(info, fi, setOneofs, pos);
          _bind(bound, fi, pos);

          if (current.kind == TokenKind.null_) {
            _checkNullable(info, fi);
            if (result != null) {
              var path = pathPrefix + fi.protoName;
              result!.markNull(path);
              if (nullMaskFi != null && _elemDepth == 0) {
                _addToNullMask(rootMsg!, nullMaskFi!, path);
              }
            }
            _advance();
            continue;
          }

          if (keyedElem != null &&
              fi.protoName == keyedElem.keyName &&
              current.kind == TokenKind.string) {
            keyedElem.checkExplicitKey(current.value, current.pos);
          }

          if (result != null) {
            result!.markPresent(pathPrefix + fi.protoName);
          }
          _decodeFieldValue(msg, fi);
          break;

        case TokenKind.lbrace:
          if (keyKind == TokenKind.int || keyKind == TokenKind.bool) {
            throw nonNameBlockError(pos, keyKind, key);
          }
          if (keyQuoted) throw quotedNameUnkeyedError(pos, key);
          _advance();
          var fi = fieldNamed(info, key);
          if (fi == null) {
            if (discardUnknown) {
              _skipBraced();
              continue;
            }
            throw PxfError(
                pos, 'unknown field "$key" in ${info.qualifiedMessageName}');
          }

          if (fi.isMapField) {
            throw PxfError(pos,
                'map field "$key" must use assignment syntax: $key = { ... }');
          }
          if (!PbFieldType.isGroupOrMessage(fi.type)) {
            throw PxfError(pos,
                'field "$key" is not a message type, cannot use block syntax');
          }

          if (fi.isRepeated) {
            final keyFi = keyFieldOf(annotations, info, fi);
            if (keyFi == null) {
              // The block spells the keyed form on a field with no key: the
              // quoted name is the more specific violation.
              if (current.kind == TokenKind.string) {
                throw quotedNameUnkeyedError(current.pos, current.value);
              }
              throw PxfError(pos,
                  'repeated field "$key" must use list syntax: $key = [...]');
            }
            if (result != null) {
              result!.markPresent(pathPrefix + fi.protoName);
            }
            _decodeKeyedBlockBody(msg, fi, keyFi);
            continue;
          }

          keyedElem?.checkBinding(info, fi, isNull: false, pos: pos);
          _checkOneof(info, fi, setOneofs, pos);
          _bind(bound, fi, pos);

          if (result != null) {
            result!.markPresent(pathPrefix + fi.protoName);
          }

          GeneratedMessage sub;
          if (!msg.hasField(fi.tagNumber)) {
            sub = fi.subBuilder!();
            msg.setField(fi.tagNumber, sub);
          } else {
            sub = msg.getField(fi.tagNumber) as GeneratedMessage;
          }
          var oldPrefix = pathPrefix;
          pathPrefix = '$oldPrefix${fi.protoName}.';
          _decodeFields(sub, true);
          pathPrefix = oldPrefix;
          break;

        default:
          throw PxfError(current.pos,
              'expected "=" or "{" after "$key", got ${current.kind.name}');
      }
    }
  }

  /// Rejects a `null` bound to [fi] unless the field has explicit presence
  /// (draft -01 § Booleans, Null, and Identifier Values). Generated classes
  /// write a proto3 `int32` and `optional int32` identically, so only the
  /// descriptor set can tell a plain scalar: with no [annotations], a null on
  /// one is accepted and recorded.
  void _checkNullable(BuilderInfo info, FieldInfo fi) {
    final name = fi.protoName;
    if (fi.isMapField) {
      throw PxfError(current.pos, 'null is not allowed on map field "$name"');
    }
    if (fi.isRepeated) {
      throw PxfError(
          current.pos, 'null is not allowed on repeated field "$name"');
    }
    if (fi.isRequired) {
      throw PxfError(current.pos,
          'null is not allowed on required field "$name": it must be set');
    }
    if (fi.isGroupOrMessage || info.oneofs.containsKey(fi.tagNumber)) return;
    if (annotations?.hasImplicitPresence(info.qualifiedMessageName, name) ??
        false) {
      throw PxfError(current.pos,
          'null is not allowed on scalar field "$name": declare it optional, or as a wrapper type, to make it nullable');
    }
  }

  /// Refuses another element once [count] are held, before it is allocated.
  void _checkRepeatedCount(int count, FieldInfo fi) {
    if (count >= limits.maxRepeatedCount) {
      throw PxfError(current.pos,
          'field "${fi.protoName}" exceeds MaxRepeatedCount=${limits.maxRepeatedCount}');
    }
  }

  /// Records [fi] as bound in this body, or rejects a second binding. A
  /// repeated field concatenates and a map merges, so neither counts.
  void _bind(Set<int> bound, FieldInfo fi, Position pos) {
    if (fi.isRepeated || fi.isMapField) return;
    if (!bound.add(fi.tagNumber)) {
      throw PxfError(pos, 'field "${fi.protoName}" is already set');
    }
  }

  void _checkOneof(BuilderInfo info, FieldInfo fi, Map<int, String> setOneofs,
      Position pos) {
    var oneofIndex = info.oneofs[fi.tagNumber];
    if (oneofIndex != null) {
      if (setOneofs.containsKey(oneofIndex)) {
        throw PxfError(pos,
            'field "${fi.protoName}" conflicts with already-set field "${setOneofs[oneofIndex]}" in the same oneof');
      }
      setOneofs[oneofIndex] = fi.protoName;
    }
  }

  void _decodeFieldValue(GeneratedMessage msg, FieldInfo fi) {
    if (fi.isRepeated) {
      final keyFi = keyFieldOf(annotations, msg.info_, fi);
      if (current.kind == TokenKind.lbracket) {
        _decodeList(msg, fi, keyFi);
      } else if (keyFi != null && current.kind == TokenKind.lbrace) {
        // `name = { ... }`: a block-tail abbreviates exactly this.
        _advance();
        _decodeKeyedBlockBody(msg, fi, keyFi);
      } else {
        throw PxfError(
            current.pos, 'expected "[" for repeated field "${fi.protoName}"');
      }
    } else if (fi.isMapField) {
      if (current.kind == TokenKind.lbrace) {
        _decodeMap(msg, fi);
      } else {
        throw PxfError(
            current.pos, 'expected "{" for map field "${fi.protoName}"');
      }
    } else if (fi.type == PbFieldType.OM) {
      _decodeMessageValue(msg, fi);
    } else {
      var val = _consumeScalar(fi);
      // Only a descriptor set can say this field has implicit presence, and
      // only then can its zero go: on an `optional` one it means "set".
      final info = msg.info_;
      if (isZeroValue(val) &&
          !info.oneofs.containsKey(fi.tagNumber) &&
          (annotations?.hasImplicitPresence(
                  info.qualifiedMessageName, fi.protoName) ??
              false)) {
        msg.clearField(fi.tagNumber);
      } else {
        msg.setField(fi.tagNumber, val);
      }
    }
  }

  /// A precision suffix is grammatical on any number, but only a
  /// pxf.BigFloat takes one, and the schema layer rejects the rest.
  void _rejectPrecision(FieldInfo fi) {
    if (current.prec == null) return;
    throw PxfError(current.pos,
        'precision suffix p${current.prec} on field "${fi.protoName}": only a pxf.BigFloat takes one');
  }

  /// Reads a number into the pxf.BigFloat [sub]. False when the token is not
  /// one, so the caller goes on to the block form.
  bool _consumeBigFloat(GeneratedMessage sub) {
    if (current.kind != TokenKind.int && current.kind != TokenKind.float) {
      return false;
    }
    try {
      setBigFloatLiteral(sub, current.value, current.prec);
    } on FormatException catch (e) {
      throw PxfError(current.pos, e.message);
    }
    _advance();
    return true;
  }

  void _decodeMessageValue(GeneratedMessage msg, FieldInfo fi) {
    var subBuilder = fi.subBuilder!;
    var subInfo = subBuilder().info_;
    if (isBigFloat(subInfo)) {
      final sub = subBuilder();
      if (_consumeBigFloat(sub)) {
        msg.setField(fi.tagNumber, sub);
        return;
      }
    } else {
      _rejectPrecision(fi);
    }

    if (isTimestamp(subInfo) && current.kind == TokenKind.timestamp) {
      var sub = subBuilder();
      setTimestampLiteral(sub, current.value);
      msg.setField(fi.tagNumber, sub);
      _advance();
      return;
    }
    if (isDuration(subInfo) && current.kind == TokenKind.duration) {
      var sub = subBuilder();
      setDurationLiteral(sub, current.value);
      msg.setField(fi.tagNumber, sub);
      _advance();
      return;
    }
    if (isWrapperType(subInfo) && current.kind != TokenKind.lbrace) {
      var valueFi = subInfo.fieldInfo[1]!;
      var val = _consumeScalar(valueFi);
      var sub = subBuilder();
      setImplicit(sub, 1, val);
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

    if (current.kind != TokenKind.lbrace) {
      throw PxfError(
          current.pos, 'expected "{" for message field "${fi.protoName}"');
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
    pathPrefix = '$oldPrefix${fi.protoName}.';
    _decodeFields(sub, true);
    pathPrefix = oldPrefix;
  }

  /// A `google.protobuf.Any` block opening with a type entry, its `{`
  /// consumed: the rest of the block is a body of the type the URL names,
  /// packed into [anyMsg], and the URL is stored as written (draft -01 "Any
  /// Blocks"). The body's fields are recorded under the Any's own path.
  void _decodeAnyBody(GeneratedMessage anyMsg) {
    _advance(); // consume @type
    if (current.kind != TokenKind.equals) {
      throw PxfError(current.pos, 'expected "=" after @type');
    }
    _advance();
    if (current.kind != TokenKind.string) {
      throw PxfError(current.pos,
          'expected a string type URL after @type =, got ${current.kind.name}');
    }
    final typeUrl = current.value;
    final urlPos = current.pos;
    _advance();

    final innerInfo = typeRegistry.lookup(anyTypeName(typeUrl));
    if (innerInfo == null) {
      throw PxfError(urlPos, 'cannot resolve Any type "$typeUrl"');
    }

    final innerMsg = innerInfo.createEmptyInstance!();
    // The body shares the Any's braces, already counted as one descent.
    _depth--;
    try {
      _decodeFields(innerMsg, true);
    } finally {
      _depth++;
    }

    // The body is about to be packed to bytes, out of reach of the pass over
    // the root, so it takes the pass here, under the Any's own path.
    final ann = annotations;
    if (ann != null && result != null) {
      _postDecode(innerMsg, result!, ann, null, pathPrefix);
    }

    anyMsg.setField(1, typeUrl);
    anyMsg.setField(2, innerMsg.writeToBuffer());
  }

  /// [keyFi] is the key field when [fi] is keyed; this is then the anonymous
  /// form, whose elements must decode as the keyed form's do.
  void _decodeList(GeneratedMessage msg, FieldInfo fi, FieldInfo? keyFi) {
    _advance(); // consume [
    _enterNesting();
    try {
      _decodeListBody(msg, fi, keyFi);
    } finally {
      _depth--;
    }
  }

  void _decodeListBody(GeneratedMessage msg, FieldInfo fi, FieldInfo? keyFi) {
    var list = msg.getField(fi.tagNumber) as List;
    while (
        current.kind != TokenKind.rbracket && current.kind != TokenKind.eof) {
      if (current.kind == TokenKind.null_) {
        throw PxfError(current.pos,
            'null is not allowed in repeated field "${fi.protoName}"');
      }
      _checkRepeatedCount(list.length, fi);
      if (fi.isGroupOrMessage) {
        var sub = fi.subBuilder!();
        if (current.kind == TokenKind.lbrace) {
          _advance();
          if (keyFi != null) {
            _decodeKeyedElement(sub, fi, list.length,
                KeyedElemState(field: fi.protoName, keyName: keyFi.protoName));
          } else {
            _decodeElementFields(
                sub, '$pathPrefix${fi.protoName}[${list.length}].');
          }
          list.add(sub);
        } else {
          var subInfo = sub.info_;
          if (isBigFloat(subInfo) && _consumeBigFloat(sub)) {
            list.add(sub);
          } else if (isTimestamp(subInfo) &&
              current.kind == TokenKind.timestamp) {
            setTimestampLiteral(sub, current.value);
            list.add(sub);
            _advance();
          } else if (isDuration(subInfo) &&
              current.kind == TokenKind.duration) {
            setDurationLiteral(sub, current.value);
            list.add(sub);
            _advance();
          } else if (isWrapperType(subInfo)) {
            var valueFi = subInfo.fieldInfo[1]!;
            var val = _consumeScalar(valueFi);
            setImplicit(sub, 1, val);
            list.add(sub);
          } else {
            throw PxfError(
                current.pos, 'expected "{" for message element in list');
          }
        }
      } else if (fi.isEnum) {
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

  /// The block form of a keyed repeated field: named entries, `name { ... }`
  /// or `name = { ... }`, where each name populates the element's key field
  /// and entry order is list order. The opening `{` has been consumed; the
  /// closing `}` is consumed here. Mirrors the reference's
  /// `decodeKeyedBlockBody`.
  void _decodeKeyedBlockBody(
      GeneratedMessage msg, FieldInfo fi, FieldInfo keyFi) {
    if (_depth >= _maxNestingDepth) {
      throw PxfError(current.pos,
          'message nesting exceeds MaxNestingDepth=$_maxNestingDepth');
    }
    _depth++;
    try {
      var list = msg.getField(fi.tagNumber) as List;
      final seen = <String>{};
      while (true) {
        if (current.kind == TokenKind.rbrace) {
          _advance();
          return;
        }
        if (current.kind == TokenKind.eof) {
          throw PxfError(current.pos,
              'expected "}" to close keyed field "${fi.protoName}", got EOF');
        }
        if (current.kind != TokenKind.ident &&
            current.kind != TokenKind.string) {
          throw PxfError(current.pos,
              'expected entry name (identifier or string) in keyed field "${fi.protoName}", got ${current.kind.name}');
        }
        final namePos = current.pos;
        final name = current.value;
        if (name.isEmpty) throw keyedEmptyNameError(namePos, fi.protoName);
        if (!seen.add(name)) {
          throw keyedDuplicateKeyError(namePos, fi.protoName, name);
        }
        _advance();

        if (current.kind == TokenKind.equals) {
          _advance();
          if (current.kind != TokenKind.lbrace) {
            throw PxfError(current.pos,
                'keyed entry "$name" of field "${fi.protoName}" must have a block value ("{ ... }"): the element type is a message');
          }
        } else if (current.kind != TokenKind.lbrace) {
          throw PxfError(current.pos,
              'expected "{" or "=" after entry name "$name" in keyed field "${fi.protoName}", got ${current.kind.name}');
        }
        _advance();

        _checkRepeatedCount(list.length, fi);
        var sub = fi.subBuilder!();
        sub.setField(keyFi.tagNumber, name);
        _decodeKeyedElement(
            sub,
            fi,
            list.length,
            KeyedElemState(
                field: fi.protoName,
                keyName: keyFi.protoName,
                entryName: name));
        list.add(sub);
      }
    } finally {
      _depth--;
    }
  }

  /// Decodes the body of element [index] of keyed field [fi], under the
  /// reference's element path `name[i].`.
  void _decodeKeyedElement(
      GeneratedMessage sub, FieldInfo fi, int index, KeyedElemState state) {
    final prefix = '$pathPrefix${fi.protoName}[$index].';
    // An entry name supplies the key field, so whatever reads presence must
    // not take it as absent (protowire-go#214).
    if (state.entryName != null) {
      result?.markPresent('$prefix${state.keyName}');
    }
    _keyedElem = state;
    _decodeElementFields(sub, prefix);
  }

  /// Decodes the body of a list element or a map value, whose fields are
  /// recorded under [prefix], not under the parent's path.
  void _decodeElementFields(GeneratedMessage sub, String prefix) {
    final oldPrefix = pathPrefix;
    pathPrefix = prefix;
    _elemDepth++;
    try {
      _decodeFields(sub, true);
    } finally {
      _elemDepth--;
      pathPrefix = oldPrefix;
    }
  }

  /// `field = { key: value, ... }` (draft -01 §3.9). Keys are converted by
  /// the entry's key field type and values decoded by its value field —
  /// scalar, enum by name or number, or a message as a `{ ... }` block
  /// with the well-known-type shorthands a singular message value takes.
  /// Mirrors the Go reference's `decodeMapInline` / `decodeMapKey`. A key is
  /// bound once in one message body, across every binding of the field
  /// (protowire#396).
  void _decodeMap(GeneratedMessage msg, FieldInfo fi) {
    // A map's `{` is a descent like any other, whatever its values are
    // (HARDENING.md § Recursion; protowire#449).
    _enterNesting();
    try {
      _decodeMapBody(msg, fi);
    } finally {
      _depth--;
    }
  }

  void _decodeMapBody(GeneratedMessage msg, FieldInfo fi) {
    _advance(); // consume {
    var map = msg.getField(fi.tagNumber) as Map;
    var mfi = fi as MapFieldInfo;
    var keyFi = mfi.mapEntryBuilderInfo.fieldInfo[1]!;
    var valueFi = mfi.valueFieldInfo;

    while (current.kind != TokenKind.rbrace && current.kind != TokenKind.eof) {
      var pos = current.pos;
      // `true` / `false` lex as bool tokens here (the reference lexes them
      // as identifiers), and they are the keys of a map<bool, V>.
      if (current.kind != TokenKind.ident &&
          current.kind != TokenKind.string &&
          current.kind != TokenKind.int &&
          current.kind != TokenKind.bool) {
        throw PxfError(pos, 'expected map key, got ${current.kind.name}');
      }
      var keyStr = current.value;
      final keyKind = current.kind;
      if (current.prec != null) {
        throw PxfError(pos,
            'map key $keyStr: a key cannot carry a precision suffix (p${current.prec})');
      }
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

      _checkRepeatedCount(map.length, fi);
      var key = _decodeMapKey(keyFi, keyStr, keyKind, pos);
      _bindMapKey(msg, fi, key, pos);

      if (current.kind == TokenKind.null_) {
        throw PxfError(current.pos,
            'null is not allowed as map value in field "${fi.protoName}"');
      }

      Object value;
      if (PbFieldType.isGroupOrMessage(valueFi.type)) {
        value = _decodeMapMessageValue(mfi, valueFi, key);
      } else {
        value = _consumeScalar(valueFi);
      }
      map[key] = value;
    }
    if (current.kind != TokenKind.rbrace) {
      throw PxfError(current.pos, 'expected "}", got ${current.kind.name}');
    }
    _advance();
  }

  /// Records that this decode bound [key] of [msg]'s map field [fi], and
  /// rejects a second binding of it. Keys compare as values of the key type,
  /// so `1` and `"1"` are one key of an integer-keyed map.
  void _bindMapKey(
      GeneratedMessage msg, FieldInfo fi, Object key, Position pos) {
    final keys = (_mapKeys[msg] ??= {})[fi.tagNumber] ??= <Object>{};
    if (!keys.add(key)) {
      throw PxfError(pos,
          'map field "${fi.protoName}": key ${_shownMapKey(key)} is already set');
    }
  }

  /// A map key as its Dart representation for the entry's key type (the
  /// token has already been read as text): string as written, integers
  /// parsed in their width. A bool key is `true` / `false`, bare or quoted,
  /// or a bare `1` / `0` (draft -01 § Entries and Keys); a quoted `"1"` is
  /// not a bool literal. The reference's `decodeMapKey`.
  Object _decodeMapKey(
      FieldInfo keyFi, String key, TokenKind kind, Position pos) {
    var t = keyFi.type;
    if (t == PbFieldType.OS) return key;
    if (t == PbFieldType.OB) {
      if (key == 'true') return true;
      if (key == 'false') return false;
      if (kind == TokenKind.int && key == '1') return true;
      if (kind == TokenKind.int && key == '0') return false;
      throw PxfError(pos, 'invalid bool map key: $key');
    }
    if (t == PbFieldType.O3 || t == PbFieldType.OS3 || t == PbFieldType.OSF3) {
      var n = int.tryParse(key);
      if (n == null || n < -2147483648 || n > 2147483647) {
        throw PxfError(pos, 'invalid int32 map key: $key');
      }
      return n;
    }
    if (t == PbFieldType.OU3 || t == PbFieldType.OF3) {
      var n = int.tryParse(key);
      if (n == null || n < 0 || n > 4294967295) {
        throw PxfError(pos, 'invalid uint32 map key: $key');
      }
      return n;
    }
    if (t == PbFieldType.O6 || t == PbFieldType.OS6 || t == PbFieldType.OSF6) {
      var n = Int64.tryParseInt(key);
      if (n == null) throw PxfError(pos, 'invalid int64 map key: $key');
      return n;
    }
    if (t == PbFieldType.OU6 || t == PbFieldType.OF6) {
      var n = Int64.tryParseInt(key);
      if (n == null || key.startsWith('-')) {
        throw PxfError(pos, 'invalid uint64 map key: $key');
      }
      return n;
    }
    throw PxfError(pos, 'unsupported map key type $t');
  }

  /// A message-typed map value: the same forms a singular message field
  /// accepts (`{ ... }` block, or the Timestamp / Duration / wrapper /
  /// big-number shorthands), decoded into a fresh value message.
  GeneratedMessage _decodeMapMessageValue(
      MapFieldInfo mfi, FieldInfo valueFi, Object key) {
    var make = mfi.valueCreator!;
    var subInfo = make().info_;
    if (isBigFloat(subInfo)) {
      final sub = make();
      if (_consumeBigFloat(sub)) return sub;
    } else {
      _rejectPrecision(valueFi);
    }

    if (isTimestamp(subInfo) && current.kind == TokenKind.timestamp) {
      var sub = make();
      setTimestampLiteral(sub, current.value);
      _advance();
      return sub;
    }
    if (isDuration(subInfo) && current.kind == TokenKind.duration) {
      var sub = make();
      setDurationLiteral(sub, current.value);
      _advance();
      return sub;
    }
    if (isWrapperType(subInfo) && current.kind != TokenKind.lbrace) {
      var sub = make();
      setImplicit(sub, 1, _consumeScalar(subInfo.fieldInfo[1]!));
      return sub;
    }
    if (isBigInt(subInfo) && current.kind == TokenKind.int) {
      var sub = make();
      setBigIntFields(sub, current.value);
      _advance();
      return sub;
    }
    if (isDecimal(subInfo) &&
        (current.kind == TokenKind.float || current.kind == TokenKind.int)) {
      var sub = make();
      setDecimalFields(sub, current.value);
      _advance();
      return sub;
    }
    if (current.kind != TokenKind.lbrace) {
      throw PxfError(current.pos,
          'expected "{" for map message value in field "${mfi.protoName}"');
    }
    _advance();
    var sub = make();
    _decodeElementFields(
        sub, '$pathPrefix${mfi.protoName}[${_shownMapKey(key)}].');
    return sub;
  }

  Object _consumeScalar(FieldInfo fi) {
    var pos = current.pos;
    _rejectPrecision(fi);
    var t = _packedAsRepeated[fi.type] ?? fi.type;
    if (t == PbFieldType.OS || t == PbFieldType.PS || t == PbFieldType.QS) {
      if (current.kind != TokenKind.string) {
        throw PxfError(pos, 'expected string for field "${fi.protoName}"');
      }
      var v = current.value;
      _advance();
      return v;
    }
    if (t == PbFieldType.OB || t == PbFieldType.PB || t == PbFieldType.QB) {
      if (current.kind != TokenKind.bool) {
        throw PxfError(pos, 'expected bool for field "${fi.protoName}"');
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
        throw PxfError(pos, 'expected integer for field "${fi.protoName}"');
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
        throw PxfError(pos, 'expected integer for field "${fi.protoName}"');
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
        throw PxfError(pos, 'expected integer for field "${fi.protoName}"');
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
        throw PxfError(pos, 'expected integer for field "${fi.protoName}"');
      }
      var v = Int64.parseInt(current.value);
      _advance();
      return v;
    }

    final isFloat =
        t == PbFieldType.OF || t == PbFieldType.PF || t == PbFieldType.QF;
    if (isFloat ||
        t == PbFieldType.OD ||
        t == PbFieldType.PD ||
        t == PbFieldType.QD) {
      if (current.kind != TokenKind.float &&
          current.kind != TokenKind.int &&
          !(current.kind == TokenKind.ident &&
              (current.value == 'inf' || current.value == 'nan'))) {
        throw PxfError(pos, 'expected number for field "${fi.protoName}"');
      }
      final v = parseFloatLiteral(current.value, float32: isFloat);
      if (v == null) {
        throw PxfError(
            pos, 'invalid ${isFloat ? 'float' : 'double'}: ${current.value}');
      }
      _advance();
      return v;
    }
    if (t == PbFieldType.OY || t == PbFieldType.PY || t == PbFieldType.QY) {
      if (current.kind != TokenKind.bytes) {
        throw PxfError(pos, 'expected bytes for field "${fi.protoName}"');
      }
      var v = base64.decode(current.value);
      _advance();
      return v;
    }
    if (t == PbFieldType.OE || t == PbFieldType.PE || t == PbFieldType.QE) {
      return _consumeEnum(fi);
    }
    throw PxfError(
        pos, 'unsupported type ${fi.type} for field "${fi.protoName}"');
  }

  // Enum fields hold a ProtobufEnum, never a bare int: FieldSet rejects
  // `setField(tag, 1)` on an enum field, so both spellings resolve through
  // the values generated code puts in FieldInfo.enumValues / valueOf.
  ProtobufEnum _consumeEnum(FieldInfo fi) {
    var pos = current.pos;
    if (current.kind == TokenKind.ident) {
      // By name, as every port writes them (draft -01 §3.2).
      final name = current.value;
      for (final e in fi.enumValues ?? const <ProtobufEnum>[]) {
        if (e.name == name) {
          _advance();
          return e;
        }
      }
      throw PxfError(
          pos, 'unknown enum value "$name" for field "${fi.protoName}"');
    } else if (current.kind == TokenKind.int) {
      var v = int.parse(current.value);
      final e = fi.valueOf?.call(v);
      if (e == null) {
        // A generated Dart enum has no instance for a number it does not
        // declare, so an open-enum unknown value cannot be carried here.
        throw PxfError(
            pos, 'unknown enum number $v for field "${fi.protoName}"');
      }
      _advance();
      return e;
    } else {
      throw PxfError(
          pos, 'expected enum name or number for field "${fi.protoName}"');
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

/// A map key as an error and a presence path show it: a string quoted, as in
/// `by_host["a"]`, anything else bare.
String _shownMapKey(Object key) => key is String ? quotePxfString(key) : '$key';

/// Resolves a PXF entry name to a field. Entry names are the proto field
/// names (draft -01 §3.2; `order_id`), which is what every other port
/// writes and reads; [BuilderInfo.byName] indexes the Dart names generated
/// code uses (`orderId`), so those are accepted too for documents written
/// against this port. The proto-name index is built once per [BuilderInfo].
FieldInfo? fieldNamed(BuilderInfo info, String key) {
  final byDart = info.byName[key];
  if (byDart != null) return byDart;
  final byProto = _byProtoNameCache[info] ??= {
    for (final fi in info.fieldInfo.values) fi.protoName: fi,
  };
  return byProto[key];
}

/// Unmarshals PXF text from [input] into the provided [msg].
///
/// Options can be provided via [options] to customize the unmarshaling
/// process. With [UnmarshalOptions.annotations] set, this is
/// [unmarshalFull] minus the returned presence, and the schema's keyed
/// repeated fields decode from their block form:
///
/// ```dart
/// final ann = PxfAnnotations.fromBytes(descriptorSetBytes);
/// unmarshal('children { greeting { type = "Label" } }', node,
///     options: UnmarshalOptions(annotations: ann));
/// ```
void unmarshal(String input, GeneratedMessage msg,
    {UnmarshalOptions? options}) {
  if (options?.annotations != null) {
    unmarshalFull(input, msg, options: options);
    return;
  }
  var d = DirectDecoder(
    input,
    typeRegistry: options?.typeRegistry ?? const TypeRegistry.empty(),
    discardUnknown: options?.discardUnknown ?? false,
    limits: options?.limits ?? const DecodeLimits(),
  );
  d.decodeDocument(msg);
}

/// The value of a float or double literal (draft -01 § Numeric Literals),
/// or null when it has none: a malformed literal, or a finite one past the
/// type's range. `inf`, `+inf` and `-inf` are infinities; `nan` is the
/// canonical quiet NaN. A float is rounded to float32 here, so a value that
/// underflows is zero, as it will be on the wire.
double? parseFloatLiteral(String literal, {required bool float32}) {
  final double d;
  switch (literal) {
    case 'inf' || '+inf':
      d = double.infinity;
    case '-inf':
      d = double.negativeInfinity;
    case 'nan':
      d = double.nan;
    default:
      final parsed = double.tryParse(literal);
      if (parsed == null || !_plainNumber.hasMatch(literal)) return null;
      if (parsed.isInfinite) return null; // past the double range
      if (!float32) return parsed;
      final rounded = (Float32List(1)..[0] = parsed)[0];
      return rounded.isInfinite ? null : rounded;
  }
  return float32 ? (Float32List(1)..[0] = d)[0] : d;
}

/// A decimal literal: double.tryParse alone also takes "Infinity", "NaN" and
/// hex, which the grammar does not.
final _plainNumber = RegExp(r'^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$');

/// Unmarshals [input] into [msg] and reports which fields the document
/// set, set to null, or left absent — the same `unmarshalFull` every
/// full-tier port has. Paths are proto field names, dotted for nesting
/// (`limits.max`).
///
/// With [UnmarshalOptions.annotations] the schema's `(pxf.required)` and
/// `(pxf.default)` are applied afterwards, as the Go reference's
/// `postDecode` does: for every field of the message's descriptor that is
/// absent (a field set to `null` counts as present), `required` is a
/// [PxfError] `required field "path" is absent`, otherwise `default` is
/// applied by the field's type. Every message body the document wrote gets
/// this: singular message fields, list elements (`items[0].`), map values
/// (`by_key["k"].`) and Any bodies. A defaulted field stays absent in the
/// [Result], since it was not in the input.
Result unmarshalFull(String input, GeneratedMessage msg,
    {UnmarshalOptions? options}) {
  final result = Result();
  var d = DirectDecoder(
    input,
    typeRegistry: options?.typeRegistry ?? const TypeRegistry.empty(),
    discardUnknown: options?.discardUnknown ?? false,
    annotations: options?.annotations,
    result: result,
    rootMsg: msg,
    limits: options?.limits ?? const DecodeLimits(),
  );
  d.decodeDocument(msg);
  final ann = options?.annotations;
  if (ann != null) {
    _postDecode(msg, result, ann, d.nullMaskFi, '');
  }
  return result;
}

// -- (pxf.required) / (pxf.default) -------------------------------------

void _postDecode(GeneratedMessage msg, Result result, PxfAnnotations ann,
    FieldInfo? nullMaskFi, String prefix) {
  final info = msg.info_;
  final tags = info.fieldInfo.keys.toList()..sort();
  for (final tag in tags) {
    final fi = info.fieldInfo[tag]!;
    if (nullMaskFi != null && fi.tagNumber == nullMaskFi.tagNumber) continue;
    final path = '$prefix${fi.protoName}';
    if (result.isAbsent(path)) {
      final a = ann.field(info.qualifiedMessageName, fi.protoName);
      if (a == null) continue;
      if (a.required) {
        throw PxfError(Position(1, 1), 'required field "$path" is absent');
      }
      if (a.defaultLiteral != null &&
          !_oneofAlreadyChosen(info, fi, result, prefix)) {
        _applyDefault(msg, fi, a.defaultLiteral!);
      }
    } else if (!result.isNull(path)) {
      _postDecodeBodies(msg, fi, result, ann, path);
    }
  }
}

/// Runs the pass on the message bodies [fi], a present field of [msg] at
/// [path], holds. Map values go in key order, so the first error is the same
/// on every run.
void _postDecodeBodies(GeneratedMessage msg, FieldInfo fi, Result result,
    PxfAnnotations ann, String path) {
  if (fi.isMapField) {
    if (!PbFieldType.isGroupOrMessage((fi as MapFieldInfo).valueFieldType)) {
      return;
    }
    final entries = [
      for (final e in (msg.getField(fi.tagNumber) as Map).entries)
        ('$path[${_shownMapKey(e.key as Object)}]', e.value as GeneratedMessage)
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    for (final (entryPath, body) in entries) {
      _postDecode(body, result, ann, null, '$entryPath.');
    }
  } else if (!fi.isGroupOrMessage) {
    return;
  } else if (fi.isRepeated) {
    final list = msg.getField(fi.tagNumber) as List;
    for (var i = 0; i < list.length; i++) {
      _postDecode(list[i] as GeneratedMessage, result, ann, null, '$path[$i].');
    }
  } else if (msg.hasField(fi.tagNumber)) {
    _postDecode(msg.getField(fi.tagNumber) as GeneratedMessage, result, ann,
        null, '$path.');
  }
}

/// A default is not applied to a oneof member when another member of the
/// same oneof is present (null included).
bool _oneofAlreadyChosen(
    BuilderInfo info, FieldInfo fi, Result result, String prefix) {
  final idx = info.oneofs[fi.tagNumber];
  if (idx == null) return false;
  for (final entry in info.oneofs.entries) {
    if (entry.value != idx || entry.key == fi.tagNumber) continue;
    final other = info.fieldInfo[entry.key];
    if (other != null && !result.isAbsent('$prefix${other.protoName}')) {
      return true;
    }
  }
  return false;
}

PxfError _badDefault(String what, String literal, FieldInfo fi) => PxfError(
    Position(1, 1),
    'invalid default $what "$literal" for field "${fi.protoName}"');

/// Applies a `(pxf.default)` literal to an absent field, read by the
/// field's type as the reference's `applyDefaultImpl` /
/// `applyMessageDefault` read it: a string is taken verbatim, `bool` is
/// exactly `true` or `false`, numbers must parse in their width, `bytes`
/// is base64, an enum names a value (or a number), and a message default
/// is meaningful only for the well-known types with a bare literal form
/// (Timestamp, Duration, the wrappers, pxf.BigInt, pxf.Decimal, pxf.BigFloat).
void _applyDefault(GeneratedMessage msg, FieldInfo fi, String literal) {
  if (fi.isMapField) {
    throw PxfError(Position(1, 1),
        'default values not supported for map field "${fi.protoName}"');
  }
  if (fi.isRepeated) {
    throw PxfError(Position(1, 1),
        'default values not supported for repeated field "${fi.protoName}"');
  }
  if (fi.type == PbFieldType.OM) {
    msg.setField(fi.tagNumber, _messageDefault(fi, literal));
    return;
  }
  msg.setField(fi.tagNumber, _scalarDefault(fi.type, literal, fi));
}

Object _scalarDefault(int t, String literal, FieldInfo fi) {
  if (t == PbFieldType.OS) return literal;
  if (t == PbFieldType.OB) {
    if (literal == 'true') return true;
    if (literal == 'false') return false;
    throw _badDefault('bool', literal, fi);
  }
  if (t == PbFieldType.O3 || t == PbFieldType.OS3 || t == PbFieldType.OSF3) {
    final n = int.tryParse(literal);
    if (n == null || n < -2147483648 || n > 2147483647) {
      throw _badDefault('int32', literal, fi);
    }
    return n;
  }
  if (t == PbFieldType.OU3 || t == PbFieldType.OF3) {
    final n = int.tryParse(literal);
    if (n == null || n < 0 || n > 4294967295) {
      throw _badDefault('uint32', literal, fi);
    }
    return n;
  }
  if (t == PbFieldType.O6 || t == PbFieldType.OS6 || t == PbFieldType.OSF6) {
    final n = Int64.tryParseInt(literal);
    if (n == null) throw _badDefault('int64', literal, fi);
    return n;
  }
  if (t == PbFieldType.OU6 || t == PbFieldType.OF6) {
    final n = Int64.tryParseInt(literal);
    if (n == null || literal.startsWith('-')) {
      throw _badDefault('uint64', literal, fi);
    }
    return n;
  }
  if (t == PbFieldType.OF) {
    final d = parseFloatLiteral(literal, float32: true);
    if (d == null) throw _badDefault('float', literal, fi);
    return d;
  }
  if (t == PbFieldType.OD) {
    final d = parseFloatLiteral(literal, float32: false);
    if (d == null) throw _badDefault('double', literal, fi);
    return d;
  }
  if (t == PbFieldType.OY) {
    try {
      return base64.decode(base64.normalize(literal));
    } on FormatException {
      throw _badDefault('bytes', literal, fi);
    }
  }
  if (t == PbFieldType.OE) {
    for (final e in fi.enumValues ?? const <ProtobufEnum>[]) {
      if (e.name == literal) return e;
    }
    final n = int.tryParse(literal);
    final e = n == null ? null : fi.valueOf?.call(n);
    if (e == null) throw _badDefault('enum', literal, fi);
    return e;
  }
  throw PxfError(Position(1, 1),
      'default values not supported for type $t (field "${fi.protoName}")');
}

GeneratedMessage _messageDefault(FieldInfo fi, String literal) {
  final sub = fi.subBuilder!();
  final info = sub.info_;
  if (isTimestamp(info)) {
    if (DateTime.tryParse(literal) == null) {
      throw _badDefault('timestamp', literal, fi);
    }
    setTimestampLiteral(sub, literal);
    return sub;
  }
  if (isDuration(info)) {
    try {
      setDurationLiteral(sub, literal);
    } on FormatException {
      throw _badDefault('duration', literal, fi);
    }
    return sub;
  }
  if (isWrapperType(info)) {
    final inner = info.fieldInfo[1]!;
    setImplicit(sub, 1, _scalarDefault(inner.type, literal, fi));
    return sub;
  }
  if (isBigInt(info)) {
    if (BigInt.tryParse(literal) == null) {
      throw _badDefault('big integer', literal, fi);
    }
    setBigIntFields(sub, literal);
    return sub;
  }
  if (isDecimal(info)) {
    if (double.tryParse(literal) == null) {
      throw _badDefault('decimal', literal, fi);
    }
    setDecimalFields(sub, literal);
    return sub;
  }
  if (isBigFloat(info)) {
    final split = literal.indexOf('p');
    try {
      setBigFloatLiteral(sub, split < 0 ? literal : literal.substring(0, split),
          split < 0 ? null : literal.substring(split + 1));
    } on FormatException {
      throw _badDefault('big float', literal, fi);
    }
    return sub;
  }
  throw PxfError(
      Position(1, 1),
      'default values not supported for message type '
      '${info.qualifiedMessageName} (field "${fi.protoName}")');
}
