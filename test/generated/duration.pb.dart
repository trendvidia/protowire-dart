// This is a generated file - do not edit.
//
// Generated from duration.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/duration.pb.dart'
    as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Holder extends $pb.GeneratedMessage {
  factory Holder({
    $0.Duration? d,
  }) {
    final result = create();
    if (d != null) result.d = d;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'duration.v1'),
      createEmptyInstance: create)
    ..aOM<$0.Duration>(1, _omitFieldNames ? '' : 'd',
        subBuilder: $0.Duration.create)
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
  $0.Duration get d => $_getN(0);
  @$pb.TagNumber(1)
  set d($0.Duration value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasD() => $_has(0);
  @$pb.TagNumber(1)
  void clearD() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Duration ensureD() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
