// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'dart:convert';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';
import 'annotations.dart';
import 'errors.dart';
import 'format.dart';
import 'keyed.dart';
import 'result.dart';
import 'token.dart' show Position;
import 'wellknown.dart';

class MarshalOptions {
  final String indent;
  final bool emitDefaults;
  final String? typeUrl;
  final TypeRegistry typeRegistry;
  final Result? nullFields;

  /// The schema's `(pxf.key)` options. With them a keyed repeated field is
  /// emitted in the keyed block form whenever it is eligible; generated
  /// messages carry no field options, so without them it never is.
  final PxfAnnotations? annotations;

  MarshalOptions({
    this.indent = '  ',
    this.emitDefaults = false,
    this.typeUrl,
    this.typeRegistry = const TypeRegistry.empty(),
    this.nullFields,
    this.annotations,
  });

  String marshal(GeneratedMessage msg) {
    var buf = StringBuffer();
    var enc = _Encoder(
      buf: buf,
      indent: indent,
      emitDefaults: emitDefaults,
      typeRegistry: typeRegistry,
      nullFields: nullFields,
      annotations: annotations,
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
  final TypeRegistry typeRegistry;
  final Result? nullFields;
  final PxfAnnotations? annotations;
  final Set<String>? nullSet = null; // TODO: implement nullSet from null_mask
  String pathPrefix = '';

  _Encoder({
    required this.buf,
    required this.indent,
    required this.emitDefaults,
    required this.typeRegistry,
    this.nullFields,
    this.annotations,
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

  /// [skipTag] is a field to leave out: the key field of a keyed-block
  /// entry, whose name already carries it.
  void encodeMessage(GeneratedMessage msg, int level, {int? skipTag}) {
    var info = msg.info_;
    // Sort fields by tag number to ensure deterministic output
    var fieldNumbers = info.fieldInfo.keys.toList()..sort();

    for (var tag in fieldNumbers) {
      if (tag == skipTag) continue;
      var fi = info.fieldInfo[tag]!;

      // Skip _null field
      if (fi.protoName == '_null' && pathPrefix == '') continue;

      var path = '$pathPrefix${fi.protoName}';

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
        _encodeListField(info, fi, val as List, level);
        continue;
      }

      if (fi.type == PbFieldType.OM) {
        if (!msg.hasField(tag)) continue;
        _encodeMessageField(fi, val as GeneratedMessage, level);
        continue;
      }

      _writeFieldPrefix(level, fi.protoName);
      _writeScalar(fi, val);
      buf.write('\n');
    }
  }

  void _encodeMessageField(FieldInfo fi, GeneratedMessage sub, int level) {
    var subInfo = sub.info_;

    if (isTimestamp(subInfo)) {
      var t = readTimestamp(sub);
      _writeFieldPrefix(level, fi.protoName);
      buf.write(t.toIso8601String());
      buf.write('\n');
      return;
    }
    if (isDuration(subInfo)) {
      var d = readDuration(sub);
      _writeFieldPrefix(level, fi.protoName);
      buf.write(_formatDuration(d));
      buf.write('\n');
      return;
    }
    if (isWrapperType(subInfo)) {
      var valueFi = subInfo.fieldInfo[1]!;
      _writeFieldPrefix(level, fi.protoName);
      _writeScalar(valueFi, sub.getField(1));
      buf.write('\n');
      return;
    }

    if (isBigInt(subInfo)) {
      _writeFieldPrefix(level, fi.protoName);
      buf.write(_formatBigInt(sub));
      buf.write('\n');
      return;
    }
    if (isDecimal(subInfo)) {
      _writeFieldPrefix(level, fi.protoName);
      buf.write(_formatDecimal(sub));
      buf.write('\n');
      return;
    }

    // TODO: BigInt, Decimal, BigFloat, Any

    _writeIndent(level);
    buf.write('${fi.protoName} {\n');
    var oldPrefix = pathPrefix;
    pathPrefix = '$oldPrefix${fi.protoName}.';
    encodeMessage(sub, level + 1);
    pathPrefix = oldPrefix;
    _writeIndent(level);
    buf.write('}\n');
  }

  void _encodeListField(BuilderInfo owner, FieldInfo fi, List list, int level) {
    if (list.isEmpty && !emitDefaults) return;

    // Elements with absent or duplicate keys can only be written anonymously.
    final keyFi = keyFieldOf(annotations, owner, fi);
    if (keyFi != null && list.isNotEmpty && _keyedFormEligible(list, keyFi)) {
      _encodeKeyedList(fi, list, keyFi, level);
      return;
    }

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

  bool _keyedFormEligible(List list, FieldInfo keyFi) {
    final seen = <String>{};
    for (final elem in list) {
      final key = (elem as GeneratedMessage).getField(keyFi.tagNumber);
      if (key == '' || !seen.add(key as String)) return false;
    }
    return true;
  }

  /// One named block per element, in list order; the name is unquoted when
  /// identifier-safe, and the key is not repeated inside the block.
  void _encodeKeyedList(FieldInfo fi, List list, FieldInfo keyFi, int level) {
    _writeIndent(level);
    buf.write('${fi.protoName} {\n');
    for (final elem in list) {
      final sub = elem as GeneratedMessage;
      final key = sub.getField(keyFi.tagNumber) as String;
      _writeIndent(level + 1);
      if (isIdentSafeEntryName(key)) {
        buf.write(key);
      } else {
        _writeQuotedString(key);
      }
      buf.write(' {\n');
      encodeMessage(sub, level + 2, skipTag: keyFi.tagNumber);
      _writeIndent(level + 1);
      buf.write('}\n');
    }
    _writeIndent(level);
    buf.write('}\n');
  }

  void _encodeMapField(FieldInfo fi, Map map, int level) {
    if (map.isEmpty && !emitDefaults) return;

    _writeFieldPrefix(level, fi.protoName);
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

  void _writeQuotedString(String s) => buf.write(quotePxfString(s));

  String _formatMapKey(Object key) {
    if (key is String) {
      if (_isValidIdent(key)) return key;
      return '"$key"'; // TODO: proper quoting
    }
    return key.toString();
  }

  bool _isValidIdent(String s) => isIdentSafeEntryName(s);

  String _formatBigInt(GeneratedMessage msg) {
    var absBytes = msg.getField(1) as List<int>;
    var negative = msg.getField(2) as bool;
    if (absBytes.isEmpty) return '0';
    var hex = absBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
    var val = BigInt.parse(hex, radix: 16);
    return _boundLiteral('pxf.BigInt', negative ? '-$val' : '$val');
  }

  /// value = unscaled × 10^(-scale). The scale is four bytes whoever wrote
  /// the message chose, so it is bounded before any work, on both signs
  /// (HARDENING.md § Arbitrary-precision magnitudes). A positive scale places
  /// the point, and a negative one means trailing zeros: 5 at -2 is 500.
  String _formatDecimal(GeneratedMessage msg) {
    var unscaledBytes = msg.getField(1) as List<int>;
    var scale = msg.getField(2) as int;
    var negative = msg.getField(3) as bool;

    if (scale.abs() > maxNumericLiteralDigits) {
      throw PxfError(Position(1, 1),
          'pxf.Decimal scale $scale exceeds MaxNumericLiteralDigits=$maxNumericLiteralDigits');
    }

    String s;
    if (unscaledBytes.isEmpty) {
      s = '0';
    } else {
      var hex = unscaledBytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join('');
      s = BigInt.parse(hex, radix: 16).toString();
    }

    if (scale > 0) {
      if (s.length <= scale) {
        s = '0.${s.padLeft(scale, '0')}';
      } else {
        s = '${s.substring(0, s.length - scale)}.${s.substring(s.length - scale)}';
      }
    } else if (scale < 0 && s != '0') {
      s = s + '0' * -scale;
    }
    return _boundLiteral('pxf.Decimal', negative ? '-$s' : s);
  }

  /// A producer never writes a value past a bound. Leading zeros are not
  /// significant, so `0.000…5` at the largest scale counts one digit.
  String _boundLiteral(String kind, String literal) {
    if (literal.length <= maxNumericLiteralDigits) return literal;
    var n = 0;
    for (final c in literal.codeUnits) {
      if (c < 0x30 || c > 0x39 || (n == 0 && c == 0x30)) continue;
      n++;
    }
    if (n > maxNumericLiteralDigits) {
      throw PxfError(Position(1, 1),
          '$kind renders to $n digits; MaxNumericLiteralDigits=$maxNumericLiteralDigits');
    }
    return literal;
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
      s += '$seconds.${ms.toString().padLeft(3, '0')}s';
    } else if (seconds > 0 || s.isEmpty) {
      s += '${seconds}s';
    }
    return s;
  }
}

/// Marshals the provided [msg] into PXF text format.
///
/// Options can be provided via [options] to customize indentation and output.
/// With [MarshalOptions.annotations] the schema's keyed repeated fields are
/// emitted in their block form:
///
/// ```dart
/// final ann = PxfAnnotations.fromBytes(descriptorSetBytes);
/// marshal(node, options: MarshalOptions(annotations: ann));
/// ```
String marshal(GeneratedMessage msg, {MarshalOptions? options}) {
  return (options ?? MarshalOptions()).marshal(msg);
}
