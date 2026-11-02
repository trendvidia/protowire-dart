// This is a generated file - do not edit.
//
// Generated from test.proto.

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

import 'test.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'test.pbenum.dart';

enum AllTypes_Choice { textChoice, numberChoice, notSet }

class AllTypes extends $pb.GeneratedMessage {
  factory AllTypes({
    $core.String? stringField,
    $core.int? int32Field,
    $fixnum.Int64? int64Field,
    $core.int? uint32Field,
    $fixnum.Int64? uint64Field,
    $core.double? floatField,
    $core.double? doubleField,
    $core.bool? boolField,
    $core.List<$core.int>? bytesField,
    Status? enumField,
    Nested? nestedField,
    $core.Iterable<$core.String>? repeatedString,
    $core.Iterable<Nested>? repeatedNested,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? stringMap,
    $core.Iterable<$core.MapEntry<$core.String, Nested>>? nestedMap,
    $core.Iterable<$core.MapEntry<$core.int, $core.String>>? intMap,
    $0.Timestamp? tsField,
    $1.Duration? durField,
    $core.String? textChoice,
    $core.int? numberChoice,
    $2.StringValue? nullableString,
    $2.Int32Value? nullableInt,
    $2.BoolValue? nullableBool,
  }) {
    final result = create();
    if (stringField != null) result.stringField = stringField;
    if (int32Field != null) result.int32Field = int32Field;
    if (int64Field != null) result.int64Field = int64Field;
    if (uint32Field != null) result.uint32Field = uint32Field;
    if (uint64Field != null) result.uint64Field = uint64Field;
    if (floatField != null) result.floatField = floatField;
    if (doubleField != null) result.doubleField = doubleField;
    if (boolField != null) result.boolField = boolField;
    if (bytesField != null) result.bytesField = bytesField;
    if (enumField != null) result.enumField = enumField;
    if (nestedField != null) result.nestedField = nestedField;
    if (repeatedString != null) result.repeatedString.addAll(repeatedString);
    if (repeatedNested != null) result.repeatedNested.addAll(repeatedNested);
    if (stringMap != null) result.stringMap.addEntries(stringMap);
    if (nestedMap != null) result.nestedMap.addEntries(nestedMap);
    if (intMap != null) result.intMap.addEntries(intMap);
    if (tsField != null) result.tsField = tsField;
    if (durField != null) result.durField = durField;
    if (textChoice != null) result.textChoice = textChoice;
    if (numberChoice != null) result.numberChoice = numberChoice;
    if (nullableString != null) result.nullableString = nullableString;
    if (nullableInt != null) result.nullableInt = nullableInt;
    if (nullableBool != null) result.nullableBool = nullableBool;
    return result;
  }

  AllTypes._();

