// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
// This is a generated file - do not edit.
//
// Generated from proto/envelope/v1/envelope.proto.

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

@$core.Deprecated('Use envelopeDescriptor instead')
const Envelope$json = {
  '1': 'Envelope',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 5, '10': 'status'},
    {'1': 'transport_error', '3': 2, '4': 1, '5': 9, '10': 'transportError'},
    {'1': 'data', '3': 3, '4': 1, '5': 12, '10': 'data'},
    {
      '1': 'error',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.envelope.v1.AppError',
      '10': 'error'
    },
  ],
};

/// Descriptor for `Envelope`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List envelopeDescriptor = $convert.base64Decode(
    'CghFbnZlbG9wZRIWCgZzdGF0dXMYASABKAVSBnN0YXR1cxInCg90cmFuc3BvcnRfZXJyb3IYAi'
    'ABKAlSDnRyYW5zcG9ydEVycm9yEhIKBGRhdGEYAyABKAxSBGRhdGESKwoFZXJyb3IYBCABKAsy'
    'FS5lbnZlbG9wZS52MS5BcHBFcnJvclIFZXJyb3I=');

@$core.Deprecated('Use appErrorDescriptor instead')
const AppError$json = {
  '1': 'AppError',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'args', '3': 3, '4': 3, '5': 9, '10': 'args'},
    {
      '1': 'details',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.envelope.v1.FieldError',
      '10': 'details'
    },
    {
      '1': 'metadata',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.envelope.v1.AppError.MetadataEntry',
      '10': 'metadata'
    },
  ],
  '3': [AppError_MetadataEntry$json],
};

@$core.Deprecated('Use appErrorDescriptor instead')
const AppError_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `AppError`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List appErrorDescriptor = $convert.base64Decode(
    'CghBcHBFcnJvchISCgRjb2RlGAEgASgJUgRjb2RlEhgKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2'
    'USEgoEYXJncxgDIAMoCVIEYXJncxIxCgdkZXRhaWxzGAQgAygLMhcuZW52ZWxvcGUudjEuRmll'
    'bGRFcnJvclIHZGV0YWlscxI/CghtZXRhZGF0YRgFIAMoCzIjLmVudmVsb3BlLnYxLkFwcEVycm'
    '9yLk1ldGFkYXRhRW50cnlSCG1ldGFkYXRhGjsKDU1ldGFkYXRhRW50cnkSEAoDa2V5GAEgASgJ'
    'UgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use fieldErrorDescriptor instead')
const FieldError$json = {
  '1': 'FieldError',
  '2': [
    {'1': 'field', '3': 1, '4': 1, '5': 9, '10': 'field'},
    {'1': 'code', '3': 2, '4': 1, '5': 9, '10': 'code'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
    {'1': 'args', '3': 4, '4': 3, '5': 9, '10': 'args'},
  ],
};

/// Descriptor for `FieldError`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldErrorDescriptor = $convert.base64Decode(
    'CgpGaWVsZEVycm9yEhQKBWZpZWxkGAEgASgJUgVmaWVsZBISCgRjb2RlGAIgASgJUgRjb2RlEh'
    'gKB21lc3NhZ2UYAyABKAlSB21lc3NhZ2USEgoEYXJncxgEIAMoCVIEYXJncw==');
