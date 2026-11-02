// This is a generated file - do not edit.
//
// Generated from bigfloat.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'pxf/bignum.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class H extends $pb.GeneratedMessage {
  factory H({
    $0.BigFloat? bf,
    $core.int? count,
  }) {
    final result = create();
    if (bf != null) result.bf = bf;
    if (count != null) result.count = count;
    return result;
  }

  H._();

  factory H.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory H.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'H',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bf.v1'),
      createEmptyInstance: create)
    ..aOM<$0.BigFloat>(1, _omitFieldNames ? '' : 'bf',
        subBuilder: $0.BigFloat.create)
    ..aI(2, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  H clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  H copyWith(void Function(H) updates) =>
      super.copyWith((message) => updates(message as H)) as H;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static H create() => H._();
  @$core.override
  H createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static H getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<H>(create);
  static H? _defaultInstance;

  @$pb.TagNumber(1)
  $0.BigFloat get bf => $_getN(0);
  @$pb.TagNumber(1)
  set bf($0.BigFloat value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBf() => $_has(0);
  @$pb.TagNumber(1)
  void clearBf() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.BigFloat ensureBf() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get count => $_getIZ(1);
  @$pb.TagNumber(2)
  set count($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
