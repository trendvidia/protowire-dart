// This is a generated file - do not edit.
//
// Generated from text.proto.

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

@$core.Deprecated('Use colorDescriptor instead')
const Color$json = {
  '1': 'Color',
  '2': [
    {'1': 'COLOR_UNSPECIFIED', '2': 0},
    {'1': 'COLOR_RED', '2': 1},
    {'1': 'COLOR_GREEN', '2': 2},
  ],
};

/// Descriptor for `Color`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List colorDescriptor = $convert.base64Decode(
    'CgVDb2xvchIVChFDT0xPUl9VTlNQRUNJRklFRBAAEg0KCUNPTE9SX1JFRBABEg8KC0NPTE9SX0'
    'dSRUVOEAI=');

@$core.Deprecated('Use itemDescriptor instead')
const Item$json = {
  '1': 'Item',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'weight', '3': 2, '4': 1, '5': 5, '10': 'weight'},
  ],
};

/// Descriptor for `Item`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List itemDescriptor = $convert.base64Decode(
    'CgRJdGVtEhIKBG5hbWUYASABKAlSBG5hbWUSFgoGd2VpZ2h0GAIgASgFUgZ3ZWlnaHQ=');

@$core.Deprecated('Use keyedDescriptor instead')
const Keyed$json = {
  '1': 'Keyed',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'weight', '3': 2, '4': 1, '5': 5, '10': 'weight'},
  ],
};

/// Descriptor for `Keyed`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyedDescriptor = $convert.base64Decode(
    'CgVLZXllZBIOCgJpZBgBIAEoCVICaWQSFgoGd2VpZ2h0GAIgASgFUgZ3ZWlnaHQ=');

@$core.Deprecated('Use scalarsDescriptor instead')
const Scalars$json = {
  '1': 'Scalars',
  '2': [
    {'1': 'f_double', '3': 1, '4': 1, '5': 1, '10': 'fDouble'},
    {'1': 'f_float', '3': 2, '4': 1, '5': 2, '10': 'fFloat'},
    {'1': 'f_int64', '3': 3, '4': 1, '5': 3, '10': 'fInt64'},
    {'1': 'f_uint64', '3': 4, '4': 1, '5': 4, '10': 'fUint64'},
    {'1': 'f_int32', '3': 5, '4': 1, '5': 5, '10': 'fInt32'},
    {'1': 'f_fixed64', '3': 6, '4': 1, '5': 6, '10': 'fFixed64'},
    {'1': 'f_fixed32', '3': 7, '4': 1, '5': 7, '10': 'fFixed32'},
    {'1': 'f_bool', '3': 8, '4': 1, '5': 8, '10': 'fBool'},
    {'1': 'f_string', '3': 9, '4': 1, '5': 9, '10': 'fString'},
    {'1': 'f_bytes', '3': 12, '4': 1, '5': 12, '10': 'fBytes'},
    {'1': 'f_uint32', '3': 13, '4': 1, '5': 13, '10': 'fUint32'},
    {
      '1': 'f_enum',
      '3': 14,
      '4': 1,
      '5': 14,
      '6': '.text.v1.Color',
      '10': 'fEnum'
    },
    {'1': 'f_sfixed32', '3': 15, '4': 1, '5': 15, '10': 'fSfixed32'},
    {'1': 'f_sfixed64', '3': 16, '4': 1, '5': 16, '10': 'fSfixed64'},
    {'1': 'f_sint32', '3': 17, '4': 1, '5': 17, '10': 'fSint32'},
    {'1': 'f_sint64', '3': 18, '4': 1, '5': 18, '10': 'fSint64'},
  ],
};

