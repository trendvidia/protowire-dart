// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// An enum number the enum does not declare (protowire-dart#82, decided by the
// owner 2026-11-03). protowire-go keeps it. A generated Dart enum has no
// instance for it, so a singular field keeps it in the message's unknown
// fields, as package:protobuf does when it reads binary, and `marshal` writes
// it back as the number. A list element or map value is refused: the number
// would be written after the declared ones, out of order.
//
// Expected bytes and text are protowire-go's, from the spec's write gate
// (testdata/write/golden/Scalars.enum-unknown.binpb) and text gate
// (testdata/text/cases/Scalars.enum-unknown.expected.pxf).
import 'package:protowire/protowire.dart';
import 'package:test/test.dart';

import '../bin/text.pb.dart' as text;

String hex(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

text.Scalars _read(String doc) {
  final m = text.Scalars();
  unmarshal(doc, m);
  return m;
}

void main() {
  test('a singular field keeps the number and writes protowire-go\'s bytes',
      () {
    final m = _read('f_enum = 99');
    expect(m.hasFEnum(), isFalse);
    expect(m.unknownFields.getField(14)!.varints.single.toInt(), 99);
    expect(hex(m.writeToBuffer()), '7063');
  });

  test('marshal writes the number back, from PXF or from binary', () {
    expect(marshal(_read('f_enum = 99')), 'f_enum = 99\n');
    expect(marshal(text.Scalars.fromBuffer([0x70, 0x63])), 'f_enum = 99\n');
  });

  test('the number is written in field order, among the declared fields', () {
    final m = _read('f_bool = true\nf_enum = 99\nf_sint32 = 1');
    expect(marshal(m), 'f_bool = true\nf_enum = 99\nf_sint32 = 1\n');
  });

  test('a negative number is a sign-extended int32, as in binary', () {
    final m = _read('f_enum = -5');
    expect(hex(m.writeToBuffer()), '70fbffffffffffffffff01');
    expect(marshal(m), 'f_enum = -5\n');
  });

  test('a number outside int32 is refused, as protowire-go refuses it', () {
    expect(
        () => _read('f_enum = 2147483648'),
        throwsA(isA<PxfError>().having(
            (e) => e.toString(), 'message', contains('invalid enum number'))));
  });

  test('a declared number still sets the field', () {
    final m = _read('f_enum = 2');
    expect(m.fEnum, text.Color.COLOR_GREEN);
    expect(m.unknownFields.isEmpty, isTrue);
  });

  // package:protobuf writes unknown fields after the declared ones. With a
  // higher-numbered field set, the bytes hold the same values as
  // protowire-go's, in another order: Go writes 70 63 88 01 02. Pinned so a
  // change to either side is seen.
  test('with a higher-numbered field the number is written last', () {
    final m = _read('f_enum = 99\nf_sint32 = 1');
    expect(hex(m.writeToBuffer()), '8801027063');
  });

  test('a list element is refused, naming why', () {
    expect(
        () => unmarshal('colors = [COLOR_RED, 99]', text.Shapes()),
        throwsA(isA<PxfError>().having((e) => e.toString(), 'message',
            contains('kept only on a singular field'))));
  });
}
