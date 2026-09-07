// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// Map fields decode (#17). `_decodeMap` used to parse each `key: value`
// entry and then skip the value, so every map came back empty. Keys and
// values follow the Go reference's decodeMapInline / decodeMapKey.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:test/test.dart';

class Color extends ProtobufEnum {
  static const Color COLOR_UNSPECIFIED = Color._(0, 'COLOR_UNSPECIFIED');
  static const Color COLOR_RED = Color._(1, 'COLOR_RED');
  static const List<Color> values = [COLOR_UNSPECIFIED, COLOR_RED];
  static Color? valueOf(int v) =>
      v >= 0 && v < values.length ? values[v] : null;
  const Color._(super.value, super.name);
}

class Point extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Point',
      package: const PackageName('maps.v1'), createEmptyInstance: create)
    ..a<int>(1, 'x', PbFieldType.O3)
    ..a<int>(2, 'y', PbFieldType.O3)
    ..hasRequiredFields = false;

  Point._();
  @override
  BuilderInfo get info_ => _i;
  @override
  Point clone() => Point.create()..mergeFromMessage(this);
  @override
  Point createEmptyInstance() => create();
  static Point create() => Point._();
}

/// Every map shape the reference's tests cover.
class Maps extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Maps',
      package: const PackageName('maps.v1'), createEmptyInstance: create)
    ..m<String, Point>(1, 'points',
        entryClassName: 'Maps.PointsEntry',
        keyFieldType: PbFieldType.OS,
        valueFieldType: PbFieldType.OM,
        valueCreator: Point.create,
        packageName: const PackageName('maps.v1'))
    ..m<int, String>(2, 'names',
        entryClassName: 'Maps.NamesEntry',
        keyFieldType: PbFieldType.O3,
        valueFieldType: PbFieldType.OS,
        packageName: const PackageName('maps.v1'))
    ..m<bool, Int64>(3, 'flags',
        entryClassName: 'Maps.FlagsEntry',
        keyFieldType: PbFieldType.OB,
        valueFieldType: PbFieldType.O6,
        packageName: const PackageName('maps.v1'))
    ..m<String, Color>(4, 'colors',
        entryClassName: 'Maps.ColorsEntry',
        keyFieldType: PbFieldType.OS,
        valueFieldType: PbFieldType.OE,
        valueOf: Color.valueOf,
        enumValues: Color.values,
        defaultEnumValue: Color.COLOR_UNSPECIFIED,
        packageName: const PackageName('maps.v1'))
    ..m<Int64, double>(5, 'weights',
        entryClassName: 'Maps.WeightsEntry',
        keyFieldType: PbFieldType.OU6,
        valueFieldType: PbFieldType.OD,
        packageName: const PackageName('maps.v1'))
    ..hasRequiredFields = false;

  Maps._();
  @override
  BuilderInfo get info_ => _i;
  @override
  Maps clone() => Maps.create()..mergeFromMessage(this);
  @override
  Maps createEmptyInstance() => create();
  static Maps create() => Maps._();
}

Maps decode(String text) {
  final m = Maps.create();
  unmarshal(text, m);
  return m;
}

