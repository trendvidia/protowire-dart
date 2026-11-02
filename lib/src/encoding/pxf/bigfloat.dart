// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// `pxf.BigFloat` as PXF text (draft -01 § PXF Annotations; protowire#406,
// #410). The value is the unsigned big-endian integer `mantissa` times
// 2^`exponent`, at `prec` bits. Dart has no big float, so both directions are
// exact rational arithmetic on BigInt, the method of the corpus's generate.py.
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

import 'lexer.dart' show countSignificantDigits, maxNumericLiteralDigits;

/// HARDENING.md § Mandatory limits: the magnitude of a value's binary
/// exponent. Rendering costs the square of it.
const int maxBigFloatExponent = 16384;

/// The precision an unsuffixed literal is read at.
const int bigFloatDefaultPrec = 256;

/// The largest precision whose N is within [maxNumericLiteralDigits]:
/// floor((4096 - 1) / log10(2)).
const int maxBigFloatPrec = 13603;

final _ten = BigInt.from(10);
final _literal = RegExp(r'^(-?)([0-9]*)(?:\.([0-9]*))?(?:[eE]([+-]?[0-9]+))?$');

/// [prec] from a literal's suffix digits, checked before anything is built.
int bigFloatSuffix(String literal, String digits) {
  final p = digits.length <= maxBigFloatPrec.toString().length
      ? int.parse(digits)
      : null;
  if (p == 0) {
    throw FormatException(
        'big float literal ${literal}p$digits: precision suffix p$digits is not a positive bit count');
  }
  if (p == null || p > maxBigFloatPrec) {
    throw FormatException(
        'big float literal ${_clip(literal)}: precision p${_clip(digits)} is past '
        'p$maxBigFloatPrec, the largest within '
        'MaxNumericLiteralDigits=$maxNumericLiteralDigits');
  }
  return p;
}

String _clip(String s) => s.length <= 32 ? s : '${s.substring(0, 32)}...';

/// Sets a BigFloat message's fields from a literal, [suffix] being its
/// precision digits or null. Proto3 zero fields stay unset.
void setBigFloatLiteral(GeneratedMessage msg, String literal, String? suffix) {
  final prec = suffix == null ? null : bigFloatSuffix(literal, suffix);
  final match = _literal.firstMatch(literal);
  if (match == null) {
    throw FormatException('invalid big float: ${_clip(literal)}');
  }
  final negative = match.group(1) == '-';
  final fraction = match.group(3) ?? '';
  final digits = '${match.group(2)}$fraction';
  if (digits.length > maxNumericLiteralDigits &&
      countSignificantDigits(digits) > maxNumericLiteralDigits) {
    throw FormatException('numeric literal exceeds '
        'MaxNumericLiteralDigits=$maxNumericLiteralDigits');
  }
  final unscaled = BigInt.parse(digits.isEmpty ? '0' : digits);
  if (unscaled == BigInt.zero) {
    _store(msg, BigInt.zero, 0, prec ?? 0, negative);
    return;
  }

  // Bounded before 10^e is built: a thirteen-byte literal names a huge one.
  final exponentText = match.group(4);
  final tooBig = exponentText != null &&
      exponentText.replaceFirst(RegExp('^[+-]'), '').length > 9;
  final e10 = (tooBig ? 0 : int.parse(exponentText ?? '0')) - fraction.length;
  final estimate = (unscaled.bitLength + e10 * 3.3219).abs();
  if (tooBig || estimate > maxBigFloatExponent + 64) {
    throw FormatException('big float literal ${_clip(literal)} exceeds '
        'MaxBigFloatExponent=$maxBigFloatExponent');
  }

  final p = prec ?? bigFloatDefaultPrec;
  final numerator = e10 >= 0 ? unscaled * _ten.pow(e10) : unscaled;
  final denominator = e10 >= 0 ? BigInt.one : _ten.pow(-e10);
  var (mantissa, exponent) = _roundToBits(numerator, denominator, p);
  if (mantissa.bitLength > p) {
    mantissa >>= 1;
    exponent++;
  }
  // On the rounded value: a literal of a value at the bound may lie just past
  // it, and rounding brings it back (protowire#410).
  final binary = exponent + mantissa.bitLength;
  if (binary.abs() > maxBigFloatExponent) {
    throw FormatException('big float literal ${_clip(literal)}: binary '
        'exponent $binary exceeds MaxBigFloatExponent=$maxBigFloatExponent');
  }
  _store(msg, mantissa, exponent, p, negative);
}

void _store(GeneratedMessage msg, BigInt mantissa, int exponent, int prec,
    bool negative) {
  if (mantissa != BigInt.zero) msg.setField(1, _bytesOf(mantissa));
  if (exponent != 0) msg.setField(2, exponent);
  if (prec != 0) msg.setField(3, prec);
  if (negative) msg.setField(4, true);
}

