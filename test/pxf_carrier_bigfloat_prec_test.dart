// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// `@default`'s big_float_value.prec is a uint32 on the wire: a reader keeps
// its low 32 bits, as protowire-go and the stock protobuf readers do. Before
// this, 2^63 + 53 read as a negative int, got past the prec bound and ran the
// VM out of memory (protowire-dart#72). Prec 0 declares no precision, which
// protowire-go reports as a problem rather than a literal.
import 'package:protowire/src/encoding/pxf/carrier.dart';
import 'package:protowire/src/generated/proto/google/protobuf/descriptor.pb.dart'
    as pbd;
import 'package:test/test.dart';

List<int> _varint(BigInt v) {
  final out = <int>[];
  while (v >= BigInt.from(0x80)) {
    out.add((v & BigInt.from(0x7f)).toInt() | 0x80);
    v >>= 7;
  }
  out.add(v.toInt());
  return out;
}

List<int> _tag(int number, int wire) =>
    _varint(BigInt.from(number << 3 | wire));

List<int> _len(int number, List<int> body) =>
    [..._tag(number, 2), ..._varint(BigInt.from(body.length)), ...body];

/// An AnnotationList holding `@default` with a big_float_value of mantissa
/// 0x19, exponent -3 (3.125) and the given prec.
List<int> _carrier(BigInt prec) {
  final bigFloat = [
    ..._len(1, [0x19]), // mantissa
    ..._tag(2, 0), ..._varint(BigInt.from(-3).toUnsigned(64)), // exponent
    ..._tag(3, 0), ..._varint(prec), // prec
  ];
  final arg = _len(18, bigFloat); // AnnotationArg.big_float_value
  final annotation = [
    ..._len(1, 'protowire.schema.v1.default'.codeUnits),
    ..._len(2, arg),
  ];
  return _len(1, annotation); // AnnotationList.entries
}

void main() {
  final fd = pbd.FieldDescriptorProto()
    ..name = 'v'
    ..type = pbd.FieldDescriptorProto_Type.TYPE_MESSAGE
    ..typeName = '.pxf.BigFloat';
  final two = BigInt.two;

  // wire prec -> the literal, or null where the problem is pinned instead.
  final rows = <String, (BigInt, String?)>{
    '53': (BigInt.from(53), '3.125p53'),
    '2^32 + 53 keeps the low 32 bits': (
      two.pow(32) + BigInt.from(53),
      '3.125p53'
    ),
    '2^63 + 53 keeps the low 32 bits': (
      two.pow(63) + BigInt.from(53),
      '3.125p53'
    ),
  };
  rows.forEach((name, row) {
    test('prec $name', () {
      final got = parseAnnotationList(_carrier(row.$1), fd);
      expect(got.defaultProblem, isNull);
      expect(got.defaultLiteral, row.$2);
    });
  });

  for (final (name, prec) in [
    ('0', BigInt.zero),
    ('2^32, which is 0 in 32 bits', two.pow(32)),
  ]) {
    test('prec $name declares no precision', () {
      final got = parseAnnotationList(_carrier(prec), fd);
      expect(got.defaultLiteral, isNull);
      expect(got.defaultProblem,
          "@default's big_float_value declares no precision");
    });
  }
}
