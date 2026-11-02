// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.

/// Marks a field of a class for the native `pb` codec with its field number.
class ProtoTag {
  final int tag;
  final bool zigzag;
  const ProtoTag(this.tag, {this.zigzag = false});
}
