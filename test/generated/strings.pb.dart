// This is a generated file - do not edit.
//
// Generated from strings.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Holder extends $pb.GeneratedMessage {
  factory Holder({
    $core.String? s,
    $core.String? t,
  }) {
    final result = create();
    if (s != null) result.s = s;
    if (t != null) result.t = t;
    return result;
  }

  Holder._();

  factory Holder.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Holder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Holder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'strings.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 's')
    ..aOS(2, _omitFieldNames ? '' : 't')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Holder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Holder copyWith(void Function(Holder) updates) =>
      super.copyWith((message) => updates(message as Holder)) as Holder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Holder create() => Holder._();
  @$core.override
  Holder createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Holder getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Holder>(create);
  static Holder? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get s => $_getSZ(0);
  @$pb.TagNumber(1)
  set s($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasS() => $_has(0);
  @$pb.TagNumber(1)
  void clearS() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get t => $_getSZ(1);
  @$pb.TagNumber(2)
  set t($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasT() => $_has(1);
  @$pb.TagNumber(2)
  void clearT() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
