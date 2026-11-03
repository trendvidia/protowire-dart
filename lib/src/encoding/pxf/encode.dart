// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'dart:convert';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';
import '../pb/depth.dart';
import 'annotations.dart';
import 'bigfloat.dart';
import 'duration.dart';
import 'errors.dart';
import 'format.dart';
import 'decode.dart' show unmarshalFull;
import 'keyed.dart';
import 'options.dart';
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

  /// The deepest document this writes, counted as a decoder reading it counts
  /// (HARDENING.md § Recursion, protowire#502): every `{` and `[`, so a map's
  /// braces and a list's brackets each count. Past it [marshal] throws a
  /// [PxfError] rather than write what a reader at the same limit refuses.
  /// Raise it only where every reader takes the deeper document.
  final int maxNestingDepth;

  MarshalOptions({
    this.indent = '  ',
    this.emitDefaults = false,
    this.typeUrl,
    this.typeRegistry = const TypeRegistry.empty(),
    this.nullFields,
    this.annotations,
    this.maxNestingDepth = defaultMaxNestingDepth,
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
      maxDepth: maxNestingDepth,
    );

    // TODO: null_mask discovery

    if (typeUrl != null && typeUrl!.isNotEmpty) {
      buf.write('@type $typeUrl\n\n');
    }

    enc.encodeMessage(msg, 0);
    return buf.toString();
  }
}

/// MaxNestingDepth's default, the draft's: 100 descents from the root.
const int defaultMaxNestingDepth = 100;

class _Encoder {
  final StringBuffer buf;
  final String indent;
  final bool emitDefaults;
  final TypeRegistry typeRegistry;
  final Result? nullFields;
  final PxfAnnotations? annotations;
  final int maxDepth;
  final Set<String>? nullSet = null; // TODO: implement nullSet from null_mask
  String pathPrefix = '';

  _Encoder({
    required this.buf,
    required this.indent,
    required this.emitDefaults,
    required this.typeRegistry,
    this.nullFields,
    this.annotations,
    required this.maxDepth,
  });

  /// Called before writing a `{` or `[` whose inside is at [depth]. The indent
  /// level is the count of brackets open, which is what a decoder counts.
  /// A message that holds itself meets this too, rather than the stack's end.
  void _descend(int depth) {
    if (depth > maxDepth) {
      throw PxfError(
          Position(1, 1), 'nesting depth exceeds MaxNestingDepth=$maxDepth');
    }
  }

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

    if (_hasLiteral(subInfo)) {
      _writeFieldPrefix(level, fi.protoName);
      _writeLiteral(sub);
      buf.write('\n');
      return;
    }

    if (isAny(subInfo) && _encodeAnyBody(fi, sub, level)) return;

