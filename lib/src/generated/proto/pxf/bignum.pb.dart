// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
// This is a generated file - do not edit.
//
// Generated from proto/pxf/bignum.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Arbitrary-precision signed integer.
/// Wire: unsigned big-endian absolute value + sign flag.
/// PXF text: bare integer literal.
class BigInt extends $pb.GeneratedMessage {
  factory BigInt({
    $core.List<$core.int>? abs,
    $core.bool? negative,
  }) {
    final result = create();
    if (abs != null) result.abs = abs;
    if (negative != null) result.negative = negative;
    return result;
  }

  BigInt._();

  factory BigInt.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BigInt.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BigInt',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pxf'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'abs', $pb.PbFieldType.OY)
    ..aOB(2, _omitFieldNames ? '' : 'negative')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BigInt clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BigInt copyWith(void Function(BigInt) updates) =>
      super.copyWith((message) => updates(message as BigInt)) as BigInt;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BigInt create() => BigInt._();
  @$core.override
  BigInt createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BigInt getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BigInt>(create);
  static BigInt? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get abs => $_getN(0);
  @$pb.TagNumber(1)
  set abs($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAbs() => $_has(0);
  @$pb.TagNumber(1)
  void clearAbs() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get negative => $_getBF(1);
  @$pb.TagNumber(2)
  set negative($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNegative() => $_has(1);
  @$pb.TagNumber(2)
  void clearNegative() => $_clearField(2);
}

/// Arbitrary-precision exact decimal: value = (-1)^negative × unscaled × 10^(-scale).
/// Wire: unsigned big-endian unscaled value + scale + sign flag.
/// PXF text: decimal literal preserving exact scale (e.g. "1.00" has scale=2).
class Decimal extends $pb.GeneratedMessage {
  factory Decimal({
    $core.List<$core.int>? unscaled,
    $core.int? scale,
    $core.bool? negative,
  }) {
    final result = create();
    if (unscaled != null) result.unscaled = unscaled;
    if (scale != null) result.scale = scale;
    if (negative != null) result.negative = negative;
    return result;
  }

  Decimal._();

  factory Decimal.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Decimal.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Decimal',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pxf'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'unscaled', $pb.PbFieldType.OY)
    ..aI(2, _omitFieldNames ? '' : 'scale')
    ..aOB(3, _omitFieldNames ? '' : 'negative')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Decimal clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Decimal copyWith(void Function(Decimal) updates) =>
      super.copyWith((message) => updates(message as Decimal)) as Decimal;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Decimal create() => Decimal._();
  @$core.override
  Decimal createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Decimal getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Decimal>(create);
  static Decimal? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get unscaled => $_getN(0);
  @$pb.TagNumber(1)
  set unscaled($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUnscaled() => $_has(0);
  @$pb.TagNumber(1)
  void clearUnscaled() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get scale => $_getIZ(1);
  @$pb.TagNumber(2)
  set scale($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScale() => $_has(1);
  @$pb.TagNumber(2)
  void clearScale() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get negative => $_getBF(2);
  @$pb.TagNumber(3)
  set negative($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNegative() => $_has(2);
  @$pb.TagNumber(3)
  void clearNegative() => $_clearField(3);
}

/// Arbitrary-precision binary floating point.
/// Wire: unsigned big-endian integer mantissa + binary exponent + precision + sign flag.
/// PXF text: float literal with arbitrary mantissa precision.
class BigFloat extends $pb.GeneratedMessage {
  factory BigFloat({
    $core.List<$core.int>? mantissa,
    $core.int? exponent,
    $core.int? prec,
    $core.bool? negative,
  }) {
    final result = create();
    if (mantissa != null) result.mantissa = mantissa;
    if (exponent != null) result.exponent = exponent;
    if (prec != null) result.prec = prec;
    if (negative != null) result.negative = negative;
    return result;
  }

  BigFloat._();

  factory BigFloat.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BigFloat.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BigFloat',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pxf'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'mantissa', $pb.PbFieldType.OY)
    ..aI(2, _omitFieldNames ? '' : 'exponent')
    ..aI(3, _omitFieldNames ? '' : 'prec', fieldType: $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'negative')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BigFloat clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BigFloat copyWith(void Function(BigFloat) updates) =>
      super.copyWith((message) => updates(message as BigFloat)) as BigFloat;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BigFloat create() => BigFloat._();
  @$core.override
  BigFloat createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BigFloat getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BigFloat>(create);
  static BigFloat? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get mantissa => $_getN(0);
  @$pb.TagNumber(1)
  set mantissa($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMantissa() => $_has(0);
  @$pb.TagNumber(1)
  void clearMantissa() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get exponent => $_getIZ(1);
  @$pb.TagNumber(2)
  set exponent($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExponent() => $_has(1);
  @$pb.TagNumber(2)
  void clearExponent() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get prec => $_getIZ(2);
  @$pb.TagNumber(3)
  set prec($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrec() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrec() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get negative => $_getBF(3);
  @$pb.TagNumber(4)
  set negative($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNegative() => $_has(3);
  @$pb.TagNumber(4)
  void clearNegative() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
