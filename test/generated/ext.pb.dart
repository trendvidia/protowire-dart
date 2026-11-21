// This is a generated file - do not edit.
//
// Generated from ext.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'ext.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'ext.pbenum.dart';

class Base_Grp extends $pb.GeneratedMessage {
  factory Base_Grp({
    $fixnum.Int64? v,
  }) {
    final result = create();
    if (v != null) result.v = v;
    return result;
  }

  Base_Grp._();

  factory Base_Grp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Base_Grp.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Base.Grp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wiretypes.v1'),
      createEmptyInstance: create)
    ..aInt64(4, _omitFieldNames ? '' : 'v')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Base_Grp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Base_Grp copyWith(void Function(Base_Grp) updates) =>
      super.copyWith((message) => updates(message as Base_Grp)) as Base_Grp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Base_Grp create() => Base_Grp._();
  @$core.override
  Base_Grp createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Base_Grp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Base_Grp>(create);
  static Base_Grp? _defaultInstance;

  @$pb.TagNumber(4)
  $fixnum.Int64 get v => $_getI64(0);
  @$pb.TagNumber(4)
  set v($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(4)
  $core.bool hasV() => $_has(0);
  @$pb.TagNumber(4)
  void clearV() => $_clearField(4);
}

class Base extends $pb.GeneratedMessage {
  factory Base({
    Color? color,
    $core.Iterable<Color>? colors,
    Base_Grp? grp,
    $fixnum.Int64? f64,
    $core.Iterable<$core.MapEntry<$fixnum.Int64, Color>>? em,
  }) {
    final result = create();
    if (color != null) result.color = color;
    if (colors != null) result.colors.addAll(colors);
    if (grp != null) result.grp = grp;
    if (f64 != null) result.f64 = f64;
    if (em != null) result.em.addEntries(em);
    return result;
  }

  Base._();

  factory Base.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Base.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Base',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wiretypes.v1'),
      createEmptyInstance: create)
    ..aE<Color>(1, _omitFieldNames ? '' : 'color', enumValues: Color.values)
    ..pPE<Color>(2, _omitFieldNames ? '' : 'colors', enumValues: Color.values)
    ..a<Base_Grp>(3, _omitFieldNames ? '' : 'grp', $pb.PbFieldType.OG,
        subBuilder: Base_Grp.create, defaultOrMaker: Base_Grp.getDefault)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'f64', $pb.PbFieldType.OF6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..m<$fixnum.Int64, Color>(7, _omitFieldNames ? '' : 'em',
        entryClassName: 'Base.EmEntry',
        keyFieldType: $pb.PbFieldType.O6,
        valueFieldType: $pb.PbFieldType.OE,
        valueOf: Color.valueOf,
        enumValues: Color.values,
        valueDefaultOrMaker: Color.COLOR_UNSPECIFIED,
        defaultEnumValue: Color.COLOR_UNSPECIFIED,
        packageName: const $pb.PackageName('wiretypes.v1'))
    ..hasExtensions = true;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Base clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Base copyWith(void Function(Base) updates) =>
      super.copyWith((message) => updates(message as Base)) as Base;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Base create() => Base._();
  @$core.override
  Base createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Base getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Base>(create);
  static Base? _defaultInstance;

  @$pb.TagNumber(1)
  Color get color => $_getN(0);
  @$pb.TagNumber(1)
  set color(Color value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasColor() => $_has(0);
  @$pb.TagNumber(1)
  void clearColor() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Color> get colors => $_getList(1);

  @$pb.TagNumber(3)
  Base_Grp get grp => $_getN(2);
  @$pb.TagNumber(3)
  set grp(Base_Grp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasGrp() => $_has(2);
  @$pb.TagNumber(3)
  void clearGrp() => $_clearField(3);

  @$pb.TagNumber(5)
  $fixnum.Int64 get f64 => $_getI64(3);
  @$pb.TagNumber(5)
  set f64($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(5)
  $core.bool hasF64() => $_has(3);
  @$pb.TagNumber(5)
  void clearF64() => $_clearField(5);

  @$pb.TagNumber(7)
  $pb.PbMap<$fixnum.Int64, Color> get em => $_getMap(4);
}

class Ext {
  static final e64 = $pb.Extension<$fixnum.Int64>(
      _omitMessageNames ? '' : 'wiretypes.v1.Base',
      _omitFieldNames ? '' : 'e64',
      100,
      $pb.PbFieldType.O6,
      defaultOrMaker: $fixnum.Int64.ZERO);
  static final sub = $pb.Extension<Base>(
      _omitMessageNames ? '' : 'wiretypes.v1.Base',
      _omitFieldNames ? '' : 'sub',
      101,
      $pb.PbFieldType.OM,
      defaultOrMaker: Base.getDefault,
      subBuilder: Base.create);
  static final subs = $pb.Extension<Base>.repeated(
      _omitMessageNames ? '' : 'wiretypes.v1.Base',
      _omitFieldNames ? '' : 'subs',
      102,
      $pb.PbFieldType.PM,
      check: $pb.getCheckFunction($pb.PbFieldType.PM),
      subBuilder: Base.create);
  static void registerAllExtensions($pb.ExtensionRegistry registry) {
    registry.add(e64);
    registry.add(sub);
    registry.add(subs);
  }
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
