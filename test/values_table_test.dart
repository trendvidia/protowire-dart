// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// The struct-binding table (protowire#509): values written through a port's
// struct API, with the bytes protowire-go writes for each. Dart's struct API
// is marshalNative over @ProtoTag classes, and this holds a twin of every row
// it can express. test/testdata/values/values.tsv is a byte copy of the
// spec's file, compared with it by the scheduled go-conformance job.
//
// The rows it cannot express need field types marshalNative does not have
// yet: repeated fields, float32, uint64, and pxf.BigInt / Decimal / BigFloat
// (protowire-dart#83). They are listed below, so a row added to the table
// fails here until it is placed in one list or the other.
import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:protowire/src/encoding/pb/native.dart';
import 'package:protowire/src/encoding/pb/proto_tag.dart';
import 'package:test/test.dart';

class Ints {
  @ProtoTag(1)
  Int64? a;
  @ProtoTag(2)
  Int64? b;
  @ProtoTag(3)
  int? c;
  @ProtoTag(4)
  Map<String, Int64>? m;
  @ProtoTag(5)
  Map<String, int>? mi;
}

class Age {
  @ProtoTag(1)
  int? age;
}

class MinLong {
  @ProtoTag(1)
  Int64? v;
}

class Zigzag {
  @ProtoTag(1, zigzag: true)
  Int64? d;
  @ProtoTag(2, zigzag: true)
  int? e;
}

class ZeroMapEntry {
  @ProtoTag(1)
  Map<String, String>? m;
  @ProtoTag(2)
  Map<String, int>? z;
  @ProtoTag(3)
  Map<int, String>? k;
}

/// The rows, by case name, as values.tsv words them.
final Map<String, Object Function()> twins = {
  'Ints': () => Ints()
    ..a = Int64(-1)
    ..b = Int64(-1)
    ..c = -1
    ..m = {'k': Int64(-1)}
    ..mi = {'k': -1},
  'Age': () => Age()..age = 30,
  'MinLong': () => MinLong()..v = Int64.MIN_VALUE,
  'Zigzag': () => Zigzag()
    ..d = Int64(-1)
    ..e = -2,
  'ZeroMapEntry': () => ZeroMapEntry()
    ..m = {'': ''}
    ..z = {'zero': 0}
    ..k = {0: 'v'},
};

/// Rows whose struct needs a field type marshalNative lacks, and which.
const notExpressible = {
  'Packed': 'repeated fields, float32',
  'Decimal': 'pxf.Decimal',
  'DecimalOne': 'pxf.Decimal',
  'DecimalFiveE2': 'pxf.Decimal',
  'DecimalFifteen': 'pxf.Decimal',
  'DecimalZero': 'pxf.Decimal',
  'DecimalNegative': 'pxf.Decimal',
  'Decimals': 'repeated pxf.Decimal',
  'Nested': 'repeated fields',
  'Zeros': 'uint64',
  'BigNumsNull': 'pxf.BigInt, Decimal, BigFloat',
  'BigNumsZero': 'pxf.BigInt, Decimal, BigFloat',
  'BigNumsNegative': 'pxf.BigInt, Decimal, BigFloat',
  'BigIntsZeroElement': 'repeated pxf.BigInt',
  'BigIntsNullElement': 'repeated pxf.BigInt',
  'DecimalsNullElement': 'repeated pxf.Decimal',
  'BigFloatMapNullValue': 'pxf.BigFloat',
  'BigFloatPrec64': 'pxf.BigFloat',
};

String hex(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

/// Zeros{i: 0, s: "", b: false, d: 0, bs: empty, u: 0} less `u`, a uint64
/// marshalNative has no type for. Zero scalars are not written, so `u` adds
/// nothing and this writes the Zeros row's bytes, or it is wrong.
class ZerosLessU {
  @ProtoTag(1)
  int? i;
  @ProtoTag(2)
  String? s;
  @ProtoTag(3)
  bool? b;
  @ProtoTag(4)
  double? d;
  @ProtoTag(5)
  Uint8List? bs;
}

void main() {
  final rows = <String, String>{};
  for (final line
      in File('test/testdata/values/values.tsv').readAsLinesSync()) {
    if (line.isEmpty || line.startsWith('#')) continue;
    final cols = line.split('\t');
    rows[cols[0]] = cols[1];
  }

  test('every row is a twin or listed as not expressible', () {
    expect(rows, isNotEmpty);
    for (final name in rows.keys) {
      expect(
          twins.containsKey(name) || notExpressible.containsKey(name), isTrue,
          reason: '$name is new in values.tsv');
    }
    expect({...twins.keys, ...notExpressible.keys}, rows.keys.toSet(),
        reason: 'a listed row is no longer in values.tsv');
  });

  test('Zeros, less its uint64 field, writes protowire-go\'s bytes', () {
    final z = ZerosLessU()
      ..i = 0
      ..s = ''
      ..b = false
      ..d = -0.0
      ..bs = Uint8List(0);
    expect(hex(marshalNative(z)), rows['Zeros']);
  });

  twins.forEach((name, build) {
    test('$name writes protowire-go\'s bytes', () {
      final bytes = marshalNative(build());
      expect(hex(bytes), rows[name]);
      expect(bytes, isA<Uint8List>());
    });
  });
}
