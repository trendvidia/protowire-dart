import 'dart:convert';
import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';
import 'options.dart';
import 'result.dart';
import 'wellknown.dart';

class MarshalOptions {
  final String indent;
  final bool emitDefaults;
  final String? typeUrl;
  final TypeResolver? typeResolver;
  final Result? nullFields;

  MarshalOptions({
    this.indent = '  ',
    this.emitDefaults = false,
    this.typeUrl,
    this.typeResolver,
    this.nullFields,
  });

  String marshal(GeneratedMessage msg) {
    var buf = StringBuffer();
    var enc = _Encoder(
      buf: buf,
      indent: indent,
      emitDefaults: emitDefaults,
      resolver: typeResolver,
      nullFields: nullFields,
    );

    // TODO: null_mask discovery

    if (typeUrl != null && typeUrl!.isNotEmpty) {
      buf.write('@type $typeUrl\n\n');
    }

    enc.encodeMessage(msg, 0);
    return buf.toString();
  }
}

class _Encoder {
  final StringBuffer buf;
  final String indent;
  final bool emitDefaults;
  final TypeResolver? resolver;
  final Result? nullFields;
  final Set<String>? nullSet = null; // TODO: implement nullSet from null_mask
  String pathPrefix = '';

  _Encoder({
    required this.buf,
    required this.indent,
    required this.emitDefaults,
    this.resolver,
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
      
      // Skip _null field
      if (fi.name == '_null' && pathPrefix == '') continue;

      var path = '$pathPrefix${fi.name}';
      
      // TODO: Handle nullSet/nullFields

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

      _writeFieldPrefix(level, fi.name);
      _writeScalar(fi, val);
      buf.write('\n');
    }
  }

  void _encodeMessageField(FieldInfo fi, GeneratedMessage sub, int level) {
    var subInfo = sub.info_;

    if (isTimestamp(subInfo)) {
      var t = readTimestamp(sub);
      _writeFieldPrefix(level, fi.name);
      buf.write(t.toIso8601String());
      buf.write('\n');
      return;
    }
    if (isDuration(subInfo)) {
      var d = readDuration(sub);
      _writeFieldPrefix(level, fi.name);
      buf.write(_formatDuration(d));
      buf.write('\n');
      return;
    }
    if (isWrapperType(subInfo)) {
      var valueFi = subInfo.fieldInfo[1]!;
      _writeFieldPrefix(level, fi.name);
      _writeScalar(valueFi, sub.getField(1));
      buf.write('\n');
      return;
    }

    // TODO: BigInt, Decimal, BigFloat, Any

    _writeIndent(level);
    buf.write('${fi.name} {\n');
    var oldPrefix = pathPrefix;
    pathPrefix = '$oldPrefix${fi.name}.';
    encodeMessage(sub, level + 1);
    pathPrefix = oldPrefix;
    _writeIndent(level);
    buf.write('}\n');
  }

  void _encodeListField(FieldInfo fi, List list, int level) {
    if (list.isEmpty && !emitDefaults) return;

    _writeFieldPrefix(level, fi.name);
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

    _writeFieldPrefix(level, fi.name);
    buf.write('{\n');

    var keys = map.keys.toList()..sort();

    for (var k in keys) {
      var v = map[k];
      _writeIndent(level + 1);
      buf.write(_formatMapKey(k));
      buf.write(': ');
      
      // In Dart GeneratedMessage, map values are usually handled via subBuilder if they are messages.
      // But FieldInfo for maps is a bit special.
      if (v is GeneratedMessage) {
        buf.write('{\n');
        encodeMessage(v, level + 2);
        _writeIndent(level + 1);
        buf.write('}\n');
      } else {
        // Need to know value type. For simplicity, assume it's a scalar if not GeneratedMessage.
        // This is a bit of a hack without MapFieldInfo.
        _writeScalarValue(v);
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

String marshal(GeneratedMessage msg, {MarshalOptions? options}) {
  return (options ?? MarshalOptions()).marshal(msg);
}
