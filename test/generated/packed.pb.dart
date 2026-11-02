// This is a generated file - do not edit.
//
// Generated from packed.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'packed.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'packed.pbenum.dart';

class Lists extends $pb.GeneratedMessage {
  factory Lists({
    $core.Iterable<$core.int>? i32,
    $core.Iterable<$fixnum.Int64>? i64,
    $core.Iterable<$core.int>? u32,
    $core.Iterable<$fixnum.Int64>? u64,
    $core.Iterable<$core.int>? s32,
    $core.Iterable<$fixnum.Int64>? s64,
    $core.Iterable<$core.int>? f32,
    $core.Iterable<$fixnum.Int64>? f64,
    $core.Iterable<$core.int>? sf32,
    $core.Iterable<$fixnum.Int64>? sf64,
    $core.Iterable<$core.double>? fl,
    $core.Iterable<$core.double>? db,
    $core.Iterable<$core.bool>? bo,
    $core.Iterable<Color>? en,
  }) {
    final result = create();
    if (i32 != null) result.i32.addAll(i32);
    if (i64 != null) result.i64.addAll(i64);
    if (u32 != null) result.u32.addAll(u32);
    if (u64 != null) result.u64.addAll(u64);
    if (s32 != null) result.s32.addAll(s32);
    if (s64 != null) result.s64.addAll(s64);
    if (f32 != null) result.f32.addAll(f32);
    if (f64 != null) result.f64.addAll(f64);
    if (sf32 != null) result.sf32.addAll(sf32);
    if (sf64 != null) result.sf64.addAll(sf64);
    if (fl != null) result.fl.addAll(fl);
    if (db != null) result.db.addAll(db);
    if (bo != null) result.bo.addAll(bo);
    if (en != null) result.en.addAll(en);
    return result;
  }

  Lists._();

  factory Lists.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Lists.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Lists',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'packed.v1'),
      createEmptyInstance: create)
    ..p<$core.int>(1, _omitFieldNames ? '' : 'i32', $pb.PbFieldType.K3)
    ..p<$fixnum.Int64>(2, _omitFieldNames ? '' : 'i64', $pb.PbFieldType.K6)
    ..p<$core.int>(3, _omitFieldNames ? '' : 'u32', $pb.PbFieldType.KU3)
    ..p<$fixnum.Int64>(4, _omitFieldNames ? '' : 'u64', $pb.PbFieldType.KU6)
    ..p<$core.int>(5, _omitFieldNames ? '' : 's32', $pb.PbFieldType.KS3)
    ..p<$fixnum.Int64>(6, _omitFieldNames ? '' : 's64', $pb.PbFieldType.KS6)
    ..p<$core.int>(7, _omitFieldNames ? '' : 'f32', $pb.PbFieldType.KF3)
    ..p<$fixnum.Int64>(8, _omitFieldNames ? '' : 'f64', $pb.PbFieldType.KF6)
    ..p<$core.int>(9, _omitFieldNames ? '' : 'sf32', $pb.PbFieldType.KSF3)
    ..p<$fixnum.Int64>(10, _omitFieldNames ? '' : 'sf64', $pb.PbFieldType.KSF6)
    ..p<$core.double>(11, _omitFieldNames ? '' : 'fl', $pb.PbFieldType.KF)
    ..p<$core.double>(12, _omitFieldNames ? '' : 'db', $pb.PbFieldType.KD)
    ..p<$core.bool>(13, _omitFieldNames ? '' : 'bo', $pb.PbFieldType.KB)
    ..pc<Color>(14, _omitFieldNames ? '' : 'en', $pb.PbFieldType.KE,
        valueOf: Color.valueOf,
        enumValues: Color.values,
        defaultEnumValue: Color.COLOR_UNSPECIFIED)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Lists clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Lists copyWith(void Function(Lists) updates) =>
      super.copyWith((message) => updates(message as Lists)) as Lists;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Lists create() => Lists._();
  @$core.override
  Lists createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Lists getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Lists>(create);
  static Lists? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.int> get i32 => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<$fixnum.Int64> get i64 => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.int> get u32 => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<$fixnum.Int64> get u64 => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.int> get s32 => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<$fixnum.Int64> get s64 => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<$core.int> get f32 => $_getList(6);

  @$pb.TagNumber(8)
  $pb.PbList<$fixnum.Int64> get f64 => $_getList(7);

  @$pb.TagNumber(9)
  $pb.PbList<$core.int> get sf32 => $_getList(8);

  @$pb.TagNumber(10)
  $pb.PbList<$fixnum.Int64> get sf64 => $_getList(9);

  @$pb.TagNumber(11)
  $pb.PbList<$core.double> get fl => $_getList(10);

  @$pb.TagNumber(12)
  $pb.PbList<$core.double> get db => $_getList(11);

  @$pb.TagNumber(13)
  $pb.PbList<$core.bool> get bo => $_getList(12);

  @$pb.TagNumber(14)
  $pb.PbList<Color> get en => $_getList(13);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
