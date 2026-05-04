// This is a generated file - do not edit.
//
// Generated from proto/bench/v1/order.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'order.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'order.pbenum.dart';

class Order_Fill extends $pb.GeneratedMessage {
  factory Order_Fill({
    $fixnum.Int64? fillPrice,
    $core.int? fillQty,
    $fixnum.Int64? fillId,
  }) {
    final result = create();
    if (fillPrice != null) result.fillPrice = fillPrice;
    if (fillQty != null) result.fillQty = fillQty;
    if (fillId != null) result.fillId = fillId;
    return result;
  }

  Order_Fill._();

  factory Order_Fill.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Order_Fill.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Order.Fill',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bench.v1'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'fillPrice')
    ..aI(2, _omitFieldNames ? '' : 'fillQty', fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'fillId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Order_Fill clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Order_Fill copyWith(void Function(Order_Fill) updates) =>
      super.copyWith((message) => updates(message as Order_Fill)) as Order_Fill;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Order_Fill create() => Order_Fill._();
  @$core.override
  Order_Fill createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Order_Fill getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Order_Fill>(create);
  static Order_Fill? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get fillPrice => $_getI64(0);
  @$pb.TagNumber(1)
  set fillPrice($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFillPrice() => $_has(0);
  @$pb.TagNumber(1)
  void clearFillPrice() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get fillQty => $_getIZ(1);
  @$pb.TagNumber(2)
  set fillQty($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFillQty() => $_has(1);
  @$pb.TagNumber(2)
  void clearFillQty() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get fillId => $_getI64(2);
  @$pb.TagNumber(3)
  set fillId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFillId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFillId() => $_clearField(3);
}

class Order extends $pb.GeneratedMessage {
  factory Order({
    $fixnum.Int64? orderId,
    $core.String? symbol,
    $fixnum.Int64? price,
    $core.int? quantity,
    Side? side,
    $core.bool? active,
    $core.double? weight,
    $core.double? score,
    $core.Iterable<Order_Fill>? fills,
  }) {
    final result = create();
    if (orderId != null) result.orderId = orderId;
    if (symbol != null) result.symbol = symbol;
    if (price != null) result.price = price;
    if (quantity != null) result.quantity = quantity;
    if (side != null) result.side = side;
    if (active != null) result.active = active;
    if (weight != null) result.weight = weight;
    if (score != null) result.score = score;
    if (fills != null) result.fills.addAll(fills);
    return result;
  }

  Order._();

  factory Order.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Order.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Order',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bench.v1'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'orderId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'symbol')
    ..aInt64(3, _omitFieldNames ? '' : 'price')
    ..aI(4, _omitFieldNames ? '' : 'quantity', fieldType: $pb.PbFieldType.OU3)
    ..aE<Side>(5, _omitFieldNames ? '' : 'side', enumValues: Side.values)
    ..aOB(6, _omitFieldNames ? '' : 'active')
    ..aD(7, _omitFieldNames ? '' : 'weight')
    ..aD(8, _omitFieldNames ? '' : 'score', fieldType: $pb.PbFieldType.OF)
    ..pPM<Order_Fill>(9, _omitFieldNames ? '' : 'fills',
        subBuilder: Order_Fill.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Order clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Order copyWith(void Function(Order) updates) =>
      super.copyWith((message) => updates(message as Order)) as Order;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Order create() => Order._();
  @$core.override
  Order createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Order getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Order>(create);
  static Order? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get orderId => $_getI64(0);
  @$pb.TagNumber(1)
  set orderId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrderId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get symbol => $_getSZ(1);
  @$pb.TagNumber(2)
  set symbol($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSymbol() => $_has(1);
  @$pb.TagNumber(2)
  void clearSymbol() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get price => $_getI64(2);
  @$pb.TagNumber(3)
  set price($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrice() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrice() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get quantity => $_getIZ(3);
  @$pb.TagNumber(4)
  set quantity($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasQuantity() => $_has(3);
  @$pb.TagNumber(4)
  void clearQuantity() => $_clearField(4);

  @$pb.TagNumber(5)
  Side get side => $_getN(4);
  @$pb.TagNumber(5)
  set side(Side value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSide() => $_has(4);
  @$pb.TagNumber(5)
  void clearSide() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get active => $_getBF(5);
  @$pb.TagNumber(6)
  set active($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasActive() => $_has(5);
  @$pb.TagNumber(6)
  void clearActive() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get weight => $_getN(6);
  @$pb.TagNumber(7)
  set weight($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasWeight() => $_has(6);
  @$pb.TagNumber(7)
  void clearWeight() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get score => $_getN(7);
  @$pb.TagNumber(8)
  set score($core.double value) => $_setFloat(7, value);
  @$pb.TagNumber(8)
  $core.bool hasScore() => $_has(7);
  @$pb.TagNumber(8)
  void clearScore() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<Order_Fill> get fills => $_getList(8);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
