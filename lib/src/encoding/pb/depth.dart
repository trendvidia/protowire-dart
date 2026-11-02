// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

import '../../limits.dart';

const _maxNestingDepth = 100;

/// The entry point for untrusted PB: merges [data] into [msg] under
/// HARDENING.md's limits. [limits] lowers them for the call.
///
/// Plain `GeneratedMessage.mergeFromBuffer` is not bounded this way. It takes
/// any input size, any element count, and does not count map entries toward
/// MaxNestingDepth, so a caller who uses it directly gets none of this
/// (protowire-dart#43).
///
/// `GeneratedMessage.mergeFromBuffer` stops at 100 submessages, but
/// package:protobuf does not count a map entry, and HARDENING.md § Recursion
/// makes every entry a descent whatever its value's type. So this walks [data]
/// against [msg]'s schema first, and past a bound throws an
/// [InvalidProtocolBufferException], the package's own for the depth. Use it
/// in place of `mergeFromBuffer` on untrusted input.
///
/// ```dart
/// final tree = Tree();
/// mergeFromBufferChecked(tree, bytes);
/// ```
void mergeFromBufferChecked(GeneratedMessage msg, List<int> data,
    [ExtensionRegistry registry = ExtensionRegistry.EMPTY,
    DecodeLimits limits = const DecodeLimits()]) {
  final tooBig = limits.checkSize(data.length);
  if (tooBig != null) throw _LimitExceeded(tooBig);
  _checkDepth(CodedBufferReader(data), msg.info_, 0, limits);
  msg.mergeFromBuffer(data, registry);
}

/// Walks one message or group whose field numbers [info] names. A field on
/// the wrong wire type is skipped, as the merge skips it, and a wire error
/// surfaces as the merge's would.
void _checkDepth(
    CodedBufferReader input, BuilderInfo info, int depth, DecodeLimits limits) {
  // Elements of each repeated field or map of this message, by field number:
  // a field may be split across the wire.
  final counts = <int, int>{};
  void count(int number, int n) {
    final total = (counts[number] ?? 0) + n;
    if (total > limits.maxRepeatedCount) {
      throw _LimitExceeded('field $number exceeds '
          'MaxRepeatedCount=${limits.maxRepeatedCount}');
    }
    counts[number] = total;
  }

  while (true) {
    final tag = input.readTag();
    final wireType = getTagWireType(tag);
    if (tag == 0 || wireType == WIRETYPE_END_GROUP) return;
    final fi = info.fieldInfo[getTagFieldNumber(tag)];
    final isGroup = fi != null && fi.type & PbFieldType.GROUP_BIT != 0;
    final BuilderInfo? child = fi is MapFieldInfo
        ? fi.mapEntryBuilderInfo
        : (fi != null && PbFieldType.isGroupOrMessage(fi.type))
            ? fi.subBuilder!().info_
            : null;
    final expected = isGroup ? WIRETYPE_START_GROUP : WIRETYPE_LENGTH_DELIMITED;
    final repeated = fi != null && (fi.isRepeated || fi.isMapField);
    if (child == null || wireType != expected) {
      if (repeated && wireType == WIRETYPE_LENGTH_DELIMITED && child == null) {
        final packed = input.readBytesAsView();
        final strings =
            PbFieldType.baseType(fi.type) == PbFieldType.STRING_BIT ||
                PbFieldType.baseType(fi.type) == PbFieldType.BYTES_BIT;
        count(fi.tagNumber, strings ? 1 : _packedCount(fi.type, packed));
        continue;
      }
      if (repeated) count(fi.tagNumber, 1);
      input.skipField(tag);
      continue;
    }
    if (repeated) count(fi.tagNumber, 1);
    if (depth >= _maxNestingDepth) {
      throw InvalidProtocolBufferException.recursionLimitExceeded();
    }
    if (isGroup) {
      _checkDepth(input, child, depth + 1, limits);
    } else {
      _checkDepth(
          CodedBufferReader(input.readBytesAsView()), child, depth + 1, limits);
    }
  }
}

/// The elements a packed field's [payload] holds, read without decoding them.
int _packedCount(int fieldType, Uint8List payload) {
  switch (PbFieldType.baseType(fieldType)) {
    case PbFieldType.FIXED32_BIT:
    case PbFieldType.SFIXED32_BIT:
    case PbFieldType.FLOAT_BIT:
      return payload.length ~/ 4;
    case PbFieldType.FIXED64_BIT:
    case PbFieldType.SFIXED64_BIT:
    case PbFieldType.DOUBLE_BIT:
      return payload.length ~/ 8;
    default:
      // One varint per byte with the continuation bit clear.
      return payload.where((b) => b < 0x80).length;
  }
}

/// A limit broken on the PB path, as the package reports a malformed message.
class _LimitExceeded implements InvalidProtocolBufferException {
  @override
  final String message;
  _LimitExceeded(this.message);

  @override
  String toString() => 'InvalidProtocolBufferException: $message';
}
