// This is a generated file - do not edit.
//
// Generated from proto/envelope/v1/envelope.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Envelope wraps every API response with transport metadata,
/// application-level error handling, and the success payload.
///
/// Usage pattern:
///   - Success: status=200, data populated, error empty
///   - App error: status=200 (or 4xx), error populated, data empty
///   - Transport error: transport_error set, everything else empty
class Envelope extends $pb.GeneratedMessage {
  factory Envelope({
    $core.int? status,
    $core.String? transportError,
    $core.List<$core.int>? data,
    AppError? error,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (transportError != null) result.transportError = transportError;
    if (data != null) result.data = data;
    if (error != null) result.error = error;
    return result;
  }

  Envelope._();

  factory Envelope.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Envelope.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Envelope',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'envelope.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'status')
    ..aOS(2, _omitFieldNames ? '' : 'transportError')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aOM<AppError>(4, _omitFieldNames ? '' : 'error',
        subBuilder: AppError.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Envelope clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Envelope copyWith(void Function(Envelope) updates) =>
      super.copyWith((message) => updates(message as Envelope)) as Envelope;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Envelope create() => Envelope._();
  @$core.override
  Envelope createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Envelope getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Envelope>(create);
  static Envelope? _defaultInstance;

  /// Transport layer.
  @$pb.TagNumber(1)
  $core.int get status => $_getIZ(0);
  @$pb.TagNumber(1)
  set status($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get transportError => $_getSZ(1);
  @$pb.TagNumber(2)
  set transportError($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTransportError() => $_has(1);
  @$pb.TagNumber(2)
  void clearTransportError() => $_clearField(2);

  /// Application layer — the response payload on success.
  /// Encoded as nested PXF block or JSON object. The border codec
  /// flattens this into state store keys.
  @$pb.TagNumber(3)
  $core.List<$core.int> get data => $_getN(2);
  @$pb.TagNumber(3)
  set data($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => $_clearField(3);

  /// Application layer — set when business logic fails.
  @$pb.TagNumber(4)
  AppError get error => $_getN(3);
  @$pb.TagNumber(4)
  set error(AppError value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => $_clearField(4);
  @$pb.TagNumber(4)
  AppError ensureError() => $_ensure(3);
}

/// AppError represents an application-level error with a machine-readable code,
/// positional format arguments for localized display, and optional field-level details.
///
/// Localization: clients look up "error.<code>" in their string table and
/// substitute args as {0}, {1}, etc. The message field is a fallback.
class AppError extends $pb.GeneratedMessage {
  factory AppError({
    $core.String? code,
    $core.String? message,
    $core.Iterable<$core.String>? args,
    $core.Iterable<FieldError>? details,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (args != null) result.args.addAll(args);
    if (details != null) result.details.addAll(details);
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  AppError._();

  factory AppError.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AppError.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AppError',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'envelope.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..pPS(3, _omitFieldNames ? '' : 'args')
    ..pPM<FieldError>(4, _omitFieldNames ? '' : 'details',
        subBuilder: FieldError.create)
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'AppError.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('envelope.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AppError clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AppError copyWith(void Function(AppError) updates) =>
      super.copyWith((message) => updates(message as AppError)) as AppError;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AppError create() => AppError._();
  @$core.override
  AppError createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AppError getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AppError>(create);
  static AppError? _defaultInstance;

  /// Machine-readable error code: "INSUFFICIENT_FUNDS", "AUTH_REQUIRED", "NOT_FOUND".
  /// Maps to string table key "error.<code>".
  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  /// Server-side human-readable message. Used as fallback when the client's
  /// string table has no entry for this code.
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  /// Positional format arguments for the localized message template.
  /// Example: code="INSUFFICIENT_FUNDS", args=["$3.50", "$10.00"]
  ///   → string table: "error.INSUFFICIENT_FUNDS" = "Your balance is {0}, minimum is {1}"
  ///   → display: "Your balance is $3.50, minimum is $10.00"
  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get args => $_getList(2);

  /// Per-field validation errors.
  @$pb.TagNumber(4)
  $pb.PbList<FieldError> get details => $_getList(3);

  /// Arbitrary metadata for client-side logic (retry_after, request_id, etc.).
  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(4);
}

/// FieldError represents a validation error on a specific field.
/// Maps to UI form validation: the border codec can wire field errors
/// directly to Entry widget validators.
///
/// Localization: clients look up "field.<code>" in their string table
/// and substitute args as {0}, {1}, etc.
class FieldError extends $pb.GeneratedMessage {
  factory FieldError({
    $core.String? field_1,
    $core.String? code,
    $core.String? message,
    $core.Iterable<$core.String>? args,
  }) {
    final result = create();
    if (field_1 != null) result.field_1 = field_1;
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (args != null) result.args.addAll(args);
    return result;
  }

  FieldError._();

  factory FieldError.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FieldError.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldError',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'envelope.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'field')
    ..aOS(2, _omitFieldNames ? '' : 'code')
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..pPS(4, _omitFieldNames ? '' : 'args')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldError clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldError copyWith(void Function(FieldError) updates) =>
      super.copyWith((message) => updates(message as FieldError)) as FieldError;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FieldError create() => FieldError._();
  @$core.override
  FieldError createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FieldError getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldError>(create);
  static FieldError? _defaultInstance;

  /// Field path matching the proto field name or PXF key: "amount", "user.email".
  @$pb.TagNumber(1)
  $core.String get field_1 => $_getSZ(0);
  @$pb.TagNumber(1)
  set field_1($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasField_1() => $_has(0);
  @$pb.TagNumber(1)
  void clearField_1() => $_clearField(1);

  /// Machine-readable error code: "REQUIRED", "MIN_VALUE", "INVALID_FORMAT", "UNIQUE".
  /// Maps to string table key "field.<code>".
  @$pb.TagNumber(2)
  $core.String get code => $_getSZ(1);
  @$pb.TagNumber(2)
  set code($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => $_clearField(2);

  /// Server-side fallback message.
  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);

  /// Positional format arguments.
  /// Example: code="MIN_VALUE", args=["10.00"]
  ///   → string table: "field.MIN_VALUE" = "Minimum value is {0}"
  ///   → display: "Minimum value is 10.00"
  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get args => $_getList(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
