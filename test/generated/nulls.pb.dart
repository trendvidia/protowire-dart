// This is a generated file - do not edit.
//
// Generated from nulls.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart'
    as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Inner extends $pb.GeneratedMessage {
  factory Inner({
    $core.int? x,
  }) {
    final result = create();
    if (x != null) result.x = x;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nulls.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'x')
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
  $core.int get x => $_getIZ(0);
  @$pb.TagNumber(1)
  set x($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => $_clearField(1);
}

enum Holder_K { ks, km, notSet }

class Holder extends $pb.GeneratedMessage {
  factory Holder({
    $core.int? n,
    $core.int? o,
    $core.Iterable<$core.int>? l,
    $core.String? ks,
    Inner? km,
    Inner? msg,
    $0.Int32Value? w,
    $core.Iterable<$core.MapEntry<$core.String, $core.int>>? m,
    $core.Iterable<$core.MapEntry<$core.String, Inner>>? mm,
  }) {
    final result = create();
    if (n != null) result.n = n;
    if (o != null) result.o = o;
    if (l != null) result.l.addAll(l);
    if (ks != null) result.ks = ks;
    if (km != null) result.km = km;
    if (msg != null) result.msg = msg;
    if (w != null) result.w = w;
    if (m != null) result.m.addEntries(m);
    if (mm != null) result.mm.addEntries(mm);
    return result;
  }

  Holder._();

  factory Holder.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Holder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Holder_K> _Holder_KByTag = {
    4: Holder_K.ks,
    5: Holder_K.km,
    0: Holder_K.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Holder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nulls.v1'),
      createEmptyInstance: create)
    ..oo(0, [4, 5])
    ..aI(1, _omitFieldNames ? '' : 'n')
    ..aI(2, _omitFieldNames ? '' : 'o')
    ..p<$core.int>(3, _omitFieldNames ? '' : 'l', $pb.PbFieldType.K3)
    ..aOS(4, _omitFieldNames ? '' : 'ks')
    ..aOM<Inner>(5, _omitFieldNames ? '' : 'km', subBuilder: Inner.create)
    ..aOM<Inner>(6, _omitFieldNames ? '' : 'msg', subBuilder: Inner.create)
    ..aOM<$0.Int32Value>(7, _omitFieldNames ? '' : 'w',
        subBuilder: $0.Int32Value.create)
    ..m<$core.String, $core.int>(8, _omitFieldNames ? '' : 'm',
        entryClassName: 'Holder.MEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('nulls.v1'))
    ..m<$core.String, Inner>(9, _omitFieldNames ? '' : 'mm',
        entryClassName: 'Holder.MmEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Inner.create,
        valueDefaultOrMaker: Inner.getDefault,
        packageName: const $pb.PackageName('nulls.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Holder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Holder copyWith(void Function(Holder) updates) =>
      super.copyWith((message) => updates(message as Holder)) as Holder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Holder create() => Holder._();
  @$core.override
  Holder createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Holder getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Holder>(create);
  static Holder? _defaultInstance;

  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  Holder_K whichK() => _Holder_KByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  void clearK() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get n => $_getIZ(0);
  @$pb.TagNumber(1)
  set n($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasN() => $_has(0);
  @$pb.TagNumber(1)
  void clearN() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get o => $_getIZ(1);
  @$pb.TagNumber(2)
  set o($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasO() => $_has(1);
  @$pb.TagNumber(2)
  void clearO() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.int> get l => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get ks => $_getSZ(3);
  @$pb.TagNumber(4)
  set ks($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasKs() => $_has(3);
  @$pb.TagNumber(4)
  void clearKs() => $_clearField(4);

  @$pb.TagNumber(5)
  Inner get km => $_getN(4);
  @$pb.TagNumber(5)
  set km(Inner value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasKm() => $_has(4);
  @$pb.TagNumber(5)
  void clearKm() => $_clearField(5);
  @$pb.TagNumber(5)
  Inner ensureKm() => $_ensure(4);

  @$pb.TagNumber(6)
  Inner get msg => $_getN(5);
  @$pb.TagNumber(6)
  set msg(Inner value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasMsg() => $_has(5);
  @$pb.TagNumber(6)
  void clearMsg() => $_clearField(6);
  @$pb.TagNumber(6)
  Inner ensureMsg() => $_ensure(5);

  @$pb.TagNumber(7)
  $0.Int32Value get w => $_getN(6);
  @$pb.TagNumber(7)
  set w($0.Int32Value value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasW() => $_has(6);
  @$pb.TagNumber(7)
  void clearW() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Int32Value ensureW() => $_ensure(6);

  @$pb.TagNumber(8)
  $pb.PbMap<$core.String, $core.int> get m => $_getMap(7);

  @$pb.TagNumber(9)
  $pb.PbMap<$core.String, Inner> get mm => $_getMap(8);
}

/// A null optional scalar counts as present for (pxf.required).
class Required extends $pb.GeneratedMessage {
  factory Required({
    $core.int? r,
  }) {
    final result = create();
    if (r != null) result.r = r;
    return result;
  }

  Required._();

  factory Required.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Required.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Required',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nulls.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'r')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Required clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Required copyWith(void Function(Required) updates) =>
      super.copyWith((message) => updates(message as Required)) as Required;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Required create() => Required._();
  @$core.override
  Required createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Required getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Required>(create);
  static Required? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get r => $_getIZ(0);
  @$pb.TagNumber(1)
  set r($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasR() => $_has(0);
  @$pb.TagNumber(1)
  void clearR() => $_clearField(1);
}

/// A null optional scalar is not given its (pxf.default).
class Defaulted extends $pb.GeneratedMessage {
  factory Defaulted({
    $core.int? d,
  }) {
    final result = create();
    if (d != null) result.d = d;
    return result;
  }

  Defaulted._();

  factory Defaulted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Defaulted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Defaulted',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'nulls.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'd')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Defaulted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Defaulted copyWith(void Function(Defaulted) updates) =>
      super.copyWith((message) => updates(message as Defaulted)) as Defaulted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Defaulted create() => Defaulted._();
  @$core.override
  Defaulted createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Defaulted getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Defaulted>(create);
  static Defaulted? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get d => $_getIZ(0);
  @$pb.TagNumber(1)
  set d($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasD() => $_has(0);
  @$pb.TagNumber(1)
  void clearD() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
