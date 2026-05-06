import 'dart:convert';
import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';
import 'result.dart';
import 'wellknown.dart';

class MarshalOptions {
  final String indent;
  final bool emitDefaults;
  final String? typeUrl;
  final TypeRegistry typeRegistry;
  final Result? nullFields;

  MarshalOptions({
    this.indent = '  ',
    this.emitDefaults = false,
    this.typeUrl,
    this.typeRegistry = const TypeRegistry.empty(),
    this.nullFields,
  });

  String marshal(GeneratedMessage msg) {
    final buf = StringBuffer();
    // Discover the root message's _null FieldMask, if it has one. The set
    // of dotted paths recorded there gates the encoder's null-emission
    // logic — fields named in the mask emit as `path = null` instead of
    // the field's zero value.
    final nullSet = <String>{};
    final fmPaths = _readNullMaskPaths(msg);
    if (fmPaths != null) nullSet.addAll(fmPaths);
    if (nullFields != null) nullSet.addAll(nullFields!.nullFields);

    final enc = _Encoder(
      buf: buf,
      indent: indent,
      emitDefaults: emitDefaults,
      typeRegistry: typeRegistry,
      nullFields: nullFields,
      nullSet: nullSet,
    );

    if (typeUrl != null && typeUrl!.isNotEmpty) {
      buf.write('@type $typeUrl\n\n');
    }

    enc.encodeMessage(msg, 0);
    return buf.toString();
  }

  /// Reads the dotted paths from a top-level `_null` field of type
  /// `google.protobuf.FieldMask`, returning null when the message
  /// doesn't declare one. Mirrors the same discovery the decoder does.
  static List<String>? _readNullMaskPaths(GeneratedMessage msg) {
    final fi = msg.info_.byName['_null'];
    if (fi == null) return null;
    if (fi.type != PbFieldType.OM) return null;
    if (fi.subBuilder == null) return null;
    if (fi.subBuilder!().info_.qualifiedMessageName !=
        'google.protobuf.FieldMask') {
      return null;
    }
    if (!msg.hasField(fi.tagNumber)) return null;
    final fm = msg.getField(fi.tagNumber) as GeneratedMessage;
    return List<String>.from(fm.getField(1) as List);
  }
}

class _Encoder {
  final StringBuffer buf;
  final String indent;
  final bool emitDefaults;
  final TypeRegistry typeRegistry;
  final Result? nullFields;
  final Set<String> nullSet;
  String pathPrefix = '';

  _Encoder({
    required this.buf,
    required this.indent,
    required this.emitDefaults,
    required this.typeRegistry,
    required this.nullSet,
    this.nullFields,
  });

  void _writeIndent(int level) {
    for (int i = 0; i < level; i++) {
      buf.write(indent);
    }
  }

  void _writeFieldPrefix(int level, String name) {
    _writeIndent(level);
    buf.write('$name = ');
  }

  void encodeMessage(GeneratedMessage msg, int level) {
    var info = msg.info_;
    // Sort fields by tag number to ensure deterministic output
    var fieldNumbers = info.fieldInfo.keys.toList()..sort();

    for (var tag in fieldNumbers) {
      var fi = info.fieldInfo[tag]!;
      // PXF emits proto-canonical (snake_case) field names so the wire
      // form is identical across all language ports.
      final wireName = fi.protoName;

      // Skip _null field — the FieldMask's contents are emitted as
      // `field = null` lines at the matching scope below.
      if (wireName == '_null' && pathPrefix == '') continue;

      final path = '$pathPrefix$wireName';
      if (nullSet.contains(path)) {
        _writeIndent(level);
        buf.write('$wireName = null\n');
        continue;
      }

      if (!emitDefaults && !msg.hasField(tag)) {
        continue;
      }

      var val = msg.getField(tag);

      if (fi.isMapField) {
        _encodeMapField(fi, val as Map, level);
        continue;
      }

      if (fi.isRepeated) {
        _encodeListField(fi, val as List, level);
        continue;
      }

      if (fi.type == PbFieldType.OM) {
        if (!msg.hasField(tag)) continue;
        _encodeMessageField(fi, val as GeneratedMessage, level);
        continue;
      }

      _writeFieldPrefix(level, wireName);
      _writeScalar(fi, val);
      buf.write('\n');
    }
  }

