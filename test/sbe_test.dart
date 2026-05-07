// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'package:test/test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protowire/src/encoding/sbe/sbe.dart';
import 'package:fixnum/fixnum.dart';

class Order extends GeneratedMessage {
  static final BuilderInfo _i =
      BuilderInfo('Order', package: const PackageName('test'))
        ..a<Int64>(1, 'orderId', PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
        ..aOS(2, 'symbol')
        ..aOM<Header>(3, 'header', subBuilder: Header.create)
        ..pc<Fill>(4, 'fills', PbFieldType.PM, subBuilder: Fill.create)
        ..a<int>(5, 'status', PbFieldType.OU3)
        ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  Order createEmptyInstance() => Order();
  @override
  Order clone() => Order()..mergeFromMessage(this);
  static Order create() => Order();
}

class Header extends GeneratedMessage {
  static final BuilderInfo _i =
      BuilderInfo('Header', package: const PackageName('test'))
        ..a<Int64>(1, 'timestamp', PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
        ..a<int>(2, 'seq', PbFieldType.OU3)
        ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  Header createEmptyInstance() => Header();
  @override
  Header clone() => Header()..mergeFromMessage(this);
  static Header create() => Header();
}

class Fill extends GeneratedMessage {
  static final BuilderInfo _i =
      BuilderInfo('Fill', package: const PackageName('test'))
        ..a<double>(1, 'price', PbFieldType.OD)
        ..a<int>(2, 'qty', PbFieldType.O3)
        ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  Fill createEmptyInstance() => Fill();
  @override
  Fill clone() => Fill()..mergeFromMessage(this);
  static Fill create() => Fill();
}

void main() {
  group('SBE Codec', () {
    final codec = Codec();

    setUp(() {
      codec.registerMessage(
        Order._i,
        1, // templateId
        1, // schemaId
        0, // version
        lengths: {2: 8}, // symbol length = 8
        encodings: {5: encUint8}, // status as uint8
      );
    });

    test('marshal and unmarshal with composite and groups', () {
      final order = Order()
        ..setField(1, Int64(12345))
        ..setField(2, 'AAPL')
        ..setField(5, 200);

      final header = Header()
        ..setField(1, Int64(1700000000000))
        ..setField(2, 42);
      order.setField(3, header);

      (order.getField(4) as List<Fill>).addAll([
        Fill()
          ..setField(1, 150.5)
          ..setField(2, 10),
        Fill()
          ..setField(1, 151.0)
          ..setField(2, 20),
      ]);

      final data = codec.marshal(order);
      // header(8) + orderId:uint64(8) + symbol:char[8](8) + Header(8+4=12) + status:uint8(1) = 37 (root block)
      // + Fill Group Header(4) + 2 * Fill(8+4=12) = 4 + 24 = 28
      // Total = 37 + 28 = 65
      expect(data.length, 65);

      final decoded = Order();
      codec.unmarshal(data, decoded);

      expect(decoded.getField(1), Int64(12345));
      expect(decoded.getField(2), 'AAPL');
      expect(decoded.getField(5), 200);

      final decHeader = decoded.getField(3) as Header;
      expect(decHeader.getField(1), Int64(1700000000000));
      expect(decHeader.getField(2), 42);

      final fills = decoded.getField(4) as List<Fill>;
      expect(fills.length, 2);
    });

    test('string truncation', () {
      final order = Order()..setField(2, 'LONGERTHAN8');
      final data = codec.marshal(order);
      final decoded = Order();
      codec.unmarshal(data, decoded);
      expect(decoded.getField(2), 'LONGERTH');
    });

    test('empty group', () {
      final order = Order()..setField(1, Int64(1));
      final data = codec.marshal(order);
      final decoded = Order();
      codec.unmarshal(data, decoded);
      expect((decoded.getField(4) as List).length, 0);
    });

    test('view with composite and groups', () {
      final order = Order()
        ..setField(1, Int64(12345))
        ..setField(2, 'AAPL')
        ..setField(5, 200);

      final header = Header()
        ..setField(1, Int64(1700000000000))
        ..setField(2, 42);
      order.setField(3, header);

      (order.getField(4) as List<Fill>).addAll([
        Fill()
          ..setField(1, 150.5)
          ..setField(2, 10),
        Fill()
          ..setField(1, 151.0)
          ..setField(2, 20),
      ]);

      final data = codec.marshal(order);
      final view = codec.view(data);

      expect(view.getUint('orderId'), 12345);
      expect(view.getString('symbol'), 'AAPL');
      expect(view.getUint('status'), 200);

      final headerView = view.getComposite('header');
      expect(headerView.getUint('timestamp'), 1700000000000);
      expect(headerView.getUint('seq'), 42);

      final fillsGroup = view.getGroup('fills');
      expect(fillsGroup.length, 2);

      final fill0 = fillsGroup.entry(0);
      expect(fill0.getFloat('price'), 150.5);
      expect(fill0.getInt('qty'), 10);
    });
  });
}
