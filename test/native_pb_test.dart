// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'dart:io';
import 'dart:typed_data';

import 'package:protowire/src/encoding/pb/native.dart';
import 'package:protowire/src/encoding/pb/proto_tag.dart';
import 'package:protowire/src/generated/proto/envelope/v1/envelope.pb.dart'
    as envpb;
import 'package:test/test.dart';

class User {
  @ProtoTag(1)
  String? name;

  @ProtoTag(2)
  int? age;

  @ProtoTag(3)
  double? weight;
}

class Inner {
  @ProtoTag(1)
  String? a;

  @ProtoTag(2)
  int? b;
}

class Probe {
  @ProtoTag(18)
  Map<String, int>? m;

  @ProtoTag(19)
  Map<int, Inner>? mm;
}

class Outer {
  @ProtoTag(1)
  Inner? inner;

  @ProtoTag(2)
  Outer? next;
}

class BadKey {
  @ProtoTag(1)
  Map<double, int>? m;
}

class NoCodec {
  @ProtoTag(1)
  Set<int>? l;
}

String hexOf(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

Uint8List bytesOf(String hex) => Uint8List.fromList([
      for (var i = 0; i < hex.length; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16)
    ]);

void main() {
  // Each golden is the output of protowire-go's pb.Marshal for the struct
  // with the same fields, protowire tags 18 and 19.
  group('map fields', () {
    final goldens = <(String, Probe)>[
      ('9201080a047a65726f1000', Probe()..m = {'zero': 0}),
      ('92010d0a0010ffffffffffffffffff01', Probe()..m = {'': -1}),
      ('9201050a01611007', Probe()..m = {'a': 7}),
      ('9a010408001200', Probe()..mm = {0: Inner()}),
      (
        '9a0109080512050a01781002',
        Probe()
          ..mm = {
            5: Inner()
              ..a = 'x'
              ..b = 2
          }
      ),
      (
        '9201050a016110019a0107080112030a0179',
        Probe()
          ..m = {'a': 1}
          ..mm = {1: Inner()..a = 'y'}
      ),
    ];

    for (final (golden, probe) in goldens) {
      test('writes $golden', () {
        expect(hexOf(marshalNative(probe)), golden);
      });

      test('reads $golden back', () {
        final back = Probe();
        unmarshalNative(bytesOf(golden), back);
        expect(hexOf(marshalNative(back)), golden);
      });
    }

    test('reads into a typed map', () {
      final back = Probe();
      unmarshalNative(bytesOf('9a0109080512050a01781002'), back);
      expect(back.mm, isA<Map<int, Inner>>());
      expect(back.mm![5]!.a, 'x');
      expect(back.mm![5]!.b, 2);
    });

    test('a key type a proto map cannot have names the field', () {
      expect(
          () => marshalNative(BadKey()..m = {1.5: 1}),
          throwsA(isA<ArgumentError>().having((e) => '$e', 'message',
              contains('BadKey.m: double is not a valid map key type'))));
    });
  });

  test('a nested class is a message field, recursively', () {
    final o = Outer()
      ..inner = (Inner()..a = 'x')
      ..next = (Outer()..inner = (Inner()..b = 3));
    final back = Outer();
    unmarshalNative(marshalNative(o), back);
    expect(back.inner!.a, 'x');
    expect(back.next!.inner!.b, 3);
  });

  test('a type with no codec names the field, past the dependency', () {
    expect(
        () => marshalNative(NoCodec()..l = {1}),
        throwsA(isA<ArgumentError>().having((e) => '$e', 'message',
            contains('NoCodec.l: Set<int> is not a supported field type'))));
  });

  group('zero-map-entry (protowire#295)', () {
    const golden = '22062a040a001200';

    test('the generated envelope writes both fields of a zero entry', () {
      final env = envpb.Envelope()
        ..error = (envpb.AppError()..metadata[''] = '');
      expect(hexOf(env.writeToBuffer()), golden);
    });

    test('the dumper prints the golden', () {
      final r = Process.runSync(Platform.resolvedExecutable,
          ['run', 'bin/dump_envelope.dart', '--vector', 'zero-map-entry']);
      expect(r.exitCode, 0, reason: '${r.stderr}');
      expect((r.stdout as String).trim(), golden);
    });

    test('an unknown vector exits 3 and names itself', () {
      final r = Process.runSync(Platform.resolvedExecutable,
          ['run', 'bin/dump_envelope.dart', '--vector', 'nope']);
      expect(r.exitCode, 3);
      expect(r.stderr as String, contains('not-implemented: nope'));
    });
  });

  group('Native Binary Encoding', () {
    test('marshal and unmarshal native class', () {
      final user = User()
        ..name = 'Alice'
        ..age = 30
        ..weight = 65.5;

      final data = marshalNative(user);

      final decoded = User();
      unmarshalNative(data, decoded);

      expect(decoded.name, 'Alice');
      expect(decoded.age, 30);
      expect(decoded.weight, 65.5);
    });
  });
}
