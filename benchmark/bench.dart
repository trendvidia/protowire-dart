import 'dart:typed_data';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protowire/protowire.dart';

class Order extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Order', package: const PackageName('bench'))
    ..a<Int64>(1, 'orderId', PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
    ..a<Int64>(2, 'clOrdId', PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
    ..aOS(3, 'account')
    ..aOS(4, 'symbol')
    ..a<int>(5, 'side', PbFieldType.OU3)
    ..a<Int64>(6, 'price', PbFieldType.O6, defaultOrMaker: Int64.ZERO)
    ..a<int>(7, 'quantity', PbFieldType.OU3)
    ..a<int>(8, 'orderType', PbFieldType.OU3)
    ..a<int>(9, 'timeInForce', PbFieldType.OU3)
    ..a<Int64>(10, 'transactTime', PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
    ..pc<Fill>(11, 'fills', PbFieldType.PM, subBuilder: Fill.create)
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
    ..a<Int64>(4, 'execTime', PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
    ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  Fill createEmptyInstance() => Fill();
  @override
  Fill clone() => Fill()..mergeFromMessage(this);
  static Fill create() => Fill();
}

const String benchPXF = '''
orderId = 1001
clOrdId = 2001
account = "ACCT-001"
symbol = "AAPL"
side = 1
price = 19150
quantity = 100
orderType = 2
timeInForce = 1
transactTime = 1719500400000000000
fills = [
  {
    fillPrice = 19155
    fillQty = 25
    fillId = 5001
    execTime = 1719500400000000100
  }
  {
    fillPrice = 19160
    fillQty = 50
    fillId = 5002
    execTime = 1719500400000000200
  }
  {
    fillPrice = 19165
    fillQty = 25
    fillId = 5003
    execTime = 1719500400000000300
  }
]
''';

final codec = Codec()
  ..registerMessage(
    Order._i,
    1, // templateId
    1, // schemaId
    0, // version
    lengths: {3: 16, 4: 8},
    encodings: {5: encUint8, 8: encUint8, 9: encUint8},
  );

final testOrder = Order()
  ..setField(1, Int64(1001))
  ..setField(2, Int64(2001))
  ..setField(3, "ACCT-001")
  ..setField(4, "AAPL")
  ..setField(5, 1)
  ..setField(6, Int64(19150))
  ..setField(7, 100)
  ..setField(8, 2)
  ..setField(9, 1)
  ..setField(10, Int64.parseInt("1719500400000000000"));

void addFills(Order o) {
  final list = o.getField(11) as List<Fill>;
  list.add(Fill()
    ..setField(1, Int64(19155))
    ..setField(2, 25)
    ..setField(3, Int64(5001))
    ..setField(4, Int64.parseInt("1719500400000000100")));
  list.add(Fill()
    ..setField(1, Int64(19160))
    ..setField(2, 50)
    ..setField(3, Int64(5002))
    ..setField(4, Int64.parseInt("1719500400000000200")));
  list.add(Fill()
    ..setField(1, Int64(19165))
    ..setField(2, 25)
    ..setField(3, Int64(5003))
    ..setField(4, Int64.parseInt("1719500400000000300")));
}

final sbeData = codec.marshal(testOrder..let(addFills));
final protoData = testOrder.writeToBuffer();

extension Let<T> on T {
  T let(void Function(T) f) {
    f(this);
    return this;
  }
}

class PXFUnmarshalBenchmark extends BenchmarkBase {
  PXFUnmarshalBenchmark() : super('PXF Unmarshal');
  @override
  void run() {
    final msg = Order();
    unmarshal(benchPXF, msg);
  }
}

class PXFMarshalBenchmark extends BenchmarkBase {
  PXFMarshalBenchmark() : super('PXF Marshal');
  @override
  void run() {
    marshal(testOrder);
  }
}

class SBEMarshalBenchmark extends BenchmarkBase {
  SBEMarshalBenchmark() : super('SBE Marshal');
  @override
  void run() {
    codec.marshal(testOrder);
  }
}

class SBEUnmarshalBenchmark extends BenchmarkBase {
  SBEUnmarshalBenchmark() : super('SBE Unmarshal');
  @override
  void run() {
    final msg = Order();
    codec.unmarshal(sbeData, msg);
  }
}

class SBEViewBenchmark extends BenchmarkBase {
  SBEViewBenchmark() : super('SBE View Read');
  @override
  void run() {
    final v = codec.view(sbeData);
    v.getUint('orderId');
    v.getUint('clOrdId');
    v.getString('account');
    v.getString('symbol');
    v.getUint('side');
    v.getInt('price');
    v.getUint('quantity');
    v.getUint('orderType');
    v.getUint('timeInForce');
    v.getUint('transactTime');
    final fills = v.getGroup('fills');
    for (int i = 0; i < fills.length; i++) {
      final e = fills.entry(i);
      e.getInt('fillPrice');
      e.getUint('fillQty');
      e.getUint('fillId');
      e.getUint('execTime');
    }
  }
}

class ProtoMarshalBenchmark extends BenchmarkBase {
  ProtoMarshalBenchmark() : super('Proto Marshal');
  @override
  void run() {
    testOrder.writeToBuffer();
  }
}

class ProtoUnmarshalBenchmark extends BenchmarkBase {
  ProtoUnmarshalBenchmark() : super('Proto Unmarshal');
  @override
  void run() {
    Order().mergeFromBuffer(protoData);
  }
}

void main() {
  PXFUnmarshalBenchmark().report();
  PXFMarshalBenchmark().report();
  SBEMarshalBenchmark().report();
  SBEUnmarshalBenchmark().report();
  SBEViewBenchmark().report();
  ProtoMarshalBenchmark().report();
  ProtoUnmarshalBenchmark().report();
}