  void _encodeMessageField(FieldInfo fi, GeneratedMessage sub, int level) {
    var subInfo = sub.info_;
    final wireName = fi.protoName;

    if (isTimestamp(subInfo)) {
      var t = readTimestamp(sub);
      _writeFieldPrefix(level, wireName);
      buf.write(t.toIso8601String());
      buf.write('\n');
      return;
    }
    if (isDuration(subInfo)) {
      var d = readDuration(sub);
      _writeFieldPrefix(level, wireName);
      buf.write(_formatDuration(d));
      buf.write('\n');
      return;
    }
    if (isWrapperType(subInfo)) {
      var valueFi = subInfo.fieldInfo[1]!;
      _writeFieldPrefix(level, wireName);
      _writeScalar(valueFi, sub.getField(1));
      buf.write('\n');
      return;
    }

    if (isBigInt(subInfo)) {
      _writeFieldPrefix(level, wireName);
      buf.write(_formatBigInt(sub));
      buf.write('\n');
      return;
    }
    if (isDecimal(subInfo)) {
      _writeFieldPrefix(level, wireName);
      buf.write(_formatDecimal(sub));
      buf.write('\n');
      return;
    }

    if (isAny(subInfo)) {
      _writeAny(wireName, sub, level);
      return;
    }

    _writeIndent(level);
    buf.write('$wireName {\n');
    final oldPrefix = pathPrefix;
    pathPrefix = '$oldPrefix$wireName.';
    encodeMessage(sub, level + 1);
    pathPrefix = oldPrefix;
    _writeIndent(level);
    buf.write('}\n');
  }

  /// Emits an Any field using the @type-sugared block form. The inner
  /// payload is decoded through the TypeRegistry before re-emitting, so the
  /// output matches the format produced by the cross-port marshalers.
  /// Falls back to the regular `name = { type_url = ..., value = b"..." }`
  /// nested-message form when the inner type isn't in the registry.
  void _writeAny(String name, GeneratedMessage anyMsg, int level) {
    final typeUrl = anyMsg.getField(1) as String;
    final payload = anyMsg.getField(2) as List<int>;

    var typeName = typeUrl;
    final slash = typeName.lastIndexOf('/');
    if (slash >= 0) typeName = typeName.substring(slash + 1);

    final innerInfo = typeRegistry.lookup(typeName);
    if (innerInfo == null) {
      // No registered type — emit as a plain message: `name = { type_url
      // = "...", value = b"..." }`. This still round-trips through PXF
      // since the proto generated Any has fields type_url=1, value=2.
      _writeIndent(level);
      buf.write('$name {\n');
      final oldPrefix = pathPrefix;
      pathPrefix = '$oldPrefix$name.';
      encodeMessage(anyMsg, level + 1);
      pathPrefix = oldPrefix;
      _writeIndent(level);
      buf.write('}\n');
      return;
    }

    final inner = innerInfo.createEmptyInstance!();
    inner.mergeFromBuffer(Uint8List.fromList(payload));

    _writeIndent(level);
    buf.write('$name {\n');
    _writeIndent(level + 1);
    buf.write('@type = "$typeUrl"\n');
    final oldPrefix = pathPrefix;
    pathPrefix = '$oldPrefix$name.';
    encodeMessage(inner, level + 1);
    pathPrefix = oldPrefix;
    _writeIndent(level);
    buf.write('}\n');
  }

  void _encodeListField(FieldInfo fi, List list, int level) {
    if (list.isEmpty && !emitDefaults) return;

    _writeFieldPrefix(level, fi.protoName);
    buf.write('[\n');

    for (int i = 0; i < list.length; i++) {
      var elem = list[i];
      if (fi.type == PbFieldType.PM || fi.type == PbFieldType.OM) {
        var sub = elem as GeneratedMessage;
        var subInfo = sub.info_;

        if (isTimestamp(subInfo)) {
          _writeIndent(level + 1);
          buf.write(readTimestamp(sub).toIso8601String());
        } else if (isDuration(subInfo)) {
          _writeIndent(level + 1);
          buf.write(_formatDuration(readDuration(sub)));
        } else if (isWrapperType(subInfo)) {
          var valueFi = subInfo.fieldInfo[1]!;
          _writeIndent(level + 1);
          _writeScalar(valueFi, sub.getField(1));
        } else {
          _writeIndent(level + 1);
          buf.write('{\n');
          encodeMessage(sub, level + 2);
          _writeIndent(level + 1);
          buf.write('}');
        }
      } else {
        _writeIndent(level + 1);
        _writeScalar(fi, elem);
      }

      if (i < list.length - 1) {
        buf.write(',');
      }
      buf.write('\n');
    }

    _writeIndent(level);
    buf.write(']\n');
  }

  void _encodeMapField(FieldInfo fi, Map map, int level) {
    if (map.isEmpty && !emitDefaults) return;

    _writeFieldPrefix(level, fi.protoName);
    buf.write('{\n');

    // MapFieldInfo carries the actual value FieldInfo so we can route
    // through the same scalar / WKT / message paths the rest of the
    // encoder uses, rather than guessing from the runtime type.
    final FieldInfo? valueFi = fi is MapFieldInfo ? fi.valueFieldInfo : null;

    final keys = map.keys.toList()..sort((a, b) => '$a'.compareTo('$b'));

    for (final k in keys) {
      final v = map[k];
      _writeIndent(level + 1);
      buf.write(_formatMapKey(k));
      buf.write(': ');

      if (v is GeneratedMessage) {
        final subInfo = v.info_;
        if (isTimestamp(subInfo)) {
          buf.write(readTimestamp(v).toIso8601String());
          buf.write('\n');
        } else if (isDuration(subInfo)) {
          buf.write(_formatDuration(readDuration(v)));
          buf.write('\n');
        } else if (isWrapperType(subInfo)) {
          final innerFi = subInfo.fieldInfo[1]!;
          _writeScalar(innerFi, v.getField(1) as Object);
          buf.write('\n');
        } else {
          buf.write('{\n');
          encodeMessage(v, level + 2);
          _writeIndent(level + 1);
          buf.write('}\n');
        }
      } else if (valueFi != null && valueFi.type == PbFieldType.OE) {
        // Enum value: prefer name form (matches the decoder's enum-by-name
        // path). The protobuf-package APIs expose a valueOf for the
        // numeric → ProtobufEnum conversion.
        final lookup = valueFi.valueOf;
        if (lookup != null && v is int) {
          final ev = lookup(v);
          if (ev != null) {
            buf.write(ev.name);
            buf.write('\n');
            continue;
          }
        }
        buf.write(v?.toString() ?? '0');
        buf.write('\n');
      } else {
        _writeScalarValue(v as Object);
        buf.write('\n');
      }
    }

    _writeIndent(level);
    buf.write('}\n');
  }

