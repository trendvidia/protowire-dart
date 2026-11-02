// This is a generated file - do not edit.
//
// Generated from blocks.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Address extends $pb.GeneratedMessage {
  factory Address({
    $core.String? city,
    $core.String? zip,
  }) {
    final result = create();
    if (city != null) result.city = city;
    if (zip != null) result.zip = zip;
    return result;
  }

  Address._();

  factory Address.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Address.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Address',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'blocks.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'city')
    ..aOS(2, _omitFieldNames ? '' : 'zip')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Address clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Address copyWith(void Function(Address) updates) =>
      super.copyWith((message) => updates(message as Address)) as Address;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Address create() => Address._();
  @$core.override
  Address createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Address getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Address>(create);
  static Address? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get city => $_getSZ(0);
  @$pb.TagNumber(1)
  set city($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get zip => $_getSZ(1);
  @$pb.TagNumber(2)
  set zip($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasZip() => $_has(1);
  @$pb.TagNumber(2)
  void clearZip() => $_clearField(2);
}

class Child extends $pb.GeneratedMessage {
  factory Child({
    $core.String? id,
    $core.String? type,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    return result;
  }

  Child._();

  factory Child.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Child.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Child',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'blocks.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Child clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Child copyWith(void Function(Child) updates) =>
      super.copyWith((message) => updates(message as Child)) as Child;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Child create() => Child._();
  @$core.override
  Child createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Child getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Child>(create);
  static Child? _defaultInstance;

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
}

class Doc extends $pb.GeneratedMessage {
  factory Doc({
    Address? address,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? headers,
    $core.Iterable<Child>? children,
  }) {
    final result = create();
    if (address != null) result.address = address;
    if (headers != null) result.headers.addEntries(headers);
    if (children != null) result.children.addAll(children);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'blocks.v1'),
      createEmptyInstance: create)
    ..aOM<Address>(1, _omitFieldNames ? '' : 'address',
        subBuilder: Address.create)
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'headers',
        entryClassName: 'Doc.HeadersEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('blocks.v1'))
    ..pPM<Child>(3, _omitFieldNames ? '' : 'children', subBuilder: Child.create)
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
  Address get address => $_getN(0);
  @$pb.TagNumber(1)
  set address(Address value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);
  @$pb.TagNumber(1)
  Address ensureAddress() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, $core.String> get headers => $_getMap(1);

  @$pb.TagNumber(3)
  $pb.PbList<Child> get children => $_getList(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