    _descend(level + 1);
    _writeIndent(level);
    buf.write('${fi.protoName} {\n');
    var oldPrefix = pathPrefix;
    pathPrefix = '$oldPrefix${fi.protoName}.';
    encodeMessage(sub, level + 1);
    pathPrefix = oldPrefix;
    _writeIndent(level);
    buf.write('}\n');
  }

  /// Writes [any] as a type entry and a body of the type it names (draft -01
  /// "Any Blocks"), or returns false, having written nothing, for the block
  /// of its own fields, type_url and value. A reader compares an Any by its
  /// bytes, so the body is written only when reading it gives back exactly
  /// the stored value (protowire#501). The reader is asked: the body is
  /// rendered at its real depth, decoded with this writer's registry and
  /// annotations, the `@default` and `@required` pass included, and packed.
  /// That covers what a body cannot say (unknown fields, field order,
  /// explicit zeros, a Timestamp no literal holds) and what a reader adds
  /// (an unset `@default`, a missing `@required`). Without
  /// [MarshalOptions.annotations] the last two are invisible here, since a
  /// generated class carries no field options.
  ///
  /// An Any at the depth limit is not unpacked, and a body nested past it is
  /// left raw, so a chain of Anys comes out readable.
  ///
  /// Only a singular field gets here: the reference writes a list element or
  /// a map value of type Any as its own fields, even with a registry.
  bool _encodeAnyBody(FieldInfo fi, GeneratedMessage any, int level) {
    final typeUrl = any.getField(1) as String;
    if (typeUrl.isEmpty || level >= maxDepth) return false;
    final innerInfo = typeRegistry.lookup(anyTypeName(typeUrl));
    if (innerInfo == null) return false;

    final value = any.getField(2) as List<int>;
    final inner = innerInfo.createEmptyInstance!();
    try {
      mergeFromBufferChecked(inner, value);
    } on InvalidProtocolBufferException {
      return false;
    }
    // Cheap first: a value package:protobuf writes back differently (field
    // order, explicit zeros) cannot read back either.
    if (!_sameBytes(inner.writeToBuffer(), value)) return false;
    if (_holdsWrittenZero(inner)) return false;

    final body = _Encoder(
      buf: StringBuffer(),
      indent: indent,
      emitDefaults: emitDefaults,
      typeRegistry: typeRegistry,
      nullFields: nullFields,
      annotations: annotations,
      maxDepth: maxDepth,
    )..pathPrefix = '$pathPrefix${fi.protoName}.';
    try {
      body.encodeMessage(inner, level + 1);
    } on PxfError {
      return false; // past the depth limit, or a value no literal holds
    }
    final text = body.buf.toString();
    if (!_readsBack(text, innerInfo, value)) return false;

    _writeIndent(level);
    buf.write('${fi.protoName} {\n');
    _writeIndent(level + 1);
    buf.write('@type = ');
    _writeQuotedString(typeUrl);
    buf.write('\n');
    buf.write(text);
    _writeIndent(level);
    buf.write('}\n');
    return true;
  }

  /// Whether [msg], or a message under it, has a singular scalar field
  /// present at its zero value. This port's reader packs such a field back
  /// as written, but a reader that knows the field has no presence (proto3
  /// without `optional`) drops it, and a generated class does not say which
  /// the field is. Writing the Any raw is right for both.
  static bool _holdsWrittenZero(GeneratedMessage msg) {
    final info = msg.info_;
    for (final fi in info.fieldInfo.values) {
      if (!msg.hasField(fi.tagNumber)) continue;
      final val = msg.getField(fi.tagNumber);
      if (val is GeneratedMessage) {
        if (_holdsWrittenZero(val)) return true;
      } else if (val is Map) {
        if (val.values
            .any((v) => v is GeneratedMessage && _holdsWrittenZero(v))) {
          return true;
        }
      } else if (val is List && fi.isRepeated) {
        if (val.any((v) => v is GeneratedMessage && _holdsWrittenZero(v))) {
          return true;
        }
      } else if (_isZero(val)) {
        return true;
      }
    }
    return false;
  }

  static bool _isZero(Object? v) => switch (v) {
        String s => s.isEmpty,
        bool b => !b,
        int i => i == 0,
        Int64 i => i.isZero,
        double d => d == 0 && !d.isNegative,
        List<int> b => b.isEmpty,
        ProtobufEnum e => e.value == 0,
        _ => false,
      };

  /// Whether [body], an Any body's entries, decodes to exactly [want]. Depth
  /// is the encoder's to bound: [body] was rendered at its real level.
  bool _readsBack(String body, BuilderInfo info, List<int> want) {
    final back = info.createEmptyInstance!();
    try {
      unmarshalFull(body, back,
          options: UnmarshalOptions(
              typeRegistry: typeRegistry, annotations: annotations));
    } on PxfError {
      return false;
    } on FormatException {
      return false;
    }
    return _sameBytes(back.writeToBuffer(), want);
  }

  static bool _sameBytes(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _encodeListField(BuilderInfo owner, FieldInfo fi, List list, int level) {
    if (list.isEmpty && !emitDefaults) return;

    // Elements with absent or duplicate keys can only be written anonymously.
    final keyFi = keyFieldOf(annotations, owner, fi);
    if (keyFi != null && list.isNotEmpty && _keyedFormEligible(list, keyFi)) {
      _encodeKeyedList(fi, list, keyFi, level);
      return;
    }

    _descend(level + 1);
    _writeFieldPrefix(level, fi.protoName);
    buf.write('[\n');

    for (int i = 0; i < list.length; i++) {
      var elem = list[i];
      if (fi.type == PbFieldType.PM || fi.type == PbFieldType.OM) {
        var sub = elem as GeneratedMessage;
        var subInfo = sub.info_;

        if (_hasLiteral(subInfo)) {
          _writeIndent(level + 1);
          _writeLiteral(sub);
        } else {
          _descend(level + 2);
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
    _descend(level + 2); // the field's block and an entry's
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

  /// Whether a message of this type is written as one literal.
  bool _hasLiteral(BuilderInfo info) =>
      isTimestamp(info) ||
      isDuration(info) ||
      isWrapperType(info) ||
      isBigInt(info) ||
      isDecimal(info) ||
      isBigFloat(info);

  void _writeLiteral(GeneratedMessage sub) {
    final info = sub.info_;
    if (isTimestamp(info)) {
      buf.write(formatTimestamp(sub));
    } else if (isDuration(info)) {
      buf.write(formatGoDuration(readDurationNanos(sub)));
    } else if (isWrapperType(info)) {
      _writeScalar(info.fieldInfo[1]!, sub.getField(1));
    } else if (isBigInt(info)) {
      buf.write(_formatBigInt(sub));
    } else if (isDecimal(info)) {
      buf.write(_formatDecimal(sub));
    } else {
      buf.write(_formatBigFloat(sub));
    }
  }

  void _encodeMapField(FieldInfo fi, Map map, int level) {
    if (map.isEmpty && !emitDefaults) return;

    _descend(level + 1);
    _writeFieldPrefix(level, fi.protoName);
    buf.write('{\n');

    // By the key as written, as the reference orders them: "10" before "9",
    // and a quoted key before a bare one.
    final byText = {for (final k in map.keys) _formatMapKey(k as Object): k};
    final ordered = byText.keys.toList()..sort();

    for (final text in ordered) {
      var v = map[byText[text]];
      _writeIndent(level + 1);
      buf.write(text);
      buf.write(': ');

      // In Dart GeneratedMessage, map values are usually handled via subBuilder if they are messages.
      // But FieldInfo for maps is a bit special.
      if (v is GeneratedMessage && _hasLiteral(v.info_)) {
        _writeLiteral(v);
        buf.write('\n');
      } else if (v is GeneratedMessage) {
        _descend(level + 2);
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
      return quotePxfString(key);
    }
    return key.toString();
  }

  bool _isValidIdent(String s) => isIdentSafeEntryName(s);

  String _formatBigFloat(GeneratedMessage msg) {
    try {
      return bigFloatLiteral(
          msg.getField(1) as List<int>,
          msg.getField(2) as int,
          msg.getField(3) as int,
          msg.getField(4) as bool);
    } on FormatException catch (e) {
      throw PxfError(Position(1, 1), e.message);
    }
  }

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
