// This is a generated file - do not edit.
//
// Generated from pxf/secret.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Sensitive scalar with optional metadata. PXF codecs recognize this
/// type and accept two surface forms:
///
///   pw = "x"                                   # scalar shorthand
///   pw { value = "x", hint = "h" }             # explicit, with metadata
///
/// Encode emits the scalar form when both `hint` and `fingerprint` are
/// empty, and the block form otherwise so authoring metadata round-
/// trips. Repeated fields accept either form per element in a list
/// literal.
///
/// The codec routes the inner `value` field as a plain string. Any
/// memory-protection semantics (mlock, encrypted-at-rest in process,
/// wipe-on-destroy) are the consumer runtime's responsibility, not the
/// codec's. This keeps the WKT contract narrow and language-portable —
/// each protowire-* port is free to integrate Secret with whatever
/// memory-safety library is idiomatic for its language.
class Secret extends $pb.GeneratedMessage {
  factory Secret({
    $core.String? value,
    $core.String? hint,
    $core.String? fingerprint,
  }) {
    final result = create();
    if (value != null) result.value = value;
    if (hint != null) result.hint = hint;
    if (fingerprint != null) result.fingerprint = fingerprint;
    return result;
  }

  Secret._();

  factory Secret.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Secret.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Secret',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pxf'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..aOS(2, _omitFieldNames ? '' : 'hint')
    ..aOS(3, _omitFieldNames ? '' : 'fingerprint')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secret clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secret copyWith(void Function(Secret) updates) =>
      super.copyWith((message) => updates(message as Secret)) as Secret;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Secret create() => Secret._();
  @$core.override
  Secret createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Secret getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Secret>(create);
  static Secret? _defaultInstance;

  /// Plaintext value. Consumer runtimes that protect secrets in memory
  /// typically move these bytes off the proto message and into a
  /// protected region immediately after parse, then clear the field.
  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);

  /// Operator-facing description of WHAT the secret is — never the
  /// value itself. Surfaced in error messages and diagnostics.
  @$pb.TagNumber(2)
  $core.String get hint => $_getSZ(1);
  @$pb.TagNumber(2)
  set hint($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHint() => $_has(1);
  @$pb.TagNumber(2)
  void clearHint() => $_clearField(2);

  /// Optional non-reversible identifier (SHA-256 prefix, JWK
  /// thumbprint, last-N of a token). Lets diagnostics answer "did the
  /// secret change?" without exposing the value. Authoring-time only;
  /// codecs do not validate it against `value`.
  @$pb.TagNumber(3)
  $core.String get fingerprint => $_getSZ(2);
  @$pb.TagNumber(3)
  set fingerprint($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFingerprint() => $_has(2);
  @$pb.TagNumber(3)
  void clearFingerprint() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