  void _writeScalar(FieldInfo fi, Object val) {
    _writeScalarValue(val);
  }

  void _writeScalarValue(Object val) {
    if (val is String) {
      _writeQuotedString(val);
    } else if (val is bool) {
      buf.write(val ? 'true' : 'false');
    } else if (val is int || val is Int64) {
      buf.write(val.toString());
    } else if (val is double) {
      if (val.isInfinite) {
        buf.write(val.isNegative ? '-inf' : 'inf');
      } else if (val.isNaN) {
        buf.write('nan');
      } else {
        buf.write(val.toString());
      }
    } else if (val is List<int>) {
      buf.write('b"');
      buf.write(base64.encode(val));
      buf.write('"');
    } else if (val is ProtobufEnum) {
      buf.write(val.name);
    } else {
      buf.write(val.toString());
    }
  }

  void _writeQuotedString(String s) {
    buf.write('"');
    for (int i = 0; i < s.length; i++) {
      var char = s[i];
      switch (char) {
        case '"':
          buf.write(r'\"');
          break;
        case r'\':
          buf.write(r'\\');
          break;
        case '\n':
          buf.write(r'\n');
          break;
        case '\r':
          buf.write(r'\r');
          break;
        case '\t':
          buf.write(r'\t');
          break;
        default:
          var code = char.codeUnitAt(0);
          if (code < 0x20) {
            buf.write(r'\x');
            buf.write(code.toRadixString(16).padLeft(2, '0'));
          } else {
            buf.write(char);
          }
      }
    }
    buf.write('"');
  }

  String _formatMapKey(Object key) {
    if (key is String) {
      if (_isValidIdent(key)) return key;
      return '"$key"'; // TODO: proper quoting
    }
    return key.toString();
  }

  bool _isValidIdent(String s) {
    if (s.isEmpty || s == 'true' || s == 'false' || s == 'null') return false;
    final identRegex = RegExp(r'^[a-zA-Z_][a-zA-Z0-9._]*$');
    return identRegex.hasMatch(s);
  }

  String _formatBigInt(GeneratedMessage msg) {
    var absBytes = msg.getField(1) as List<int>;
    var negative = msg.getField(2) as bool;
    if (absBytes.isEmpty) return '0';
    var hex = absBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
    var val = BigInt.parse(hex, radix: 16);
    return negative ? '-$val' : '$val';
  }

  String _formatDecimal(GeneratedMessage msg) {
    var unscaledBytes = msg.getField(1) as List<int>;
    var scale = msg.getField(2) as int;
    var negative = msg.getField(3) as bool;
    
    String s;
    if (unscaledBytes.isEmpty) {
      s = '0';
    } else {
      var hex = unscaledBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
      s = BigInt.parse(hex, radix: 16).toString();
    }
    
    if (scale > 0) {
      if (s.length <= scale) {
        s = '0.${s.padLeft(scale, '0')}';
      } else {
        s = '${s.substring(0, s.length - scale)}.${s.substring(s.length - scale)}';
      }
    }
    return negative ? '-$s' : s;
  }

  String _formatDuration(Duration d) {
    // Ported from Go-style duration formatting if needed,
    // but for now use a simple version.
    if (d == Duration.zero) return '0s';
    var s = '';
    if (d.isNegative) {
      s += '-';
      d = -d;
    }
    var hours = d.inHours;
    if (hours > 0) s += '${hours}h';
    var minutes = d.inMinutes % 60;
    if (minutes > 0) s += '${minutes}m';
    var seconds = d.inSeconds % 60;
    var ms = d.inMilliseconds % 1000;
    if (ms > 0) {
        s += '${seconds}.${ms.toString().padLeft(3, '0')}s';
    } else if (seconds > 0 || s.isEmpty) {
        s += '${seconds}s';
    }
    return s;
  }
}

/// Marshals the provided [msg] into PXF text format.
/// 
/// Options can be provided via [options] to customize indentation and output.
String marshal(GeneratedMessage msg, {MarshalOptions? options}) {
  return (options ?? MarshalOptions()).marshal(msg);
}
