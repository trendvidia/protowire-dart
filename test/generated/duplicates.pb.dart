// This is a generated file - do not edit.
//
// Generated from duplicates.proto.

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
    $core.int? a,
    $core.int? b,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? tags,
  }) {
    final result = create();
    if (a != null) result.a = a;
    if (b != null) result.b = b;
    if (tags != null) result.tags.addEntries(tags);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dup.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'a')
    ..aI(2, _omitFieldNames ? '' : 'b')
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'tags',
        entryClassName: 'Inner.TagsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('dup.v1'))
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
  $core.int get a => $_getIZ(0);
  @$pb.TagNumber(1)
  set a($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasA() => $_has(0);
  @$pb.TagNumber(1)
  void clearA() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get b => $_getIZ(1);
  @$pb.TagNumber(2)
  set b($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasB() => $_has(1);
  @$pb.TagNumber(2)
  void clearB() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, $core.String> get tags => $_getMap(2);
}

enum Holder_K { km, ks, notSet }

class Holder extends $pb.GeneratedMessage {
  factory Holder({
    $core.String? s,
    $0.Int32Value? w,
    Inner? m,
    Inner? km,
    $core.String? ks,
    Inner? n,
    $core.Iterable<Inner>? items,
    $core.int? o,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? labels,
    $core.Iterable<$core.MapEntry<$core.int, $core.String>>? nums,
    $core.Iterable<$core.MapEntry<$core.String, Inner>>? inners,
  }) {
    final result = create();
    if (s != null) result.s = s;
    if (w != null) result.w = w;
    if (m != null) result.m = m;
    if (km != null) result.km = km;
    if (ks != null) result.ks = ks;
    if (n != null) result.n = n;
    if (items != null) result.items.addAll(items);
    if (o != null) result.o = o;
    if (labels != null) result.labels.addEntries(labels);
    if (nums != null) result.nums.addEntries(nums);
    if (inners != null) result.inners.addEntries(inners);
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
    4: Holder_K.km,
    5: Holder_K.ks,
    0: Holder_K.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Holder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dup.v1'),
      createEmptyInstance: create)
    ..oo(0, [4, 5])
    ..aOS(1, _omitFieldNames ? '' : 's')
    ..aOM<$0.Int32Value>(2, _omitFieldNames ? '' : 'w',
        subBuilder: $0.Int32Value.create)
    ..aOM<Inner>(3, _omitFieldNames ? '' : 'm', subBuilder: Inner.create)
    ..aOM<Inner>(4, _omitFieldNames ? '' : 'km', subBuilder: Inner.create)
    ..aOS(5, _omitFieldNames ? '' : 'ks')
    ..aOM<Inner>(6, _omitFieldNames ? '' : 'n', subBuilder: Inner.create)
    ..pPM<Inner>(7, _omitFieldNames ? '' : 'items', subBuilder: Inner.create)
    ..aI(8, _omitFieldNames ? '' : 'o')
    ..m<$core.String, $core.String>(9, _omitFieldNames ? '' : 'labels',
        entryClassName: 'Holder.LabelsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('dup.v1'))
    ..m<$core.int, $core.String>(10, _omitFieldNames ? '' : 'nums',
        entryClassName: 'Holder.NumsEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('dup.v1'))
    ..m<$core.String, Inner>(11, _omitFieldNames ? '' : 'inners',
        entryClassName: 'Holder.InnersEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Inner.create,
        valueDefaultOrMaker: Inner.getDefault,
        packageName: const $pb.PackageName('dup.v1'))
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
  $core.String get s => $_getSZ(0);
  @$pb.TagNumber(1)
  set s($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasS() => $_has(0);
  @$pb.TagNumber(1)
  void clearS() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Int32Value get w => $_getN(1);
  @$pb.TagNumber(2)
  set w($0.Int32Value value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasW() => $_has(1);
  @$pb.TagNumber(2)
  void clearW() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Int32Value ensureW() => $_ensure(1);

  @$pb.TagNumber(3)
  Inner get m => $_getN(2);
  @$pb.TagNumber(3)
  set m(Inner value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasM() => $_has(2);
  @$pb.TagNumber(3)
  void clearM() => $_clearField(3);
  @$pb.TagNumber(3)
  Inner ensureM() => $_ensure(2);

  @$pb.TagNumber(4)
  Inner get km => $_getN(3);
  @$pb.TagNumber(4)
  set km(Inner value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasKm() => $_has(3);
  @$pb.TagNumber(4)
  void clearKm() => $_clearField(4);
  @$pb.TagNumber(4)
  Inner ensureKm() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.String get ks => $_getSZ(4);
  @$pb.TagNumber(5)
  set ks($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasKs() => $_has(4);
  @$pb.TagNumber(5)
  void clearKs() => $_clearField(5);

  @$pb.TagNumber(6)
  Inner get n => $_getN(5);
  @$pb.TagNumber(6)
  set n(Inner value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasN() => $_has(5);
  @$pb.TagNumber(6)
  void clearN() => $_clearField(6);
  @$pb.TagNumber(6)
  Inner ensureN() => $_ensure(5);

  @$pb.TagNumber(7)
  $pb.PbList<Inner> get items => $_getList(6);

  @$pb.TagNumber(8)
  $core.int get o => $_getIZ(7);
  @$pb.TagNumber(8)
  set o($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasO() => $_has(7);
  @$pb.TagNumber(8)
  void clearO() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbMap<$core.String, $core.String> get labels => $_getMap(8);

  @$pb.TagNumber(10)
  $pb.PbMap<$core.int, $core.String> get nums => $_getMap(9);

  @$pb.TagNumber(11)
  $pb.PbMap<$core.String, Inner> get inners => $_getMap(10);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
