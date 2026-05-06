// This is a generated file - do not edit.
//
// Generated from proto/bench/v1/bench.proto.

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

import 'bench.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'bench.pbenum.dart';

class Config extends $pb.GeneratedMessage {
  factory Config({
    $core.String? hostname,
    $core.int? port,
    $core.bool? enabled,
    $core.double? weight,
    Status? status,
    $core.Iterable<$core.String>? tags,
    TLS? tls,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? labels,
    $core.Iterable<Endpoint>? endpoints,
    $0.Timestamp? createdAt,
    $1.Duration? timeout,
  }) {
    final result = create();
    if (hostname != null) result.hostname = hostname;
    if (port != null) result.port = port;
    if (enabled != null) result.enabled = enabled;
    if (weight != null) result.weight = weight;
    if (status != null) result.status = status;
    if (tags != null) result.tags.addAll(tags);
    if (tls != null) result.tls = tls;
    if (labels != null) result.labels.addEntries(labels);
    if (endpoints != null) result.endpoints.addAll(endpoints);
    if (createdAt != null) result.createdAt = createdAt;
    if (timeout != null) result.timeout = timeout;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bench.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hostname')
    ..aI(2, _omitFieldNames ? '' : 'port')
    ..aOB(3, _omitFieldNames ? '' : 'enabled')
    ..aD(4, _omitFieldNames ? '' : 'weight')
    ..aE<Status>(5, _omitFieldNames ? '' : 'status', enumValues: Status.values)
    ..pPS(6, _omitFieldNames ? '' : 'tags')
    ..aOM<TLS>(7, _omitFieldNames ? '' : 'tls', subBuilder: TLS.create)
    ..m<$core.String, $core.String>(8, _omitFieldNames ? '' : 'labels',
        entryClassName: 'Config.LabelsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('bench.v1'))
    ..pPM<Endpoint>(9, _omitFieldNames ? '' : 'endpoints',
        subBuilder: Endpoint.create)
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$1.Duration>(11, _omitFieldNames ? '' : 'timeout',
        subBuilder: $1.Duration.create)
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
  $core.String get hostname => $_getSZ(0);
  @$pb.TagNumber(1)
  set hostname($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHostname() => $_has(0);
  @$pb.TagNumber(1)
  void clearHostname() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get port => $_getIZ(1);
  @$pb.TagNumber(2)
  set port($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPort() => $_has(1);
  @$pb.TagNumber(2)
  void clearPort() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get enabled => $_getBF(2);
  @$pb.TagNumber(3)
  set enabled($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEnabled() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnabled() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get weight => $_getN(3);
  @$pb.TagNumber(4)
  set weight($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearWeight() => $_clearField(4);

  @$pb.TagNumber(5)
  Status get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(Status value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get tags => $_getList(5);

  @$pb.TagNumber(7)
  TLS get tls => $_getN(6);
  @$pb.TagNumber(7)
  set tls(TLS value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasTls() => $_has(6);
  @$pb.TagNumber(7)
  void clearTls() => $_clearField(7);
  @$pb.TagNumber(7)
  TLS ensureTls() => $_ensure(6);

  @$pb.TagNumber(8)
  $pb.PbMap<$core.String, $core.String> get labels => $_getMap(7);

  @$pb.TagNumber(9)
  $pb.PbList<Endpoint> get endpoints => $_getList(8);

  @$pb.TagNumber(10)
  $0.Timestamp get createdAt => $_getN(9);
  @$pb.TagNumber(10)
  set createdAt($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureCreatedAt() => $_ensure(9);

  @$pb.TagNumber(11)
  $1.Duration get timeout => $_getN(10);
  @$pb.TagNumber(11)
  set timeout($1.Duration value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasTimeout() => $_has(10);
  @$pb.TagNumber(11)
  void clearTimeout() => $_clearField(11);
  @$pb.TagNumber(11)
  $1.Duration ensureTimeout() => $_ensure(10);
}

class TLS extends $pb.GeneratedMessage {
  factory TLS({
    $core.String? certFile,
    $core.String? keyFile,
    $core.bool? verify,
  }) {
    final result = create();
    if (certFile != null) result.certFile = certFile;
    if (keyFile != null) result.keyFile = keyFile;
    if (verify != null) result.verify = verify;
    return result;
  }

  TLS._();

  factory TLS.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TLS.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TLS',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bench.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'certFile')
    ..aOS(2, _omitFieldNames ? '' : 'keyFile')
    ..aOB(3, _omitFieldNames ? '' : 'verify')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TLS clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TLS copyWith(void Function(TLS) updates) =>
      super.copyWith((message) => updates(message as TLS)) as TLS;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TLS create() => TLS._();
  @$core.override
  TLS createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TLS getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TLS>(create);
  static TLS? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get certFile => $_getSZ(0);
  @$pb.TagNumber(1)
  set certFile($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCertFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearCertFile() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get keyFile => $_getSZ(1);
  @$pb.TagNumber(2)
  set keyFile($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKeyFile() => $_has(1);
  @$pb.TagNumber(2)
  void clearKeyFile() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get verify => $_getBF(2);
  @$pb.TagNumber(3)
  set verify($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVerify() => $_has(2);
  @$pb.TagNumber(3)
  void clearVerify() => $_clearField(3);
}

class Endpoint extends $pb.GeneratedMessage {
  factory Endpoint({
    $core.String? path,
    $core.String? method,
    $core.int? timeoutMs,
  }) {
    final result = create();
    if (path != null) result.path = path;
    if (method != null) result.method = method;
    if (timeoutMs != null) result.timeoutMs = timeoutMs;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bench.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..aOS(2, _omitFieldNames ? '' : 'method')
    ..aI(3, _omitFieldNames ? '' : 'timeoutMs')
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
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get method => $_getSZ(1);
  @$pb.TagNumber(2)
  set method($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMethod() => $_has(1);
  @$pb.TagNumber(2)
  void clearMethod() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get timeoutMs => $_getIZ(2);
  @$pb.TagNumber(3)
  set timeoutMs($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimeoutMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimeoutMs() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
