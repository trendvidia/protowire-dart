// This is a generated file - do not edit.
//
// Generated from proto/bench/v1/order.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use sideDescriptor instead')
const Side$json = {
  '1': 'Side',
  '2': [
    {'1': 'SIDE_BUY', '2': 0},
    {'1': 'SIDE_SELL', '2': 1},
  ],
};

/// Descriptor for `Side`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sideDescriptor =
    $convert.base64Decode('CgRTaWRlEgwKCFNJREVfQlVZEAASDQoJU0lERV9TRUxMEAE=');

@$core.Deprecated('Use orderDescriptor instead')
const Order$json = {
  '1': 'Order',
  '2': [
    {'1': 'order_id', '3': 1, '4': 1, '5': 4, '10': 'orderId'},
    {'1': 'symbol', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'symbol'},
    {'1': 'price', '3': 3, '4': 1, '5': 3, '10': 'price'},
    {'1': 'quantity', '3': 4, '4': 1, '5': 13, '10': 'quantity'},
    {'1': 'side', '3': 5, '4': 1, '5': 14, '6': '.bench.v1.Side', '10': 'side'},
    {'1': 'active', '3': 6, '4': 1, '5': 8, '10': 'active'},
    {'1': 'weight', '3': 7, '4': 1, '5': 1, '10': 'weight'},
    {'1': 'score', '3': 8, '4': 1, '5': 2, '10': 'score'},
    {
      '1': 'fills',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.bench.v1.Order.Fill',
      '10': 'fills'
    },
  ],
  '3': [Order_Fill$json],
  '7': {},
};

@$core.Deprecated('Use orderDescriptor instead')
const Order_Fill$json = {
  '1': 'Fill',
  '2': [
    {'1': 'fill_price', '3': 1, '4': 1, '5': 3, '10': 'fillPrice'},
    {'1': 'fill_qty', '3': 2, '4': 1, '5': 13, '10': 'fillQty'},
    {'1': 'fill_id', '3': 3, '4': 1, '5': 4, '10': 'fillId'},
  ],
};

/// Descriptor for `Order`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orderDescriptor = $convert.base64Decode(
    'CgVPcmRlchIZCghvcmRlcl9pZBgBIAEoBFIHb3JkZXJJZBIcCgZzeW1ib2wYAiABKAlCBODHGA'
    'hSBnN5bWJvbBIUCgVwcmljZRgDIAEoA1IFcHJpY2USGgoIcXVhbnRpdHkYBCABKA1SCHF1YW50'
    'aXR5EiIKBHNpZGUYBSABKA4yDi5iZW5jaC52MS5TaWRlUgRzaWRlEhYKBmFjdGl2ZRgGIAEoCF'
    'IGYWN0aXZlEhYKBndlaWdodBgHIAEoAVIGd2VpZ2h0EhQKBXNjb3JlGAggASgCUgVzY29yZRIq'
    'CgVmaWxscxgJIAMoCzIULmJlbmNoLnYxLk9yZGVyLkZpbGxSBWZpbGxzGlkKBEZpbGwSHQoKZm'
    'lsbF9wcmljZRgBIAEoA1IJZmlsbFByaWNlEhkKCGZpbGxfcXR5GAIgASgNUgdmaWxsUXR5EhcK'
    'B2ZpbGxfaWQYAyABKARSBmZpbGxJZDoEwMEYAQ==');
