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

import 'package:protobuf/protobuf.dart' as $pb;

class Side extends $pb.ProtobufEnum {
  static const Side SIDE_BUY = Side._(0, _omitEnumNames ? '' : 'SIDE_BUY');
  static const Side SIDE_SELL = Side._(1, _omitEnumNames ? '' : 'SIDE_SELL');

  static const $core.List<Side> values = <Side>[
    SIDE_BUY,
    SIDE_SELL,
  ];

  static final $core.List<Side?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static Side? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Side._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
