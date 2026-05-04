// This is a generated file - do not edit.
//
// Generated from proto/test_fixtures/annotated.proto.

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

@$core.Deprecated('Use statusDescriptor instead')
const Status$json = {
  '1': 'Status',
  '2': [
    {'1': 'STATUS_UNSPECIFIED', '2': 0},
    {'1': 'STATUS_ACTIVE', '2': 1},
    {'1': 'STATUS_INACTIVE', '2': 2},
  ],
};

/// Descriptor for `Status`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List statusDescriptor = $convert.base64Decode(
    'CgZTdGF0dXMSFgoSU1RBVFVTX1VOU1BFQ0lGSUVEEAASEQoNU1RBVFVTX0FDVElWRRABEhMKD1'
    'NUQVRVU19JTkFDVElWRRAC');

@$core.Deprecated('Use configDescriptor instead')
const Config$json = {
  '1': 'Config',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'role', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'role'},
    {'1': 'priority', '3': 3, '4': 1, '5': 5, '8': {}, '10': 'priority'},
    {'1': 'enabled', '3': 4, '4': 1, '5': 8, '8': {}, '10': 'enabled'},
    {'1': 'email', '3': 5, '4': 1, '5': 9, '10': 'email'},
    {'1': 'token', '3': 6, '4': 1, '5': 12, '8': {}, '10': 'token'},
    {'1': 'weight', '3': 7, '4': 1, '5': 1, '8': {}, '10': 'weight'},
    {
      '1': 'created_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '8': {},
      '10': 'createdAt'
    },
    {
      '1': 'timeout',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Duration',
      '8': {},
      '10': 'timeout'
    },
    {
      '1': 'nickname',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.StringValue',
      '8': {},
      '10': 'nickname'
    },
    {
      '1': 'status',
      '3': 11,
      '4': 1,
      '5': 14,
      '6': '.annotated.v1.Status',
      '8': {},
      '10': 'status'
    },
    {
      '1': 'endpoint',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.annotated.v1.Endpoint',
      '10': 'endpoint'
    },
  ],
};

/// Descriptor for `Config`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configDescriptor = $convert.base64Decode(
    'CgZDb25maWcSGAoEbmFtZRgBIAEoCUIEgLUYAVIEbmFtZRIeCgRyb2xlGAIgASgJQgqKtRgGdm'
    'lld2VyUgRyb2xlEiEKCHByaW9yaXR5GAMgASgFQgWKtRgBNVIIcHJpb3JpdHkSIgoHZW5hYmxl'
    'ZBgEIAEoCEIIirUYBHRydWVSB2VuYWJsZWQSFAoFZW1haWwYBSABKAlSBWVtYWlsEh4KBXRva2'
    'VuGAYgASgMQgiKtRgEQVFJRFIFdG9rZW4SIAoGd2VpZ2h0GAcgASgBQgiKtRgEMC43NVIGd2Vp'
    'Z2h0ElMKCmNyZWF0ZWRfYXQYCCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wQhiKtR'
    'gUMjAyNC0wMS0xNVQxMDozMDowMFpSCWNyZWF0ZWRBdBI8Cgd0aW1lb3V0GAkgASgLMhkuZ29v'
    'Z2xlLnByb3RvYnVmLkR1cmF0aW9uQgeKtRgDMzBzUgd0aW1lb3V0EkIKCG5pY2tuYW1lGAogAS'
    'gLMhwuZ29vZ2xlLnByb3RvYnVmLlN0cmluZ1ZhbHVlQgiKtRgEYW5vblIIbmlja25hbWUSPwoG'
    'c3RhdHVzGAsgASgOMhQuYW5ub3RhdGVkLnYxLlN0YXR1c0IRirUYDVNUQVRVU19BQ1RJVkVSBn'
    'N0YXR1cxIyCghlbmRwb2ludBgMIAEoCzIWLmFubm90YXRlZC52MS5FbmRwb2ludFIIZW5kcG9p'
    'bnQ=');

@$core.Deprecated('Use endpointDescriptor instead')
const Endpoint$json = {
  '1': 'Endpoint',
  '2': [
    {'1': 'host', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'host'},
    {'1': 'port', '3': 2, '4': 1, '5': 5, '8': {}, '10': 'port'},
  ],
};

/// Descriptor for `Endpoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List endpointDescriptor = $convert.base64Decode(
    'CghFbmRwb2ludBIYCgRob3N0GAEgASgJQgSAtRgBUgRob3N0EhwKBHBvcnQYAiABKAVCCIq1GA'
    'Q4MDgwUgRwb3J0');
