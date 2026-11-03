// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// Float and double literals (draft -01 § Numeric Literals), and pxf.Secret's
// string literal, as the write gate (protowire#509) found them differ from
// protowire-go. Each expectation is the bytes protowire-go writes, from the
// spec's testdata/write/golden and testdata/text/cases.
import 'dart:typed_data';

import 'package:protowire/protowire.dart';
import 'package:test/test.dart';

import 'package:protobuf/protobuf.dart';

import '../bin/pxf/secret.pb.dart' as pxf;
import '../bin/text.pb.dart' as text;

/// repeated pxf.Secret list = 1; map<string, pxf.Secret> by_key = 2;
class Secrets extends GeneratedMessage {
  static final BuilderInfo _i =
      BuilderInfo('Secrets', package: const PackageName('test'))
        ..pPM<pxf.Secret>(1, 'list', subBuilder: pxf.Secret.create)
        ..m<String, pxf.Secret>(2, 'byKey',
            protoName: 'by_key',
            entryClassName: 'Secrets.ByKeyEntry',
            keyFieldType: PbFieldType.OS,
            valueFieldType: PbFieldType.OM,
            valueCreator: pxf.Secret.create,
            valueDefaultOrMaker: pxf.Secret.getDefault)
        ..hasRequiredFields = false;
  @override
  BuilderInfo get info_ => _i;
  @override
  Secrets createEmptyInstance() => Secrets();
  @override
  Secrets clone() => Secrets()..mergeFromMessage(this);
}

String hex(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

text.Scalars scalars(String doc) =>
    text.Scalars()..mergeFromMessage(_read(doc));

text.Scalars _read(String doc) {
  final m = text.Scalars();
  unmarshal(doc, m);
  return m;
}

final refused = throwsA(isA<PxfError>());

void main() {
  group('non-finite literals', () {
    test('inf and -inf', () {
      expect(hex(scalars('f_double = inf\nf_float = -inf').writeToBuffer()),
          '09000000000000f07f15000080ff');
    });
    test('+inf', () {
      expect(scalars('f_double = +inf').fDouble, double.infinity);
    });
    test('nan is the canonical quiet NaN', () {
      expect(hex(scalars('f_double = nan\nf_float = nan').writeToBuffer()),
          '09000000000000f87f150000c07f');
    });
    test('what marshal writes reads back', () {
      final m = text.Scalars()
        ..fDouble = double.negativeInfinity
        ..fFloat = double.infinity;
      expect(scalars(marshal(m)).writeToBuffer(), m.writeToBuffer());
    });
    test('a sign is valid only before a number or inf', () {
      expect(() => _read('f_double = +1'), refused);
      expect(() => _read('f_double = -nan'), refused);
      expect(() => _read('f_double = -infinity'), refused);
      expect(() => _read('f_int32 = inf'), refused);
    });
    test('-inf is not a decimal', () {
      expect(() => unmarshal('dec = -inf', text.WellKnown()), refused);
    });
  });

  group('range', () {
    test('a double past its range is refused', () {
      expect(
          () => _read('f_double = 1e400'),
          throwsA(isA<PxfError>()
              .having((e) => '$e', 'message', contains('invalid double'))));
    });
    test('a float past its range is refused', () {
      expect(
          () => _read('f_float = 3.5e38'),
          throwsA(isA<PxfError>()
              .having((e) => '$e', 'message', contains('invalid float'))));
    });
    test('a float within half a ULP of the largest is the largest', () {
      expect(
          hex(scalars('f_float = 3.4028235e38').writeToBuffer()), '15ffff7f7f');
    });
    test('a float that underflows is zero', () {
      final m = scalars('f_float = 1e-46');
      expect(m.fFloat, 0.0);
    });
    test('a float is rounded to float32 as it is read', () {
      expect(scalars('f_float = 0.1').fFloat, (Float32List(1)..[0] = 0.1)[0]);
    });
  });

  group('pxf.Secret string literal', () {
    test('a singular field', () {
      final m = text.WellKnown();
      unmarshal('secret = "pw"', m);
      expect(hex(m.writeToBuffer()), '7a040a027077');
    });
    test('a list element and a map value', () {
      final a = Secrets(), b = Secrets();
      unmarshal(
          'list = ["a", { value = "b" hint = "h" }]\nby_key = { k: "c" }', a);
      unmarshal(
          'list = [{ value = "a" }, { value = "b" hint = "h" }]\n'
          'by_key = { k: { value = "c" } }',
          b);
      expect(a.writeToBuffer(), b.writeToBuffer());
      expect((a.getField(1) as List).length, 2);
    });

    test('the block form is the same message', () {
      final a = text.WellKnown(), b = text.WellKnown();
      unmarshal('secret = "pw"', a);
      unmarshal('secret { value = "pw" }', b);
      expect(a.writeToBuffer(), b.writeToBuffer());
    });
  });
}
