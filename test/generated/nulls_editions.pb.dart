// This is a generated file - do not edit.
//
// Generated from nulls_editions.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Ed extends $pb.GeneratedMessage {
  factory Ed({
    $core.int? explicitScalar,
    $core.int? implicitScalar,
  }) {
    final result = create();
    if (explicitScalar != null) result.explicitScalar = explicitScalar;
    if (implicitScalar != null) result.implicitScalar = implicitScalar;
    return result;
  }

  Ed._();

  factory Ed.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Ed.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Ed',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nulls.ed.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'explicitScalar')
    ..aI(2, _omitFieldNames ? '' : 'implicitScalar')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ed clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ed copyWith(void Function(Ed) updates) =>
      super.copyWith((message) => updates(message as Ed)) as Ed;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Ed create() => Ed._();
  @$core.override
  Ed createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Ed getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Ed>(create);
  static Ed? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get explicitScalar => $_getIZ(0);
  @$pb.TagNumber(1)
  set explicitScalar($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasExplicitScalar() => $_has(0);
  @$pb.TagNumber(1)
  void clearExplicitScalar() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get implicitScalar => $_getIZ(1);
  @$pb.TagNumber(2)
  set implicitScalar($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasImplicitScalar() => $_has(1);
  @$pb.TagNumber(2)
  void clearImplicitScalar() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
