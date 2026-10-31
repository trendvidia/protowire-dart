// This is a generated file - do not edit.
//
// Generated from adversarial.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'package:protowire/src/generated/proto/pxf/bignum.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Tree is self-recursive — used to construct deeply-nested PXF text and
/// PB binary inputs that exercise the decoder's MaxNestingDepth cap.
class Tree extends $pb.GeneratedMessage {
  factory Tree({
    Tree? child,
    $core.String? label,
    $core.Iterable<Tree>? children,
    $core.Iterable<$core.MapEntry<$core.String, Tree>>? branches,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? tags,
  }) {
    final result = create();
    if (child != null) result.child = child;
    if (label != null) result.label = label;
    if (children != null) result.children.addAll(children);
    if (branches != null) result.branches.addEntries(branches);
    if (tags != null) result.tags.addEntries(tags);
    return result;
  }

  Tree._();

  factory Tree.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Tree.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Tree',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'adversarial.v1'),
      createEmptyInstance: create)
    ..aOM<Tree>(1, _omitFieldNames ? '' : 'child', subBuilder: Tree.create)
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..pPM<Tree>(3, _omitFieldNames ? '' : 'children', subBuilder: Tree.create)
    ..m<$core.String, Tree>(4, _omitFieldNames ? '' : 'branches',
        entryClassName: 'Tree.BranchesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Tree.create,
        valueDefaultOrMaker: Tree.getDefault,
        packageName: const $pb.PackageName('adversarial.v1'))
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'tags',
        entryClassName: 'Tree.TagsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('adversarial.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tree clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tree copyWith(void Function(Tree) updates) =>
      super.copyWith((message) => updates(message as Tree)) as Tree;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tree create() => Tree._();
  @$core.override
  Tree createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Tree getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tree>(create);
  static Tree? _defaultInstance;

  @$pb.TagNumber(1)
  Tree get child => $_getN(0);
  @$pb.TagNumber(1)
  set child(Tree value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasChild() => $_has(0);
  @$pb.TagNumber(1)
  void clearChild() => $_clearField(1);
  @$pb.TagNumber(1)
  Tree ensureChild() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  /// children alternates a list with a block, so a document can descend
  /// through both kinds of PXF nesting (issue #301).
  @$pb.TagNumber(3)
  $pb.PbList<Tree> get children => $_getList(2);

  /// branches and tags descend through a map, with a message value and a
  /// scalar value: a map's `{` and every PB map entry are descents whatever
  /// the value's type (issue #449).
  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, Tree> get branches => $_getMap(3);

  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.String> get tags => $_getMap(4);
}

