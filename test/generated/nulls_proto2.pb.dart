// This is a generated file - do not edit.
//
// Generated from nulls_proto2.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Legacy extends $pb.GeneratedMessage {
  factory Legacy({
    $core.int? p,
  }) {
    final result = create();
    if (p != null) result.p = p;
    return result;
  }

  Legacy._();

  factory Legacy.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Legacy.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Legacy',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nulls.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'p')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Legacy clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Legacy copyWith(void Function(Legacy) updates) =>
      super.copyWith((message) => updates(message as Legacy)) as Legacy;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Legacy create() => Legacy._();
  @$core.override
  Legacy createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Legacy getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Legacy>(create);
  static Legacy? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get p => $_getIZ(0);
  @$pb.TagNumber(1)
  set p($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasP() => $_has(0);
  @$pb.TagNumber(1)
  void clearP() => $_clearField(1);
}

class Strict extends $pb.GeneratedMessage {
  factory Strict({
    $core.int? r,
  }) {
    final result = create();
    if (r != null) result.r = r;
    return result;
  }

  Strict._();

  factory Strict.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Strict.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Strict',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nulls.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'r', fieldType: $pb.PbFieldType.Q3);

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Strict clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Strict copyWith(void Function(Strict) updates) =>
      super.copyWith((message) => updates(message as Strict)) as Strict;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Strict create() => Strict._();
  @$core.override
  Strict createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Strict getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Strict>(create);
  static Strict? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get r => $_getIZ(0);
  @$pb.TagNumber(1)
  set r($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasR() => $_has(0);
  @$pb.TagNumber(1)
  void clearR() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