/// [v], unsigned, big-endian, with no leading zeros.
Uint8List _bytesOf(BigInt v) {
  final out = Uint8List((v.bitLength + 7) >> 3);
  var rest = v;
  final mask = BigInt.from(0xFF);
  for (var i = out.length - 1; i >= 0; i--) {
    out[i] = (rest & mask).toInt();
    rest >>= 8;
  }
  return out;
}

BigInt _valueOf(List<int> bytes) {
  var v = BigInt.zero;
  for (final b in bytes) {
    v = (v << 8) | BigInt.from(b);
  }
  return v;
}

/// [n]/[d] to the nearest integer, ties to even.
BigInt _roundHalfEven(BigInt n, BigInt d) {
  var q = n ~/ d;
  final twice = (n - q * d) * BigInt.two;
  if (twice > d || (twice == d && q.isOdd)) q += BigInt.one;
  return q;
}

/// [n]/[d] as `m * 2^e`, with m rounded to [bits] significant bits. m may come
/// back one bit wider, when rounding carries past the significand.
(BigInt, int) _roundToBits(BigInt n, BigInt d, int bits) {
  var e = n.bitLength - d.bitLength - bits;
  // 2^(bits-1) <= n / (d * 2^e) < 2^bits
  bool below(int e) =>
      e >= 0 ? n < (d << (e + bits - 1)) : (n << -e) < (d << (bits - 1));
  bool atOrAbove(int e) =>
      e >= 0 ? n >= (d << (e + bits)) : (n << -e) >= (d << bits);
  while (atOrAbove(e)) {
    e++;
  }
  while (below(e)) {
    e--;
  }
  final m = e >= 0 ? _roundHalfEven(n, d << e) : _roundHalfEven(n << -e, d);
  return (m, e);
}

/// The literal for a value of the given fields, or a [FormatException] when
/// the message has none: an exponent or precision past the bounds.
String bigFloatLiteral(
    List<int> mantissaBytes, int exponent, int prec, bool negative) {
  final sign = negative ? '-' : '';
  if (prec == 0) return '${sign}0';
  final mantissa = _valueOf(mantissaBytes);
  if (mantissa == BigInt.zero) return '${sign}0p$prec';
  final binary = exponent + mantissa.bitLength;
  if (binary.abs() > maxBigFloatExponent) {
    throw FormatException('pxf.BigFloat binary exponent $binary exceeds '
        'MaxBigFloatExponent=$maxBigFloatExponent');
  }
  if (prec > maxBigFloatPrec) {
    throw FormatException('pxf.BigFloat prec $prec is past p$maxBigFloatPrec, '
        'the largest within MaxNumericLiteralDigits=$maxNumericLiteralDigits');
  }

  // A mantissa wider than prec bits: the value is the rounded one.
  var m = mantissa;
  var e = exponent;
  if (m.bitLength > prec) {
    final (rounded, shift) = _roundToBits(m, BigInt.one, prec);
    m = rounded;
    e += shift;
  }
  final numerator = e >= 0 ? m << e : m;
  final denominator = e >= 0 ? BigInt.one : BigInt.one << -e;

  final n = (BigInt.one << prec).toString().length + 1;
  // 10^k <= v < 10^(k+1)
  var k = ((m.bitLength + e - 1) * math.ln2 / math.ln10).floor();
  bool lessThanPow10(int power) => power >= 0
      ? numerator < denominator * _ten.pow(power)
      : numerator * _ten.pow(-power) < denominator;
  while (!lessThanPow10(k + 1)) {
    k++;
  }
  while (lessThanPow10(k)) {
    k--;
  }
  final scale = k - n + 1;
  var q = scale >= 0
      ? _roundHalfEven(numerator, denominator * _ten.pow(scale))
      : _roundHalfEven(numerator * _ten.pow(-scale), denominator);
  if (q == _ten.pow(n)) {
    q ~/= _ten;
    k++;
  }
  var digits = q.toString().replaceFirst(RegExp(r'0+$'), '');
  if (digits.isEmpty) digits = '0';

  if (k < -4 || k >= n) {
    final fraction = digits.length > 1 ? '.${digits.substring(1)}' : '';
    final sign10 = k < 0 ? '-' : '+';
    final magnitude = k.abs().toString().padLeft(2, '0');
    return '$sign${digits[0]}${fraction}e$sign10${magnitude}p$prec';
  }
  if (k >= 0) {
    final whole = digits.length > k + 1
        ? digits.substring(0, k + 1)
        : digits.padRight(k + 1, '0');
    final rest = digits.length > k + 1 ? '.${digits.substring(k + 1)}' : '';
    return '$sign$whole${rest}p$prec';
  }
  return '${sign}0.${'0' * (-k - 1)}${digits}p$prec';
}
