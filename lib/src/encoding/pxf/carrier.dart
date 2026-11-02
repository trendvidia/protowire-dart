// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// The schema-extension annotation carrier (RFC-001 §8.1). `@required` and
// `@default(v)` lower to one AnnotationList on extension 1327 of the field's
// options, not to the 1314 / 1315 the bracket spelling uses, and a compiler
// never writes both for one annotation. A reader of the bracket options alone
// sees nothing on such a schema.
//
// 1327 is not in the extension registry, so its bytes arrive as unknown fields
// and are walked here. The shape is small and frozen by STABILITY.md promise
// 3. Mirrors protowire-go's encoding/pxf/carrier.go.
import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';

import '../../generated/proto/google/protobuf/descriptor.pb.dart' as pbd;
import 'bigfloat.dart';
import 'lexer.dart' show maxNumericLiteralDigits;

/// The carrier's extension number.
const extAnnotations = 1327;

const _annotationRequired = 'protowire.schema.v1.required';
const _annotationDefault = 'protowire.schema.v1.default';

const _fnListEntries = 1; // AnnotationList.entries
const _fnAnnotationName = 1; // Annotation.name
const _fnAnnotationArgs = 2; // Annotation.args
const _fnArgName = 1; // AnnotationArg.name
const _fnArgStringValue = 10;
const _fnArgIntValue = 11;
const _fnArgDoubleValue = 12;
const _fnArgBoolValue = 13;
const _fnArgBytesValue = 14;
const _fnArgLiteral = 15;
const _fnArgBigIntValue = 16;
const _fnArgDecimalValue = 17;
const _fnArgBigFloatValue = 18;
const _fnLiteralEnumValue = 1; // Literal.enum_value
const _fnEnumValueName = 2; // EnumLiteral.value_name

const _defaultParamName = 'value';

const _wireVarint = 0;
const _wireFixed64 = 1;
const _wireBytes = 2;
const _wireFixed32 = 5;

/// What the carrier says about one field. Annotations this binder does not
/// act on (`@validate`, `@description`, ...) are skipped.
class CarrierOptions {
  bool required = false;

  /// `@default`'s argument as the literal the bracket form would carry.
  String? defaultLiteral;

  /// Why a `@default` the field does carry reduces to no literal. Reported at
  /// bind, never dropped: dropping it is silent non-enforcement.
  String? defaultProblem;
}

/// One field of a protobuf message.
class _Field {
  final int number;
  final int wireType;

  /// The payload of a varint or fixed field.
  final Int64 scalar;

  /// The payload of a length-delimited field.
  final List<int>? bytes;

  _Field(this.number, this.wireType, this.scalar, this.bytes);
}

/// The fields of [b]. Truncated or unreadable bytes stop the walk and keep
/// what came before: reporting a schema as unannotated because its last entry
/// was garbled is the silent non-enforcement this path exists to remove.
List<_Field> _fields(List<int> b) {
  final out = <_Field>[];
  final r = CodedBufferReader(b, sizeLimit: b.length);
  try {
    while (!r.isAtEnd()) {
      final tag = r.readTag();
      final number = tag >> 3;
      switch (tag & 7) {
        case _wireVarint:
          out.add(_Field(number, _wireVarint, r.readUint64(), null));
        case _wireFixed64:
          out.add(_Field(number, _wireFixed64, r.readFixed64(), null));
        case _wireBytes:
          out.add(_Field(number, _wireBytes, Int64.ZERO, r.readBytes()));
        case _wireFixed32:
          out.add(_Field(number, _wireFixed32, Int64(r.readFixed32()), null));
        default:
          return out;
      }
    }
  } on InvalidProtocolBufferException {
    return out;
  }
  return out;
}

/// The carrier payloads on [options], merged: a message field split across
/// occurrences concatenates, and AnnotationList holds only a repeated field.
List<int> carrierBytes(pbd.FieldOptions options) {
  final field = options.unknownFields.getField(extAnnotations);
  if (field == null) return const [];
  return [for (final part in field.lengthDelimited) ...part];
}

