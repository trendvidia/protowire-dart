// This is a generated file - do not edit.
//
// Generated from adversarial.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Tree is self-recursive — used to construct deeply-nested PXF text and
/// PB binary inputs that exercise the decoder's MaxNestingDepth cap.
class Tree extends $pb.GeneratedMessage {
  factory Tree({
    Tree? child,
    $core.String? label,
  }) {
    final result = create();
    if (child != null) result.child = child;
    if (label != null) result.label = label;
    return result;
  }

  Tree._();

  factory Tree.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Tree.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Tree',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'adversarial.v1'),
      createEmptyInstance: create)
    ..aOM<Tree>(1, _omitFieldNames ? '' : 'child', subBuilder: Tree.create)
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tree clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tree copyWith(void Function(Tree) updates) =>
      super.copyWith((message) => updates(message as Tree)) as Tree;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tree create() => Tree._();
  @$core.override
  Tree createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Tree getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tree>(create);
  static Tree? _defaultInstance;

  @$pb.TagNumber(1)
  Tree get child => $_getN(0);
  @$pb.TagNumber(1)
  set child(Tree value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasChild() => $_has(0);
  @$pb.TagNumber(1)
  void clearChild() => $_clearField(1);
  @$pb.TagNumber(1)
  Tree ensureChild() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);
}

/// StringHolder isolates a single proto3 `string` field for the UTF-8
/// conformance tests (invalid byte sequences, lone surrogates, etc.).
class StringHolder extends $pb.GeneratedMessage {
  factory StringHolder({
    $core.String? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  StringHolder._();

  factory StringHolder.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StringHolder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StringHolder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'adversarial.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StringHolder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StringHolder copyWith(void Function(StringHolder) updates) =>
      super.copyWith((message) => updates(message as StringHolder))
          as StringHolder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StringHolder create() => StringHolder._();
  @$core.override
  StringHolder createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StringHolder getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StringHolder>(create);
  static StringHolder? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

/// BytesHolder isolates a single `bytes` field. Used for PXF base64
/// literal-length caps (the `bytes` field is the only place arbitrary
/// non-UTF-8 bytes are legal).
class BytesHolder extends $pb.GeneratedMessage {
  factory BytesHolder({
    $core.List<$core.int>? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  BytesHolder._();

  factory BytesHolder.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BytesHolder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BytesHolder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'adversarial.v1'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'value', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BytesHolder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BytesHolder copyWith(void Function(BytesHolder) updates) =>
      super.copyWith((message) => updates(message as BytesHolder))
          as BytesHolder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BytesHolder create() => BytesHolder._();
  @$core.override
  BytesHolder createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BytesHolder getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BytesHolder>(create);
  static BytesHolder? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get value => $_getN(0);
  @$pb.TagNumber(1)
  set value($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

/// BigIntHolder is a bare int64 holder — corpus inputs target the lexer's
/// numeric-literal digit cap, so the field type doesn't need to be a
/// well-known BigInt; rejection happens before the parser dispatches.
class BigIntHolder extends $pb.GeneratedMessage {
  factory BigIntHolder({
    $fixnum.Int64? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  BigIntHolder._();

  factory BigIntHolder.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BigIntHolder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BigIntHolder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'adversarial.v1'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BigIntHolder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BigIntHolder copyWith(void Function(BigIntHolder) updates) =>
      super.copyWith((message) => updates(message as BigIntHolder))
          as BigIntHolder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BigIntHolder create() => BigIntHolder._();
  @$core.override
  BigIntHolder createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BigIntHolder getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BigIntHolder>(create);
  static BigIntHolder? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get value => $_getI64(0);
  @$pb.TagNumber(1)
  set value($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
