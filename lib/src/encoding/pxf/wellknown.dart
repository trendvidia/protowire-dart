// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';

import 'lexer.dart' show countSignificantDigits;

bool isTimestamp(BuilderInfo info) {
  return info.qualifiedMessageName == 'google.protobuf.Timestamp';
}

bool isDuration(BuilderInfo info) {
  return info.qualifiedMessageName == 'google.protobuf.Duration';
}

bool isAny(BuilderInfo info) {
  return info.qualifiedMessageName == 'google.protobuf.Any';
}

void setTimestampFields(GeneratedMessage msg, DateTime t) {
  // Use tag numbers instead of names because GeneratedMessage works better with tags
  // seconds = 1, nanos = 2
  msg.setField(1, Int64(t.millisecondsSinceEpoch ~/ 1000));
  msg.setField(2, (t.millisecondsSinceEpoch % 1000) * 1000000);
}

void setDurationFields(GeneratedMessage msg, Duration dur) {
  // seconds = 1, nanos = 2
  int microseconds = dur.inMicroseconds;
  int seconds = microseconds ~/ 1000000;
  int nanos = (microseconds % 1000000) * 1000;
  msg.setField(1, Int64(seconds));
  msg.setField(2, nanos);
}

DateTime readTimestamp(GeneratedMessage msg) {
  Int64 seconds = msg.getField(1);
  int nanos = msg.getField(2);
  return DateTime.fromMillisecondsSinceEpoch(
    seconds.toInt() * 1000 + nanos ~/ 1000000,
    isUtc: true,
  );
}

Duration readDuration(GeneratedMessage msg) {
  Int64 seconds = msg.getField(1);
  int nanos = msg.getField(2);
  return Duration(
    seconds: seconds.toInt(),
    microseconds: nanos ~/ 1000,
  );
}

bool isBigInt(BuilderInfo info) {
  return info.qualifiedMessageName == 'pxf.BigInt';
}

bool isDecimal(BuilderInfo info) {
  return info.qualifiedMessageName == 'pxf.Decimal';
}

bool isBigFloat(BuilderInfo info) {
  return info.qualifiedMessageName == 'pxf.BigFloat';
}

/// HARDENING.md § Numeric-literal cap. `BigInt.parse` is O(n²) in the digit
/// count, so a multi-thousand-digit literal is a CPU-DoS vector. The
/// cross-port spec mandates ≤ 4096 significant digits per numeric literal.
const int maxNumericLiteralDigits = 4096;

void _checkDigitCap(String literal) {
  if (literal.length <= maxNumericLiteralDigits) return;
  final n = countSignificantDigits(literal);
  if (n > maxNumericLiteralDigits) {
    throw FormatException(
        'numeric literal exceeds MaxNumericLiteralDigits=$maxNumericLiteralDigits '
        '($n digits)');
  }
}

/// [BigInt.parse] matches its input with a backtracking regular expression
/// that overflows the stack on a few million characters, and the cap does
/// not count leading zeros. Dropping them is what keeps its input bounded.
String _trimLeadingZeros(String digits) {
  final start = digits.startsWith('-') ? 1 : 0;
  var i = start;
  while (i < digits.length - 1 && digits.codeUnitAt(i) == 48) {
    i++;
  }
  return i == start ? digits : digits.substring(0, start) + digits.substring(i);
}

void setBigIntFields(GeneratedMessage msg, String raw) {
  _checkDigitCap(raw);
  var val = BigInt.parse(_trimLeadingZeros(raw));
  var negative = val < BigInt.zero;
  var abs = val.abs();
  msg.setField(1, bigIntToBytes(abs));
  msg.setField(2, negative);
}

void setDecimalFields(GeneratedMessage msg, String raw) {
  var negative = raw.startsWith('-');
  if (negative) raw = raw.substring(1);

  var dotIndex = raw.indexOf('.');
  int scale = 0;
  String unscaledStr;
  if (dotIndex == -1) {
    unscaledStr = raw;
  } else {
    scale = raw.length - dotIndex - 1;
    unscaledStr = raw.replaceFirst('.', '');
  }

  _checkDigitCap(unscaledStr);
  // The digit cap no longer bounds the scale: leading zeros are not
  // significant (protowire#410), so `0.000…1` counts one digit however many
  // places it has. The scale is bounded on its own, inclusive.
  if (scale > maxNumericLiteralDigits) {
    throw FormatException(
        'pxf.Decimal scale $scale exceeds MaxNumericLiteralDigits=$maxNumericLiteralDigits');
  }
  var unscaled = BigInt.parse(_trimLeadingZeros(unscaledStr));
  msg.setField(1, bigIntToBytes(unscaled));
  msg.setField(2, scale);
  msg.setField(3, negative);
}

// TODO: setBigFloatFields (requires more complex parsing)

Uint8List bigIntToBytes(BigInt abs) {
  if (abs == BigInt.zero) return Uint8List.fromList([0]);
  var hex = abs.toRadixString(16);
  if (hex.length % 2 != 0) hex = '0$hex';
  return Uint8List.fromList(List.generate(hex.length ~/ 2,
      (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)));
}

// Wrapper type check
final Set<String> wrapperTypes = {
  'google.protobuf.BoolValue',
  'google.protobuf.BytesValue',
  'google.protobuf.DoubleValue',
  'google.protobuf.FloatValue',
  'google.protobuf.Int32Value',
  'google.protobuf.Int64Value',
  'google.protobuf.StringValue',
  'google.protobuf.UInt32Value',
  'google.protobuf.UInt64Value',
};

bool isWrapperType(BuilderInfo info) {
  return wrapperTypes.contains(info.qualifiedMessageName);
}
