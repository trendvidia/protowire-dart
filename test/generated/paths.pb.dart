// This is a generated file - do not edit.
//
// Generated from paths.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as $4;
import 'package:protobuf/well_known_types/google/protobuf/duration.pb.dart'
    as $2;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $1;
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart'
    as $0;

import 'pxf/bignum.pb.dart' as $3;
import 'pxf/secret.pb.dart' as $5;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Tempo extends $pb.GeneratedMessage {
  factory Tempo({
    $core.int? minBpm,
    $core.int? maxBpm,
  }) {
    final result = create();
    if (minBpm != null) result.minBpm = minBpm;
    if (maxBpm != null) result.maxBpm = maxBpm;
    return result;
  }

  Tempo._();

  factory Tempo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Tempo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Tempo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dataset.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'minBpm')
    ..aI(2, _omitFieldNames ? '' : 'maxBpm')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tempo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tempo copyWith(void Function(Tempo) updates) =>
      super.copyWith((message) => updates(message as Tempo)) as Tempo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tempo create() => Tempo._();
  @$core.override
  Tempo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Tempo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tempo>(create);
  static Tempo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get minBpm => $_getIZ(0);
  @$pb.TagNumber(1)
  set minBpm($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMinBpm() => $_has(0);
  @$pb.TagNumber(1)
  void clearMinBpm() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get maxBpm => $_getIZ(1);
  @$pb.TagNumber(2)
  set maxBpm($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxBpm() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxBpm() => $_clearField(2);
}

class Desc extends $pb.GeneratedMessage {
  factory Desc({
    $core.double? energy,
    Tempo? tempo,
    $core.Iterable<$core.String>? tags,
    $0.StringValue? label,
  }) {
    final result = create();
    if (energy != null) result.energy = energy;
    if (tempo != null) result.tempo = tempo;
    if (tags != null) result.tags.addAll(tags);
    if (label != null) result.label = label;
    return result;
  }

  Desc._();

  factory Desc.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Desc.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Desc',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dataset.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'energy')
    ..aOM<Tempo>(2, _omitFieldNames ? '' : 'tempo', subBuilder: Tempo.create)
    ..pPS(3, _omitFieldNames ? '' : 'tags')
    ..aOM<$0.StringValue>(4, _omitFieldNames ? '' : 'label',
        subBuilder: $0.StringValue.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Desc clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Desc copyWith(void Function(Desc) updates) =>
      super.copyWith((message) => updates(message as Desc)) as Desc;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Desc create() => Desc._();
  @$core.override
  Desc createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Desc getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Desc>(create);
  static Desc? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get energy => $_getN(0);
  @$pb.TagNumber(1)
  set energy($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEnergy() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnergy() => $_clearField(1);

  @$pb.TagNumber(2)
  Tempo get tempo => $_getN(1);
  @$pb.TagNumber(2)
  set tempo(Tempo value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTempo() => $_has(1);
  @$pb.TagNumber(2)
  void clearTempo() => $_clearField(2);
  @$pb.TagNumber(2)
  Tempo ensureTempo() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get tags => $_getList(2);

  @$pb.TagNumber(4)
  $0.StringValue get label => $_getN(3);
  @$pb.TagNumber(4)
  set label($0.StringValue value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLabel() => $_has(3);
  @$pb.TagNumber(4)
  void clearLabel() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.StringValue ensureLabel() => $_ensure(3);
}

class Pick extends $pb.GeneratedMessage {
  factory Pick({
    $core.String? name,
    $core.int? n,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (n != null) result.n = n;
    return result;
  }

  Pick._();

  factory Pick.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Pick.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pick',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dataset.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aI(2, _omitFieldNames ? '' : 'n')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pick clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pick copyWith(void Function(Pick) updates) =>
      super.copyWith((message) => updates(message as Pick)) as Pick;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Pick create() => Pick._();
  @$core.override
  Pick createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Pick getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Pick>(create);
  static Pick? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get n => $_getIZ(1);
  @$pb.TagNumber(2)
  set n($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasN() => $_has(1);
  @$pb.TagNumber(2)
  void clearN() => $_clearField(2);
}

class Req extends $pb.GeneratedMessage {
  factory Req({
    $core.int? n,
    $core.String? d,
  }) {
    final result = create();
    if (n != null) result.n = n;
    if (d != null) result.d = d;
    return result;
  }

  Req._();

  factory Req.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Req.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Req',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dataset.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'n')
    ..aOS(2, _omitFieldNames ? '' : 'd')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Req clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Req copyWith(void Function(Req) updates) =>
      super.copyWith((message) => updates(message as Req)) as Req;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Req create() => Req._();
  @$core.override
  Req createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Req getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Req>(create);
  static Req? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get n => $_getIZ(0);
  @$pb.TagNumber(1)
  set n($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasN() => $_has(0);
  @$pb.TagNumber(1)
  void clearN() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get d => $_getSZ(1);
  @$pb.TagNumber(2)
  set d($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasD() => $_has(1);
  @$pb.TagNumber(2)
  void clearD() => $_clearField(2);
}

enum Event_Choice { a, b, notSet }

class Event extends $pb.GeneratedMessage {
  factory Event({
    $core.String? id,
    Desc? desc,
    $core.Iterable<Pick>? picks,
    $core.Iterable<$core.MapEntry<$core.String, Pick>>? byName,
    $1.Timestamp? ts,
    Pick? a,
    Pick? b,
    Req? req,
    $core.int? plain,
    $0.Int32Value? wrap,
    $2.Duration? dur,
    $3.BigInt? big,
    $4.Any? payload,
    $5.Secret? pw,
    $core.int? opt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (desc != null) result.desc = desc;
    if (picks != null) result.picks.addAll(picks);
    if (byName != null) result.byName.addEntries(byName);
    if (ts != null) result.ts = ts;
    if (a != null) result.a = a;
    if (b != null) result.b = b;
    if (req != null) result.req = req;
    if (plain != null) result.plain = plain;
    if (wrap != null) result.wrap = wrap;
    if (dur != null) result.dur = dur;
    if (big != null) result.big = big;
    if (payload != null) result.payload = payload;
    if (pw != null) result.pw = pw;
    if (opt != null) result.opt = opt;
    return result;
  }

  Event._();

  factory Event.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Event_Choice> _Event_ChoiceByTag = {
    6: Event_Choice.a,
    7: Event_Choice.b,
    0: Event_Choice.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'dataset.v1'),
      createEmptyInstance: create)
    ..oo(0, [6, 7])
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<Desc>(2, _omitFieldNames ? '' : 'desc', subBuilder: Desc.create)
    ..pPM<Pick>(3, _omitFieldNames ? '' : 'picks', subBuilder: Pick.create)
    ..m<$core.String, Pick>(4, _omitFieldNames ? '' : 'byName',
        entryClassName: 'Event.ByNameEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Pick.create,
        valueDefaultOrMaker: Pick.getDefault,
        packageName: const $pb.PackageName('dataset.v1'))
    ..aOM<$1.Timestamp>(5, _omitFieldNames ? '' : 'ts',
        subBuilder: $1.Timestamp.create)
    ..aOM<Pick>(6, _omitFieldNames ? '' : 'a', subBuilder: Pick.create)
    ..aOM<Pick>(7, _omitFieldNames ? '' : 'b', subBuilder: Pick.create)
    ..aOM<Req>(8, _omitFieldNames ? '' : 'req', subBuilder: Req.create)
    ..aI(9, _omitFieldNames ? '' : 'plain')
    ..aOM<$0.Int32Value>(10, _omitFieldNames ? '' : 'wrap',
        subBuilder: $0.Int32Value.create)
    ..aOM<$2.Duration>(11, _omitFieldNames ? '' : 'dur',
        subBuilder: $2.Duration.create)
    ..aOM<$3.BigInt>(12, _omitFieldNames ? '' : 'big',
        subBuilder: $3.BigInt.create)
    ..aOM<$4.Any>(13, _omitFieldNames ? '' : 'payload',
        subBuilder: $4.Any.create)
    ..aOM<$5.Secret>(14, _omitFieldNames ? '' : 'pw',
        subBuilder: $5.Secret.create)
    ..aI(15, _omitFieldNames ? '' : 'opt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event copyWith(void Function(Event) updates) =>
      super.copyWith((message) => updates(message as Event)) as Event;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event create() => Event._();
  @$core.override
  Event createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Event>(create);
  static Event? _defaultInstance;

  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  Event_Choice whichChoice() => _Event_ChoiceByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  void clearChoice() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  Desc get desc => $_getN(1);
  @$pb.TagNumber(2)
  set desc(Desc value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDesc() => $_has(1);
  @$pb.TagNumber(2)
  void clearDesc() => $_clearField(2);
  @$pb.TagNumber(2)
  Desc ensureDesc() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<Pick> get picks => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, Pick> get byName => $_getMap(3);

  @$pb.TagNumber(5)
  $1.Timestamp get ts => $_getN(4);
  @$pb.TagNumber(5)
  set ts($1.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasTs() => $_has(4);
  @$pb.TagNumber(5)
  void clearTs() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.Timestamp ensureTs() => $_ensure(4);

  @$pb.TagNumber(6)
  Pick get a => $_getN(5);
  @$pb.TagNumber(6)
  set a(Pick value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasA() => $_has(5);
  @$pb.TagNumber(6)
  void clearA() => $_clearField(6);
  @$pb.TagNumber(6)
  Pick ensureA() => $_ensure(5);

  @$pb.TagNumber(7)
  Pick get b => $_getN(6);
  @$pb.TagNumber(7)
  set b(Pick value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasB() => $_has(6);
  @$pb.TagNumber(7)
  void clearB() => $_clearField(7);
  @$pb.TagNumber(7)
  Pick ensureB() => $_ensure(6);

  @$pb.TagNumber(8)
  Req get req => $_getN(7);
  @$pb.TagNumber(8)
  set req(Req value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasReq() => $_has(7);
  @$pb.TagNumber(8)
  void clearReq() => $_clearField(8);
  @$pb.TagNumber(8)
  Req ensureReq() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.int get plain => $_getIZ(8);
  @$pb.TagNumber(9)
  set plain($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPlain() => $_has(8);
  @$pb.TagNumber(9)
  void clearPlain() => $_clearField(9);

  @$pb.TagNumber(10)
  $0.Int32Value get wrap => $_getN(9);
  @$pb.TagNumber(10)
  set wrap($0.Int32Value value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasWrap() => $_has(9);
  @$pb.TagNumber(10)
  void clearWrap() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Int32Value ensureWrap() => $_ensure(9);

  @$pb.TagNumber(11)
  $2.Duration get dur => $_getN(10);
  @$pb.TagNumber(11)
  set dur($2.Duration value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasDur() => $_has(10);
  @$pb.TagNumber(11)
  void clearDur() => $_clearField(11);
  @$pb.TagNumber(11)
  $2.Duration ensureDur() => $_ensure(10);

  @$pb.TagNumber(12)
  $3.BigInt get big => $_getN(11);
  @$pb.TagNumber(12)
  set big($3.BigInt value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasBig() => $_has(11);
  @$pb.TagNumber(12)
  void clearBig() => $_clearField(12);
  @$pb.TagNumber(12)
  $3.BigInt ensureBig() => $_ensure(11);

  @$pb.TagNumber(13)
  $4.Any get payload => $_getN(12);
  @$pb.TagNumber(13)
  set payload($4.Any value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasPayload() => $_has(12);
  @$pb.TagNumber(13)
  void clearPayload() => $_clearField(13);
  @$pb.TagNumber(13)
  $4.Any ensurePayload() => $_ensure(12);

  @$pb.TagNumber(14)
  $5.Secret get pw => $_getN(13);
  @$pb.TagNumber(14)
  set pw($5.Secret value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasPw() => $_has(13);
  @$pb.TagNumber(14)
  void clearPw() => $_clearField(14);
  @$pb.TagNumber(14)
  $5.Secret ensurePw() => $_ensure(13);

  @$pb.TagNumber(15)
  $core.int get opt => $_getIZ(14);
  @$pb.TagNumber(15)
  set opt($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasOpt() => $_has(14);
  @$pb.TagNumber(15)
  void clearOpt() => $_clearField(15);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
