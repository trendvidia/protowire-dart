// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// The field types marshalNative gained for the struct-binding table
// (protowire-dart#83): lists, float32, unsigned, BigInt, and generated
// messages such as pxf.Decimal and pxf.BigFloat. values_table_test.dart holds
// the bytes protowire-go writes; this holds what reads back and what is
// refused.
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:protowire/src/encoding/pb/native.dart';
import 'package:protowire/src/encoding/pb/proto_tag.dart';
import 'package:protowire/src/encoding/pxf/wellknown.dart' show bigIntToBytes;
import 'package:protowire/src/generated/proto/pxf/bignum.pb.dart' as bn;
import 'package:test/test.dart';

class Item {
  @ProtoTag(1)
  String? name;
}

class All {
  @ProtoTag(1)
  List<int>? ints;
  @ProtoTag(2, unsigned: true)
  List<Int64>? u64s;
  @ProtoTag(3, float32: true)
  List<double>? floats;
  @ProtoTag(4)
  List<String>? strings;
  @ProtoTag(5)
  List<Uint8List>? blobs;
  @ProtoTag(6)
  List<Item>? items;
  @ProtoTag(7)
  List<BigInt?>? bigs;
  @ProtoTag(8)
  BigInt? big;
  @ProtoTag(9)
  bn.Decimal? dec;
  @ProtoTag(10, unsigned: true)
  Int64? u64;
  @ProtoTag(11, unsigned: true)
  int? u32;
  @ProtoTag(12, float32: true)
  double? f32;
  @ProtoTag(13)
  Map<String, BigInt>? bigByName;
  @ProtoTag(14)
  Uint8List? blob;
}

class BadFlag {
  @ProtoTag(1, float32: true)
  int? i;
}

class BothFlags {
  @ProtoTag(1, zigzag: true, unsigned: true)
  int? i;
}

class NullableInts {
  @ProtoTag(1)
  List<int?>? xs;
}

class FloatHolder {
  @ProtoTag(1)
  bn.BigFloat? f;
}

class DecimalHolder {
  @ProtoTag(1)
  bn.Decimal? d;
}

String hex(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

void main() {
  test('every new type reads back as it was written', () {
    final huge = BigInt.parse('-123456789012345678901234567890');
    final all = All()
      ..ints = [1, 0, -1]
      ..u64s = [Int64(-1), Int64.ZERO]
      ..floats = [0.5, -2.5]
      ..strings = ['', 'b']
      ..blobs = [
        Uint8List(0),
        Uint8List.fromList([1, 2])
      ]
      ..items = [Item(), Item()..name = 'x']
      ..bigs = [BigInt.zero, huge, null]
      ..big = huge
      ..dec = (bn.Decimal()
        ..unscaled = [5]
        ..scale = 1)
      ..u64 = Int64(-1)
      ..u32 = 0xFFFFFFFF
      ..f32 = 0.25
      ..bigByName = {'a': BigInt.two}
      ..blob = Uint8List.fromList([9]);
    final back = All();
    unmarshalNative(marshalNative(all), back);

    expect(back.ints, [1, 0, -1]);
    expect(back.ints, isA<List<int>>());
    expect(back.u64s, [Int64(-1), Int64.ZERO]);
    expect(back.floats, [0.5, -2.5]);
    expect(back.strings, ['', 'b']);
    expect(back.blobs, [
      <int>[],
      [1, 2]
    ]);
    expect(back.items!.map((i) => i.name), [null, 'x']);
    // A null element is written as the empty message, which reads as zero.
    expect(back.bigs, [BigInt.zero, huge, BigInt.zero]);
    expect(back.big, huge);
    expect(back.dec!.unscaled, [5]);
    expect(back.dec!.scale, 1);
    expect(back.u64, Int64(-1));
    expect(back.u32, 0xFFFFFFFF);
    expect(back.f32, 0.25);
    expect(back.bigByName, {'a': BigInt.two});
    expect(back.blob, [9]);
  });

  test('uint32 and float are their proto types on the wire', () {
    // Field 11 uint32 0xFFFFFFFF is a 5-byte varint, not int32's 10 bytes;
    // field 12 float 0.25 is fixed32.
    expect(hex(marshalNative(All()..u32 = 0xFFFFFFFF)), '58ffffffff0f');
    expect(hex(marshalNative(All()..f32 = 0.25)), '650000803e');
  });

  test('the Decimal passed in is not changed by its reduction', () {
    final d = bn.Decimal()
      ..unscaled = bigIntToBytes(BigInt.from(100))
      ..scale = 2;
    expect(hex(marshalNative(DecimalHolder()..d = d)), '0a030a0101');
    expect(d.scale, 2);
    expect(d.unscaled, [100]);
  });

  group('refused', () {
    test('a null element of a list of scalars', () {
      expect(
          () => marshalNative(NullableInts()..xs = [1, null]),
          throwsA(isA<ArgumentError>()
              .having((e) => '$e', 'message', contains('NullableInts.xs[1]'))));
    });
    test('float32 on an int, and zigzag with unsigned', () {
      expect(
          () => marshalNative(BadFlag()..i = 1), throwsA(isA<ArgumentError>()));
      expect(() => marshalNative(BothFlags()..i = 1),
          throwsA(isA<ArgumentError>()));
    });
    test('a BigFloat mantissa wider than its prec', () {
      final f = bn.BigFloat()
        ..mantissa = [0xFF, 0xFF]
        ..prec = 8;
      expect(
          () => marshalNative(FloatHolder()..f = f),
          throwsA(isA<ArgumentError>()
              .having((e) => '$e', 'message', contains('16 bits'))));
    });
    test('a Decimal scale past MaxNumericLiteralDigits', () {
      final d = bn.Decimal()
        ..unscaled = [1]
        ..scale = -5000;
      expect(() => marshalNative(DecimalHolder()..d = d),
          throwsA(isA<ArgumentError>()));
    });
  });
}
