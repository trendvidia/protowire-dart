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
  ],
};

/// Descriptor for `Tree`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeDescriptor = $convert.base64Decode(
    'CgRUcmVlEioKBWNoaWxkGAEgASgLMhQuYWR2ZXJzYXJpYWwudjEuVHJlZVIFY2hpbGQSFAoFbG'
    'FiZWwYAiABKAlSBWxhYmVs');

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
