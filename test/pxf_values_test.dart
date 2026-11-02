// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// What the lexer and decoder accept as a value: the spec repo's
// testdata/nulls/, strings/, blocks/ and duration/ corpora, vendored verbatim
// under test/testdata/, and the packed lists of test/testdata/packed/. The
// generated classes come from those schemas:
//
//   protoc -I test/testdata/<dir> -I proto --dart_out=test/generated <schema>
//   protoc -I test/testdata/nulls -I proto --include_imports \
//     --descriptor_set_out=test/testdata/nulls/nulls.binpb \
//     test/testdata/nulls/nulls.proto test/testdata/nulls/nulls_proto2.proto \
//     test/testdata/nulls/nulls_editions.proto
import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/duration.pb.dart'
    as wkt;
import 'package:protowire/protowire.dart';
import 'package:protowire/src/encoding/pxf/lexer.dart';
import 'package:protowire/src/encoding/pxf/parser.dart';
import 'package:protowire/src/encoding/pxf/token.dart';
import 'package:test/test.dart';

import 'generated/blocks.pb.dart' as blocks;
import 'generated/duration.pb.dart' as duration;
import 'generated/nulls.pb.dart' as nulls;
import 'generated/nulls_editions.pb.dart' as editions;
import 'generated/nulls_proto2.pb.dart' as proto2;
import 'generated/packed.pb.dart' as packed;
import 'generated/strings.pb.dart' as strings;
import 'generated/test.pb.dart' as testpb;

