// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.

/// Marks a field of a class for the native `pb` codec with its field number.
///
/// Dart has one `int` and one `double`, so the flags say which proto type a
/// field is when it is not the default:
/// - [zigzag]: `int` is `sint32`, `Int64` is `sint64`.
/// - [unsigned]: `int` is `uint32`, `Int64` is `uint64` (held in the Int64's
///   64 bits, as package:protobuf holds it).
/// - [float32]: `double` is `float`.
///
/// They apply to a list's elements too: a `List<double>` field tagged
/// `@ProtoTag(1, float32: true)` is `repeated float`.
class ProtoTag {
  final int tag;
  final bool zigzag;
  final bool unsigned;
  final bool float32;
  const ProtoTag(this.tag,
      {this.zigzag = false, this.unsigned = false, this.float32 = false});
}
