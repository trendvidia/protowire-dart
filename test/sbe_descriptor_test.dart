// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// Codec.registerFromDescriptorSet against protowire's canonical
// bench.v1.Order (testdata/sbe-bench.proto), built here as a descriptor set
// with the (sbe.*) options set through the generated extensions. The
// expected bytes are the ones every port's dumper agrees on
// (protowire/testdata/sbe-bench.expected.hex).
import 'package:fixnum/fixnum.dart';
import 'package:protowire/protowire.dart';
import 'package:protowire/src/generated/proto/envelope/v1/envelope.pb.dart'
    as envpb;
import 'package:protowire/src/generated/proto/google/protobuf/descriptor.pb.dart';
import 'package:protowire/src/generated/proto/sbe/annotations.pb.dart';
import 'package:test/test.dart';

import '../bin/sbe_bench.pb.dart';

FieldDescriptorProto field(
    String name, int number, FieldDescriptorProto_Type type,
    {FieldDescriptorProto_Label label =
        FieldDescriptorProto_Label.LABEL_OPTIONAL,
    String? typeName,
    int? length,
    String? encoding}) {
  final f = FieldDescriptorProto()
    ..name = name
    ..number = number
    ..type = type
    ..label = label;
  if (typeName != null) f.typeName = typeName;
  if (length != null || encoding != null) {
    final o = FieldOptions();
    if (length != null) o.setExtension(Annotations.length, length);
    if (encoding != null) o.setExtension(Annotations.encoding, encoding);
    f.options = o;
  }
  return f;
}

FileDescriptorSet benchSet() {
  final fill = DescriptorProto()
    ..name = 'Fill'
    ..field.addAll([
      field('fill_price', 1, FieldDescriptorProto_Type.TYPE_INT64),
      field('fill_qty', 2, FieldDescriptorProto_Type.TYPE_UINT32),
      field('fill_id', 3, FieldDescriptorProto_Type.TYPE_UINT64),
    ]);
  final order = DescriptorProto()
    ..name = 'Order'
    ..options = (MessageOptions()..setExtension(Annotations.templateId, 1))
    ..field.addAll([
      field('order_id', 1, FieldDescriptorProto_Type.TYPE_UINT64),
      field('symbol', 2, FieldDescriptorProto_Type.TYPE_STRING, length: 8),
      field('price', 3, FieldDescriptorProto_Type.TYPE_INT64),
      field('quantity', 4, FieldDescriptorProto_Type.TYPE_UINT32),
      field('side', 5, FieldDescriptorProto_Type.TYPE_ENUM,
          typeName: '.bench.v1.Side'),
      field('active', 6, FieldDescriptorProto_Type.TYPE_BOOL),
      field('weight', 7, FieldDescriptorProto_Type.TYPE_DOUBLE),
      field('score', 8, FieldDescriptorProto_Type.TYPE_FLOAT),
      field('fills', 9, FieldDescriptorProto_Type.TYPE_MESSAGE,
          label: FieldDescriptorProto_Label.LABEL_REPEATED,
          typeName: '.bench.v1.Order.Fill'),
    ])
    ..nestedType.add(fill);
  final file = FileDescriptorProto()
    ..name = 'sbe-bench.proto'
    ..package = 'bench.v1'
    ..options = (FileOptions()
      ..setExtension(Annotations.schemaId, 1)
      ..setExtension(Annotations.version, 0))
    ..messageType.add(order);
  return FileDescriptorSet()..file.add(file);
}

Order canonicalOrder() => Order(
      orderId: Int64(1001),
      symbol: 'AAPL',
      price: Int64(19150),
      quantity: 100,
      side: Side.SIDE_SELL,
      active: true,
      weight: 0.85,
      score: 2.5,
      fills: [
        Order_Fill(fillPrice: Int64(19155), fillQty: 25, fillId: Int64(5001)),
        Order_Fill(fillPrice: Int64(19160), fillQty: 50, fillId: Int64(5002)),
      ],
    );

const goldenHex =
    '2a00010001000000e9030000000000004141504c00000000ce4a000000000000640000000101333333333333eb3f0000204014000200d34a000000000000190000008913000000000000d84a000000000000320000008a13000000000000';

String hex(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

void main() {
  test(
      'registers the canonical Order from its descriptor and marshals the shared bytes',
      () {
    final codec = Codec()..registerFromDescriptorSet(benchSet(), Order());
    expect(hex(codec.marshal(canonicalOrder())), goldenHex);
  });

  test(
      'reads the annotations back from a descriptor set parsed with sbeExtensionRegistry',
      () {
    final bytes = benchSet().writeToBuffer();
    final parsed = FileDescriptorSet.fromBuffer(bytes, sbeExtensionRegistry());
    final codec = Codec()..registerFromDescriptorSet(parsed, Order());
    expect(hex(codec.marshal(canonicalOrder())), goldenHex);
  });

  test(
      'a descriptor set parsed without the registry has no (sbe.schema_id) to read',
      () {
    final parsed = FileDescriptorSet.fromBuffer(benchSet().writeToBuffer());
    expect(() => Codec().registerFromDescriptorSet(parsed, Order()),
        throwsA(predicate((e) => '$e'.contains('missing (sbe.schema_id)'))));
  });

  test(
      '(sbe.encoding) narrows a field; a missing message or template_id is an error',
      () {
    final set = benchSet();
    set.file[0].messageType[0].field[3].options =
        (FieldOptions()..setExtension(Annotations.encoding, 'uint8'));
    final codec = Codec()..registerFromDescriptorSet(set, Order());
    final bytes = codec.marshal(canonicalOrder());
    expect(bytes.length, 8 + 39 + 4 + 2 * 20);

    final noTemplate = benchSet();
    noTemplate.file[0].messageType[0].options = MessageOptions();
    expect(() => Codec().registerFromDescriptorSet(noTemplate, Order()),
        throwsA(predicate((e) => '$e'.contains('missing (sbe.template_id)'))));

    // Nested messages are found by the walk; Fill just carries no template_id.
    expect(() => Codec().registerFromDescriptorSet(benchSet(), Order_Fill()),
        throwsA(predicate((e) => '$e'.contains('missing (sbe.template_id)'))));
    expect(
        () => Codec().registerFromDescriptorSet(benchSet(), envpb.Envelope()),
        throwsA(
            predicate((e) => '$e'.contains('not found in descriptor set'))));
  });
}
