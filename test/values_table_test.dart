// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// The struct-binding table (protowire#509): values written through a port's
// struct API, with the bytes protowire-go writes for each. Dart's struct API
// is marshalNative over @ProtoTag classes, and this holds a twin of every
// row (protowire-dart#83). test/testdata/values/values.tsv is a byte copy of
// the spec's file, compared with it by the scheduled go-conformance job. A
// row added to the table fails here until it has a twin.
//
// Go's big.Rat and big.Float are pxf.Decimal and pxf.BigFloat messages here,
// built as the row's words spell them (1.00 is unscaled 100, scale 2), so
// the reduction protowire-go gets from its types is marshalNative's to do.
import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:protowire/src/encoding/pxf/wellknown.dart' show bigIntToBytes;
import 'package:protowire/src/generated/proto/pxf/bignum.pb.dart' as bn;
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

class Packed {
  @ProtoTag(1)
  List<int>? xs;
  @ProtoTag(2)
  List<Int64>? ys;
  @ProtoTag(3)
  List<bool>? bs;
  @ProtoTag(4)
  List<double>? ds;
  @ProtoTag(5, float32: true)
  List<double>? fs;
}

class DecimalHolder {
  @ProtoTag(1)
  bn.Decimal? d;
}

class Decimals {
  @ProtoTag(1)
  List<bn.Decimal?>? ds;
}

class Leaf {
  @ProtoTag(1)
  String? name;
  @ProtoTag(2)
  int? n;
}

class Nested {
  @ProtoTag(1)
  String? s;
  @ProtoTag(2)
  List<Leaf>? ls;
  @ProtoTag(3)
  List<String>? ss;
}

class Zeros {
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
  @ProtoTag(6, unsigned: true)
  Int64? u;
}

class BigNums {
  @ProtoTag(1)
  BigInt? i;
  @ProtoTag(2)
  bn.Decimal? d;
  @ProtoTag(3)
  bn.BigFloat? f;
}

class BigInts {
  @ProtoTag(1)
  List<BigInt?>? values;
}

class BigFloatMap {
  @ProtoTag(1)
  Map<String, bn.BigFloat?>? m;
}

class BigFloatHolder {
  @ProtoTag(1)
  bn.BigFloat? f;
}

/// A pxf.Decimal of [unscaled] × 10^-[scale], unreduced.
bn.Decimal dec(int unscaled, int scale, {bool negative = false}) => bn.Decimal()
  ..unscaled = bigIntToBytes(BigInt.from(unscaled))
  ..scale = scale
  ..negative = negative;

/// A pxf.BigFloat of [mantissa] × 2^[exponent] at [prec] bits, unwidened.
bn.BigFloat bf(int mantissa, int exponent, int prec, {bool negative = false}) =>
    bn.BigFloat()
      ..mantissa = bigIntToBytes(BigInt.from(mantissa))
      ..exponent = exponent
      ..prec = prec
      ..negative = negative;

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
  'Packed': () => Packed()
    ..xs = [1, 0, -1]
    ..ys = [Int64(300)]
    ..bs = [true, false]
    ..ds = [1.5]
    ..fs = [-2.5],
  'Decimal': () => DecimalHolder()..d = dec(31415, 4),
  'DecimalOne': () => DecimalHolder()..d = dec(100, 2),
  'DecimalFiveE2': () => DecimalHolder()..d = dec(5, -2),
  'DecimalFifteen': () => DecimalHolder()..d = dec(1500, 2),
  'DecimalZero': () => DecimalHolder()..d = dec(0, 2),
  'DecimalNegative': () => DecimalHolder()..d = dec(150, 2, negative: true),
  'Decimals': () => Decimals()..ds = [dec(0, 2), dec(100, 2), dec(5, -2)],
  'Nested': () => Nested()
    ..s = 'x'
    ..ls = [
      Leaf(),
      Leaf()
        ..name = 'l'
        ..n = -3
    ]
    ..ss = ['', 's'],
  'Zeros': () => Zeros()
    ..i = 0
    ..s = ''
    ..b = false
    ..d = -0.0
    ..bs = Uint8List(0)
    ..u = Int64.ZERO,
  'BigNumsNull': () => BigNums(),
  'BigNumsZero': () => BigNums()
    ..i = BigInt.zero
    ..d = dec(0, 0)
    ..f = bf(0, 0, 0),
  'BigNumsNegative': () => BigNums()
    ..i = BigInt.parse('-12345678901234567890')
    ..d = dec(5, 1, negative: true)
    ..f = bf(3, -1, 53, negative: true),
  'BigIntsZeroElement': () => BigInts()..values = [BigInt.zero, BigInt.one],
  'BigIntsNullElement': () => BigInts()..values = [BigInt.one, null],
  'DecimalsNullElement': () => Decimals()..ds = [dec(1, 0), null],
  'BigFloatMapNullValue': () => BigFloatMap()..m = {'k': null},
  'BigFloatPrec64': () => BigFloatHolder()..f = bf(3, -1, 64),
};

String hex(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

void main() {
  final rows = <String, String>{};
  for (final line
      in File('test/testdata/values/values.tsv').readAsLinesSync()) {
    if (line.isEmpty || line.startsWith('#')) continue;
    final cols = line.split('\t');
    rows[cols[0]] = cols[1];
  }

  test('every row has a twin', () {
    expect(rows, hasLength(23));
    expect(twins.keys.toSet(), rows.keys.toSet());
  });

  twins.forEach((name, build) {
    test('$name writes protowire-go\'s bytes', () {
      final bytes = marshalNative(build());
      expect(hex(bytes), rows[name]);
      expect(bytes, isA<Uint8List>());
    });
  });
}
