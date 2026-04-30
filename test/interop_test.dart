import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protowire/protowire.dart';

class Side extends ProtobufEnum {
  static const Side SIDE_BUY = Side._(0, 'SIDE_BUY');
  static const Side SIDE_SELL = Side._(1, 'SIDE_SELL');

  static const List<Side> values = <Side>[
    SIDE_BUY,
    SIDE_SELL,
  ];

  static final Map<int, Side> _byValue = ProtobufEnum.initByValue(values);
  static Side? valueOf(int value) => _byValue[value];

  const Side._(int v, String n) : super(v, n);
}

class Order extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Order', package: const PackageName('bench'))
    ..a<Int64>(1, 'orderId', PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
    ..aOS(2, 'symbol')
    ..a<Int64>(3, 'price', PbFieldType.O6, defaultOrMaker: Int64.ZERO)
    ..a<int>(4, 'quantity', PbFieldType.OU3)
    ..e<Side>(5, 'side', PbFieldType.OE, defaultOrMaker: Side.SIDE_BUY, valueOf: Side.valueOf, enumValues: Side.values)
    ..aOB(6, 'active')
    ..a<double>(7, 'weight', PbFieldType.OD)
    ..a<double>(8, 'score', PbFieldType.OF)
    ..pc<Fill>(9, 'fills', PbFieldType.PM, subBuilder: Fill.create)
    ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  Order createEmptyInstance() => Order();
  @override
  Order clone() => Order()..mergeFromMessage(this);
  static Order create() => Order();
}

class Fill extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Fill', package: const PackageName('bench'))
    ..a<Int64>(1, 'fillPrice', PbFieldType.O6, defaultOrMaker: Int64.ZERO)
    ..a<int>(2, 'fillQty', PbFieldType.OU3)
    ..a<Int64>(3, 'fillId', PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
    ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  Fill createEmptyInstance() => Fill();
  @override
  Fill clone() => Fill()..mergeFromMessage(this);
  static Fill create() => Fill();
}

String toHex(Uint8List data) {
  return data.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
}

void main() {
  test('SBE binary interop with Go', () {
    final codec = Codec()
      ..registerMessage(
        Order._i,
        1, // templateId
        1, // schemaId
        0, // version
        lengths: {2: 8}, // symbol length = 8
      );

    final order = Order()
      ..setField(1, Int64(12345))
      ..setField(2, 'AAPL')
      ..setField(3, Int64(15050))
      ..setField(4, 100)
      ..setField(5, Side.SIDE_SELL) // SIDE_SELL
      ..setField(6, true)
      ..setField(7, 1.5)
      ..setField(8, 4.5);

    (order.getField(9) as List<Fill>).add(
      Fill()
        ..setField(1, Int64(15055))
        ..setField(2, 50)
        ..setField(3, Int64(1)),
    );

    final data = codec.marshal(order);
    final hex = toHex(data);
    
    const expectedHex = '2a0001000100000039300000000000004141504c00000000ca3a000000000000640000000101000000000000f83f0000904014000100cf3a000000000000320000000100000000000000';
    
    expect(hex, expectedHex);
  });

  test('PB binary interop with Go', () {
    final msg = TestMessage()
      ..setField(1, 'Alice')
      ..setField(2, 30)
      ..setField(3, 65.5)
      ..setField(4, true);
    (msg.getField(5) as List<String>).addAll(['admin', 'user']);

    final data = msg.writeToBuffer();
    final hex = toHex(data);

    // Go output: 0a05416c696365101e19000000000060504020012a0561646d696e2a0475736572
    const expectedHex = '0a05416c696365101e19000000000060504020012a0561646d696e2a0475736572';
    
    expect(hex, expectedHex);
  });
}

class TestMessage extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('TestMessage', package: const PackageName('test'))
    ..aOS(1, 'name')
    ..a<int>(2, 'age', PbFieldType.O3)
    ..a<double>(3, 'weight', PbFieldType.OD)
    ..aOB(4, 'active')
    ..pPS(5, 'tags')
    ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  TestMessage createEmptyInstance() => TestMessage();
  @override
  TestMessage clone() => TestMessage()..mergeFromMessage(this);
  static TestMessage create() => TestMessage();
}
