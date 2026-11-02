// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.

/// HARDENING.md § Mandatory limits: 64 MiB, the total input to one decode.
const int defaultMaxMessageSize = 64 * 1024 * 1024;

/// The per-call limits of draft -01 § Mandatory Limits. Every decoder enforces
/// them before allocating memory proportional to the violating quantity, and
/// each is configurable per call, these defaults being the contract.
class DecodeLimits {
  /// The total input to one decode call, in bytes.
  final int maxMessageSize;

  /// The decoded length of one `b"..."` literal, checked from its encoded
  /// length before it is decoded.
  final int maxBytesLiteralLength;

  /// The elements of one repeated field or map, or an SBE group's declared
  /// count, checked before any are allocated.
  final int maxRepeatedCount;

  const DecodeLimits({
    this.maxMessageSize = defaultMaxMessageSize,
    this.maxBytesLiteralLength = defaultMaxMessageSize,
    this.maxRepeatedCount = defaultMaxMessageSize,
  });

  /// The error for an [actual]-byte input past [maxMessageSize], or null.
  String? checkSize(int actual) => actual > maxMessageSize
      ? 'input of $actual bytes exceeds MaxMessageSize=$maxMessageSize'
      : null;
}

/// The UTF-8 length of [s], past [limit] only as far as it takes to say so.
/// A code unit encodes to at most three bytes (a surrogate pair to four), so
/// most inputs need no counting at all.
int utf8LengthUpTo(String s, int limit) {
  if (s.length > limit) return s.length;
  if (s.length * 3 <= limit) return s.length;
  var n = 0;
  for (var i = 0; i < s.length && n <= limit; i++) {
    final c = s.codeUnitAt(i);
    n += c < 0x80
        ? 1
        : (c < 0x800
            ? 2
            : (c & 0xF800) == 0xD800
                ? 2
                : 3);
  }
  return n;
}
