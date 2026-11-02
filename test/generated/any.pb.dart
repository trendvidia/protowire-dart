// This is a generated file - do not edit.
//
// Generated from any.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Holder extends $pb.GeneratedMessage {
  factory Holder({
    $0.Any? payload,
    $core.Iterable<$0.Any>? anys,
    $core.Iterable<$core.MapEntry<$core.String, $0.Any>>? byKey,
    Leaf? leaf,
  }) {
    final result = create();
    if (payload != null) result.payload = payload;
    if (anys != null) result.anys.addAll(anys);
    if (byKey != null) result.byKey.addEntries(byKey);
    if (leaf != null) result.leaf = leaf;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'any.v1'),
      createEmptyInstance: create)
    ..aOM<$0.Any>(1, _omitFieldNames ? '' : 'payload',
        subBuilder: $0.Any.create)
    ..pPM<$0.Any>(2, _omitFieldNames ? '' : 'anys', subBuilder: $0.Any.create)
    ..m<$core.String, $0.Any>(3, _omitFieldNames ? '' : 'byKey',
        entryClassName: 'Holder.ByKeyEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $0.Any.create,
        valueDefaultOrMaker: $0.Any.getDefault,
        packageName: const $pb.PackageName('any.v1'))
    ..aOM<Leaf>(4, _omitFieldNames ? '' : 'leaf', subBuilder: Leaf.create)
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
  $0.Any get payload => $_getN(0);
  @$pb.TagNumber(1)
  set payload($0.Any value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPayload() => $_has(0);
  @$pb.TagNumber(1)
  void clearPayload() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Any ensurePayload() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<$0.Any> get anys => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $0.Any> get byKey => $_getMap(2);

  @$pb.TagNumber(4)
  Leaf get leaf => $_getN(3);
  @$pb.TagNumber(4)
  set leaf(Leaf value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLeaf() => $_has(3);
  @$pb.TagNumber(4)
  void clearLeaf() => $_clearField(4);
  @$pb.TagNumber(4)
  Leaf ensureLeaf() => $_ensure(3);
}

class Leaf extends $pb.GeneratedMessage {
  factory Leaf({
    $core.String? tag,
    $core.int? n,
  }) {
    final result = create();
    if (tag != null) result.tag = tag;
    if (n != null) result.n = n;
    return result;
  }

  Leaf._();

  factory Leaf.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Leaf.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Leaf',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'any.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tag')
    ..aI(2, _omitFieldNames ? '' : 'n')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Leaf clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Leaf copyWith(void Function(Leaf) updates) =>
      super.copyWith((message) => updates(message as Leaf)) as Leaf;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Leaf create() => Leaf._();
  @$core.override
  Leaf createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Leaf getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Leaf>(create);
  static Leaf? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tag => $_getSZ(0);
  @$pb.TagNumber(1)
  set tag($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTag() => $_has(0);
  @$pb.TagNumber(1)
  void clearTag() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get n => $_getIZ(1);
  @$pb.TagNumber(2)
  set n($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasN() => $_has(1);
  @$pb.TagNumber(2)
  void clearN() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
