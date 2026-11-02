// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// What go_conformance_test.dart found, held here too: that test needs Go, and
// `dart test` alone should still catch these.
import 'dart:io';

import 'package:protowire/protowire.dart';
import 'package:test/test.dart';

import 'generated/bool_keys.pb.dart';
import 'generated/conformance.pb.dart';

void main() {
  Values read(String doc) {
    final m = Values();
    unmarshal(doc, m);
    return m;
  }

  test('a bool-keyed map can be written', () {
    final f = Flags();
    unmarshal(
        File('test/testdata/map-keys/bool-keys.pxf').readAsStringSync(), f);
    expect(marshal(f), startsWith('by_flag = {\n  false: '));
  });

  test('map keys sort as written', () {
    expect(marshal(read('mi = { 9: "a" 10: "b" }')),
        'mi = {\n  10: "b"\n  9: "a"\n}\n');
  });

  test('a map key is escaped', () {
    final out = marshal(read(r'ms = { "a\"b": "x" }'));
    expect(out, contains(r'"a\"b": "x"'));
    expect(read(out).ms, {'a"b': 'x'});
  });

  test('a map value of a well-known type is a literal', () {
    expect(marshal(read('md = { a: 500ms }')), 'md = {\n  a: 500ms\n}\n');
    expect(marshal(read('mw = { a: 1 }')), 'mw = {\n  a: 1\n}\n');
  });

  test('a Timestamp keeps its nanoseconds and needs no fraction', () {
    final doc = 'ts = 2024-01-02T03:04:05.123456789Z\n';
    expect(read(doc).ts.nanos, 123456789);
    expect(marshal(read(doc)), doc);
    expect(marshal(read('ts = 2024-01-02T03:04:05Z\n')),
        'ts = 2024-01-02T03:04:05Z\n');
  });

  test('a Timestamp before the epoch has non-negative nanos', () {
    final m = read('ts = 1969-12-31T23:59:59.5Z');
    expect(m.ts.seconds.toInt(), -1);
    expect(m.ts.nanos, 500000000);
  });

  test('a zero in a well-known type is unset', () {
    expect(read('du = 5s').du.hasNanos(), isFalse);
    expect(read('w = 0').w.hasValue(), isFalse);
    expect(read('bi = 0').bi.writeToBuffer(), isEmpty);
    expect(read('de = 0').de.writeToBuffer(), isEmpty);
  });

  test('a plain zero stays set without a descriptor set, unlike the reference',
      () {
    // Generated `int32` and `optional int32` are the same code, so dropping
    // it here would lose `oi = 0`. A descriptor set resolves this.
    expect(read('i = 0').hasI(), isTrue);
    expect(read('oi = 0').hasOi(), isTrue);
  });
}
