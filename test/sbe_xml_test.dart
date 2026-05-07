// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'package:test/test.dart';
import 'package:protowire/src/encoding/sbe/xmltoproto.dart';
import 'package:protowire/src/encoding/sbe/prototoxml.dart';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';

void main() {
  group('SBE XML Interop', () {
    test('xmlToProto basic', () {
      final xml = '''
<messageSchema package="test" id="1" version="0">
    <types>
        <enum name="Side" encodingType="uint8">
            <validValue name="Buy">0</validValue>
            <validValue name="Sell">1</validValue>
        </enum>
    </types>
    <message name="Order" id="1">
        <field name="orderId" id="1" type="uint64"/>
        <field name="side" id="2" type="Side"/>
    </message>
</messageSchema>
''';
      final proto = xmlToProto(xml);
      expect(proto, contains('package test;'));
      expect(proto, contains('enum Side {'));
      expect(proto, contains('SIDE_BUY = 0;'));
      expect(proto, contains('SIDE_SELL = 1;'));
      expect(proto, contains('message Order {'));
      expect(proto, contains('uint64 order_id = 1;'));
      expect(proto, contains('Side side = 2;'));
    });

    test('protoToXml basic', () {
      final info = BuilderInfo('Order', package: const PackageName('test'))
        ..a<Int64>(1, 'orderId', PbFieldType.OU6, defaultOrMaker: Int64.ZERO);

      final xml = protoToXml(info, 1, 0, package: 'test');
      expect(xml, contains('<sbe:messageSchema'));
      expect(xml, contains('package="test"'));
      expect(xml, contains('id="1"'));
      expect(xml, contains('<sbe:message name="Order" id="1">'));
      expect(xml, contains('<field name="orderId" id="1" type="uint64"/>'));
    });
  });
}
