// This is a generated file - do not edit.
//
// Generated from proto/sbe/annotations.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Annotations {
  static final schemaId = $pb.Extension<$core.int>(
      _omitMessageNames ? '' : 'google.protobuf.FileOptions',
      _omitFieldNames ? '' : 'schemaId',
      50100,
      $pb.PbFieldType.OU3);
  static final version = $pb.Extension<$core.int>(
      _omitMessageNames ? '' : 'google.protobuf.FileOptions',
      _omitFieldNames ? '' : 'version',
      50101,
      $pb.PbFieldType.OU3);
  static final templateId = $pb.Extension<$core.int>(
      _omitMessageNames ? '' : 'google.protobuf.MessageOptions',
      _omitFieldNames ? '' : 'templateId',
      50200,
      $pb.PbFieldType.OU3);
  static final length = $pb.Extension<$core.int>(
      _omitMessageNames ? '' : 'google.protobuf.FieldOptions',
      _omitFieldNames ? '' : 'length',
      50300,
      $pb.PbFieldType.OU3);
  static final encoding = $pb.Extension<$core.String>(
      _omitMessageNames ? '' : 'google.protobuf.FieldOptions',
      _omitFieldNames ? '' : 'encoding',
      50301,
      $pb.PbFieldType.OS);
  static void registerAllExtensions($pb.ExtensionRegistry registry) {
    registry.add(schemaId);
    registry.add(version);
    registry.add(templateId);
    registry.add(length);
    registry.add(encoding);
  }
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
