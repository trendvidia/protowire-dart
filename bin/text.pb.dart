// This is a generated file - do not edit.
//
// Generated from text.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/duration.pb.dart'
    as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart'
    as $2;

import 'package:protowire/src/generated/proto/pxf/bignum.pb.dart' as $3;
import 'pxf/secret.pb.dart' as $4;
import 'text.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'text.pbenum.dart';

class Item extends $pb.GeneratedMessage {
  factory Item({
    $core.String? name,
    $core.int? weight,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (weight != null) result.weight = weight;
    return result;
  }

  Item._();

  factory Item.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Item.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Item',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'text.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aI(2, _omitFieldNames ? '' : 'weight')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Item clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Item copyWith(void Function(Item) updates) =>
      super.copyWith((message) => updates(message as Item)) as Item;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Item create() => Item._();
  @$core.override
  Item createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Item getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Item>(create);
  static Item? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get weight => $_getIZ(1);
  @$pb.TagNumber(2)
  set weight($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearWeight() => $_clearField(2);
}

class Keyed extends $pb.GeneratedMessage {
  factory Keyed({
    $core.String? id,
    $core.int? weight,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (weight != null) result.weight = weight;
    return result;
  }

  Keyed._();

  factory Keyed.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Keyed.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Keyed',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'text.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'weight')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Keyed clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Keyed copyWith(void Function(Keyed) updates) =>
      super.copyWith((message) => updates(message as Keyed)) as Keyed;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Keyed create() => Keyed._();
  @$core.override
  Keyed createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Keyed getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Keyed>(create);
  static Keyed? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get weight => $_getIZ(1);
  @$pb.TagNumber(2)
  set weight($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearWeight() => $_clearField(2);
}

class Scalars extends $pb.GeneratedMessage {
  factory Scalars({
    $core.double? fDouble,
    $core.double? fFloat,
    $fixnum.Int64? fInt64,
    $fixnum.Int64? fUint64,
    $core.int? fInt32,
    $fixnum.Int64? fFixed64,
    $core.int? fFixed32,
    $core.bool? fBool,
    $core.String? fString,
    $core.List<$core.int>? fBytes,
    $core.int? fUint32,
    Color? fEnum,
    $core.int? fSfixed32,
    $fixnum.Int64? fSfixed64,
    $core.int? fSint32,
    $fixnum.Int64? fSint64,
  }) {
    final result = create();
    if (fDouble != null) result.fDouble = fDouble;
    if (fFloat != null) result.fFloat = fFloat;
    if (fInt64 != null) result.fInt64 = fInt64;
    if (fUint64 != null) result.fUint64 = fUint64;
    if (fInt32 != null) result.fInt32 = fInt32;
    if (fFixed64 != null) result.fFixed64 = fFixed64;
    if (fFixed32 != null) result.fFixed32 = fFixed32;
    if (fBool != null) result.fBool = fBool;
    if (fString != null) result.fString = fString;
    if (fBytes != null) result.fBytes = fBytes;
    if (fUint32 != null) result.fUint32 = fUint32;
    if (fEnum != null) result.fEnum = fEnum;
    if (fSfixed32 != null) result.fSfixed32 = fSfixed32;
    if (fSfixed64 != null) result.fSfixed64 = fSfixed64;
    if (fSint32 != null) result.fSint32 = fSint32;
    if (fSint64 != null) result.fSint64 = fSint64;
    return result;
  }

  Scalars._();

  factory Scalars.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Scalars.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Scalars',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'text.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'fDouble')
    ..aD(2, _omitFieldNames ? '' : 'fFloat', fieldType: $pb.PbFieldType.OF)
    ..aInt64(3, _omitFieldNames ? '' : 'fInt64')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'fUint64', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(5, _omitFieldNames ? '' : 'fInt32')
    ..a<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'fFixed64', $pb.PbFieldType.OF6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(7, _omitFieldNames ? '' : 'fFixed32', fieldType: $pb.PbFieldType.OF3)
    ..aOB(8, _omitFieldNames ? '' : 'fBool')
    ..aOS(9, _omitFieldNames ? '' : 'fString')
    ..a<$core.List<$core.int>>(
        12, _omitFieldNames ? '' : 'fBytes', $pb.PbFieldType.OY)
    ..aI(13, _omitFieldNames ? '' : 'fUint32', fieldType: $pb.PbFieldType.OU3)
    ..aE<Color>(14, _omitFieldNames ? '' : 'fEnum', enumValues: Color.values)
    ..aI(15, _omitFieldNames ? '' : 'fSfixed32',
        fieldType: $pb.PbFieldType.OSF3)
    ..a<$fixnum.Int64>(
        16, _omitFieldNames ? '' : 'fSfixed64', $pb.PbFieldType.OSF6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(17, _omitFieldNames ? '' : 'fSint32', fieldType: $pb.PbFieldType.OS3)
    ..a<$fixnum.Int64>(
        18, _omitFieldNames ? '' : 'fSint64', $pb.PbFieldType.OS6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Scalars clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Scalars copyWith(void Function(Scalars) updates) =>
      super.copyWith((message) => updates(message as Scalars)) as Scalars;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Scalars create() => Scalars._();
  @$core.override
  Scalars createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Scalars getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Scalars>(create);
  static Scalars? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get fDouble => $_getN(0);
  @$pb.TagNumber(1)
  set fDouble($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFDouble() => $_has(0);
  @$pb.TagNumber(1)
  void clearFDouble() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get fFloat => $_getN(1);
  @$pb.TagNumber(2)
  set fFloat($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFFloat() => $_has(1);
  @$pb.TagNumber(2)
  void clearFFloat() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get fInt64 => $_getI64(2);
  @$pb.TagNumber(3)
  set fInt64($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFInt64() => $_has(2);
  @$pb.TagNumber(3)
  void clearFInt64() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get fUint64 => $_getI64(3);
  @$pb.TagNumber(4)
  set fUint64($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFUint64() => $_has(3);
  @$pb.TagNumber(4)
  void clearFUint64() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get fInt32 => $_getIZ(4);
  @$pb.TagNumber(5)
  set fInt32($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFInt32() => $_has(4);
  @$pb.TagNumber(5)
  void clearFInt32() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get fFixed64 => $_getI64(5);
  @$pb.TagNumber(6)
  set fFixed64($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFFixed64() => $_has(5);
  @$pb.TagNumber(6)
  void clearFFixed64() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get fFixed32 => $_getIZ(6);
  @$pb.TagNumber(7)
  set fFixed32($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFFixed32() => $_has(6);
  @$pb.TagNumber(7)
  void clearFFixed32() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get fBool => $_getBF(7);
  @$pb.TagNumber(8)
  set fBool($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFBool() => $_has(7);
  @$pb.TagNumber(8)
  void clearFBool() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get fString => $_getSZ(8);
  @$pb.TagNumber(9)
  set fString($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFString() => $_has(8);
  @$pb.TagNumber(9)
  void clearFString() => $_clearField(9);

  @$pb.TagNumber(12)
  $core.List<$core.int> get fBytes => $_getN(9);
  @$pb.TagNumber(12)
  set fBytes($core.List<$core.int> value) => $_setBytes(9, value);
  @$pb.TagNumber(12)
  $core.bool hasFBytes() => $_has(9);
  @$pb.TagNumber(12)
  void clearFBytes() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get fUint32 => $_getIZ(10);
  @$pb.TagNumber(13)
  set fUint32($core.int value) => $_setUnsignedInt32(10, value);
  @$pb.TagNumber(13)
  $core.bool hasFUint32() => $_has(10);
  @$pb.TagNumber(13)
  void clearFUint32() => $_clearField(13);

  @$pb.TagNumber(14)
  Color get fEnum => $_getN(11);
  @$pb.TagNumber(14)
  set fEnum(Color value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasFEnum() => $_has(11);
  @$pb.TagNumber(14)
  void clearFEnum() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.int get fSfixed32 => $_getIZ(12);
  @$pb.TagNumber(15)
  set fSfixed32($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(15)
  $core.bool hasFSfixed32() => $_has(12);
  @$pb.TagNumber(15)
  void clearFSfixed32() => $_clearField(15);

  @$pb.TagNumber(16)
  $fixnum.Int64 get fSfixed64 => $_getI64(13);
  @$pb.TagNumber(16)
  set fSfixed64($fixnum.Int64 value) => $_setInt64(13, value);
  @$pb.TagNumber(16)
  $core.bool hasFSfixed64() => $_has(13);
  @$pb.TagNumber(16)
  void clearFSfixed64() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.int get fSint32 => $_getIZ(14);
  @$pb.TagNumber(17)
  set fSint32($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(17)
  $core.bool hasFSint32() => $_has(14);
  @$pb.TagNumber(17)
  void clearFSint32() => $_clearField(17);

  @$pb.TagNumber(18)
  $fixnum.Int64 get fSint64 => $_getI64(15);
  @$pb.TagNumber(18)
  set fSint64($fixnum.Int64 value) => $_setInt64(15, value);
  @$pb.TagNumber(18)
  $core.bool hasFSint64() => $_has(15);
  @$pb.TagNumber(18)
  void clearFSint64() => $_clearField(18);
}

enum Shapes_Choice { choiceString, choiceItem, notSet }

class Shapes extends $pb.GeneratedMessage {
  factory Shapes({
    Item? one,
    $core.String? optString,
    $core.int? optInt,
    $core.Iterable<$core.int>? ints,
    $core.Iterable<$core.String>? strings,
    $core.Iterable<Item>? items,
    $core.Iterable<Color>? colors,
    $core.Iterable<Keyed>? keyed,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? byString,
    $core.Iterable<$core.MapEntry<$core.int, $core.String>>? byInt,
    $core.Iterable<$core.MapEntry<$core.bool, $core.String>>? byBool,
    $core.Iterable<$core.MapEntry<$core.String, Item>>? byItem,
    $core.String? choiceString,
    Item? choiceItem,
  }) {
    final result = create();
    if (one != null) result.one = one;
    if (optString != null) result.optString = optString;
    if (optInt != null) result.optInt = optInt;
    if (ints != null) result.ints.addAll(ints);
    if (strings != null) result.strings.addAll(strings);
    if (items != null) result.items.addAll(items);
    if (colors != null) result.colors.addAll(colors);
    if (keyed != null) result.keyed.addAll(keyed);
    if (byString != null) result.byString.addEntries(byString);
    if (byInt != null) result.byInt.addEntries(byInt);
    if (byBool != null) result.byBool.addEntries(byBool);
    if (byItem != null) result.byItem.addEntries(byItem);
    if (choiceString != null) result.choiceString = choiceString;
    if (choiceItem != null) result.choiceItem = choiceItem;
    return result;
  }

  Shapes._();

  factory Shapes.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Shapes.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Shapes_Choice> _Shapes_ChoiceByTag = {
    13: Shapes_Choice.choiceString,
    14: Shapes_Choice.choiceItem,
    0: Shapes_Choice.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Shapes',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'text.v1'),
      createEmptyInstance: create)
    ..oo(0, [13, 14])
    ..aOM<Item>(1, _omitFieldNames ? '' : 'one', subBuilder: Item.create)
    ..aOS(2, _omitFieldNames ? '' : 'optString')
    ..aI(3, _omitFieldNames ? '' : 'optInt')
    ..p<$core.int>(4, _omitFieldNames ? '' : 'ints', $pb.PbFieldType.K3)
    ..pPS(5, _omitFieldNames ? '' : 'strings')
    ..pPM<Item>(6, _omitFieldNames ? '' : 'items', subBuilder: Item.create)
    ..pc<Color>(7, _omitFieldNames ? '' : 'colors', $pb.PbFieldType.KE,
        valueOf: Color.valueOf,
        enumValues: Color.values,
        defaultEnumValue: Color.COLOR_UNSPECIFIED)
    ..pPM<Keyed>(8, _omitFieldNames ? '' : 'keyed', subBuilder: Keyed.create)
    ..m<$core.String, $core.String>(9, _omitFieldNames ? '' : 'byString',
        entryClassName: 'Shapes.ByStringEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('text.v1'))
    ..m<$core.int, $core.String>(10, _omitFieldNames ? '' : 'byInt',
        entryClassName: 'Shapes.ByIntEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('text.v1'))
    ..m<$core.bool, $core.String>(11, _omitFieldNames ? '' : 'byBool',
        entryClassName: 'Shapes.ByBoolEntry',
        keyFieldType: $pb.PbFieldType.OB,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('text.v1'))
    ..m<$core.String, Item>(12, _omitFieldNames ? '' : 'byItem',
        entryClassName: 'Shapes.ByItemEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Item.create,
        valueDefaultOrMaker: Item.getDefault,
        packageName: const $pb.PackageName('text.v1'))
    ..aOS(13, _omitFieldNames ? '' : 'choiceString')
    ..aOM<Item>(14, _omitFieldNames ? '' : 'choiceItem',
        subBuilder: Item.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Shapes clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Shapes copyWith(void Function(Shapes) updates) =>
      super.copyWith((message) => updates(message as Shapes)) as Shapes;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Shapes create() => Shapes._();
  @$core.override
  Shapes createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Shapes getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Shapes>(create);
  static Shapes? _defaultInstance;

  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  Shapes_Choice whichChoice() => _Shapes_ChoiceByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  void clearChoice() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Item get one => $_getN(0);
  @$pb.TagNumber(1)
  set one(Item value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOne() => $_has(0);
  @$pb.TagNumber(1)
  void clearOne() => $_clearField(1);
  @$pb.TagNumber(1)
  Item ensureOne() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get optString => $_getSZ(1);
  @$pb.TagNumber(2)
  set optString($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOptString() => $_has(1);
  @$pb.TagNumber(2)
  void clearOptString() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get optInt => $_getIZ(2);
  @$pb.TagNumber(3)
  set optInt($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOptInt() => $_has(2);
  @$pb.TagNumber(3)
  void clearOptInt() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.int> get ints => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get strings => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<Item> get items => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<Color> get colors => $_getList(6);

  @$pb.TagNumber(8)
  $pb.PbList<Keyed> get keyed => $_getList(7);

  @$pb.TagNumber(9)
  $pb.PbMap<$core.String, $core.String> get byString => $_getMap(8);

  @$pb.TagNumber(10)
  $pb.PbMap<$core.int, $core.String> get byInt => $_getMap(9);

  @$pb.TagNumber(11)
  $pb.PbMap<$core.bool, $core.String> get byBool => $_getMap(10);

  @$pb.TagNumber(12)
  $pb.PbMap<$core.String, Item> get byItem => $_getMap(11);

  @$pb.TagNumber(13)
  $core.String get choiceString => $_getSZ(12);
  @$pb.TagNumber(13)
  set choiceString($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasChoiceString() => $_has(12);
  @$pb.TagNumber(13)
  void clearChoiceString() => $_clearField(13);

  @$pb.TagNumber(14)
  Item get choiceItem => $_getN(13);
  @$pb.TagNumber(14)
  set choiceItem(Item value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasChoiceItem() => $_has(13);
  @$pb.TagNumber(14)
  void clearChoiceItem() => $_clearField(14);
  @$pb.TagNumber(14)
  Item ensureChoiceItem() => $_ensure(13);
}

class WellKnown extends $pb.GeneratedMessage {
  factory WellKnown({
    $0.Timestamp? ts,
    $1.Duration? dur,
    $2.StringValue? strW,
    $2.BytesValue? bytesW,
    $2.BoolValue? boolW,
    $2.Int32Value? i32W,
    $2.Int64Value? i64W,
    $2.UInt32Value? u32W,
    $2.UInt64Value? u64W,
    $2.FloatValue? fltW,
    $2.DoubleValue? dblW,
    $3.BigInt? bigInt,
    $3.Decimal? dec,
    $3.BigFloat? bigFloat,
    $4.Secret? secret,
    $core.Iterable<$1.Duration>? durs,
    $core.Iterable<$core.MapEntry<$core.String, $0.Timestamp>>? stamps,
    $core.Iterable<$core.MapEntry<$core.String, $3.Decimal>>? decs,
  }) {
    final result = create();
    if (ts != null) result.ts = ts;
    if (dur != null) result.dur = dur;
    if (strW != null) result.strW = strW;
    if (bytesW != null) result.bytesW = bytesW;
    if (boolW != null) result.boolW = boolW;
    if (i32W != null) result.i32W = i32W;
    if (i64W != null) result.i64W = i64W;
    if (u32W != null) result.u32W = u32W;
    if (u64W != null) result.u64W = u64W;
    if (fltW != null) result.fltW = fltW;
    if (dblW != null) result.dblW = dblW;
    if (bigInt != null) result.bigInt = bigInt;
    if (dec != null) result.dec = dec;
    if (bigFloat != null) result.bigFloat = bigFloat;
    if (secret != null) result.secret = secret;
    if (durs != null) result.durs.addAll(durs);
    if (stamps != null) result.stamps.addEntries(stamps);
    if (decs != null) result.decs.addEntries(decs);
    return result;
  }

  WellKnown._();

  factory WellKnown.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WellKnown.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WellKnown',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'text.v1'),
      createEmptyInstance: create)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'ts',
        subBuilder: $0.Timestamp.create)
    ..aOM<$1.Duration>(2, _omitFieldNames ? '' : 'dur',
        subBuilder: $1.Duration.create)
    ..aOM<$2.StringValue>(3, _omitFieldNames ? '' : 'strW',
        subBuilder: $2.StringValue.create)
    ..aOM<$2.BytesValue>(4, _omitFieldNames ? '' : 'bytesW',
        subBuilder: $2.BytesValue.create)
    ..aOM<$2.BoolValue>(5, _omitFieldNames ? '' : 'boolW',
        subBuilder: $2.BoolValue.create)
    ..aOM<$2.Int32Value>(6, _omitFieldNames ? '' : 'i32W',
        subBuilder: $2.Int32Value.create)
    ..aOM<$2.Int64Value>(7, _omitFieldNames ? '' : 'i64W',
        subBuilder: $2.Int64Value.create)
    ..aOM<$2.UInt32Value>(8, _omitFieldNames ? '' : 'u32W',
        subBuilder: $2.UInt32Value.create)
    ..aOM<$2.UInt64Value>(9, _omitFieldNames ? '' : 'u64W',
        subBuilder: $2.UInt64Value.create)
    ..aOM<$2.FloatValue>(10, _omitFieldNames ? '' : 'fltW',
        subBuilder: $2.FloatValue.create)
    ..aOM<$2.DoubleValue>(11, _omitFieldNames ? '' : 'dblW',
        subBuilder: $2.DoubleValue.create)
    ..aOM<$3.BigInt>(12, _omitFieldNames ? '' : 'bigInt',
        subBuilder: $3.BigInt.create)
    ..aOM<$3.Decimal>(13, _omitFieldNames ? '' : 'dec',
        subBuilder: $3.Decimal.create)
    ..aOM<$3.BigFloat>(14, _omitFieldNames ? '' : 'bigFloat',
        subBuilder: $3.BigFloat.create)
    ..aOM<$4.Secret>(15, _omitFieldNames ? '' : 'secret',
        subBuilder: $4.Secret.create)
    ..pPM<$1.Duration>(16, _omitFieldNames ? '' : 'durs',
        subBuilder: $1.Duration.create)
    ..m<$core.String, $0.Timestamp>(17, _omitFieldNames ? '' : 'stamps',
        entryClassName: 'WellKnown.StampsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $0.Timestamp.create,
        valueDefaultOrMaker: $0.Timestamp.getDefault,
        packageName: const $pb.PackageName('text.v1'))
    ..m<$core.String, $3.Decimal>(18, _omitFieldNames ? '' : 'decs',
        entryClassName: 'WellKnown.DecsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: $3.Decimal.create,
        valueDefaultOrMaker: $3.Decimal.getDefault,
        packageName: const $pb.PackageName('text.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WellKnown clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WellKnown copyWith(void Function(WellKnown) updates) =>
      super.copyWith((message) => updates(message as WellKnown)) as WellKnown;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WellKnown create() => WellKnown._();
  @$core.override
  WellKnown createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WellKnown getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WellKnown>(create);
  static WellKnown? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Timestamp get ts => $_getN(0);
  @$pb.TagNumber(1)
  set ts($0.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTs() => $_has(0);
  @$pb.TagNumber(1)
  void clearTs() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureTs() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.Duration get dur => $_getN(1);
  @$pb.TagNumber(2)
  set dur($1.Duration value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDur() => $_has(1);
  @$pb.TagNumber(2)
  void clearDur() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Duration ensureDur() => $_ensure(1);

  @$pb.TagNumber(3)
  $2.StringValue get strW => $_getN(2);
  @$pb.TagNumber(3)
  set strW($2.StringValue value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStrW() => $_has(2);
  @$pb.TagNumber(3)
  void clearStrW() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.StringValue ensureStrW() => $_ensure(2);

  @$pb.TagNumber(4)
  $2.BytesValue get bytesW => $_getN(3);
  @$pb.TagNumber(4)
  set bytesW($2.BytesValue value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasBytesW() => $_has(3);
  @$pb.TagNumber(4)
  void clearBytesW() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.BytesValue ensureBytesW() => $_ensure(3);

  @$pb.TagNumber(5)
  $2.BoolValue get boolW => $_getN(4);
  @$pb.TagNumber(5)
  set boolW($2.BoolValue value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasBoolW() => $_has(4);
  @$pb.TagNumber(5)
  void clearBoolW() => $_clearField(5);
  @$pb.TagNumber(5)
  $2.BoolValue ensureBoolW() => $_ensure(4);

  @$pb.TagNumber(6)
  $2.Int32Value get i32W => $_getN(5);
  @$pb.TagNumber(6)
  set i32W($2.Int32Value value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasI32W() => $_has(5);
  @$pb.TagNumber(6)
  void clearI32W() => $_clearField(6);
  @$pb.TagNumber(6)
  $2.Int32Value ensureI32W() => $_ensure(5);

  @$pb.TagNumber(7)
  $2.Int64Value get i64W => $_getN(6);
  @$pb.TagNumber(7)
  set i64W($2.Int64Value value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasI64W() => $_has(6);
  @$pb.TagNumber(7)
  void clearI64W() => $_clearField(7);
  @$pb.TagNumber(7)
  $2.Int64Value ensureI64W() => $_ensure(6);

  @$pb.TagNumber(8)
  $2.UInt32Value get u32W => $_getN(7);
  @$pb.TagNumber(8)
  set u32W($2.UInt32Value value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasU32W() => $_has(7);
  @$pb.TagNumber(8)
  void clearU32W() => $_clearField(8);
  @$pb.TagNumber(8)
  $2.UInt32Value ensureU32W() => $_ensure(7);

  @$pb.TagNumber(9)
  $2.UInt64Value get u64W => $_getN(8);
  @$pb.TagNumber(9)
  set u64W($2.UInt64Value value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasU64W() => $_has(8);
  @$pb.TagNumber(9)
  void clearU64W() => $_clearField(9);
  @$pb.TagNumber(9)
  $2.UInt64Value ensureU64W() => $_ensure(8);

  @$pb.TagNumber(10)
  $2.FloatValue get fltW => $_getN(9);
  @$pb.TagNumber(10)
  set fltW($2.FloatValue value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasFltW() => $_has(9);
  @$pb.TagNumber(10)
  void clearFltW() => $_clearField(10);
  @$pb.TagNumber(10)
  $2.FloatValue ensureFltW() => $_ensure(9);

  @$pb.TagNumber(11)
  $2.DoubleValue get dblW => $_getN(10);
  @$pb.TagNumber(11)
  set dblW($2.DoubleValue value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasDblW() => $_has(10);
  @$pb.TagNumber(11)
  void clearDblW() => $_clearField(11);
  @$pb.TagNumber(11)
  $2.DoubleValue ensureDblW() => $_ensure(10);

  @$pb.TagNumber(12)
  $3.BigInt get bigInt => $_getN(11);
  @$pb.TagNumber(12)
  set bigInt($3.BigInt value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasBigInt() => $_has(11);
  @$pb.TagNumber(12)
  void clearBigInt() => $_clearField(12);
  @$pb.TagNumber(12)
  $3.BigInt ensureBigInt() => $_ensure(11);

  @$pb.TagNumber(13)
  $3.Decimal get dec => $_getN(12);
  @$pb.TagNumber(13)
  set dec($3.Decimal value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasDec() => $_has(12);
  @$pb.TagNumber(13)
  void clearDec() => $_clearField(13);
  @$pb.TagNumber(13)
  $3.Decimal ensureDec() => $_ensure(12);

  @$pb.TagNumber(14)
  $3.BigFloat get bigFloat => $_getN(13);
  @$pb.TagNumber(14)
  set bigFloat($3.BigFloat value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasBigFloat() => $_has(13);
  @$pb.TagNumber(14)
  void clearBigFloat() => $_clearField(14);
  @$pb.TagNumber(14)
  $3.BigFloat ensureBigFloat() => $_ensure(13);

  @$pb.TagNumber(15)
  $4.Secret get secret => $_getN(14);
  @$pb.TagNumber(15)
  set secret($4.Secret value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasSecret() => $_has(14);
  @$pb.TagNumber(15)
  void clearSecret() => $_clearField(15);
  @$pb.TagNumber(15)
  $4.Secret ensureSecret() => $_ensure(14);

  @$pb.TagNumber(16)
  $pb.PbList<$1.Duration> get durs => $_getList(15);

  @$pb.TagNumber(17)
  $pb.PbMap<$core.String, $0.Timestamp> get stamps => $_getMap(16);

  @$pb.TagNumber(18)
  $pb.PbMap<$core.String, $3.Decimal> get decs => $_getMap(17);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
