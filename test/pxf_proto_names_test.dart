// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// PXF entry names are the proto field names (draft -01 §3.2): `order_id`,
// as every other port writes them. Generated Dart code indexes fields by
// their Dart names (`orderId`), which is all the decoder used to accept —
// protowire's shared testdata/sbe-bench.pxf was rejected with
// `unknown field "order_id"`. Both spellings decode now.
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
}