/// StringHolder isolates a single proto3 `string` field for the UTF-8
/// conformance tests (invalid byte sequences, lone surrogates, etc.).
class StringHolder extends $pb.GeneratedMessage {
  factory StringHolder({
    $core.String? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  StringHolder._();

  factory StringHolder.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StringHolder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StringHolder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'adversarial.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StringHolder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StringHolder copyWith(void Function(StringHolder) updates) =>
      super.copyWith((message) => updates(message as StringHolder))
          as StringHolder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StringHolder create() => StringHolder._();
  @$core.override
  StringHolder createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StringHolder getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StringHolder>(create);
  static StringHolder? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

/// BytesHolder isolates a single `bytes` field. Used for PXF base64
/// literal-length caps (the `bytes` field is the only place arbitrary
/// non-UTF-8 bytes are legal).
class BytesHolder extends $pb.GeneratedMessage {
  factory BytesHolder({
    $core.List<$core.int>? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  BytesHolder._();

  factory BytesHolder.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BytesHolder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BytesHolder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'adversarial.v1'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'value', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BytesHolder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BytesHolder copyWith(void Function(BytesHolder) updates) =>
      super.copyWith((message) => updates(message as BytesHolder))
          as BytesHolder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BytesHolder create() => BytesHolder._();
  @$core.override
  BytesHolder createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BytesHolder getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BytesHolder>(create);
  static BytesHolder? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get value => $_getN(0);
  @$pb.TagNumber(1)
  set value($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

/// BigIntHolder is a bare int64 holder — corpus inputs target the lexer's
/// numeric-literal digit cap, so the field type doesn't need to be a
/// well-known BigInt; rejection happens before the parser dispatches.
class BigIntHolder extends $pb.GeneratedMessage {
  factory BigIntHolder({
    $fixnum.Int64? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  BigIntHolder._();

  factory BigIntHolder.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BigIntHolder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BigIntHolder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'adversarial.v1'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BigIntHolder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BigIntHolder copyWith(void Function(BigIntHolder) updates) =>
      super.copyWith((message) => updates(message as BigIntHolder))
          as BigIntHolder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BigIntHolder create() => BigIntHolder._();
  @$core.override
  BigIntHolder createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BigIntHolder getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BigIntHolder>(create);
  static BigIntHolder? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get value => $_getI64(0);
  @$pb.TagNumber(1)
  set value($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

/// BigNumHolder carries the arbitrary-precision types, so the digit cap can be
/// proved on a field that only the cap rejects (an int64 rejects a long
/// literal as out of range, whatever the cap), and Decimal.scale can be bound
/// on the PB wire (issue #279).
class BigNumHolder extends $pb.GeneratedMessage {
  factory BigNumHolder({
    $0.BigInt? bigInt,
    $0.Decimal? decimal,
    $0.BigFloat? bigFloat,
  }) {
    final result = create();
    if (bigInt != null) result.bigInt = bigInt;
    if (decimal != null) result.decimal = decimal;
    if (bigFloat != null) result.bigFloat = bigFloat;
    return result;
  }

  BigNumHolder._();

  factory BigNumHolder.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BigNumHolder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BigNumHolder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'adversarial.v1'),
      createEmptyInstance: create)
    ..aOM<$0.BigInt>(1, _omitFieldNames ? '' : 'bigInt',
        subBuilder: $0.BigInt.create)
    ..aOM<$0.Decimal>(2, _omitFieldNames ? '' : 'decimal',
        subBuilder: $0.Decimal.create)
    ..aOM<$0.BigFloat>(3, _omitFieldNames ? '' : 'bigFloat',
        subBuilder: $0.BigFloat.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BigNumHolder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BigNumHolder copyWith(void Function(BigNumHolder) updates) =>
      super.copyWith((message) => updates(message as BigNumHolder))
          as BigNumHolder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BigNumHolder create() => BigNumHolder._();
  @$core.override
  BigNumHolder createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BigNumHolder getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BigNumHolder>(create);
  static BigNumHolder? _defaultInstance;

  @$pb.TagNumber(1)
  $0.BigInt get bigInt => $_getN(0);
  @$pb.TagNumber(1)
  set bigInt($0.BigInt value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBigInt() => $_has(0);
  @$pb.TagNumber(1)
  void clearBigInt() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.BigInt ensureBigInt() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.Decimal get decimal => $_getN(1);
  @$pb.TagNumber(2)
  set decimal($0.Decimal value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDecimal() => $_has(1);
  @$pb.TagNumber(2)
  void clearDecimal() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Decimal ensureDecimal() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.BigFloat get bigFloat => $_getN(2);
  @$pb.TagNumber(3)
  set bigFloat($0.BigFloat value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBigFloat() => $_has(2);
  @$pb.TagNumber(3)
  void clearBigFloat() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.BigFloat ensureBigFloat() => $_ensure(2);
}

/// ListHolder carries the repeated field the MaxRepeatedCount fixtures bound
/// (HARDENING.md § Mandatory limits, issue #299).
class ListHolder extends $pb.GeneratedMessage {
  factory ListHolder({
    $core.Iterable<$core.int>? values,
  }) {
    final result = create();
    if (values != null) result.values.addAll(values);
    return result;
  }

  ListHolder._();

  factory ListHolder.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListHolder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListHolder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'adversarial.v1'),
      createEmptyInstance: create)
    ..p<$core.int>(1, _omitFieldNames ? '' : 'values', $pb.PbFieldType.K3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListHolder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListHolder copyWith(void Function(ListHolder) updates) =>
      super.copyWith((message) => updates(message as ListHolder)) as ListHolder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListHolder create() => ListHolder._();
  @$core.override
  ListHolder createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListHolder getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListHolder>(create);
  static ListHolder? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.int> get values => $_getList(0);
}

class SbeWithGroup_Entry extends $pb.GeneratedMessage {
  factory SbeWithGroup_Entry({
    $core.int? entryValue,
  }) {
    final result = create();
    if (entryValue != null) result.entryValue = entryValue;
    return result;
  }

  SbeWithGroup_Entry._();

  factory SbeWithGroup_Entry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SbeWithGroup_Entry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SbeWithGroup.Entry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'adversarial.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'entryValue', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SbeWithGroup_Entry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SbeWithGroup_Entry copyWith(void Function(SbeWithGroup_Entry) updates) =>
      super.copyWith((message) => updates(message as SbeWithGroup_Entry))
          as SbeWithGroup_Entry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SbeWithGroup_Entry create() => SbeWithGroup_Entry._();
  @$core.override
  SbeWithGroup_Entry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SbeWithGroup_Entry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SbeWithGroup_Entry>(create);
  static SbeWithGroup_Entry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get entryValue => $_getIZ(0);
  @$pb.TagNumber(1)
  set entryValue($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntryValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryValue() => $_clearField(1);
}

/// SbeWithGroup backs the SBE adversarial inputs. Wire layout per port's
/// SBE codec:
///   header(8) + root_block(4) + group_header(4) + count*entry_block(4)
///   header        : block_length(2) | template_id(2) | schema_id(2) | version(2)
///   root_block    : root_value (uint32 LE, offset 0, size 4)
///   group_header  : entry_block_length(2) | count(2)
///   entry_block   : entry_value (uint32 LE, offset 0, size 4)
///
/// Every adversarial input below targets one of the wire-header fields and
/// expects the decoder to reject before allocating writer state proportional
/// to attacker-supplied counts. See HARDENING.md § SBE.
class SbeWithGroup extends $pb.GeneratedMessage {
  factory SbeWithGroup({
    $core.int? rootValue,
    $core.Iterable<SbeWithGroup_Entry>? entries,
  }) {
    final result = create();
    if (rootValue != null) result.rootValue = rootValue;
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  SbeWithGroup._();

  factory SbeWithGroup.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SbeWithGroup.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SbeWithGroup',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'adversarial.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'rootValue', fieldType: $pb.PbFieldType.OU3)
    ..pPM<SbeWithGroup_Entry>(2, _omitFieldNames ? '' : 'entries',
        subBuilder: SbeWithGroup_Entry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SbeWithGroup clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SbeWithGroup copyWith(void Function(SbeWithGroup) updates) =>
      super.copyWith((message) => updates(message as SbeWithGroup))
          as SbeWithGroup;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SbeWithGroup create() => SbeWithGroup._();
  @$core.override
  SbeWithGroup createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SbeWithGroup getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SbeWithGroup>(create);
  static SbeWithGroup? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get rootValue => $_getIZ(0);
  @$pb.TagNumber(1)
  set rootValue($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRootValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearRootValue() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<SbeWithGroup_Entry> get entries => $_getList(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
