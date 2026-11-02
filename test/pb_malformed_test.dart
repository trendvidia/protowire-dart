// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// `mergeFromBufferChecked` is the entry point for untrusted PB, so malformed
// input must end in InvalidProtocolBufferException and nothing else. A length
// varint with bit 31 set reads as negative in package:protobuf, which then
// throws a RangeError, or rewinds its read position.
import 'dart:isolate';
import 'dart:math';

import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:test/test.dart';

import 'generated/any.pb.dart' as anypb;

/// [n] as the unsigned varint of its low 32 bits.
List<int> length32(int n) {
  var v = n & 0xffffffff;
  final out = <int>[];
  while (v >= 0x80) {
    out.add((v & 0x7f) | 0x80);
    v >>= 7;
  }
  return out..add(v);
}

// Field 99 on the length-delimited wire type: Holder does not declare it.
const unknownLen = [0x9a, 0x06];

/// What decoding [data] threw, off this isolate: a decode that never returns
/// has to fail this test, and only another isolate can time out on it. That
/// isolate is killed, or it would hold the test process open.
Future<String> outcome(List<int> data,
    [GeneratedMessage Function() message = anypb.Holder.new]) async {
  final port = ReceivePort();
  final isolate = await Isolate.spawn((SendPort reply) {
    try {
      mergeFromBufferChecked(message(), data);
      reply.send('ok');
    } on InvalidProtocolBufferException {
      reply.send('rejected');
    } catch (e) {
      reply.send('${e.runtimeType}');
    }
  }, port.sendPort);
  final got = await port.first
      .timeout(const Duration(seconds: 5), onTimeout: () => 'hung');
  isolate.kill(priority: Isolate.immediate);
  port.close();
  return got as String;
}

void main() {
  test('a length that overflows 32 bits is rejected', () async {
    expect(await outcome([10, 208, 184, 175, 221, 11, 16]), 'rejected');
  });

  test('a skipped field cannot rewind onto its own tag', () async {
    // Tag and length are 7 bytes, so -7 lands back on the tag, for ever.
    final data = [...unknownLen, ...length32(-7)];
    expect(data, [154, 6, 249, 255, 255, 255, 15]);
    expect(await outcome(data), 'rejected');
  });

  test('a skipped field cannot rewind past the start', () async {
    expect(await outcome([...unknownLen, ...length32(-50)]), 'rejected');
  });

  test('a skipped singular string cannot rewind either', () async {
    // Leaf.tag, field 1 on its own wire type, is walked as a skip.
    expect(await outcome([10, ...length32(-6)], anypb.Leaf.new), 'rejected');
  });

  test('the walk rejects before anything is merged', () {
    final m = anypb.Leaf();
    final good = (anypb.Leaf()..tag = 'x').writeToBuffer();
    // -50 rewinds past the start, so unfixed this throws rather than spins.
    expect(() => mergeFromBufferChecked(m, [...good, 10, ...length32(-50)]),
        throwsA(isA<InvalidProtocolBufferException>()));
    expect(m.tag, isEmpty);
  });

  test('random input ends in a merge or the documented exception', () async {
    final seen = await Isolate.run(() {
      final random = Random(64);
      const bytes = [10, 18, 26, 8, 16, 0x9a, 0x06, 11, 12, 0x80, 0xff];
      final seen = <String, int>{};
      for (var i = 0; i < 50000; i++) {
        final data = List.generate(
            random.nextInt(14),
            (_) => random.nextBool()
                ? bytes[random.nextInt(bytes.length)]
                : random.nextInt(256));
        String key;
        try {
          mergeFromBufferChecked(anypb.Holder(), data);
          key = 'ok';
        } on InvalidProtocolBufferException {
          key = 'rejected';
        } catch (e) {
          key = '${e.runtimeType} on $data';
        }
        seen[key] = (seen[key] ?? 0) + 1;
      }
      return seen;
    }).timeout(const Duration(seconds: 60));
    expect(seen.keys, unorderedEquals(['ok', 'rejected']));
    expect(seen['ok']! + seen['rejected']!, 50000);
  });
}