  factory AllTypes.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AllTypes.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, AllTypes_Choice> _AllTypes_ChoiceByTag = {
    19: AllTypes_Choice.textChoice,
    20: AllTypes_Choice.numberChoice,
    0: AllTypes_Choice.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AllTypes',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'test.v1'),
      createEmptyInstance: create)
    ..oo(0, [19, 20])
    ..aOS(1, _omitFieldNames ? '' : 'stringField')
    ..aI(2, _omitFieldNames ? '' : 'int32Field')
    ..aInt64(3, _omitFieldNames ? '' : 'int64Field')
    ..aI(4, _omitFieldNames ? '' : 'uint32Field',
        fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'uint64Field', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aD(6, _omitFieldNames ? '' : 'floatField', fieldType: $pb.PbFieldType.OF)
    ..aD(7, _omitFieldNames ? '' : 'doubleField')
    ..aOB(8, _omitFieldNames ? '' : 'boolField')
    ..a<$core.List<$core.int>>(
        9, _omitFieldNames ? '' : 'bytesField', $pb.PbFieldType.OY)
    ..aE<Status>(10, _omitFieldNames ? '' : 'enumField',
        enumValues: Status.values)
    ..aOM<Nested>(11, _omitFieldNames ? '' : 'nestedField',
        subBuilder: Nested.create)
    ..pPS(12, _omitFieldNames ? '' : 'repeatedString')
    ..pPM<Nested>(13, _omitFieldNames ? '' : 'repeatedNested',
        subBuilder: Nested.create)
    ..m<$core.String, $core.String>(14, _omitFieldNames ? '' : 'stringMap',
        entryClassName: 'AllTypes.StringMapEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('test.v1'))
    ..m<$core.String, Nested>(15, _omitFieldNames ? '' : 'nestedMap',
        entryClassName: 'AllTypes.NestedMapEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Nested.create,
        valueDefaultOrMaker: Nested.getDefault,
        packageName: const $pb.PackageName('test.v1'))
    ..m<$core.int, $core.String>(16, _omitFieldNames ? '' : 'intMap',
        entryClassName: 'AllTypes.IntMapEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('test.v1'))
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'tsField',
        subBuilder: $0.Timestamp.create)
    ..aOM<$1.Duration>(18, _omitFieldNames ? '' : 'durField',
        subBuilder: $1.Duration.create)
    ..aOS(19, _omitFieldNames ? '' : 'textChoice')
    ..aI(20, _omitFieldNames ? '' : 'numberChoice')
    ..aOM<$2.StringValue>(21, _omitFieldNames ? '' : 'nullableString',
        subBuilder: $2.StringValue.create)
    ..aOM<$2.Int32Value>(22, _omitFieldNames ? '' : 'nullableInt',
        subBuilder: $2.Int32Value.create)
    ..aOM<$2.BoolValue>(23, _omitFieldNames ? '' : 'nullableBool',
        subBuilder: $2.BoolValue.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllTypes clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllTypes copyWith(void Function(AllTypes) updates) =>
      super.copyWith((message) => updates(message as AllTypes)) as AllTypes;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AllTypes create() => AllTypes._();
  @$core.override
  AllTypes createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AllTypes getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AllTypes>(create);
  static AllTypes? _defaultInstance;

  @$pb.TagNumber(19)
  @$pb.TagNumber(20)
  AllTypes_Choice whichChoice() => _AllTypes_ChoiceByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(19)
  @$pb.TagNumber(20)
  void clearChoice() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get stringField => $_getSZ(0);
  @$pb.TagNumber(1)
  set stringField($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStringField() => $_has(0);
  @$pb.TagNumber(1)
  void clearStringField() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get int32Field => $_getIZ(1);
  @$pb.TagNumber(2)
  set int32Field($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInt32Field() => $_has(1);
  @$pb.TagNumber(2)
  void clearInt32Field() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get int64Field => $_getI64(2);
  @$pb.TagNumber(3)
  set int64Field($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInt64Field() => $_has(2);
  @$pb.TagNumber(3)
  void clearInt64Field() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get uint32Field => $_getIZ(3);
  @$pb.TagNumber(4)
  set uint32Field($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUint32Field() => $_has(3);
  @$pb.TagNumber(4)
  void clearUint32Field() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get uint64Field => $_getI64(4);
  @$pb.TagNumber(5)
  set uint64Field($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUint64Field() => $_has(4);
  @$pb.TagNumber(5)
  void clearUint64Field() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get floatField => $_getN(5);
  @$pb.TagNumber(6)
  set floatField($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFloatField() => $_has(5);
  @$pb.TagNumber(6)
  void clearFloatField() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get doubleField => $_getN(6);
  @$pb.TagNumber(7)
  set doubleField($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDoubleField() => $_has(6);
  @$pb.TagNumber(7)
  void clearDoubleField() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get boolField => $_getBF(7);
  @$pb.TagNumber(8)
  set boolField($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBoolField() => $_has(7);
  @$pb.TagNumber(8)
  void clearBoolField() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.List<$core.int> get bytesField => $_getN(8);
  @$pb.TagNumber(9)
  set bytesField($core.List<$core.int> value) => $_setBytes(8, value);
  @$pb.TagNumber(9)
  $core.bool hasBytesField() => $_has(8);
  @$pb.TagNumber(9)
  void clearBytesField() => $_clearField(9);

  @$pb.TagNumber(10)
  Status get enumField => $_getN(9);
  @$pb.TagNumber(10)
  set enumField(Status value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasEnumField() => $_has(9);
  @$pb.TagNumber(10)
  void clearEnumField() => $_clearField(10);

  @$pb.TagNumber(11)
  Nested get nestedField => $_getN(10);
  @$pb.TagNumber(11)
  set nestedField(Nested value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasNestedField() => $_has(10);
  @$pb.TagNumber(11)
  void clearNestedField() => $_clearField(11);
  @$pb.TagNumber(11)
  Nested ensureNestedField() => $_ensure(10);

  @$pb.TagNumber(12)
  $pb.PbList<$core.String> get repeatedString => $_getList(11);

  @$pb.TagNumber(13)
  $pb.PbList<Nested> get repeatedNested => $_getList(12);

  @$pb.TagNumber(14)
  $pb.PbMap<$core.String, $core.String> get stringMap => $_getMap(13);

  @$pb.TagNumber(15)
  $pb.PbMap<$core.String, Nested> get nestedMap => $_getMap(14);

  @$pb.TagNumber(16)
  $pb.PbMap<$core.int, $core.String> get intMap => $_getMap(15);

  @$pb.TagNumber(17)
  $0.Timestamp get tsField => $_getN(16);
  @$pb.TagNumber(17)
  set tsField($0.Timestamp value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasTsField() => $_has(16);
  @$pb.TagNumber(17)
  void clearTsField() => $_clearField(17);
  @$pb.TagNumber(17)
  $0.Timestamp ensureTsField() => $_ensure(16);

  @$pb.TagNumber(18)
  $1.Duration get durField => $_getN(17);
  @$pb.TagNumber(18)
  set durField($1.Duration value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasDurField() => $_has(17);
  @$pb.TagNumber(18)
  void clearDurField() => $_clearField(18);
  @$pb.TagNumber(18)
  $1.Duration ensureDurField() => $_ensure(17);

  @$pb.TagNumber(19)
  $core.String get textChoice => $_getSZ(18);
  @$pb.TagNumber(19)
  set textChoice($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasTextChoice() => $_has(18);
  @$pb.TagNumber(19)
  void clearTextChoice() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.int get numberChoice => $_getIZ(19);
  @$pb.TagNumber(20)
  set numberChoice($core.int value) => $_setSignedInt32(19, value);
  @$pb.TagNumber(20)
  $core.bool hasNumberChoice() => $_has(19);
  @$pb.TagNumber(20)
  void clearNumberChoice() => $_clearField(20);

  @$pb.TagNumber(21)
  $2.StringValue get nullableString => $_getN(20);
  @$pb.TagNumber(21)
  set nullableString($2.StringValue value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasNullableString() => $_has(20);
  @$pb.TagNumber(21)
  void clearNullableString() => $_clearField(21);
  @$pb.TagNumber(21)
  $2.StringValue ensureNullableString() => $_ensure(20);

  @$pb.TagNumber(22)
  $2.Int32Value get nullableInt => $_getN(21);
  @$pb.TagNumber(22)
  set nullableInt($2.Int32Value value) => $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasNullableInt() => $_has(21);
  @$pb.TagNumber(22)
  void clearNullableInt() => $_clearField(22);
  @$pb.TagNumber(22)
  $2.Int32Value ensureNullableInt() => $_ensure(21);

  @$pb.TagNumber(23)
  $2.BoolValue get nullableBool => $_getN(22);
  @$pb.TagNumber(23)
  set nullableBool($2.BoolValue value) => $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasNullableBool() => $_has(22);
  @$pb.TagNumber(23)
  void clearNullableBool() => $_clearField(23);
  @$pb.TagNumber(23)
  $2.BoolValue ensureNullableBool() => $_ensure(22);
}

class Nested extends $pb.GeneratedMessage {
  factory Nested({
    $core.String? name,
    $core.int? value,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (value != null) result.value = value;
    return result;
  }

  Nested._();

  factory Nested.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Nested.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Nested',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'test.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aI(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Nested clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Nested copyWith(void Function(Nested) updates) =>
      super.copyWith((message) => updates(message as Nested)) as Nested;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Nested create() => Nested._();
  @$core.override
  Nested createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Nested getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Nested>(create);
  static Nested? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get value => $_getIZ(1);
  @$pb.TagNumber(2)
  set value($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
