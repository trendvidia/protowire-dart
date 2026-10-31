// This is a generated file - do not edit.
//
// Generated from keyed.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Node extends $pb.GeneratedMessage {
  factory Node({
    $core.String? id,
    $core.String? type,
    $core.int? weight,
    $core.Iterable<Node>? children,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (weight != null) result.weight = weight;
    if (children != null) result.children.addAll(children);
    return result;
  }

  Node._();

  factory Node.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Node.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Node',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'keyed.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aI(3, _omitFieldNames ? '' : 'weight')
    ..pPM<Node>(4, _omitFieldNames ? '' : 'children', subBuilder: Node.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Node clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Node copyWith(void Function(Node) updates) =>
      super.copyWith((message) => updates(message as Node)) as Node;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Node create() => Node._();
  @$core.override
  Node createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Node getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Node>(create);
  static Node? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get weight => $_getIZ(2);
  @$pb.TagNumber(3)
  set weight($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearWeight() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<Node> get children => $_getList(3);
}

class Region extends $pb.GeneratedMessage {
  factory Region({
    $core.String? name,
    $core.int? replicas,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (replicas != null) result.replicas = replicas;
    return result;
  }

  Region._();

  factory Region.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Region.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Region',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'keyed.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aI(2, _omitFieldNames ? '' : 'replicas')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Region clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Region copyWith(void Function(Region) updates) =>
      super.copyWith((message) => updates(message as Region)) as Region;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Region create() => Region._();
  @$core.override
  Region createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Region getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Region>(create);
  static Region? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get replicas => $_getIZ(1);
  @$pb.TagNumber(2)
  set replicas($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReplicas() => $_has(1);
  @$pb.TagNumber(2)
  void clearReplicas() => $_clearField(2);
}

class Deployment extends $pb.GeneratedMessage {
  factory Deployment({
    $core.String? service,
    $core.Iterable<Region>? regions,
  }) {
    final result = create();
    if (service != null) result.service = service;
    if (regions != null) result.regions.addAll(regions);
    return result;
  }

  Deployment._();

  factory Deployment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Deployment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Deployment',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'keyed.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'service')
    ..pPM<Region>(2, _omitFieldNames ? '' : 'regions',
        subBuilder: Region.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Deployment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Deployment copyWith(void Function(Deployment) updates) =>
      super.copyWith((message) => updates(message as Deployment)) as Deployment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Deployment create() => Deployment._();
  @$core.override
  Deployment createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Deployment getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Deployment>(create);
  static Deployment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get service => $_getSZ(0);
  @$pb.TagNumber(1)
  set service($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasService() => $_has(0);
  @$pb.TagNumber(1)
  void clearService() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Region> get regions => $_getList(1);
}

class Plain extends $pb.GeneratedMessage {
  factory Plain({
    $core.String? id,
    $core.String? label,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (label != null) result.label = label;
    return result;
  }

  Plain._();

  factory Plain.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Plain.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Plain',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'keyed.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Plain clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Plain copyWith(void Function(Plain) updates) =>
      super.copyWith((message) => updates(message as Plain)) as Plain;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Plain create() => Plain._();
  @$core.override
  Plain createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Plain getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Plain>(create);
  static Plain? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);
}

class Doc extends $pb.GeneratedMessage {
  factory Doc({
    $core.Iterable<Plain>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  Doc._();

  factory Doc.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Doc.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Doc',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'keyed.v1'),
      createEmptyInstance: create)
    ..pPM<Plain>(1, _omitFieldNames ? '' : 'items', subBuilder: Plain.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Doc clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Doc copyWith(void Function(Doc) updates) =>
      super.copyWith((message) => updates(message as Doc)) as Doc;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Doc create() => Doc._();
  @$core.override
  Doc createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Doc getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Doc>(create);
  static Doc? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Plain> get items => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