String read(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

List<String> corpus(String dir) {
  final names = Directory(dir)
      .listSync()
      .map((e) => e.path.split(Platform.pathSeparator).last)
      .where((n) => n.endsWith('.pxf'))
      .toList()
    ..sort();
  if (names.isEmpty) throw StateError('no fixtures in $dir');
  return names;
}

wkt.Duration duration_(BigInt seconds, BigInt nanos) =>
    wkt.Duration(seconds: Int64.parseInt('$seconds'), nanos: nanos.toInt());

Matcher pxfError(String text) =>
    throwsA(isA<PxfError>().having((e) => '$e', 'message', contains(text)));

final rejected = throwsA(isA<PxfError>());

void main() {
  group('testdata/nulls', () {
    const dir = 'test/testdata/nulls';
    final ann =
        PxfAnnotations.fromBytes(File('$dir/nulls.binpb').readAsBytesSync());

    GeneratedMessage messageFor(String doc) {
      final type = RegExp(r'@type (\S+)').firstMatch(doc)?.group(1);
      switch (type) {
        case 'nulls.v1.Inner':
          return nulls.Inner();
        case 'nulls.v1.Required':
          return nulls.Required();
        case 'nulls.v1.Defaulted':
          return nulls.Defaulted();
        case 'nulls.v1.Legacy':
          return proto2.Legacy();
        case 'nulls.v1.Strict':
          return proto2.Strict();
        case 'nulls.ed.v1.Ed':
          return editions.Ed();
        default:
          return nulls.Holder();
      }
    }

    final names = corpus(dir);
    test('has the corpus the spec states', () => expect(names, hasLength(19)));

    for (final name in names) {
      test(name, () {
        final doc = read('$dir/$name');
        expect(() => parse(doc), returnsNormally,
            reason: 'parse has no schema and accepts them all');
        void decode() => unmarshalFull(doc, messageFor(doc),
            options: UnmarshalOptions(annotations: ann));
        if (name.startsWith('err-')) {
          expect(decode, rejected);
        } else {
          decode();
        }
      });
    }

    test('an accepted null is present-but-null and leaves the field unset', () {
      final m = nulls.Holder();
      final r = unmarshalFull('o = null', m,
          options: UnmarshalOptions(annotations: ann));
      expect(r.isNull('o'), isTrue);
      expect(m.hasO(), isFalse);
    });

    test('a null optional scalar takes no default', () {
      final m = nulls.Defaulted();
      unmarshalFull('d = null', m, options: UnmarshalOptions(annotations: ann));
      expect(m.hasD(), isFalse);
    });

    // Generated classes write `int32` and `optional int32` identically, so
    // this is the one rule a descriptor-less decode cannot apply. This pin
    // fails the day it can, or the day the behaviour changes.
    test('with no descriptor set a null on a plain scalar is still accepted',
        () {
      final m = nulls.Holder();
      final r = unmarshalFull('n = null', m);
      expect(r.isNull('n'), isTrue);
      final info = m.info_;
      expect(info.fieldInfo[1]!.type, info.fieldInfo[2]!.type,
          reason: 'n and o generate the same field type');
    });

    test('the rest of the rule needs no descriptor set', () {
      expect(() => unmarshal('l = null', nulls.Holder()),
          pxfError('null is not allowed on repeated field "l"'));
      expect(() => unmarshal('m = null', nulls.Holder()),
          pxfError('null is not allowed on map field "m"'));
      expect(() => unmarshal('r = null', proto2.Strict()),
          pxfError('null is not allowed on required field "r"'));
    });

    test('names the plain scalar', () {
      expect(
          () => unmarshalFull('n = null', nulls.Holder(),
              options: UnmarshalOptions(annotations: ann)),
          pxfError('null is not allowed on scalar field "n"'));
    });
  });

  group('testdata/strings', () {
    const dir = 'test/testdata/strings';

    test('err-raw-newline.pxf', () {
      final doc = read('$dir/err-raw-newline.pxf');
      expect(() => parse(doc), rejected);
      expect(() => unmarshal(doc, strings.Holder()),
          pxfError('newline in string literal'));
    });

    test('escaped-newline.pxf', () {
      final m = strings.Holder();
      unmarshal(read('$dir/escaped-newline.pxf'), m);
      expect(m.s, 'x\ny');
    });

    test('triple-quoted.pxf', () {
      final m = strings.Holder();
      unmarshal(read('$dir/triple-quoted.pxf'), m);
      expect(m.s, 'x\ny');
    });

    test('newline-after-string.pxf', () {
      final m = strings.Holder();
      unmarshal(read('$dir/newline-after-string.pxf'), m);
      expect([m.s, m.t], ['x', 'y']);
    });

    test('every fixture is covered', () {
      expect(corpus(dir), hasLength(4));
    });

    test('a raw newline in a @dataset cell is rejected on both paths', () {
      final doc = read('test/testdata/dataset/string-newline-in-cell.pxf');
      expect(() => parse(doc), rejected);
      expect(() => unmarshalFull(doc, strings.Holder()), rejected);
    });

    test('a null cell parses, and binding it is pxf_dataset_test.dart', () {
      for (final name in ['null-on-scalar-cell', 'null-on-optional-cell']) {
        final doc = read('test/testdata/dataset/$name.pxf');
        expect(parse(doc).datasets.single.rows, isNotEmpty);
      }
    });
  });

  group('testdata/blocks', () {
    const dir = 'test/testdata/blocks';
    final names = corpus(dir);

    test('has the corpus the spec states', () {
      expect(names.where((n) => n.startsWith('err-')), hasLength(4));
      expect(names, hasLength(7));
    });

    for (final name in names) {
      test(name, () {
        final doc = read('$dir/$name');
        if (name.startsWith('err-')) {
          expect(() => parse(doc), rejected);
          expect(() => unmarshal(doc, blocks.Doc()), rejected);
          expect(() => unmarshalFull(doc, blocks.Doc()), rejected);
        } else {
          parse(doc);
          unmarshal(doc, blocks.Doc());
        }
      });
    }

    test('the accepted spellings bind', () {
      for (final name in ['space-in-block.pxf', 'newline-in-block.pxf']) {
        final d = blocks.Doc();
        unmarshal(read('$dir/$name'), d);
        expect(d.address.city, 'Berlin');
        expect(d.address.zip, '10115');
      }
      final d = blocks.Doc();
      unmarshal(read('$dir/comma-between-elements.pxf'), d);
      expect(d.children.map((c) => c.id), ['greeting', 'title']);
    });
  });

  group('testdata/duration', () {
    const dir = 'test/testdata/duration';

    duration.Holder decode(String doc) {
      final m = duration.Holder();
      unmarshal(doc, m);
      return m;
    }

    for (final name in corpus(dir).where((n) => n.startsWith('err-'))) {
      test(name, () {
        expect(() => decode(read('$dir/$name')), rejected);
      });
    }

    test('signed literals', () {
      expect(decode(read('$dir/negative-seconds.pxf')).d.seconds, Int64(-30));
      final f = decode(read('$dir/negative-fractional.pxf')).d;
      expect(f.seconds, Int64(-1));
      expect(f.nanos, -500000000);
      expect(decode(read('$dir/negative-multi-segment.pxf')).d.seconds,
          Int64(-5400));
      expect(decode(read('$dir/negative-zero.pxf')).d.seconds, Int64.ZERO);
    });

    test('roundtrip-negative re-encodes as the expected file', () {
      final m = decode(read('$dir/roundtrip-negative.pxf'));
      expect(read('$dir/roundtrip-negative.expected.pxf'),
          contains(marshal(m).trim()));
    });
  });

  group('duration literals', () {
    List<(TokenKind, String)> tokens(String input) {
      final lex = Lexer(input);
      final out = <(TokenKind, String)>[];
      for (var i = 0; i < 64; i++) {
        final t = lex.next();
        if (t.kind == TokenKind.eof) return out;
        out.add((t.kind, t.value));
      }
      fail('no EOF in $input');
    }

    const durations = [
      '30s', '1h30m', '500ms', '1.5h', '2µs', '2us', '1.234567ms', '1.5ms',
      '312.5µs', '1.234µs', '1h30m0.5s', '-1.5s', '-312.5µs', '0s', '1.5ns',
      '1.5us', '1.5µs', '1.5s', '1.5m', '1h30.5m', '1.5h30.5m1.5s',
      '1h30m500ms', '1ms234us567ns', '250ms', //
    ];
    for (final d in durations) {
      test('$d is one duration token', () {
        expect(tokens(d), [(TokenKind.duration, d)]);
      });
    }

    final others = <String, List<(TokenKind, String)>>{
      '1.5': [(TokenKind.float, '1.5')],
      '1.5e3': [(TokenKind.float, '1.5e3')],
      '1.5E-3': [(TokenKind.float, '1.5E-3')],
      '-1.5': [(TokenKind.float, '-1.5')],
      '1.': [(TokenKind.float, '1.')],
      '1.e3': [(TokenKind.float, '1.e3')],
      '1.5e3ms': [(TokenKind.float, '1.5e3'), (TokenKind.ident, 'ms')],
      '1e3s': [(TokenKind.float, '1e3'), (TokenKind.ident, 's')],
      '1.ms': [(TokenKind.float, '1.'), (TokenKind.ident, 'ms')],
      '1.5x': [(TokenKind.float, '1.5'), (TokenKind.ident, 'x')],
      '1.5 x': [(TokenKind.float, '1.5'), (TokenKind.ident, 'x')],
      '5x': [(TokenKind.int, '5'), (TokenKind.ident, 'x')],
      '1.5min': [(TokenKind.illegal, 'invalid duration: 1.5min')],
      '5min': [(TokenKind.illegal, 'invalid duration: 5min')],
      '2µ': [(TokenKind.illegal, 'invalid duration: 2µ')],
      '2µm': [(TokenKind.illegal, 'invalid duration: 2µm')],
    };
    others.forEach((input, want) {
      test('$input is not a duration', () {
        expect(tokens(input), want);
      });
    });

    test('U+03BC GREEK SMALL LETTER MU is not a unit', () {
      final t = tokens('2μs');
      expect(t.first, (TokenKind.int, '2'));
      expect(t.any((e) => e.$1 == TokenKind.duration), isFalse);
    });

    test('a literal past 64-bit nanoseconds is invalid', () {
      expect(tokens('9223372037s').single.$1, TokenKind.illegal);
    });

    final one = BigInt.one;
    final max = (one << 63) - one;
    final values = <BigInt>[
      for (final n in [
        0,
        1,
        999,
        1000,
        1234,
        1500,
        312500,
        1234567,
        1500000,
        250000000,
        1000000000,
        1500000000,
        5400000000000,
        5400500000000,
        5445123456789,
        360000000000000,
        -1,
        -1500,
        -312500,
        -1500000000,
        -5400500000000,
      ])
        BigInt.from(n),
      max,
      -(one << 63),
    ];

    test('what marshal writes reads back to the same seconds and nanos', () {
      final second = BigInt.from(1000000000);
      for (final v in values) {
        final m = testpb.AllTypes();
        m.durField = duration_(v ~/ second, v.remainder(second));
        final text = marshal(m);
        final back = testpb.AllTypes();
        unmarshal(text, back);
        expect(back.durField.seconds, m.durField.seconds, reason: text);
        expect(back.durField.nanos, m.durField.nanos, reason: text);
      }
    });

    test('marshal writes what time.Duration.String() writes', () {
      String write(int seconds, int nanos) {
        final m = testpb.AllTypes()
          ..durField = duration_(BigInt.from(seconds), BigInt.from(nanos));
        return marshal(m).trim();
      }

      expect(write(0, 1500000), 'dur_field = 1.5ms');
      expect(write(0, 312500), 'dur_field = 312.5µs');
      expect(write(0, 100), 'dur_field = 100ns');
      expect(write(5400, 500000000), 'dur_field = 1h30m0.5s');
      expect(write(-1, -500000000), 'dur_field = -1.5s');
      expect(write(3600, 0), 'dur_field = 1h0m0s');
    });
  });

  group('packed repeated scalars', () {
    test('every packed type decodes from a list', () {
      final m = packed.Lists();
      unmarshal(
          'i32 = [1, -2]\ni64 = [3]\nu32 = [4]\nu64 = [5]\ns32 = [-6]\n'
          's64 = [-7]\nf32 = [8]\nf64 = [9]\nsf32 = [-10]\nsf64 = [-11]\n'
          'fl = [1.5, 2]\ndb = [2.5]\nbo = [true, false]\n'
          'en = [COLOR_RED, 0]',
          m);
      expect(m.i32, [1, -2]);
      expect(m.i64, [Int64(3)]);
      expect(m.u32, [4]);
      expect(m.u64, [Int64(5)]);
      expect(m.s32, [-6]);
      expect(m.s64, [Int64(-7)]);
      expect(m.f32, [8]);
      expect(m.f64, [Int64(9)]);
      expect(m.sf32, [-10]);
      expect(m.sf64, [Int64(-11)]);
      expect(m.fl, [1.5, 2.0]);
      expect(m.db, [2.5]);
      expect(m.bo, [true, false]);
      expect(m.en, [packed.Color.COLOR_RED, packed.Color.COLOR_UNSPECIFIED]);
    });

    test('a null element is refused by the null rule', () {
      expect(() => unmarshal('i32 = [1, null]', packed.Lists()),
          pxfError('null is not allowed in repeated field "i32"'));
    });

    test('marshal reads back', () {
      final m = packed.Lists()
        ..i32.addAll([1, 2])
        ..fl.add(1.5)
        ..en.add(packed.Color.COLOR_RED);
      final back = packed.Lists();
      unmarshal(marshal(m), back);
      expect(back.writeToBuffer(), m.writeToBuffer());
    });
  });
}
