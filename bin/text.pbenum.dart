// This is a generated file - do not edit.
//
// Generated from text.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Color extends $pb.ProtobufEnum {
  static const Color COLOR_UNSPECIFIED =
      Color._(0, _omitEnumNames ? '' : 'COLOR_UNSPECIFIED');
  static const Color COLOR_RED = Color._(1, _omitEnumNames ? '' : 'COLOR_RED');
  static const Color COLOR_GREEN =
      Color._(2, _omitEnumNames ? '' : 'COLOR_GREEN');

  static const $core.List<Color> values = <Color>[
    COLOR_UNSPECIFIED,
    COLOR_RED,
    COLOR_GREEN,
  ];

  static final $core.List<Color?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Color? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Color._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
