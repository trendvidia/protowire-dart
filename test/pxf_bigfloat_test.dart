// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// pxf.BigFloat as PXF text (protowire#393, #406, #410): the spec repo's
// testdata/bigfloat/ corpus, vendored verbatim. Its expected values come from
// exact rational arithmetic in generate.py, independently of any port.
import 'dart:io';

import 'package:protowire/protowire.dart';
import 'package:test/test.dart';

import 'generated/bigfloat.pb.dart';

const dir = 'test/testdata/bigfloat';

String hexOf(List<int> b) =>
    b.map((v) => v.toRadixString(16).padLeft(2, '0')).join();

void main() {
  final names = Directory(dir)
      .listSync()
      .map((e) => e.uri.pathSegments.last)
      .where((n) => n.endsWith('.pxf'))
      .toList()
    ..sort();
  final ran = <String>{};

  for (final name in names) {
    final stem = name.substring(0, name.length - 4);
    final text = File('$dir/$name').readAsStringSync().replaceAll('\r\n', '\n');

    if (stem.startsWith('enc-')) {
      test('writes $stem', () {
        final m = H.fromBuffer(File('$dir/$stem.binpb').readAsBytesSync());
        expect(marshal(m), text);
        ran.add(name);
      });
    } else if (stem.startsWith('dec-')) {
      test('reads $stem', () {
        final m = H();
        unmarshal(text, m);
        expect(hexOf(m.writeToBuffer()),
            hexOf(File('$dir/$stem.binpb').readAsBytesSync()));
        ran.add(name);
      });
    } else {
      test('rejects $stem', () {
        expect(() => unmarshal(text, H()), throwsA(isA<PxfError>()));
        ran.add(name);
      });
    }
  }

  test('the suffix error names the field', () {
    expect(
        () => unmarshal('count = 5p64', H()),
        throwsA(isA<PxfError>()
            .having((e) => '$e', 'message', contains('on field "count"'))));
  });

  test('what it writes reads back', () {
    for (final name in names.where((n) => n.startsWith('enc-'))) {
      final stem = name.substring(0, name.length - 4);
      final m = H.fromBuffer(File('$dir/$stem.binpb').readAsBytesSync());
      final back = H();
      unmarshal(marshal(m), back);
      expect(marshal(back), marshal(m), reason: stem);
    }
  });

  test('a huge exponent is refused before it is built', () {
    final sw = Stopwatch()..start();
    expect(() => unmarshal('bf = 1e646456992', H()), throwsA(isA<PxfError>()));
    expect(() => unmarshal('bf = 1e-99999999999999', H()),
        throwsA(isA<PxfError>()));
    expect(sw.elapsedMilliseconds, lessThan(1000));
  });

  test('marshal refuses an exponent past the bound', () {
    final m = H();
    unmarshal('bf { mantissa = b"AQ==" exponent = 1048576 prec = 64 }', m);
    expect(() => marshal(m), throwsA(isA<PxfError>()));
  });

  test('the block form still reads', () {
    final m = H();
    unmarshal('bf { mantissa = b"AQ==" exponent = 3 prec = 8 }', m);
    expect(m.bf.exponent, 3);
  });

  test('every fixture ran', () {
    expect(names.where((n) => n.startsWith('enc-')), hasLength(13));
    expect(ran, names.toSet());
  });
}
