// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// The spec's text gate (scripts/cross_text_check.sh, protowire#503) in this
// repo's tests: each case's PB bytes, read with the stock runtime and written
// with `marshal`, must be the PXF protowire-go writes. test/testdata/text is
// a byte copy of the spec's testdata/text, compared with it by the
// go-conformance job. check_decode --format pb-text does the same for the
// gate itself (protowire-dart#85).
//
// The groups below pin each difference the gate found, on shapes the corpus
// does not hold: a list element, a map key and a map value.
import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:test/test.dart';

import '../bin/pxf/secret.pb.dart' as pxf;
import '../bin/text.pb.dart' as text;

final _annotations = PxfAnnotations.fromBytes(
    File('test/testdata/text/text.binpb').readAsBytesSync());

GeneratedMessage _message(String name) => switch (name) {
      'Scalars' => text.Scalars(),
      'Shapes' => text.Shapes(),
      'WellKnown' => text.WellKnown(),
      _ => throw ArgumentError('no text.v1 message $name'),
    };

String _write(GeneratedMessage m) =>
    marshal(m, options: MarshalOptions(annotations: _annotations));

/// repeated pxf.Secret list = 1; map<string, pxf.Secret> by_key = 2;
/// map<uint64, uint64> big = 3; repeated uint64 bigs = 4; repeated float fs = 5;
class Shapes2 extends GeneratedMessage {
  static final BuilderInfo _i =
      BuilderInfo('Shapes2', package: const PackageName('test'))
        ..pPM<pxf.Secret>(1, 'list', subBuilder: pxf.Secret.create)
        ..m<String, pxf.Secret>(2, 'byKey',
            protoName: 'by_key',
            entryClassName: 'Shapes2.ByKeyEntry',
            keyFieldType: PbFieldType.OS,
            valueFieldType: PbFieldType.OM,
            valueCreator: pxf.Secret.create,
            valueDefaultOrMaker: pxf.Secret.getDefault)
        ..m<Int64, Int64>(3, 'big',
            entryClassName: 'Shapes2.BigEntry',
            keyFieldType: PbFieldType.OU6,
            valueFieldType: PbFieldType.OU6)
        ..p<Int64>(4, 'bigs', PbFieldType.KU6)
        ..p<double>(5, 'fs', PbFieldType.KF)
        ..hasRequiredFields = false;
  @override
  BuilderInfo get info_ => _i;
  @override
  Shapes2 createEmptyInstance() => Shapes2();
  @override
  Shapes2 clone() => Shapes2()..mergeFromMessage(this);
}

void main() {
  group('every text-gate case writes protowire-go\'s text', () {
    final cases = Directory('test/testdata/text/cases')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.binpb'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    test('the corpus is there', () => expect(cases.length, 56));
    for (final f in cases) {
      final name = f.uri.pathSegments.last.replaceFirst('.binpb', '');
      test(name, () {
        final m = _message(name.split('.').first)
          ..mergeFromBuffer(f.readAsBytesSync());
        final golden = File('test/testdata/text/cases/$name.expected.pxf')
            .readAsStringSync();
        expect(_write(m), golden);
      });
    }
  });

  group('a uint64 or fixed64 is written unsigned', () {
    test('singular, in a list, as a map key and value', () {
      final m = Shapes2()
        ..getField(3)[Int64(-1)] = Int64(-2)
        ..getField(4).add(Int64(-1));
      expect(
          marshal(m),
          'big = {\n'
          '  18446744073709551615: 18446744073709551614\n'
          '}\n'
          'bigs = [\n'
          '  18446744073709551615\n'
          ']\n');
      expect(marshal(text.Scalars()..fUint64 = Int64(-1)),
          'f_uint64 = 18446744073709551615\n');
    });
    test('what it writes reads back', () {
      final m = text.Scalars()..fUint64 = Int64(-1);
      final back = text.Scalars();
      unmarshal(marshal(m), back);
      expect(back.fUint64, Int64(-1));
    });
  });

  group('a float is written as protowire-go writes it', () {
    for (final (v, float32, want) in [
      (1e10, false, '1e+10'),
      (100.0, false, '100'),
      (-0.0, false, '-0'),
      (1e-7, false, '1e-07'),
      (0.1, false, '0.1'),
      (123456.0, false, '123456'),
      (1234567.0, false, '1.234567e+06'),
      (0.0001, false, '0.0001'),
      (1.5e300, false, '1.5e+300'),
      (0.1, true, '0.1'),
      (1e-6, true, '1e-06'),
      (3.0, true, '3'),
      (16777216.0, true, '1.6777216e+07'),
    ]) {
      test('$v as ${float32 ? 'float' : 'double'} is $want', () {
        final m = text.Scalars();
        if (float32) {
          m.fFloat = v;
          expect(marshal(m), 'f_float = $want\n');
        } else {
          m.fDouble = v;
          expect(marshal(m), 'f_double = $want\n');
        }
        final back = text.Scalars();
        unmarshal(marshal(m), back);
        expect(float32 ? back.fFloat : back.fDouble,
            float32 ? (Float32List(1)..[0] = v)[0] : v);
      });
    }
    test('a float in a list is the shortest float32', () {
      final m = Shapes2()..getField(5).addAll([0.1, -2.5]);
      expect(marshal(m), 'fs = [\n  0.1,\n  -2.5\n]\n');
    });
  });

  group('a pxf.Secret with only a value is its string literal', () {
    Shapes2 secrets() => Shapes2()
      ..getField(1).addAll([
        pxf.Secret()..value = 'a',
        pxf.Secret()
          ..value = 'b'
          ..hint = 'h',
      ])
      ..getField(2)['k'] = (pxf.Secret()..value = 'c');
    test('in a list and as a map value; a hint keeps the block', () {
      expect(
          marshal(secrets()),
          'list = [\n'
          '  "a",\n'
          '  {\n'
          '    value = "b"\n'
          '    hint = "h"\n'
          '  }\n'
          ']\n'
          'by_key = {\n'
          '  k: "c"\n'
          '}\n');
    });
    test('what it writes reads back', () {
      final back = Shapes2();
      unmarshal(marshal(secrets()), back);
      expect(back.writeToBuffer(), secrets().writeToBuffer());
    });
  });
}
