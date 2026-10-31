// This is a generated file - do not edit.
//
// Generated from adversarial.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use treeDescriptor instead')
const Tree$json = {
  '1': 'Tree',
  '2': [
    {
      '1': 'child',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.adversarial.v1.Tree',
      '10': 'child'
    },
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {
      '1': 'children',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.adversarial.v1.Tree',
      '10': 'children'
    },
    {
      '1': 'branches',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.adversarial.v1.Tree.BranchesEntry',
      '10': 'branches'
    },
    {
      '1': 'tags',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.adversarial.v1.Tree.TagsEntry',
      '10': 'tags'
    },
  ],
  '3': [Tree_BranchesEntry$json, Tree_TagsEntry$json],
};

@$core.Deprecated('Use treeDescriptor instead')
const Tree_BranchesEntry$json = {
  '1': 'BranchesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.adversarial.v1.Tree',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use treeDescriptor instead')
const Tree_TagsEntry$json = {
  '1': 'TagsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Tree`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeDescriptor = $convert.base64Decode(
    'CgRUcmVlEioKBWNoaWxkGAEgASgLMhQuYWR2ZXJzYXJpYWwudjEuVHJlZVIFY2hpbGQSFAoFbG'
    'FiZWwYAiABKAlSBWxhYmVsEjAKCGNoaWxkcmVuGAMgAygLMhQuYWR2ZXJzYXJpYWwudjEuVHJl'
    'ZVIIY2hpbGRyZW4SPgoIYnJhbmNoZXMYBCADKAsyIi5hZHZlcnNhcmlhbC52MS5UcmVlLkJyYW'
    '5jaGVzRW50cnlSCGJyYW5jaGVzEjIKBHRhZ3MYBSADKAsyHi5hZHZlcnNhcmlhbC52MS5UcmVl'
    'LlRhZ3NFbnRyeVIEdGFncxpRCg1CcmFuY2hlc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EioKBX'
    'ZhbHVlGAIgASgLMhQuYWR2ZXJzYXJpYWwudjEuVHJlZVIFdmFsdWU6AjgBGjcKCVRhZ3NFbnRy'
    'eRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use stringHolderDescriptor instead')
const StringHolder$json = {
  '1': 'StringHolder',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `StringHolder`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stringHolderDescriptor =
    $convert.base64Decode('CgxTdHJpbmdIb2xkZXISFAoFdmFsdWUYASABKAlSBXZhbHVl');

@$core.Deprecated('Use bytesHolderDescriptor instead')
const BytesHolder$json = {
  '1': 'BytesHolder',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 12, '10': 'value'},
  ],
};

/// Descriptor for `BytesHolder`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bytesHolderDescriptor =
    $convert.base64Decode('CgtCeXRlc0hvbGRlchIUCgV2YWx1ZRgBIAEoDFIFdmFsdWU=');

@$core.Deprecated('Use bigIntHolderDescriptor instead')
const BigIntHolder$json = {
  '1': 'BigIntHolder',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 3, '10': 'value'},
  ],
};

/// Descriptor for `BigIntHolder`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bigIntHolderDescriptor =
    $convert.base64Decode('CgxCaWdJbnRIb2xkZXISFAoFdmFsdWUYASABKANSBXZhbHVl');

@$core.Deprecated('Use bigNumHolderDescriptor instead')
const BigNumHolder$json = {
  '1': 'BigNumHolder',
  '2': [
    {
      '1': 'big_int',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pxf.BigInt',
      '10': 'bigInt'
    },
    {
      '1': 'decimal',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pxf.Decimal',
      '10': 'decimal'
    },
    {
      '1': 'big_float',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.pxf.BigFloat',
      '10': 'bigFloat'
    },
  ],
};

/// Descriptor for `BigNumHolder`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bigNumHolderDescriptor = $convert.base64Decode(
    'CgxCaWdOdW1Ib2xkZXISJAoHYmlnX2ludBgBIAEoCzILLnB4Zi5CaWdJbnRSBmJpZ0ludBImCg'
    'dkZWNpbWFsGAIgASgLMgwucHhmLkRlY2ltYWxSB2RlY2ltYWwSKgoJYmlnX2Zsb2F0GAMgASgL'
    'Mg0ucHhmLkJpZ0Zsb2F0UghiaWdGbG9hdA==');

@$core.Deprecated('Use listHolderDescriptor instead')
const ListHolder$json = {
  '1': 'ListHolder',
  '2': [
    {'1': 'values', '3': 1, '4': 3, '5': 5, '10': 'values'},
  ],
};

/// Descriptor for `ListHolder`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listHolderDescriptor =
    $convert.base64Decode('CgpMaXN0SG9sZGVyEhYKBnZhbHVlcxgBIAMoBVIGdmFsdWVz');

@$core.Deprecated('Use sbeWithGroupDescriptor instead')
const SbeWithGroup$json = {
  '1': 'SbeWithGroup',
  '2': [
    {'1': 'root_value', '3': 1, '4': 1, '5': 13, '10': 'rootValue'},
    {
      '1': 'entries',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.adversarial.v1.SbeWithGroup.Entry',
      '10': 'entries'
    },
  ],
  '3': [SbeWithGroup_Entry$json],
  '7': {},
};

@$core.Deprecated('Use sbeWithGroupDescriptor instead')
const SbeWithGroup_Entry$json = {
  '1': 'Entry',
  '2': [
    {'1': 'entry_value', '3': 1, '4': 1, '5': 13, '10': 'entryValue'},
  ],
};

/// Descriptor for `SbeWithGroup`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sbeWithGroupDescriptor = $convert.base64Decode(
    'CgxTYmVXaXRoR3JvdXASHQoKcm9vdF92YWx1ZRgBIAEoDVIJcm9vdFZhbHVlEjwKB2VudHJpZX'
    'MYAiADKAsyIi5hZHZlcnNhcmlhbC52MS5TYmVXaXRoR3JvdXAuRW50cnlSB2VudHJpZXMaKAoF'
    'RW50cnkSHwoLZW50cnlfdmFsdWUYASABKA1SCmVudHJ5VmFsdWU6BMhSqUY=');