/// Picks `@required` and `@default` out of an AnnotationList. [fd] decides how
/// a typed `@default` argument reads as a literal.
CarrierOptions parseAnnotationList(List<int> b, pbd.FieldDescriptorProto fd) {
  final got = CarrierOptions();
  for (final f in _fields(b)) {
    if (f.number == _fnListEntries && f.bytes != null) {
      _applyAnnotation(got, f.bytes!, fd);
    }
  }
  return got;
}

void _applyAnnotation(
    CarrierOptions got, List<int> b, pbd.FieldDescriptorProto fd) {
  String? name;
  final args = <List<int>>[];
  for (final f in _fields(b)) {
    if (f.number == _fnAnnotationName && f.bytes != null) {
      name = utf8.decode(f.bytes!, allowMalformed: true);
    } else if (f.number == _fnAnnotationArgs && f.bytes != null) {
      args.add(f.bytes!);
    }
  }
  if (name == _annotationRequired) {
    got.required = true;
  } else if (name == _annotationDefault) {
    // The first @default wins; a second is the compiler's to reject.
    if (got.defaultLiteral != null || got.defaultProblem != null) return;
    final arg = _defaultArg(args);
    if (arg == null) {
      got.defaultProblem = '@default carries no value argument';
      return;
    }
    final (literal, problem) = _argLiteral(arg, fd);
    got.defaultLiteral = literal;
    got.defaultProblem = problem;
  }
}

/// The first positional argument, or the first named `value`.
List<int>? _defaultArg(List<List<int>> args) {
  for (final a in args) {
    final name = _argName(a);
    if (name.isEmpty || name == _defaultParamName) return a;
  }
  return null;
}

String _argName(List<int> b) {
  for (final f in _fields(b)) {
    if (f.number == _fnArgName && f.bytes != null) {
      return utf8.decode(f.bytes!, allowMalformed: true);
    }
  }
  return '';
}

bool _unsignedTarget(pbd.FieldDescriptorProto fd) {
  switch (fd.type) {
    case pbd.FieldDescriptorProto_Type.TYPE_UINT32:
    case pbd.FieldDescriptorProto_Type.TYPE_UINT64:
    case pbd.FieldDescriptorProto_Type.TYPE_FIXED32:
    case pbd.FieldDescriptorProto_Type.TYPE_FIXED64:
      return true;
    default:
      return fd.typeName == '.google.protobuf.UInt32Value' ||
          fd.typeName == '.google.protobuf.UInt64Value';
  }
}

/// An AnnotationArg as the literal the bracket form carries, so everything
/// downstream is shared between the two spellings. Returns the literal or
/// the reason there is none.
(String?, String?) _argLiteral(List<int> b, pbd.FieldDescriptorProto fd) {
  for (final f in _fields(b)) {
    switch (f.number) {
      case _fnArgStringValue when f.bytes != null:
        return (utf8.decode(f.bytes!, allowMalformed: true), null);
      case _fnArgIntValue when f.wireType == _wireVarint:
        return (
          _unsignedTarget(fd)
              ? f.scalar.toStringUnsigned()
              : f.scalar.toString(),
          null
        );
      case _fnArgDoubleValue when f.wireType == _wireFixed64:
        return (_doubleLiteral(f.scalar, fd), null);
      case _fnArgBoolValue when f.wireType == _wireVarint:
        return (f.scalar.isZero ? 'false' : 'true', null);
      case _fnArgBytesValue when f.bytes != null:
        return (base64.encode(f.bytes!), null);
      case _fnArgBigIntValue when f.bytes != null:
        return _bigIntLiteral(f.bytes!);
      case _fnArgDecimalValue when f.bytes != null:
        return _decimalLiteral(f.bytes!);
      case _fnArgBigFloatValue when f.bytes != null:
        return _bigFloatArg(f.bytes!);
      case _fnArgLiteral when f.bytes != null:
        return _literalValue(f.bytes!);
    }
  }
  return (null, "@default's value is empty");
}

