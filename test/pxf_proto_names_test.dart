// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// PXF entry names are the proto field names (draft -01 §3.2): `order_id`,
// as every other port writes them. Generated Dart code indexes fields by
// their Dart names (`orderId`), which is all the decoder used to accept —
// protowire's shared testdata/sbe-bench.pxf was rejected with
// `unknown field "order_id"`. Both spellings decode now, and the encoder
// writes proto names (#15) — it used to write `orderId`, which no other
// port could read.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:test/test.dart';

class Kind extends ProtobufEnum {
  static const Kind KIND_UNSPECIFIED = Kind._(0, 'KIND_UNSPECIFIED');
  static const Kind KIND_BUG = Kind._(1, 'KIND_BUG');
  static const List<Kind> values = [KIND_UNSPECIFIED, KIND_BUG];
  static Kind? valueOf(int v) => v >= 0 && v < values.length ? values[v] : null;
  const Kind._(super.value, super.name);
}

class Ticket extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Ticket',
      package: const PackageName('names.v1'), createEmptyInstance: create)
    ..a<Int64>(1, 'orderId', PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
    ..aOS(2, 'displayName')
    ..aOM<Ticket>(3, 'parentTicket', subBuilder: Ticket.create)
    ..e<Kind>(4, 'kind', PbFieldType.OE,
        defaultOrMaker: Kind.KIND_UNSPECIFIED,
        valueOf: Kind.valueOf,
        enumValues: Kind.values)
    ..hasRequiredFields = false;

  Ticket._();
  @override
  BuilderInfo get info_ => _i;
  @override
  Ticket clone() => Ticket.create()..mergeFromMessage(this);
  @override
  Ticket createEmptyInstance() => create();
  static Ticket create() => Ticket._();
}

void main() {
  test('proto field names decode, including for nested blocks', () {
    final t = Ticket.create();
    unmarshal('''
order_id = 7
display_name = "spec"
parent_ticket {
  order_id = 6
}
''', t);
    expect(t.getField(1), Int64(7));
    expect(t.getField(2), 'spec');
    expect((t.getField(3) as Ticket).getField(1), Int64(6));
  });

  test('the Dart names generated code indexes by still decode', () {
    final t = Ticket.create();
    unmarshal('orderId = 7\ndisplayName = "dart"\n', t);
    expect(t.getField(1), Int64(7));
    expect(t.getField(2), 'dart');
  });

  test('enum values decode by name, as every port writes them', () {
    final t = Ticket.create();
    unmarshal('kind = KIND_BUG\n', t);
    expect(t.getField(4), Kind.KIND_BUG);
    expect(
        () => unmarshal('kind = KIND_FEATURE\n', Ticket.create()),
        throwsA(predicate(
            (e) => '$e'.contains('unknown enum value "KIND_FEATURE"'))));
  });

  test('an unknown name is still unknown', () {
    expect(() => unmarshal('order_identifier = 1\n', Ticket.create()),
        throwsA(isA<PxfError>()));
  });

  // -- encoder (#15): entries are proto field names in every position ----

  test('marshal writes proto field names at root, nested, list and map', () {
    final o = Order.create()
      ..setField(1, Int64(1001))
      ..setField(2, Inner.create()..setField(1, Int64(19155)))
      ..setField(5, Kind.KIND_BUG);
    (o.getField(3) as List<Inner>)
      ..add(Inner.create()..setField(1, Int64(1)))
      ..add(Inner.create()..setField(1, Int64(2)));
    (o.getField(4) as Map<String, Inner>)['a'] = Inner.create()
      ..setField(1, Int64(3));
    final text = marshal(o);
    expect(text, contains('order_id = 1001'));
    expect(text, contains('last_fill {'));
    expect(text, contains('all_fills = ['));
    expect(text, contains('tag_fills = {'));
    expect(text, contains('fill_price = 19155'));
    expect(text, contains('kind = KIND_BUG'));
    // No Dart name anywhere: a document with one would be unreadable by
    // every other port (draft -01 §3.2).
    expect(RegExp(r'[a-z]+[A-Z][A-Za-z]* *[={]').hasMatch(text), isFalse,
        reason: text);
  });

  test('a marshalled document round-trips through the proto-name path', () {
    // No map entry here: the decoder parses map blocks and discards their
    // values (#17), so a map would not survive the trip for a reason
    // unrelated to names. The encoder side of maps is covered above.
    final o = Order.create()
      ..setField(1, Int64(42))
      ..setField(2, Inner.create()..setField(1, Int64(7)));
    (o.getField(3) as List<Inner>).add(Inner.create()..setField(1, Int64(8)));
    final back = Order.create();
    unmarshal(marshal(o), back);
    expect(back.writeToBuffer(), o.writeToBuffer());
  });

  test('presence paths and diagnostics use proto names', () {
    // Result paths are what callers compare against their own schema
    // knowledge, and what the reference port reports.
    final result = Result();
    final o = Order.create();
    DirectDecoder('order_id = 1\nlast_fill { fill_price = null }\n',
            result: result, rootMsg: o)
        .decodeDocument(o);
    expect(result.isSet('order_id'), isTrue);
    expect(result.isNull('last_fill.fill_price'), isTrue);
    expect(result.isAbsent('orderId'), isTrue);

    expect(
        () => unmarshal('all_fills = 1\n', Order.create()),
        throwsA(predicate((e) =>
            '$e'.contains('repeated field "all_fills"') && !'$e'.contains('allFills'))));
  });
}

/// A message with a multi-word name in every entry position.
class Inner extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Inner',
      package: const PackageName('names.v1'), createEmptyInstance: create)
    ..a<Int64>(1, 'fillPrice', PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
    ..hasRequiredFields = false;

  Inner._();
  @override
  BuilderInfo get info_ => _i;
  @override
  Inner clone() => Inner.create()..mergeFromMessage(this);
  @override
  Inner createEmptyInstance() => create();
  static Inner create() => Inner._();
}

class Order extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Order',
      package: const PackageName('names.v1'), createEmptyInstance: create)
    ..a<Int64>(1, 'orderId', PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
    ..aOM<Inner>(2, 'lastFill', subBuilder: Inner.create)
    ..pc<Inner>(3, 'allFills', PbFieldType.PM, subBuilder: Inner.create)
    ..m<String, Inner>(4, 'tagFills',
        entryClassName: 'Order.TagFillsEntry',
        keyFieldType: PbFieldType.OS,
        valueFieldType: PbFieldType.OM,
        valueCreator: Inner.create,
        packageName: const PackageName('names.v1'))
    ..e<Kind>(5, 'kind', PbFieldType.OE,
        defaultOrMaker: Kind.KIND_UNSPECIFIED,
        valueOf: Kind.valueOf,
        enumValues: Kind.values)
    ..hasRequiredFields = false;

  Order._();
  @override
  BuilderInfo get info_ => _i;
  @override
  Order clone() => Order.create()..mergeFromMessage(this);
  @override
  Order createEmptyInstance() => create();
  static Order create() => Order._();
}
