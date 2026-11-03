// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// HARDENING.md § UTF-8: a decoder validates a `string` field strictly, from
// PB bytes and from an SBE char array alike, and a `bytes` field takes any
// bytes (protowire#496, protowire-dart#70). The fixtures are the spec repo's
// testdata/adversarial/ rows, vendored verbatim.
import 'dart:io';

import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:protowire/src/generated/proto/google/protobuf/descriptor.pb.dart'
    as pbd;
import 'package:test/test.dart';

import '../bin/adversarial.pb.dart' as adv;

const dir = 'test/testdata/adversarial';

/// repeated string tags = 1; map<string, string> labels = 2; Strings child = 3;
class Strings extends GeneratedMessage {
  static final BuilderInfo _i =
      BuilderInfo('Strings', package: const PackageName('test'))
        ..pPS(1, 'tags')
        ..m<String, String>(2, 'labels',
            entryClassName: 'Strings.LabelsEntry',
            keyFieldType: PbFieldType.OS,
            valueFieldType: PbFieldType.OS)
        ..aOM<Strings>(3, 'child', subBuilder: Strings.create)
        ..hasRequiredFields = false;
  @override
  BuilderInfo get info_ => _i;
  @override
  Strings createEmptyInstance() => Strings();
  @override
  Strings clone() => Strings()..mergeFromMessage(this);
  static Strings create() => Strings();
}

final rejected = throwsA(isA<InvalidProtocolBufferException>()
    .having((e) => e.message, 'message', contains('not valid UTF-8')));

List<int> ld(int field, List<int> body) =>
    [field << 3 | 2, body.length, ...body];

void main() {
  group('PB corpus rows', () {
    List<int> read(String name) => File('$dir/pb/$name').readAsBytesSync();

    test('invalid UTF-8 in a string field is rejected', () {
      expect(
          () => mergeFromBufferChecked(
              adv.StringHolder(), read('utf8-invalid-string.binpb')),
          rejected);
    });
    test('a lone surrogate is rejected', () {
      expect(
          () => mergeFromBufferChecked(
              adv.StringHolder(), read('utf8-surrogate-string.binpb')),
          rejected);
    });
    test('valid two- and three-byte UTF-8 is accepted', () {
      final m = adv.StringHolder();
      mergeFromBufferChecked(m, read('utf8-valid-string.binpb'));
      expect(m.value, 'café€');
    });
    test('the same bytes in a bytes field are accepted', () {
      final m = adv.BytesHolder();
      mergeFromBufferChecked(m, read('utf8-invalid-bytes.binpb'));
      expect(m.value, [0x41, 0x42, 0xFF, 0xFE]);
    });
  });

  group('PB string fields of every shape', () {
    const bad = [0x41, 0xFF];
    final cases = <String, List<int>>{
      'repeated element': ld(1, bad),
      'map key': ld(2, [...ld(1, bad), ...ld(2, 'v'.codeUnits)]),
      'map value': ld(2, [...ld(1, 'k'.codeUnits), ...ld(2, bad)]),
      'nested message': ld(3, ld(1, bad)),
      'overlong encoding of NUL': ld(1, [0xC0, 0x80]),
    };
    cases.forEach((name, wire) {
      test('$name is rejected', () {
        expect(() => mergeFromBufferChecked(Strings(), wire), rejected);
      });
    });

    test('valid text in each is accepted', () {
      final m = Strings();
      mergeFromBufferChecked(m, [
        ...ld(1, [0xC3, 0xA9]),
        ...ld(2, [...ld(1, 'k'.codeUnits), ...ld(2, 'v'.codeUnits)]),
        ...ld(3, ld(1, 'x'.codeUnits)),
      ]);
      expect(m.getField(1), ['é']);
      expect(m.getField(2), {'k': 'v'});
    });
  });

  group('SBE corpus rows', () {
    final fds = pbd.FileDescriptorSet.fromBuffer(
        File('$dir/adversarial.binpb').readAsBytesSync(),
        sbeExtensionRegistry());
    adv.SbeText decode(String name) {
      final msg = adv.SbeText();
      Codec()
        ..registerFromDescriptorSet(fds, msg)
        ..unmarshal(File('$dir/sbe/$name').readAsBytesSync(), msg);
      return msg;
    }

    test('invalid UTF-8 in a string field is rejected', () {
      expect(() => decode('utf8-invalid-string.sbe'), throwsFormatException);
    });
    test('a character cut by a byte-exact limit is rejected', () {
      expect(() => decode('utf8-split-char-string.sbe'), throwsFormatException);
    });
    test('valid UTF-8 filling the field is accepted', () {
      expect(decode('utf8-valid-string.sbe').text, 'café€');
    });
    test('invalid UTF-8 in a bytes field is accepted', () {
      final m = decode('utf8-invalid-bytes.sbe');
      expect(m.text, 'AB');
      expect(m.raw, [0x41, 0x42, 0xFF, 0xFE, 0, 0, 0, 0]);
    });
  });
}