/// Descriptor for `Scalars`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scalarsDescriptor = $convert.base64Decode(
    'CgdTY2FsYXJzEhkKCGZfZG91YmxlGAEgASgBUgdmRG91YmxlEhcKB2ZfZmxvYXQYAiABKAJSBm'
    'ZGbG9hdBIXCgdmX2ludDY0GAMgASgDUgZmSW50NjQSGQoIZl91aW50NjQYBCABKARSB2ZVaW50'
    'NjQSFwoHZl9pbnQzMhgFIAEoBVIGZkludDMyEhsKCWZfZml4ZWQ2NBgGIAEoBlIIZkZpeGVkNj'
    'QSGwoJZl9maXhlZDMyGAcgASgHUghmRml4ZWQzMhIVCgZmX2Jvb2wYCCABKAhSBWZCb29sEhkK'
    'CGZfc3RyaW5nGAkgASgJUgdmU3RyaW5nEhcKB2ZfYnl0ZXMYDCABKAxSBmZCeXRlcxIZCghmX3'
    'VpbnQzMhgNIAEoDVIHZlVpbnQzMhIlCgZmX2VudW0YDiABKA4yDi50ZXh0LnYxLkNvbG9yUgVm'
    'RW51bRIdCgpmX3NmaXhlZDMyGA8gASgPUglmU2ZpeGVkMzISHQoKZl9zZml4ZWQ2NBgQIAEoEF'
    'IJZlNmaXhlZDY0EhkKCGZfc2ludDMyGBEgASgRUgdmU2ludDMyEhkKCGZfc2ludDY0GBIgASgS'
    'UgdmU2ludDY0');

@$core.Deprecated('Use shapesDescriptor instead')
const Shapes$json = {
  '1': 'Shapes',
  '2': [
    {'1': 'one', '3': 1, '4': 1, '5': 11, '6': '.text.v1.Item', '10': 'one'},
    {
      '1': 'opt_string',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'optString',
      '17': true
    },
    {
      '1': 'opt_int',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 2,
      '10': 'optInt',
      '17': true
    },
    {'1': 'ints', '3': 4, '4': 3, '5': 5, '10': 'ints'},
    {'1': 'strings', '3': 5, '4': 3, '5': 9, '10': 'strings'},
    {
      '1': 'items',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.text.v1.Item',
      '10': 'items'
    },
    {
      '1': 'colors',
      '3': 7,
      '4': 3,
      '5': 14,
      '6': '.text.v1.Color',
      '10': 'colors'
    },
    {
      '1': 'keyed',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.text.v1.Keyed',
      '8': {},
      '10': 'keyed'
    },
    {
      '1': 'by_string',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.text.v1.Shapes.ByStringEntry',
      '10': 'byString'
    },
    {
      '1': 'by_int',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.text.v1.Shapes.ByIntEntry',
      '10': 'byInt'
    },
    {
      '1': 'by_bool',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.text.v1.Shapes.ByBoolEntry',
      '10': 'byBool'
    },
    {
      '1': 'by_item',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.text.v1.Shapes.ByItemEntry',
      '10': 'byItem'
    },
    {
      '1': 'choice_string',
      '3': 13,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'choiceString'
    },
    {
      '1': 'choice_item',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.text.v1.Item',
      '9': 0,
      '10': 'choiceItem'
    },
  ],
  '3': [
    Shapes_ByStringEntry$json,
    Shapes_ByIntEntry$json,
    Shapes_ByBoolEntry$json,
    Shapes_ByItemEntry$json
  ],
  '8': [
    {'1': 'choice'},
    {'1': '_opt_string'},
    {'1': '_opt_int'},
  ],
};

@$core.Deprecated('Use shapesDescriptor instead')
const Shapes_ByStringEntry$json = {
  '1': 'ByStringEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use shapesDescriptor instead')
const Shapes_ByIntEntry$json = {
  '1': 'ByIntEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use shapesDescriptor instead')
const Shapes_ByBoolEntry$json = {
  '1': 'ByBoolEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 8, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use shapesDescriptor instead')
