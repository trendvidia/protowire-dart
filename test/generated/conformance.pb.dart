// This is a generated file - do not edit.
//
// Generated from conformance.proto.

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

import 'pxf/bignum.pb.dart' as $3;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Inner extends $pb.GeneratedMessage {
  factory Inner({
    $core.int? n,
    $core.String? s,
  }) {
    final result = create();
    if (n != null) result.n = n;
    if (s != null) result.s = s;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'conformance.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'n')
    ..aOS(2, _omitFieldNames ? '' : 's')
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
  $core.int get n => $_getIZ(0);
  @$pb.TagNumber(1)
  set n($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasN() => $_has(0);
  @$pb.TagNumber(1)
  void clearN() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get s => $_getSZ(1);
  @$pb.TagNumber(2)
  set s($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasS() => $_has(1);
  @$pb.TagNumber(2)
  void clearS() => $_clearField(2);
}

class Values extends $pb.GeneratedMessage {
  factory Values({
    $core.int? i,
    $core.String? s,
    $core.bool? b,
    $core.List<$core.int>? y,
    $core.double? d,
    Inner? m,
    $core.int? oi,
    $0.Timestamp? ts,
    $1.Duration? du,
    $2.Int32Value? w,
    $core.Iterable<$core.MapEntry<$core.String, $1.Duration>>? md,
    $core.Iterable<$core.MapEntry<$core.String, $0.Timestamp>>? mt,
    $core.Iterable<$core.MapEntry<$core.int, $core.String>>? mi,
    $core.Iterable<$core.MapEntry<$core.String, $2.Int32Value>>? mw,
    $core.Iterable<$core.MapEntry<$core.String, Inner>>? mm,
    $core.Iterable<$1.Duration>? rd,
    $3.BigInt? bi,
    $3.Decimal? de,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? ms,
  }) {
    final result = create();
    if (i != null) result.i = i;
    if (s != null) result.s = s;
    if (b != null) result.b = b;
    if (y != null) result.y = y;
    if (d != null) result.d = d;
    if (m != null) result.m = m;
    if (oi != null) result.oi = oi;
    if (ts != null) result.ts = ts;
    if (du != null) result.du = du;
    if (w != null) result.w = w;
    if (md != null) result.md.addEntries(md);
    if (mt != null) result.mt.addEntries(mt);
    if (mi != null) result.mi.addEntries(mi);
    if (mw != null) result.mw.addEntries(mw);
    if (mm != null) result.mm.addEntries(mm);
    if (rd != null) result.rd.addAll(rd);
    if (bi != null) result.bi = bi;
    if (de != null) result.de = de;
    if (ms != null) result.ms.addEntries(ms);
    return result;
  }

  Values._();

  factory Values.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Values.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Values',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'conformance.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'i')
    ..aOS(2, _omitFieldNames ? '' : 's')
    ..aOB(3, _omitFieldNames ? '' : 'b')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'y', $pb.PbFieldType.OY)
    ..aD(5, _omitFieldNames ? '' : 'd')
    ..aOM<Inner>(6, _omitFieldNames ? '' : 'm', subBuilder: Inner.create)
    ..aI(7, _omitFieldNames ? '' : 'oi')
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'ts',
        subBuilder: $0.Timestamp.create)
    ..aOM<$1.Duration>(9, _omitFieldNames ? '' : 'du',
        subBuilder: $1.Duration.create)
    ..aOM<$2.Int32Value>(10, _omitFieldNames ? '' : 'w',
        subBuilder: $2.Int32Value.create)
    ..m<$core.String, $1.Duration>(11, _omitFieldNames ? '' : 'md',
        entryClassName: 'Values.MdEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $1.Duration.create,
        valueDefaultOrMaker: $1.Duration.getDefault,
        packageName: const $pb.PackageName('conformance.v1'))
    ..m<$core.String, $0.Timestamp>(12, _omitFieldNames ? '' : 'mt',
        entryClassName: 'Values.MtEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $0.Timestamp.create,
        valueDefaultOrMaker: $0.Timestamp.getDefault,
        packageName: const $pb.PackageName('conformance.v1'))
    ..m<$core.int, $core.String>(13, _omitFieldNames ? '' : 'mi',
        entryClassName: 'Values.MiEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('conformance.v1'))
    ..m<$core.String, $2.Int32Value>(14, _omitFieldNames ? '' : 'mw',
        entryClassName: 'Values.MwEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $2.Int32Value.create,
        valueDefaultOrMaker: $2.Int32Value.getDefault,
        packageName: const $pb.PackageName('conformance.v1'))
    ..m<$core.String, Inner>(15, _omitFieldNames ? '' : 'mm',
        entryClassName: 'Values.MmEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Inner.create,
        valueDefaultOrMaker: Inner.getDefault,
        packageName: const $pb.PackageName('conformance.v1'))
    ..pPM<$1.Duration>(16, _omitFieldNames ? '' : 'rd',
        subBuilder: $1.Duration.create)
    ..aOM<$3.BigInt>(17, _omitFieldNames ? '' : 'bi',
        subBuilder: $3.BigInt.create)
    ..aOM<$3.Decimal>(18, _omitFieldNames ? '' : 'de',
        subBuilder: $3.Decimal.create)
    ..m<$core.String, $core.String>(19, _omitFieldNames ? '' : 'ms',
        entryClassName: 'Values.MsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('conformance.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Values clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Values copyWith(void Function(Values) updates) =>
      super.copyWith((message) => updates(message as Values)) as Values;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Values create() => Values._();
  @$core.override
  Values createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Values getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Values>(create);
  static Values? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get i => $_getIZ(0);
  @$pb.TagNumber(1)
  set i($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasI() => $_has(0);
  @$pb.TagNumber(1)
  void clearI() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get s => $_getSZ(1);
  @$pb.TagNumber(2)
  set s($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasS() => $_has(1);
  @$pb.TagNumber(2)
  void clearS() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get b => $_getBF(2);
  @$pb.TagNumber(3)
  set b($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasB() => $_has(2);
  @$pb.TagNumber(3)
  void clearB() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get y => $_getN(3);
  @$pb.TagNumber(4)
  set y($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasY() => $_has(3);
  @$pb.TagNumber(4)
  void clearY() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get d => $_getN(4);
  @$pb.TagNumber(5)
  set d($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasD() => $_has(4);
  @$pb.TagNumber(5)
  void clearD() => $_clearField(5);

  @$pb.TagNumber(6)
  Inner get m => $_getN(5);
  @$pb.TagNumber(6)
  set m(Inner value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasM() => $_has(5);
  @$pb.TagNumber(6)
  void clearM() => $_clearField(6);
  @$pb.TagNumber(6)
  Inner ensureM() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.int get oi => $_getIZ(6);
  @$pb.TagNumber(7)
  set oi($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOi() => $_has(6);
  @$pb.TagNumber(7)
  void clearOi() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get ts => $_getN(7);
  @$pb.TagNumber(8)
  set ts($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasTs() => $_has(7);
  @$pb.TagNumber(8)
  void clearTs() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureTs() => $_ensure(7);

  @$pb.TagNumber(9)
  $1.Duration get du => $_getN(8);
  @$pb.TagNumber(9)
  set du($1.Duration value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasDu() => $_has(8);
  @$pb.TagNumber(9)
  void clearDu() => $_clearField(9);
  @$pb.TagNumber(9)
  $1.Duration ensureDu() => $_ensure(8);

  @$pb.TagNumber(10)
  $2.Int32Value get w => $_getN(9);
  @$pb.TagNumber(10)
  set w($2.Int32Value value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasW() => $_has(9);
  @$pb.TagNumber(10)
  void clearW() => $_clearField(10);
  @$pb.TagNumber(10)
  $2.Int32Value ensureW() => $_ensure(9);

  @$pb.TagNumber(11)
  $pb.PbMap<$core.String, $1.Duration> get md => $_getMap(10);

  @$pb.TagNumber(12)
  $pb.PbMap<$core.String, $0.Timestamp> get mt => $_getMap(11);

  @$pb.TagNumber(13)
  $pb.PbMap<$core.int, $core.String> get mi => $_getMap(12);

  @$pb.TagNumber(14)
  $pb.PbMap<$core.String, $2.Int32Value> get mw => $_getMap(13);

  @$pb.TagNumber(15)
  $pb.PbMap<$core.String, Inner> get mm => $_getMap(14);

  @$pb.TagNumber(16)
  $pb.PbList<$1.Duration> get rd => $_getList(15);

  @$pb.TagNumber(17)
  $3.BigInt get bi => $_getN(16);
  @$pb.TagNumber(17)
  set bi($3.BigInt value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasBi() => $_has(16);
  @$pb.TagNumber(17)
  void clearBi() => $_clearField(17);
  @$pb.TagNumber(17)
  $3.BigInt ensureBi() => $_ensure(16);

  @$pb.TagNumber(18)
  $3.Decimal get de => $_getN(17);
  @$pb.TagNumber(18)
  set de($3.Decimal value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasDe() => $_has(17);
  @$pb.TagNumber(18)
  void clearDe() => $_clearField(18);
  @$pb.TagNumber(18)
  $3.Decimal ensureDe() => $_ensure(17);

  @$pb.TagNumber(19)
  $pb.PbMap<$core.String, $core.String> get ms => $_getMap(18);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