void main() {
  test('map<string, Message> decodes blocks, bare and quoted keys', () {
    final m = decode('''
points = {
  origin: { x = 0 y = 0 }
  "far away": { x = 7 y = 9 },
}
''');
    final points = m.getField(1) as Map<String, Point>;
    expect(points.keys.toSet(), {'origin', 'far away'});
    expect(points['far away']!.getField(1), 7);
    expect(points['far away']!.getField(2), 9);
  });

  test('map<int32, string> and map<bool, int64> convert their keys', () {
    final m = decode('''
names = { 1: "one", -2: "minus two" }
flags = { true: 10, false: 20 }
''');
    expect(m.getField(2), {1: 'one', -2: 'minus two'});
    expect(m.getField(3), {true: Int64(10), false: Int64(20)});
  });

  test('enum-valued maps take names or numbers', () {
    final m = decode('colors = { a: COLOR_RED, b: 0 }\n');
    expect(m.getField(4), {'a': Color.COLOR_RED, 'b': Color.COLOR_UNSPECIFIED});
  });

  test('map<uint64, double>', () {
    final m = decode('weights = { 18446744073709551615: 0.5, 3: 2 }\n');
    final w = m.getField(5) as Map<Int64, double>;
    expect(w[Int64.parseInt('18446744073709551615')], 0.5);
    expect(w[Int64(3)], 2.0);
  });

  test('duplicate keys are last-wins, as in the reference', () {
    expect(decode('names = { 1: "a", 1: "b" }\n').getField(2), {1: 'b'});
  });

  test('bad keys and null values are rejected with the reference messages', () {
    expect(() => decode('names = { x: "a" }\n'),
        throwsA(predicate((e) => '$e'.contains('invalid int32 map key: x'))));
    expect(() => decode('names = { 3000000000: "a" }\n'),
        throwsA(predicate((e) => '$e'.contains('invalid int32 map key'))));
    expect(
        () => decode('flags = { maybe: 1 }\n'),
        throwsA(
            predicate((e) => '$e'.contains('invalid bool map key: maybe'))));
    expect(() => decode('weights = { -1: 1.0 }\n'),
        throwsA(predicate((e) => '$e'.contains('invalid uint64 map key: -1'))));
    expect(
        () => decode('names = { 1: null }\n'),
        throwsA(predicate((e) => '$e'
            .contains('null is not allowed as map value in field "names"'))));
    expect(() => decode('names = { 1 = "a" }\n'),
        throwsA(predicate((e) => '$e'.contains('use ":" for map entries'))));
    expect(
        () => decode('points = { a: 1 }\n'),
        throwsA(predicate((e) => '$e'.contains(
            'expected "{" for map message value in field "points"'))));
  });

  test('marshal → unmarshal round-trips every map shape byte-identically', () {
    final m = Maps.create();
    (m.getField(1) as Map<String, Point>)['p'] = Point.create()
      ..setField(1, 1)
      ..setField(2, 2);
    (m.getField(2) as Map<int, String>)[5] = 'five';
    (m.getField(3) as Map<bool, Int64>)[true] = Int64(1);
    (m.getField(4) as Map<String, Color>)['c'] = Color.COLOR_RED;
    (m.getField(5) as Map<Int64, double>)[Int64(9)] = 1.5;
    final back = Maps.create();
    unmarshal(marshal(m), back);
    expect(back.writeToBuffer(), m.writeToBuffer());
  });

  test('map values count toward MaxNestingDepth like any block', () {
    // A map value block is one level, and its nested blocks count on from
    // there (HARDENING.md § Recursion): the cap trips, never the Dart stack.
    final n = Node.create();
    final deep = 'kids = { a: { ${'child { ' * 100}${'} ' * 100} } }\n';
    expect(() => unmarshal(deep, n),
        throwsA(predicate((e) => '$e'.contains('MaxNestingDepth'))));
    final ok = 'kids = { a: { ${'child { ' * 90}${'} ' * 90} } }\n';
    unmarshal(ok, Node.create());
  });
}

/// `message Node { Node child = 1; map<string, Node> kids = 2; }`
class Node extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Node',
      package: const PackageName('maps.v1'), createEmptyInstance: create)
    ..aOM<Node>(1, 'child', subBuilder: Node.create)
    ..m<String, Node>(2, 'kids',
        entryClassName: 'Node.KidsEntry',
        keyFieldType: PbFieldType.OS,
        valueFieldType: PbFieldType.OM,
        valueCreator: Node.create,
        packageName: const PackageName('maps.v1'))
    ..hasRequiredFields = false;

  Node._();
  @override
  BuilderInfo get info_ => _i;
  @override
  Node clone() => Node.create()..mergeFromMessage(this);
  @override
  Node createEmptyInstance() => create();
  static Node create() => Node._();
}
