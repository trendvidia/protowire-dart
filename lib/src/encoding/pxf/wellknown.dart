// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';

import 'duration.dart';
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

/// The message an Any's [typeUrl] names: what follows its last `/`.
String anyTypeName(String typeUrl) =>
    typeUrl.substring(typeUrl.lastIndexOf('/') + 1);

/// A field with implicit presence holds its zero value by being unset, and
/// package:protobuf would otherwise write a set zero to the wire.
bool isZeroValue(Object value) => switch (value) {
      int v => v == 0,
      Int64 v => v.isZero,
      double v => v == 0 && !v.isNegative,
      bool v => !v,
      String v => v.isEmpty,
      List v => v.isEmpty,
      ProtobufEnum v => v.value == 0,
      _ => false,
    };

/// Sets field [tag] of a well-known type, whose fields have implicit presence.
void setImplicit(GeneratedMessage msg, int tag, Object value) {
  if (isZeroValue(value)) {
    msg.clearField(tag);
  } else {
    msg.setField(tag, value);
  }
}

void setTimestampFields(GeneratedMessage msg, DateTime t) {
  // seconds = 1, nanos = 2. Seconds round down and nanos are never negative,
  // so a time before the epoch keeps its fraction.
  final millis = t.millisecondsSinceEpoch;
  setImplicit(msg, 1, Int64((millis - millis % 1000) ~/ 1000));
  setImplicit(msg, 2, (millis % 1000) * 1000000);
}

/// A `google.protobuf.Timestamp` from a literal, exact to the nanosecond,
/// where a DateTime holds microseconds.
void setTimestampLiteral(GeneratedMessage msg, String literal) {
  final t = DateTime.parse(literal);
  final fraction = RegExp(r'\.(\d+)').firstMatch(literal)?.group(1) ?? '';
  final nanos = int.parse(fraction.padRight(9, '0').substring(0, 9));
  final micros = t.microsecondsSinceEpoch;
  final whole = micros - micros % 1000000;
  setImplicit(msg, 1, Int64(whole ~/ 1000000));
  setImplicit(msg, 2, nanos);
}

/// A Timestamp as RFC 3339 with the fraction it needs, as Go's
/// `time.RFC3339Nano` writes it.
String formatTimestamp(GeneratedMessage msg) {
  final seconds = msg.getField(1) as Int64;
  final nanos = msg.getField(2) as int;
  final t =
      DateTime.fromMillisecondsSinceEpoch(seconds.toInt() * 1000, isUtc: true);
  String two(int v) => v.toString().padLeft(2, '0');
  final date = '${t.year.toString().padLeft(4, '0')}-${two(t.month)}-'
      '${two(t.day)}T${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  if (nanos == 0) return '${date}Z';
  final fraction =
      nanos.toString().padLeft(9, '0').replaceFirst(RegExp(r'0+$'), '');
  return '$date.${fraction}Z';
}

void setDurationFields(GeneratedMessage msg, Duration dur) {
  // seconds = 1, nanos = 2
  int microseconds = dur.inMicroseconds;
  int seconds = microseconds ~/ 1000000;
  int nanos = (microseconds % 1000000) * 1000;
  setImplicit(msg, 1, Int64(seconds));
  setImplicit(msg, 2, nanos);
}

/// A `google.protobuf.Duration` from a literal, exact to the nanosecond:
/// seconds and nanos carry the same sign, so `-1.5s` is -1 and -500000000.
void setDurationLiteral(GeneratedMessage msg, String literal) {
  final nanos = parseGoDurationNanos(literal);
  final second = BigInt.from(1000000000);
  setImplicit(msg, 1, Int64.parseInt((nanos ~/ second).toString()));
  setImplicit(msg, 2, nanos.remainder(second).toInt());
}

/// The nanoseconds of a `google.protobuf.Duration`.
BigInt readDurationNanos(GeneratedMessage msg) {
  final seconds = msg.getField(1) as Int64;
  final nanos = msg.getField(2) as int;
  return BigInt.parse(seconds.toString()) * BigInt.from(1000000000) +
      BigInt.from(nanos);
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

/// pxf.Secret, which a string literal stands for when it carries only its
/// value: `pw = "x"` is `pw { value = "x" }`.
bool isSecret(BuilderInfo info) => info.qualifiedMessageName == 'pxf.Secret';

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
  setImplicit(msg, 1, bigIntToBytes(abs));
  setImplicit(msg, 2, negative);
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
  setImplicit(msg, 1, bigIntToBytes(unscaled));
  setImplicit(msg, 2, scale);
  setImplicit(msg, 3, negative);
}

Uint8List bigIntToBytes(BigInt abs) {
  if (abs == BigInt.zero) return Uint8List(0);
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