const Shapes_ByItemEntry$json = {
  '1': 'ByItemEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.text.v1.Item',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `Shapes`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shapesDescriptor = $convert.base64Decode(
    'CgZTaGFwZXMSHwoDb25lGAEgASgLMg0udGV4dC52MS5JdGVtUgNvbmUSIgoKb3B0X3N0cmluZx'
    'gCIAEoCUgBUglvcHRTdHJpbmeIAQESHAoHb3B0X2ludBgDIAEoBUgCUgZvcHRJbnSIAQESEgoE'
    'aW50cxgEIAMoBVIEaW50cxIYCgdzdHJpbmdzGAUgAygJUgdzdHJpbmdzEiMKBWl0ZW1zGAYgAy'
    'gLMg0udGV4dC52MS5JdGVtUgVpdGVtcxImCgZjb2xvcnMYByADKA4yDi50ZXh0LnYxLkNvbG9y'
    'UgZjb2xvcnMSKwoFa2V5ZWQYCCADKAsyDi50ZXh0LnYxLktleWVkQgWiUgJpZFIFa2V5ZWQSOg'
    'oJYnlfc3RyaW5nGAkgAygLMh0udGV4dC52MS5TaGFwZXMuQnlTdHJpbmdFbnRyeVIIYnlTdHJp'
    'bmcSMQoGYnlfaW50GAogAygLMhoudGV4dC52MS5TaGFwZXMuQnlJbnRFbnRyeVIFYnlJbnQSNA'
    'oHYnlfYm9vbBgLIAMoCzIbLnRleHQudjEuU2hhcGVzLkJ5Qm9vbEVudHJ5UgZieUJvb2wSNAoH'
    'YnlfaXRlbRgMIAMoCzIbLnRleHQudjEuU2hhcGVzLkJ5SXRlbUVudHJ5UgZieUl0ZW0SJQoNY2'
    'hvaWNlX3N0cmluZxgNIAEoCUgAUgxjaG9pY2VTdHJpbmcSMAoLY2hvaWNlX2l0ZW0YDiABKAsy'
    'DS50ZXh0LnYxLkl0ZW1IAFIKY2hvaWNlSXRlbRo7Cg1CeVN0cmluZ0VudHJ5EhAKA2tleRgBIA'
    'EoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAEaOAoKQnlJbnRFbnRyeRIQCgNrZXkY'
    'ASABKAVSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgBGjkKC0J5Qm9vbEVudHJ5EhAKA2'
    'tleRgBIAEoCFIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAEaSAoLQnlJdGVtRW50cnkS'
    'EAoDa2V5GAEgASgJUgNrZXkSIwoFdmFsdWUYAiABKAsyDS50ZXh0LnYxLkl0ZW1SBXZhbHVlOg'
    'I4AUIICgZjaG9pY2VCDQoLX29wdF9zdHJpbmdCCgoIX29wdF9pbnQ=');

@$core.Deprecated('Use wellKnownDescriptor instead')
const WellKnown$json = {
  '1': 'WellKnown',
  '2': [
    {
      '1': 'ts',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'ts'
    },
    {
      '1': 'dur',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Duration',
      '10': 'dur'
    },
    {
      '1': 'str_w',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.StringValue',
      '10': 'strW'
    },
    {
      '1': 'bytes_w',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.BytesValue',
      '10': 'bytesW'
    },
    {
      '1': 'bool_w',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.BoolValue',
      '10': 'boolW'
    },
    {
      '1': 'i32_w',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Int32Value',
      '10': 'i32W'
    },
    {
      '1': 'i64_w',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Int64Value',
      '10': 'i64W'
    },
    {
      '1': 'u32_w',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.UInt32Value',
      '10': 'u32W'
    },
    {
      '1': 'u64_w',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.UInt64Value',
      '10': 'u64W'
    },
    {
      '1': 'flt_w',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FloatValue',
      '10': 'fltW'
    },
    {
      '1': 'dbl_w',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.DoubleValue',
      '10': 'dblW'
    },
    {
      '1': 'big_int',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.pxf.BigInt',
      '10': 'bigInt'
    },
    {'1': 'dec', '3': 13, '4': 1, '5': 11, '6': '.pxf.Decimal', '10': 'dec'},
    {
      '1': 'big_float',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.pxf.BigFloat',
      '10': 'bigFloat'
    },
    {
      '1': 'secret',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.pxf.Secret',
      '10': 'secret'
    },
    {
      '1': 'durs',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.google.protobuf.Duration',
      '10': 'durs'
    },
    {
      '1': 'stamps',
      '3': 17,
      '4': 3,
      '5': 11,
      '6': '.text.v1.WellKnown.StampsEntry',
      '10': 'stamps'
    },
    {
      '1': 'decs',
      '3': 18,
      '4': 3,
      '5': 11,
      '6': '.text.v1.WellKnown.DecsEntry',
      '10': 'decs'
    },
  ],
  '3': [WellKnown_StampsEntry$json, WellKnown_DecsEntry$json],
};

@$core.Deprecated('Use wellKnownDescriptor instead')
const WellKnown_StampsEntry$json = {
  '1': 'StampsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use wellKnownDescriptor instead')
const WellKnown_DecsEntry$json = {
  '1': 'DecsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.pxf.Decimal', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `WellKnown`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wellKnownDescriptor = $convert.base64Decode(
    'CglXZWxsS25vd24SKgoCdHMYASABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgJ0cx'
    'IrCgNkdXIYAiABKAsyGS5nb29nbGUucHJvdG9idWYuRHVyYXRpb25SA2R1chIxCgVzdHJfdxgD'
    'IAEoCzIcLmdvb2dsZS5wcm90b2J1Zi5TdHJpbmdWYWx1ZVIEc3RyVxI0CgdieXRlc193GAQgAS'
    'gLMhsuZ29vZ2xlLnByb3RvYnVmLkJ5dGVzVmFsdWVSBmJ5dGVzVxIxCgZib29sX3cYBSABKAsy'
    'Gi5nb29nbGUucHJvdG9idWYuQm9vbFZhbHVlUgVib29sVxIwCgVpMzJfdxgGIAEoCzIbLmdvb2'
    'dsZS5wcm90b2J1Zi5JbnQzMlZhbHVlUgRpMzJXEjAKBWk2NF93GAcgASgLMhsuZ29vZ2xlLnBy'
    'b3RvYnVmLkludDY0VmFsdWVSBGk2NFcSMQoFdTMyX3cYCCABKAsyHC5nb29nbGUucHJvdG9idW'
    'YuVUludDMyVmFsdWVSBHUzMlcSMQoFdTY0X3cYCSABKAsyHC5nb29nbGUucHJvdG9idWYuVUlu'
    'dDY0VmFsdWVSBHU2NFcSMAoFZmx0X3cYCiABKAsyGy5nb29nbGUucHJvdG9idWYuRmxvYXRWYW'
    'x1ZVIEZmx0VxIxCgVkYmxfdxgLIAEoCzIcLmdvb2dsZS5wcm90b2J1Zi5Eb3VibGVWYWx1ZVIE'
    'ZGJsVxIkCgdiaWdfaW50GAwgASgLMgsucHhmLkJpZ0ludFIGYmlnSW50Eh4KA2RlYxgNIAEoCz'
    'IMLnB4Zi5EZWNpbWFsUgNkZWMSKgoJYmlnX2Zsb2F0GA4gASgLMg0ucHhmLkJpZ0Zsb2F0Ughi'
    'aWdGbG9hdBIjCgZzZWNyZXQYDyABKAsyCy5weGYuU2VjcmV0UgZzZWNyZXQSLQoEZHVycxgQIA'
    'MoCzIZLmdvb2dsZS5wcm90b2J1Zi5EdXJhdGlvblIEZHVycxI2CgZzdGFtcHMYESADKAsyHi50'
    'ZXh0LnYxLldlbGxLbm93bi5TdGFtcHNFbnRyeVIGc3RhbXBzEjAKBGRlY3MYEiADKAsyHC50ZX'
    'h0LnYxLldlbGxLbm93bi5EZWNzRW50cnlSBGRlY3MaVQoLU3RhbXBzRW50cnkSEAoDa2V5GAEg'
    'ASgJUgNrZXkSMAoFdmFsdWUYAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgV2YW'
    'x1ZToCOAEaRQoJRGVjc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EiIKBXZhbHVlGAIgASgLMgwu'
    'cHhmLkRlY2ltYWxSBXZhbHVlOgI4AQ==');