/// A Literal: only a resolved enum reference has a single-literal form.
(String?, String?) _literalValue(List<int> b) {
  for (final f in _fields(b)) {
    if (f.number != _fnLiteralEnumValue || f.bytes == null) continue;
    for (final e in _fields(f.bytes!)) {
      if (e.number == _fnEnumValueName && e.bytes != null) {
        return (utf8.decode(e.bytes!, allowMalformed: true), null);
      }
    }
    return (
      null,
      '@default names an enum value the lowering pass left unresolved'
    );
  }
  return (
    null,
    '@default carries a message or list literal, and a default is exactly one literal'
  );
}

/// A double_value as a literal. The arbitrary-precision targets take
/// positional notation only, so an exponent must not appear for them.
String _doubleLiteral(Int64 bits, pbd.FieldDescriptorProto fd) {
  final bytes = Uint8List.fromList(bits.toBytes());
  final d = ByteData.sublistView(bytes).getFloat64(0, Endian.little);
  final positional =
      fd.typeName == '.pxf.BigInt' || fd.typeName == '.pxf.Decimal';
  if (!positional) return _shortest(d);
  if (d == d.truncateToDouble() && d.isFinite) return BigInt.from(d).toString();
  return _shortest(d);
}

String _shortest(double d) {
  final s = d.toString();
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}

BigInt _magnitude(List<int> bytes) {
  var v = BigInt.zero;
  for (final byte in bytes) {
    v = (v << 8) | BigInt.from(byte);
  }
  return v;
}

/// pxf.BigInt{abs=1, negative=2}.
(String?, String?) _bigIntLiteral(List<int> b) {
  var abs = BigInt.zero;
  var negative = false;
  for (final f in _fields(b)) {
    if (f.number == 1 && f.bytes != null) abs = _magnitude(f.bytes!);
    if (f.number == 2 && f.wireType == _wireVarint) {
      negative = !f.scalar.isZero;
    }
  }
  return ((negative ? -abs : abs).toString(), null);
}

/// pxf.BigFloat{mantissa=1, exponent=2, prec=3, negative=4}.
(String?, String?) _bigFloatArg(List<int> b) {
  var mantissa = const <int>[];
  var exponent = 0;
  var prec = 0;
  var negative = false;
  for (final f in _fields(b)) {
    if (f.number == 1 && f.bytes != null) mantissa = f.bytes!;
    if (f.number == 2 && f.wireType == _wireVarint) {
      exponent = f.scalar.toInt32().toInt();
    }
    if (f.number == 3 && f.wireType == _wireVarint) prec = f.scalar.toInt();
    if (f.number == 4 && f.wireType == _wireVarint) {
      negative = !f.scalar.isZero;
    }
  }
  try {
    return (bigFloatLiteral(mantissa, exponent, prec, negative), null);
  } on FormatException catch (e) {
    return (null, "@default's big_float_value: ${e.message}");
  }
}

/// pxf.Decimal{unscaled=1, scale=2, negative=3}. The scale is bounded before
/// any work: five bytes of descriptor must not build 10^(2^31).
(String?, String?) _decimalLiteral(List<int> b) {
  var unscaled = BigInt.zero;
  var scale = 0;
  var negative = false;
  for (final f in _fields(b)) {
    if (f.number == 1 && f.bytes != null) unscaled = _magnitude(f.bytes!);
    if (f.number == 2 && f.wireType == _wireVarint) {
      scale = f.scalar.toInt32().toInt();
    }
    if (f.number == 3 && f.wireType == _wireVarint) {
      negative = !f.scalar.isZero;
    }
  }
  if (scale > maxNumericLiteralDigits || scale < -maxNumericLiteralDigits) {
    return (
      null,
      "@default's decimal_value has scale $scale, and "
          'MaxNumericLiteralDigits=$maxNumericLiteralDigits bounds its magnitude'
    );
  }
  final sign = negative ? '-' : '';
  if (scale <= 0) {
    return ('$sign${unscaled * BigInt.from(10).pow(-scale)}', null);
  }
  final digits = unscaled.toString().padLeft(scale + 1, '0');
  final split = digits.length - scale;
  return (
    '$sign${digits.substring(0, split)}.${digits.substring(split)}',
    null
  );
}
