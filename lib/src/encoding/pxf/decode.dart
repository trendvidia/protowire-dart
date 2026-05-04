import 'dart:convert';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';
import 'annotations.dart' as ann;
import 'token.dart';
import 'lexer.dart';
import 'errors.dart';
import 'options.dart';
import 'result.dart';
import 'wellknown.dart';
import 'duration.dart';

/// Caches the proto-name → FieldInfo lookup per [BuilderInfo]. Built once
/// per message type and reused across decode calls — `BuilderInfo` instances
/// are static-final per generated class, so the [Expando] never holds onto
/// per-message state.
final Expando<Map<String, FieldInfo>> _byProtoNameCache = Expando('pxfByProto');

class DirectDecoder {
  final Lexer lex;
  late Token current;
  final TypeRegistry typeRegistry;
  final bool discardUnknown;
  Result? result;
  GeneratedMessage? rootMsg;
  FieldInfo? nullMaskFi;
  String pathPrefix = '';

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
      if (current.kind != TokenKind.comment &&
          current.kind != TokenKind.newline) {
        return;
      }
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
    if (current.kind == TokenKind.atType) {
      _advance();
      if (current.kind != TokenKind.ident) {
        throw PxfError(current.pos, 'expected type name after @type, got ${current.kind.name}');
      }
      _advance();
    }
    _decodeFields(msg, false);
  }

  void _decodeFields(GeneratedMessage msg, bool inBlock) {
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
        throw PxfError(pos, 'expected identifier, string, or integer, got ${current.kind.name} ("${current.value}")');
      }
      var key = current.value;
      _advance();

      switch (current.kind) {
        case TokenKind.equals:
          _advance();
          var fi = _lookupField(info, key);
          if (fi == null) {
            if (discardUnknown) {
              _skipValue();
              continue;
            }
            throw PxfError(pos, 'unknown field "$key" in ${info.qualifiedMessageName}');
          }
          _checkOneof(info, fi, setOneofs, pos);

          if (current.kind == TokenKind.null_) {
            final path = pathPrefix + fi.protoName;
            // Result tracking is opt-in via unmarshalFull.
            if (result != null) {
              result!.markNull(path);
            }
            // _null FieldMask population happens whenever the message
            // declares one — it's not gated on Result so plain unmarshal()
            // also preserves null state across a protobuf-binary round-trip.
            if (nullMaskFi != null) {
              _addToNullMask(rootMsg!, nullMaskFi!, path);
            }
            _advance();
            continue;
          }

          if (result != null) {
            result!.markPresent(pathPrefix + fi.protoName);
          }
          _decodeFieldValue(msg, fi);
          break;

        case TokenKind.lbrace:
          _advance();
          var fi = _lookupField(info, key);
          if (fi == null) {
            if (discardUnknown) {
              _skipBraced();
              continue;
            }
            throw PxfError(pos, 'unknown field "$key" in ${info.qualifiedMessageName}');
          }

          // Any sugar handling: name { @type = "..." ... }
          if (isAny(fi.subBuilder!().info_) && current.kind == TokenKind.atType) {
            _checkOneof(info, fi, setOneofs, pos);
            if (result != null) {
              result!.markPresent(pathPrefix + fi.protoName);
            }
            _decodeAnyInner(msg, fi);
            continue;
          }

          if (fi.type != PbFieldType.OM && fi.type != PbFieldType.PM) {
            throw PxfError(pos, 'field "$key" is not a message type, cannot use block syntax');
          }
          _checkOneof(info, fi, setOneofs, pos);

          if (result != null) {
            result!.markPresent(pathPrefix + fi.protoName);
          }

          if (fi.isRepeated) {
            var list = msg.getField(fi.tagNumber) as List;
            var sub = fi.subBuilder!();
            var oldPrefix = pathPrefix;
            pathPrefix = '$oldPrefix${fi.protoName}.';
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
            pathPrefix = '$oldPrefix${fi.protoName}.';
            _decodeFields(sub, true);
            pathPrefix = oldPrefix;
          }
          break;

        default:
          throw PxfError(current.pos, 'expected "=" or "{" after "$key", got ${current.kind.name}');
      }
    }
  }

  /// Resolves a PXF field name to its [FieldInfo].
  ///
  /// PXF uses proto-canonical (snake_case) field names on the wire, but the
  /// Dart `BuilderInfo.byName` index is keyed by the codegen-side camelCase
  /// name. We try the proto name first (the contract), then fall back to the
  /// Dart name so hand-defined `BuilderInfo`s still resolve.
  FieldInfo? _lookupField(BuilderInfo info, String key) {
    var byProto = _byProtoNameCache[info];
    if (byProto == null) {
      byProto = <String, FieldInfo>{};
      for (final fi in info.byName.values) {
        byProto[fi.protoName] = fi;
      }
      _byProtoNameCache[info] = byProto;
    }
    final fi = byProto[key];
    if (fi != null) return fi;
    return info.byName[key];
  }

  void _checkOneof(BuilderInfo info, FieldInfo fi, Map<int, String> setOneofs, Position pos) {
    var oneofIndex = info.oneofs[fi.tagNumber];
    if (oneofIndex != null) {
      if (setOneofs.containsKey(oneofIndex)) {
        throw PxfError(pos, 'field "${fi.name}" conflicts with already-set field "${setOneofs[oneofIndex]}" in the same oneof');
      }
      setOneofs[oneofIndex] = fi.name;
    }
  }

  void _decodeFieldValue(GeneratedMessage msg, FieldInfo fi) {
    if (fi.isRepeated) {
      if (current.kind == TokenKind.lbracket) {
        _decodeList(msg, fi);
      } else {
        throw PxfError(current.pos, 'expected "[" for repeated field "${fi.name}"');
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
    if (isDecimal(subInfo) && (current.kind == TokenKind.float || current.kind == TokenKind.int)) {
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
      throw PxfError(current.pos, 'expected "{" for message field "${fi.name}"');
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
      throw PxfError(current.pos, 'expected type URL string or identifier after @type');
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
    pathPrefix = '$oldPrefix${fi.protoName}.';
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
    while (current.kind != TokenKind.rbracket && current.kind != TokenKind.eof) {
      if (current.kind == TokenKind.null_) {
        throw PxfError(current.pos, 'null is not allowed in repeated field "${fi.name}"');
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
          } else if (isDuration(subInfo) && current.kind == TokenKind.duration) {
            setDurationFields(sub, parseGoDuration(current.value));
            list.add(sub);
            _advance();
          } else if (isWrapperType(subInfo)) {
            var valueFi = subInfo.fieldInfo[1]!;
            var val = _consumeScalar(valueFi);
            sub.setField(1, val);
            list.add(sub);
          } else {
            throw PxfError(current.pos, 'expected "{" for message element in list');
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

    if (fi is! MapFieldInfo) {
      throw PxfError(current.pos,
          'internal: field "${fi.name}" is map-typed but FieldInfo is not MapFieldInfo');
    }
    final mapFi = fi;
    final map = msg.getField(fi.tagNumber) as Map;
    final valueFi = mapFi.valueFieldInfo;

    while (current.kind != TokenKind.rbrace && current.kind != TokenKind.eof) {
      final pos = current.pos;
      if (current.kind != TokenKind.ident &&
          current.kind != TokenKind.string &&
          current.kind != TokenKind.int) {
        throw PxfError(pos, 'expected map key, got ${current.kind.name}');
      }
      final keyRaw = current.value;
      _advance(); // consume key token

      if (current.kind == TokenKind.equals) {
        throw PxfError(current.pos,
            'unexpected "=" in map, use ":" for map entries');
      }
      if (current.kind != TokenKind.colon) {
        throw PxfError(current.pos,
            'expected ":" after map key, got ${current.kind.name}');
      }
      _advance(); // consume :

      if (current.kind == TokenKind.null_) {
        throw PxfError(current.pos,
            'null is not allowed as map value in field "${fi.name}"');
      }

      final key = _coerceMapKey(mapFi.keyFieldType, keyRaw, pos);
      final value = _consumeMapValue(valueFi);
      map[key] = value;

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
    if (t == PbFieldType.O3 || t == PbFieldType.P3 || t == PbFieldType.Q3 || 
        t == PbFieldType.OS3 || t == PbFieldType.PS3 || t == PbFieldType.QS3 || 
        t == PbFieldType.OSF3 || t == PbFieldType.PSF3 || t == PbFieldType.QSF3) {
        if (current.kind != TokenKind.int) {
          throw PxfError(pos, 'expected integer for field "${fi.name}"');
        }
        var v = int.parse(current.value);
        _advance();
        return v;
    }
    if (t == PbFieldType.O6 || t == PbFieldType.P6 || t == PbFieldType.Q6 || 
        t == PbFieldType.OS6 || t == PbFieldType.PS6 || t == PbFieldType.QS6 || 
        t == PbFieldType.OSF6 || t == PbFieldType.PSF6 || t == PbFieldType.QSF6) {
        if (current.kind != TokenKind.int) {
          throw PxfError(pos, 'expected integer for field "${fi.name}"');
        }
        var v = Int64.parseInt(current.value);
        _advance();
        return v;
    }
    if (t == PbFieldType.OU3 || t == PbFieldType.PU3 || t == PbFieldType.QU3 || 
        t == PbFieldType.OF3 || t == PbFieldType.PF3 || t == PbFieldType.QF3) {
        if (current.kind != TokenKind.int) {
          throw PxfError(pos, 'expected integer for field "${fi.name}"');
        }
        var v = int.parse(current.value);
        _advance();
        return v;
    }
    if (t == PbFieldType.OU6 || t == PbFieldType.PU6 || t == PbFieldType.QU6 || 
        t == PbFieldType.OF6 || t == PbFieldType.PF6 || t == PbFieldType.QF6) {
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

  /// Coerces a token value into the protobuf map key type.
  /// Map keys are restricted by spec to string + integer + bool.
  Object _coerceMapKey(int keyFieldType, String raw, Position pos) {
    // The key field-type bits mirror PbFieldType: same _BOOL_BIT / _INT*_BIT
    // / _UINT*_BIT / _STRING_BIT layout the SBE codec uses. We don't need
    // every variant — proto map keys are always one of: string, bool, or
    // an integer kind.
    if ((keyFieldType & 0x40) != 0) return raw; // string
    if ((keyFieldType & 0x10) != 0) {            // bool
      if (raw == 'true') return true;
      if (raw == 'false') return false;
      throw PxfError(pos, 'invalid bool map key: "$raw"');
    }
    // 64-bit integer kinds (Int64): _INT64 | _SINT64 | _SFIXED64
    final i64Bits = 0x1000 | 0x4000 | 0x100000;
    final u64Bits = 0x10000 | 0x40000;
    if ((keyFieldType & i64Bits) != 0) {
      return Int64.parseInt(raw);
    }
    if ((keyFieldType & u64Bits) != 0) {
      return Int64.parseInt(raw);
    }
    // 32-bit integer kinds: _INT32/_SINT32/_SFIXED32/_UINT32/_FIXED32
    final i32Bits = 0x800 | 0x2000 | 0x80000 | 0x8000 | 0x20000;
    if ((keyFieldType & i32Bits) != 0) {
      final n = int.tryParse(raw);
      if (n == null) throw PxfError(pos, 'invalid integer map key: "$raw"');
      return n;
    }
    throw PxfError(pos,
        'unsupported map key type (proto field-type bits: 0x${keyFieldType.toRadixString(16)})');
  }

  /// Decodes a single map value at the current position. Handles scalars,
  /// enums (by name or number), and message values (block syntax + WKT
  /// shorthand for Timestamp / Duration / wrapper types).
  Object _consumeMapValue(FieldInfo valueFi) {
    if (valueFi.type == PbFieldType.OM) {
      final subBuilder = valueFi.subBuilder!;
      final subInfo = subBuilder().info_;
      if (isTimestamp(subInfo) && current.kind == TokenKind.timestamp) {
        final t = DateTime.parse(current.value);
        final sub = subBuilder();
        setTimestampFields(sub, t);
        _advance();
        return sub;
      }
      if (isDuration(subInfo) && current.kind == TokenKind.duration) {
        final d = parseGoDuration(current.value);
        final sub = subBuilder();
        setDurationFields(sub, d);
        _advance();
        return sub;
      }
      if (isWrapperType(subInfo) && current.kind != TokenKind.lbrace) {
        final innerFi = subInfo.fieldInfo[1]!;
        final v = _consumeScalar(innerFi);
        final sub = subBuilder();
        sub.setField(1, v);
        return sub;
      }
      if (current.kind != TokenKind.lbrace) {
        throw PxfError(current.pos,
            'expected "{" for message map value, got ${current.kind.name}');
      }
      _advance();
      final sub = subBuilder();
      _decodeFields(sub, true);
      return sub;
    }
    if (valueFi.type == PbFieldType.OE) {
      return _consumeEnum(valueFi);
    }
    return _consumeScalar(valueFi);
  }

  /// Decodes an enum value (by name or numeric form). Returns the
  /// `ProtobufEnum` instance the protobuf package's `setField` accepts
  /// for enum-typed fields. Mirrors the Go reference's `fd.Enum().Values()
  /// .ByName(...)` lookup with a numeric fallback.
  ProtobufEnum _consumeEnum(FieldInfo fi) {
    final pos = current.pos;
    final values = fi.enumValues;
    if (current.kind == TokenKind.int) {
      final n = int.parse(current.value);
      final lookup = fi.valueOf;
      if (lookup != null) {
        final ev = lookup(n);
        if (ev != null) {
          _advance();
          return ev;
        }
      }
      throw PxfError(pos,
          'unknown enum number $n for field "${fi.name}"');
    }
    if (current.kind != TokenKind.ident) {
      throw PxfError(pos,
          'expected enum name or number for field "${fi.name}", got ${current.kind.name}');
    }
    final name = current.value;
    if (values != null) {
      for (final ev in values) {
        if (ev.name == name) {
          _advance();
          return ev;
        }
      }
    }
    throw PxfError(pos,
        'unknown enum value "$name" for field "${fi.name}"');
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

  void _addToNullMask(GeneratedMessage rootMsg, FieldInfo nullMaskFi, String path) {
    // Ensure the FieldMask sub-message is mutably set on the root before
    // appending. getField returns a frozen default for unset fields, so
    // append-without-set throws "'add' on a read-only list".
    GeneratedMessage fm;
    if (!rootMsg.hasField(nullMaskFi.tagNumber)) {
      fm = nullMaskFi.subBuilder!();
      rootMsg.setField(nullMaskFi.tagNumber, fm);
    } else {
      fm = rootMsg.getField(nullMaskFi.tagNumber) as GeneratedMessage;
    }
    final paths = fm.getField(1) as List<String>;
    paths.add(path);
  }
}

/// Unmarshals PXF text from [input] into the provided [msg].
///
/// Mirrors the Go reference's `pxf.Unmarshal` — silently absorbs `field = null`
/// entries (without surfacing the null-state to the caller). Any null fields
/// are recorded into [msg]'s `_null` FieldMask if it declares one, so the
/// nulls survive a subsequent protobuf-binary round-trip.
///
/// Use [unmarshalFull] when you need a [Result] reporting which fields were
/// set, null, or absent.
void unmarshal(String input, GeneratedMessage msg, {UnmarshalOptions? options}) {
  final annotations = options?.annotations;
  // Tracking presence costs a hash-set insert per decoded field. Skip it
  // unless the caller asked for annotation enforcement.
  final result = annotations != null && !annotations.isEmpty ? Result() : null;
  final d = DirectDecoder(
    input,
    typeRegistry: options?.typeRegistry ?? const TypeRegistry.empty(),
    discardUnknown: options?.discardUnknown ?? false,
    result: result,
    rootMsg: msg,
  );
  d.decodeDocument(msg);
  if (annotations != null && !annotations.isEmpty) {
    ann.postDecode(msg, result!.presentFields, annotations, '');
  }
}

/// Unmarshals PXF text from [input] into [msg] and returns a [Result] with
/// per-field presence info (set / null / absent by dotted field path).
///
/// Mirrors the Go reference's `pxf.UnmarshalFull`. Like [unmarshal], any
/// null fields are also recorded into [msg]'s `_null` FieldMask if it
/// declares one.
Result unmarshalFull(String input, GeneratedMessage msg,
    {UnmarshalOptions? options}) {
  final result = Result();
  final d = DirectDecoder(
    input,
    typeRegistry: options?.typeRegistry ?? const TypeRegistry.empty(),
    discardUnknown: options?.discardUnknown ?? false,
    result: result,
    rootMsg: msg,
  );
  d.decodeDocument(msg);
  final annotations = options?.annotations;
  if (annotations != null && !annotations.isEmpty) {
    ann.postDecode(msg, result.presentFields, annotations, '');
  }
  return result;
}
