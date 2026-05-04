// This is a generated file - do not edit.
//
// Generated from proto/bench/v1/bench.proto.

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
    {'1': 'STATUS_SERVING', '2': 1},
  ],
};

/// Descriptor for `Status`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List statusDescriptor = $convert.base64Decode(
    'CgZTdGF0dXMSFgoSU1RBVFVTX1VOU1BFQ0lGSUVEEAASEgoOU1RBVFVTX1NFUlZJTkcQAQ==');

@$core.Deprecated('Use configDescriptor instead')
const Config$json = {
  '1': 'Config',
  '2': [
    {'1': 'hostname', '3': 1, '4': 1, '5': 9, '10': 'hostname'},
    {'1': 'port', '3': 2, '4': 1, '5': 5, '10': 'port'},
    {'1': 'enabled', '3': 3, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'weight', '3': 4, '4': 1, '5': 1, '10': 'weight'},
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.bench.v1.Status',
      '10': 'status'
    },
    {'1': 'tags', '3': 6, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'tls', '3': 7, '4': 1, '5': 11, '6': '.bench.v1.TLS', '10': 'tls'},
    {
      '1': 'labels',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.bench.v1.Config.LabelsEntry',
      '10': 'labels'
    },
    {
      '1': 'endpoints',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.bench.v1.Endpoint',
      '10': 'endpoints'
    },
    {
      '1': 'created_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'timeout',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Duration',
      '10': 'timeout'
    },
  ],
  '3': [Config_LabelsEntry$json],
};

@$core.Deprecated('Use configDescriptor instead')
const Config_LabelsEntry$json = {
  '1': 'LabelsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Config`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configDescriptor = $convert.base64Decode(
    'CgZDb25maWcSGgoIaG9zdG5hbWUYASABKAlSCGhvc3RuYW1lEhIKBHBvcnQYAiABKAVSBHBvcn'
    'QSGAoHZW5hYmxlZBgDIAEoCFIHZW5hYmxlZBIWCgZ3ZWlnaHQYBCABKAFSBndlaWdodBIoCgZz'
    'dGF0dXMYBSABKA4yEC5iZW5jaC52MS5TdGF0dXNSBnN0YXR1cxISCgR0YWdzGAYgAygJUgR0YW'
    'dzEh8KA3RscxgHIAEoCzINLmJlbmNoLnYxLlRMU1IDdGxzEjQKBmxhYmVscxgIIAMoCzIcLmJl'
    'bmNoLnYxLkNvbmZpZy5MYWJlbHNFbnRyeVIGbGFiZWxzEjAKCWVuZHBvaW50cxgJIAMoCzISLm'
    'JlbmNoLnYxLkVuZHBvaW50UgllbmRwb2ludHMSOQoKY3JlYXRlZF9hdBgKIAEoCzIaLmdvb2ds'
    'ZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBIzCgd0aW1lb3V0GAsgASgLMhkuZ29vZ2'
    'xlLnByb3RvYnVmLkR1cmF0aW9uUgd0aW1lb3V0GjkKC0xhYmVsc0VudHJ5EhAKA2tleRgBIAEo'
    'CVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use tLSDescriptor instead')
const TLS$json = {
  '1': 'TLS',
  '2': [
    {'1': 'cert_file', '3': 1, '4': 1, '5': 9, '10': 'certFile'},
    {'1': 'key_file', '3': 2, '4': 1, '5': 9, '10': 'keyFile'},
    {'1': 'verify', '3': 3, '4': 1, '5': 8, '10': 'verify'},
  ],
};

/// Descriptor for `TLS`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tLSDescriptor = $convert.base64Decode(
    'CgNUTFMSGwoJY2VydF9maWxlGAEgASgJUghjZXJ0RmlsZRIZCghrZXlfZmlsZRgCIAEoCVIHa2'
    'V5RmlsZRIWCgZ2ZXJpZnkYAyABKAhSBnZlcmlmeQ==');

@$core.Deprecated('Use endpointDescriptor instead')
const Endpoint$json = {
  '1': 'Endpoint',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    {'1': 'method', '3': 2, '4': 1, '5': 9, '10': 'method'},
    {'1': 'timeout_ms', '3': 3, '4': 1, '5': 5, '10': 'timeoutMs'},
  ],
};

/// Descriptor for `Endpoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List endpointDescriptor = $convert.base64Decode(
    'CghFbmRwb2ludBISCgRwYXRoGAEgASgJUgRwYXRoEhYKBm1ldGhvZBgCIAEoCVIGbWV0aG9kEh'
    '0KCnRpbWVvdXRfbXMYAyABKAVSCXRpbWVvdXRNcw==');
