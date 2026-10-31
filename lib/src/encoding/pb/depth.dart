// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'package:protobuf/protobuf.dart';

const _maxNestingDepth = 100;

/// Merges the PB [data] into [msg], counting every map entry toward
/// MaxNestingDepth.
///
/// `GeneratedMessage.mergeFromBuffer` stops at 100 submessages, but
/// package:protobuf does not count a map entry, and HARDENING.md § Recursion
/// makes every entry a descent whatever its value's type. So this walks [data]
/// against [msg]'s schema first, and past the bound throws the package's own
/// [InvalidProtocolBufferException]. Use it in place of `mergeFromBuffer` on
/// untrusted input.
///
/// ```dart
/// final tree = Tree();
/// mergeFromBufferChecked(tree, bytes);
/// ```
void mergeFromBufferChecked(GeneratedMessage msg, List<int> data,
    [ExtensionRegistry registry = ExtensionRegistry.EMPTY]) {
  _checkDepth(CodedBufferReader(data), msg.info_, 0);
  msg.mergeFromBuffer(data, registry);
}

/// Walks one message or group whose field numbers [info] names. A field on
/// the wrong wire type is skipped, as the merge skips it, and a wire error
/// surfaces as the merge's would.
void _checkDepth(CodedBufferReader input, BuilderInfo info, int depth) {
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
    if (child == null || wireType != expected) {
      input.skipField(tag);
      continue;
    }
    if (depth >= _maxNestingDepth) {
      throw InvalidProtocolBufferException.recursionLimitExceeded();
    }
    if (isGroup) {
      _checkDepth(input, child, depth + 1);
    } else {
      _checkDepth(CodedBufferReader(input.readBytesAsView()), child, depth + 1);
    }
  }
}
