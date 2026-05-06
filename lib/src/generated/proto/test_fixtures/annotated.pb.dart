// This is a generated file - do not edit.
//
// Generated from proto/test_fixtures/annotated.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/duration.pb.dart'
    as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart'
    as $2;

import 'annotated.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'annotated.pbenum.dart';

class Config extends $pb.GeneratedMessage {
  factory Config({
    $core.String? name,
    $core.String? role,
    $core.int? priority,
    $core.bool? enabled,
    $core.String? email,
    $core.List<$core.int>? token,
    $core.double? weight,
    $0.Timestamp? createdAt,
    $1.Duration? timeout,
    $2.StringValue? nickname,
    Status? status,
    Endpoint? endpoint,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (role != null) result.role = role;
    if (priority != null) result.priority = priority;
    if (enabled != null) result.enabled = enabled;
    if (email != null) result.email = email;
    if (token != null) result.token = token;
    if (weight != null) result.weight = weight;
    if (createdAt != null) result.createdAt = createdAt;
    if (timeout != null) result.timeout = timeout;
    if (nickname != null) result.nickname = nickname;
    if (status != null) result.status = status;
    if (endpoint != null) result.endpoint = endpoint;
    return result;
  }

  Config._();

  factory Config.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Config.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Config',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'annotated.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'role')
    ..aI(3, _omitFieldNames ? '' : 'priority')
    ..aOB(4, _omitFieldNames ? '' : 'enabled')
    ..aOS(5, _omitFieldNames ? '' : 'email')
    ..a<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'token', $pb.PbFieldType.OY)
    ..aD(7, _omitFieldNames ? '' : 'weight')
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$1.Duration>(9, _omitFieldNames ? '' : 'timeout',
        subBuilder: $1.Duration.create)
    ..aOM<$2.StringValue>(10, _omitFieldNames ? '' : 'nickname',
        subBuilder: $2.StringValue.create)
    ..aE<Status>(11, _omitFieldNames ? '' : 'status', enumValues: Status.values)
    ..aOM<Endpoint>(12, _omitFieldNames ? '' : 'endpoint',
        subBuilder: Endpoint.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Config clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Config copyWith(void Function(Config) updates) =>
      super.copyWith((message) => updates(message as Config)) as Config;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Config create() => Config._();
  @$core.override
  Config createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Config getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Config>(create);
  static Config? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get role => $_getSZ(1);
  @$pb.TagNumber(2)
  set role($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRole() => $_has(1);
  @$pb.TagNumber(2)
  void clearRole() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get priority => $_getIZ(2);
  @$pb.TagNumber(3)
  set priority($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPriority() => $_has(2);
  @$pb.TagNumber(3)
  void clearPriority() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get enabled => $_getBF(3);
  @$pb.TagNumber(4)
  set enabled($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEnabled() => $_has(3);
  @$pb.TagNumber(4)
  void clearEnabled() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get email => $_getSZ(4);
  @$pb.TagNumber(5)
  set email($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEmail() => $_has(4);
  @$pb.TagNumber(5)
  void clearEmail() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get token => $_getN(5);
  @$pb.TagNumber(6)
  set token($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasToken() => $_has(5);
  @$pb.TagNumber(6)
  void clearToken() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get weight => $_getN(6);
  @$pb.TagNumber(7)
  set weight($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasWeight() => $_has(6);
  @$pb.TagNumber(7)
  void clearWeight() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get createdAt => $_getN(7);
  @$pb.TagNumber(8)
  set createdAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureCreatedAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $1.Duration get timeout => $_getN(8);
  @$pb.TagNumber(9)
  set timeout($1.Duration value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasTimeout() => $_has(8);
  @$pb.TagNumber(9)
  void clearTimeout() => $_clearField(9);
  @$pb.TagNumber(9)
  $1.Duration ensureTimeout() => $_ensure(8);

  @$pb.TagNumber(10)
  $2.StringValue get nickname => $_getN(9);
  @$pb.TagNumber(10)
  set nickname($2.StringValue value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasNickname() => $_has(9);
  @$pb.TagNumber(10)
  void clearNickname() => $_clearField(10);
  @$pb.TagNumber(10)
  $2.StringValue ensureNickname() => $_ensure(9);

  @$pb.TagNumber(11)
  Status get status => $_getN(10);
  @$pb.TagNumber(11)
  set status(Status value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasStatus() => $_has(10);
  @$pb.TagNumber(11)
  void clearStatus() => $_clearField(11);

  @$pb.TagNumber(12)
  Endpoint get endpoint => $_getN(11);
  @$pb.TagNumber(12)
  set endpoint(Endpoint value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasEndpoint() => $_has(11);
  @$pb.TagNumber(12)
  void clearEndpoint() => $_clearField(12);
  @$pb.TagNumber(12)
  Endpoint ensureEndpoint() => $_ensure(11);
}

class Endpoint extends $pb.GeneratedMessage {
  factory Endpoint({
    $core.String? host,
    $core.int? port,
  }) {
    final result = create();
    if (host != null) result.host = host;
    if (port != null) result.port = port;
    return result;
  }

  Endpoint._();

  factory Endpoint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Endpoint.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Endpoint',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'annotated.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'host')
    ..aI(2, _omitFieldNames ? '' : 'port')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Endpoint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Endpoint copyWith(void Function(Endpoint) updates) =>
      super.copyWith((message) => updates(message as Endpoint)) as Endpoint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Endpoint create() => Endpoint._();
  @$core.override
  Endpoint createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Endpoint getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Endpoint>(create);
  static Endpoint? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get host => $_getSZ(0);
  @$pb.TagNumber(1)
  set host($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHost() => $_has(0);
  @$pb.TagNumber(1)
  void clearHost() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get port => $_getIZ(1);
  @$pb.TagNumber(2)
  set port($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPort() => $_has(1);
  @$pb.TagNumber(2)
  void clearPort() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
