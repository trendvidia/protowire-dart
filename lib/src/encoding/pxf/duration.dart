// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
final _segment = RegExp(r'([0-9]+)(?:\.([0-9]+))?(ns|us|µs|ms|s|m|h)');

final _nanosRange = BigInt.parse('9223372036854775808'); // 2^63

const _unitNanos = {
  'ns': 1,
  'us': 1000,
  'µs': 1000,
  'ms': 1000000,
  's': 1000000000,
  'm': 60000000000,
  'h': 3600000000000,
};

/// A Go-style duration literal in nanoseconds, exactly. A fraction past the
/// last nanosecond is truncated, and a literal outside a signed 64-bit count
/// of nanoseconds is a [FormatException], as in `time.ParseDuration`.
BigInt parseGoDurationNanos(String s) {
  if (s == '0' || s == '+0' || s == '-0') return BigInt.zero;
  final matches = _segment.allMatches(s);
  if (matches.isEmpty) throw FormatException('Invalid duration: $s');

  var total = BigInt.zero;
  for (final match in matches) {
    final unit = BigInt.from(_unitNanos[match.group(3)]!);
    total += BigInt.parse(match.group(1)!) * unit;
    final fraction = match.group(2);
    if (fraction != null) {
      total +=
          BigInt.parse(fraction) * unit ~/ BigInt.from(10).pow(fraction.length);
    }
  }
  final value = s.startsWith('-') ? -total : total;
  if (value >= _nanosRange || value < -_nanosRange) {
    throw FormatException('Duration overflow: $s');
  }
  return value;
}

/// A Go-style duration literal, to the microsecond [Duration] holds.
Duration parseGoDuration(String s) => Duration(
    microseconds: (parseGoDurationNanos(s) ~/ BigInt.from(1000)).toInt());

/// [nanos] as `time.Duration.String()` writes it, which is what every port's
/// encoder mirrors: `1h30m0.5s`, `1.5ms`, `312.5µs`, `0s`.
String formatGoDuration(BigInt nanos) {
  if (nanos == BigInt.zero) return '0s';
  final sign = nanos.isNegative ? '-' : '';
  final u = nanos.abs();
  final second = BigInt.from(1000000000);
  if (u < second) {
    if (u < BigInt.from(1000)) return '$sign${u}ns';
    if (u < BigInt.from(1000000)) return '$sign${_fraction(u, 3)}µs';
    return '$sign${_fraction(u, 6)}ms';
  }
  final seconds = _fraction(u % (second * BigInt.from(60)), 9);
  final totalMinutes = u ~/ (second * BigInt.from(60));
  if (totalMinutes == BigInt.zero) return '$sign${seconds}s';
  final minutes = totalMinutes % BigInt.from(60);
  final hours = totalMinutes ~/ BigInt.from(60);
  if (hours == BigInt.zero) return '$sign${minutes}m${seconds}s';
  return '$sign${hours}h${minutes}m${seconds}s';
}

/// [v] divided by 10^[digits], without trailing zeros.
String _fraction(BigInt v, int digits) {
  final scale = BigInt.from(10).pow(digits);
  final whole = v ~/ scale;
  final rest = (v % scale).toString().padLeft(digits, '0');
  final trimmed = rest.replaceFirst(RegExp(r'0+$'), '');
  return trimmed.isEmpty ? '$whole' : '$whole.$trimmed';
}
