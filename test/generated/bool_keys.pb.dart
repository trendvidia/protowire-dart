// This is a generated file - do not edit.
//
// Generated from bool-keys.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Schema for the bool map-key fixtures under testdata/map-keys/.
class Flags extends $pb.GeneratedMessage {
  factory Flags({
    $core.Iterable<$core.MapEntry<$core.bool, $core.String>>? byFlag,
  }) {
    final result = create();
    if (byFlag != null) result.byFlag.addEntries(byFlag);
    return result;
  }

  Flags._();

  factory Flags.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Flags.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Flags',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mapkeys.v1'),
      createEmptyInstance: create)
    ..m<$core.bool, $core.String>(1, _omitFieldNames ? '' : 'byFlag',
        entryClassName: 'Flags.ByFlagEntry',
        keyFieldType: $pb.PbFieldType.OB,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('mapkeys.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Flags clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Flags copyWith(void Function(Flags) updates) =>
      super.copyWith((message) => updates(message as Flags)) as Flags;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Flags create() => Flags._();
  @$core.override
  Flags createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Flags getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Flags>(create);
  static Flags? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.bool, $core.String> get byFlag => $_getMap(0);
}

/// Schema for the string-key spelling fixtures (issue #306): a string-keyed
/// map whose keys are spelled like keywords and integers.
class Labels extends $pb.GeneratedMessage {
  factory Labels({
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? byLabel,
  }) {
    final result = create();
    if (byLabel != null) result.byLabel.addEntries(byLabel);
    return result;
  }

  Labels._();

  factory Labels.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Labels.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Labels',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mapkeys.v1'),
      createEmptyInstance: create)
    ..m<$core.String, $core.String>(1, _omitFieldNames ? '' : 'byLabel',
        entryClassName: 'Labels.ByLabelEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('mapkeys.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Labels clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Labels copyWith(void Function(Labels) updates) =>
      super.copyWith((message) => updates(message as Labels)) as Labels;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Labels create() => Labels._();
  @$core.override
  Labels createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Labels getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Labels>(create);
  static Labels? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, $core.String> get byLabel => $_getMap(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
