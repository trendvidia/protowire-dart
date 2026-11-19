// This is a generated file - do not edit.
//
// Generated from conf.proto.

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

class Inner extends $pb.GeneratedMessage {
  factory Inner({
    $core.String? name,
    $fixnum.Int64? n,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (n != null) result.n = n;
    return result;
  }

  Inner._();

  factory Inner.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Inner.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Inner',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'conf'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aInt64(2, _omitFieldNames ? '' : 'n')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Inner clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Inner copyWith(void Function(Inner) updates) =>
      super.copyWith((message) => updates(message as Inner)) as Inner;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Inner create() => Inner._();
  @$core.override
  Inner createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Inner getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Inner>(create);
  static Inner? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get n => $_getI64(1);
  @$pb.TagNumber(2)
  set n($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasN() => $_has(1);
  @$pb.TagNumber(2)
  void clearN() => $_clearField(2);
}

enum All_Choice { a, c, d, notSet }

class All extends $pb.GeneratedMessage {
  factory All({
    $core.String? s,
    $fixnum.Int64? i64,
    $core.int? i32,
    $fixnum.Int64? u64,
    $core.int? u32,
    $fixnum.Int64? z64,
    $core.int? z32,
    $core.bool? b,
    $core.double? f64,
    $core.double? f32,
    $core.List<$core.int>? buf,
    Inner? inner,
    $core.Iterable<Inner>? list,
    $core.Iterable<$core.int>? nums,
    $core.Iterable<$fixnum.Int64>? zigs,
    $core.Iterable<$core.double>? reals,
    $core.Iterable<$core.String>? strs,
    $core.Iterable<$core.MapEntry<$core.String, $fixnum.Int64>>? m,
    $core.Iterable<$core.MapEntry<$core.int, Inner>>? mm,
    $core.String? a,
    $fixnum.Int64? c,
    Inner? d,
    $core.Iterable<$core.bool>? flags,
    $core.Iterable<$fixnum.Int64>? negs,
    $core.Iterable<$core.MapEntry<$core.bool, $core.bool>>? bm,
  }) {
    final result = create();
    if (s != null) result.s = s;
    if (i64 != null) result.i64 = i64;
    if (i32 != null) result.i32 = i32;
    if (u64 != null) result.u64 = u64;
    if (u32 != null) result.u32 = u32;
    if (z64 != null) result.z64 = z64;
    if (z32 != null) result.z32 = z32;
    if (b != null) result.b = b;
    if (f64 != null) result.f64 = f64;
    if (f32 != null) result.f32 = f32;
    if (buf != null) result.buf = buf;
    if (inner != null) result.inner = inner;
    if (list != null) result.list.addAll(list);
    if (nums != null) result.nums.addAll(nums);
    if (zigs != null) result.zigs.addAll(zigs);
    if (reals != null) result.reals.addAll(reals);
    if (strs != null) result.strs.addAll(strs);
    if (m != null) result.m.addEntries(m);
    if (mm != null) result.mm.addEntries(mm);
    if (a != null) result.a = a;
    if (c != null) result.c = c;
    if (d != null) result.d = d;
    if (flags != null) result.flags.addAll(flags);
    if (negs != null) result.negs.addAll(negs);
    if (bm != null) result.bm.addEntries(bm);
    return result;
  }

  All._();

  factory All.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory All.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, All_Choice> _All_ChoiceByTag = {
    20: All_Choice.a,
    21: All_Choice.c,
    22: All_Choice.d,
    0: All_Choice.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'All',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'conf'),
      createEmptyInstance: create)
    ..oo(0, [20, 21, 22])
    ..aOS(1, _omitFieldNames ? '' : 's')
    ..aInt64(2, _omitFieldNames ? '' : 'i64')
    ..aI(3, _omitFieldNames ? '' : 'i32')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'u64', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(5, _omitFieldNames ? '' : 'u32', fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(6, _omitFieldNames ? '' : 'z64', $pb.PbFieldType.OS6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(7, _omitFieldNames ? '' : 'z32', fieldType: $pb.PbFieldType.OS3)
    ..aOB(8, _omitFieldNames ? '' : 'b')
    ..aD(9, _omitFieldNames ? '' : 'f64')
    ..aD(10, _omitFieldNames ? '' : 'f32', fieldType: $pb.PbFieldType.OF)
    ..a<$core.List<$core.int>>(
        11, _omitFieldNames ? '' : 'buf', $pb.PbFieldType.OY)
    ..aOM<Inner>(12, _omitFieldNames ? '' : 'inner', subBuilder: Inner.create)
    ..pPM<Inner>(13, _omitFieldNames ? '' : 'list', subBuilder: Inner.create)
    ..p<$core.int>(14, _omitFieldNames ? '' : 'nums', $pb.PbFieldType.KU3)
    ..p<$fixnum.Int64>(15, _omitFieldNames ? '' : 'zigs', $pb.PbFieldType.KS6)
    ..p<$core.double>(16, _omitFieldNames ? '' : 'reals', $pb.PbFieldType.KF)
    ..pPS(17, _omitFieldNames ? '' : 'strs')
    ..m<$core.String, $fixnum.Int64>(18, _omitFieldNames ? '' : 'm',
        entryClassName: 'All.MEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O6,
        packageName: const $pb.PackageName('conf'))
    ..m<$core.int, Inner>(19, _omitFieldNames ? '' : 'mm',
        entryClassName: 'All.MmEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Inner.create,
        valueDefaultOrMaker: Inner.getDefault,
        packageName: const $pb.PackageName('conf'))
    ..aOS(20, _omitFieldNames ? '' : 'a')
    ..aInt64(21, _omitFieldNames ? '' : 'c')
    ..aOM<Inner>(22, _omitFieldNames ? '' : 'd', subBuilder: Inner.create)
    ..p<$core.bool>(23, _omitFieldNames ? '' : 'flags', $pb.PbFieldType.KB)
    ..p<$fixnum.Int64>(24, _omitFieldNames ? '' : 'negs', $pb.PbFieldType.K6)
    ..m<$core.bool, $core.bool>(25, _omitFieldNames ? '' : 'bm',
        entryClassName: 'All.BmEntry',
        keyFieldType: $pb.PbFieldType.OB,
        valueFieldType: $pb.PbFieldType.OB,
        packageName: const $pb.PackageName('conf'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  All clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  All copyWith(void Function(All) updates) =>
      super.copyWith((message) => updates(message as All)) as All;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static All create() => All._();
  @$core.override
  All createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static All getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<All>(create);
  static All? _defaultInstance;

  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  @$pb.TagNumber(22)
  All_Choice whichChoice() => _All_ChoiceByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  @$pb.TagNumber(22)
  void clearChoice() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get s => $_getSZ(0);
  @$pb.TagNumber(1)
  set s($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasS() => $_has(0);
  @$pb.TagNumber(1)
  void clearS() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get i64 => $_getI64(1);
  @$pb.TagNumber(2)
  set i64($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasI64() => $_has(1);
  @$pb.TagNumber(2)
  void clearI64() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get i32 => $_getIZ(2);
  @$pb.TagNumber(3)
  set i32($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasI32() => $_has(2);
  @$pb.TagNumber(3)
  void clearI32() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get u64 => $_getI64(3);
  @$pb.TagNumber(4)
  set u64($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasU64() => $_has(3);
  @$pb.TagNumber(4)
  void clearU64() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get u32 => $_getIZ(4);
  @$pb.TagNumber(5)
  set u32($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasU32() => $_has(4);
  @$pb.TagNumber(5)
  void clearU32() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get z64 => $_getI64(5);
  @$pb.TagNumber(6)
  set z64($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasZ64() => $_has(5);
  @$pb.TagNumber(6)
  void clearZ64() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get z32 => $_getIZ(6);
  @$pb.TagNumber(7)
  set z32($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasZ32() => $_has(6);
  @$pb.TagNumber(7)
  void clearZ32() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get b => $_getBF(7);
  @$pb.TagNumber(8)
  set b($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasB() => $_has(7);
  @$pb.TagNumber(8)
  void clearB() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get f64 => $_getN(8);
  @$pb.TagNumber(9)
  set f64($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasF64() => $_has(8);
  @$pb.TagNumber(9)
  void clearF64() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get f32 => $_getN(9);
  @$pb.TagNumber(10)
  set f32($core.double value) => $_setFloat(9, value);
  @$pb.TagNumber(10)
  $core.bool hasF32() => $_has(9);
  @$pb.TagNumber(10)
  void clearF32() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.List<$core.int> get buf => $_getN(10);
  @$pb.TagNumber(11)
  set buf($core.List<$core.int> value) => $_setBytes(10, value);
  @$pb.TagNumber(11)
  $core.bool hasBuf() => $_has(10);
  @$pb.TagNumber(11)
  void clearBuf() => $_clearField(11);

  @$pb.TagNumber(12)
  Inner get inner => $_getN(11);
  @$pb.TagNumber(12)
  set inner(Inner value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasInner() => $_has(11);
  @$pb.TagNumber(12)
  void clearInner() => $_clearField(12);
  @$pb.TagNumber(12)
  Inner ensureInner() => $_ensure(11);

  @$pb.TagNumber(13)
  $pb.PbList<Inner> get list => $_getList(12);

  @$pb.TagNumber(14)
  $pb.PbList<$core.int> get nums => $_getList(13);

  @$pb.TagNumber(15)
  $pb.PbList<$fixnum.Int64> get zigs => $_getList(14);

  @$pb.TagNumber(16)
  $pb.PbList<$core.double> get reals => $_getList(15);

  @$pb.TagNumber(17)
  $pb.PbList<$core.String> get strs => $_getList(16);

  @$pb.TagNumber(18)
  $pb.PbMap<$core.String, $fixnum.Int64> get m => $_getMap(17);

  @$pb.TagNumber(19)
  $pb.PbMap<$core.int, Inner> get mm => $_getMap(18);

  @$pb.TagNumber(20)
  $core.String get a => $_getSZ(19);
  @$pb.TagNumber(20)
  set a($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasA() => $_has(19);
  @$pb.TagNumber(20)
  void clearA() => $_clearField(20);

  @$pb.TagNumber(21)
  $fixnum.Int64 get c => $_getI64(20);
  @$pb.TagNumber(21)
  set c($fixnum.Int64 value) => $_setInt64(20, value);
  @$pb.TagNumber(21)
  $core.bool hasC() => $_has(20);
  @$pb.TagNumber(21)
  void clearC() => $_clearField(21);

  @$pb.TagNumber(22)
  Inner get d => $_getN(21);
  @$pb.TagNumber(22)
  set d(Inner value) => $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasD() => $_has(21);
  @$pb.TagNumber(22)
  void clearD() => $_clearField(22);
  @$pb.TagNumber(22)
  Inner ensureD() => $_ensure(21);

  @$pb.TagNumber(23)
  $pb.PbList<$core.bool> get flags => $_getList(22);

  @$pb.TagNumber(24)
  $pb.PbList<$fixnum.Int64> get negs => $_getList(23);

  @$pb.TagNumber(25)
  $pb.PbMap<$core.bool, $core.bool> get bm => $_getMap(24);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
