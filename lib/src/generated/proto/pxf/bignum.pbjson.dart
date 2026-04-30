// This is a generated file - do not edit.
//
// Generated from proto/pxf/bignum.proto.

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

@$core.Deprecated('Use bigIntDescriptor instead')
const BigInt$json = {
  '1': 'BigInt',
  '2': [
    {'1': 'abs', '3': 1, '4': 1, '5': 12, '10': 'abs'},
    {'1': 'negative', '3': 2, '4': 1, '5': 8, '10': 'negative'},
  ],
};

/// Descriptor for `BigInt`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bigIntDescriptor = $convert.base64Decode(
    'CgZCaWdJbnQSEAoDYWJzGAEgASgMUgNhYnMSGgoIbmVnYXRpdmUYAiABKAhSCG5lZ2F0aXZl');

@$core.Deprecated('Use decimalDescriptor instead')
const Decimal$json = {
  '1': 'Decimal',
  '2': [
    {'1': 'unscaled', '3': 1, '4': 1, '5': 12, '10': 'unscaled'},
    {'1': 'scale', '3': 2, '4': 1, '5': 5, '10': 'scale'},
    {'1': 'negative', '3': 3, '4': 1, '5': 8, '10': 'negative'},
  ],
};

/// Descriptor for `Decimal`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decimalDescriptor = $convert.base64Decode(
    'CgdEZWNpbWFsEhoKCHVuc2NhbGVkGAEgASgMUgh1bnNjYWxlZBIUCgVzY2FsZRgCIAEoBVIFc2'
    'NhbGUSGgoIbmVnYXRpdmUYAyABKAhSCG5lZ2F0aXZl');

@$core.Deprecated('Use bigFloatDescriptor instead')
const BigFloat$json = {
  '1': 'BigFloat',
  '2': [
    {'1': 'mantissa', '3': 1, '4': 1, '5': 12, '10': 'mantissa'},
    {'1': 'exponent', '3': 2, '4': 1, '5': 5, '10': 'exponent'},
    {'1': 'prec', '3': 3, '4': 1, '5': 13, '10': 'prec'},
    {'1': 'negative', '3': 4, '4': 1, '5': 8, '10': 'negative'},
  ],
};

/// Descriptor for `BigFloat`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bigFloatDescriptor = $convert.base64Decode(
    'CghCaWdGbG9hdBIaCghtYW50aXNzYRgBIAEoDFIIbWFudGlzc2ESGgoIZXhwb25lbnQYAiABKA'
    'VSCGV4cG9uZW50EhIKBHByZWMYAyABKA1SBHByZWMSGgoIbmVnYXRpdmUYBCABKAhSCG5lZ2F0'
    'aXZl');
