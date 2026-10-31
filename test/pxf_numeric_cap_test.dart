// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// MaxNumericLiteralDigits, both sides of the bound (HARDENING.md § Mandatory
// limits, protowire#279, #25). The cap counts a literal's significant
// mantissa digits only: no leading zeros, exponent or suffix (protowire#410).
import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:protowire/src/generated/proto/pxf/bignum.pb.dart' as pxf;
import 'package:test/test.dart';

import '../bin/adversarial.pb.dart';

/// A `double` field: the exponent rule on a literal no big-number type reads.
class FloatProbe extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('FloatProbe',
      package: const PackageName('numeric.v1'), createEmptyInstance: create)
    ..a<double>(1, 'value', PbFieldType.OD)
    ..hasRequiredFields = false;

  FloatProbe._();
  @override
  BuilderInfo get info_ => _i;
  @override
  FloatProbe clone() => FloatProbe.create()..mergeFromMessage(this);
  @override
  FloatProbe createEmptyInstance() => create();
  static FloatProbe create() => FloatProbe._();
}

BigInt magnitude(List<int> bytes) => bytes.fold(
    BigInt.zero, (value, byte) => (value << 8) | BigInt.from(byte & 0xff));

BigNumHolder decode(String body) {
  final msg = BigNumHolder();
  unmarshal('@type adversarial.v1.BigNumHolder\n\n$body\n', msg);
  return msg;
}

final limitError = throwsA(predicate(
    (Object e) => '$e'.contains('MaxNumericLiteralDigits=4096'),
    'an error naming MaxNumericLiteralDigits=4096'));

void main() {
  _producerTests();

  final atCap = '1' * maxNumericLiteralDigits;
  final pastCap = '1' * (maxNumericLiteralDigits + 1);

  group('pxf.BigInt', () {
    test('exactly 4096 digits decodes to that value', () {
      final got = decode('big_int = $atCap').bigInt;
      expect(magnitude(got.abs), BigInt.parse(atCap));
      expect(got.negative, isFalse);
    });

    test('the sign is not a digit', () {
      final got = decode('big_int = -$atCap').bigInt;
      expect(magnitude(got.abs), BigInt.parse(atCap));
      expect(got.negative, isTrue);
    });

    test('4097 digits is rejected naming the limit', () {
      expect(() => decode('big_int = $pastCap'), limitError);
      expect(() => decode('big_int = -$pastCap'), limitError);
    });

    test('leading zeros are not significant', () {
      final got = decode('big_int = ${'0' * 10}$atCap').bigInt;
      expect(magnitude(got.abs), BigInt.parse(atCap));
      expect(() => decode('big_int = ${'0' * 10}$pastCap'), limitError);
    });

    test('a zero digit after the first significant one counts', () {
      final tens = '1${'0' * 4095}';
      expect(
          magnitude(decode('big_int = $tens').bigInt.abs), BigInt.parse(tens));
      expect(() => decode('big_int = ${tens}0'), limitError);
    });
  });

  group('pxf.Decimal', () {
    test('both sides of the point share the cap', () {
      final whole = '1' * 2048;
      final frac = '2' * 2048;
      final got = decode('decimal = $whole.$frac').decimal;
      expect(magnitude(got.unscaled), BigInt.parse(whole + frac));
      expect(got.scale, 2048);
      expect(() => decode('decimal = $whole.${frac}2'), limitError);
    });

    test('scale 4096 has a literal, scale 4097 does not', () {
      final got = decode('decimal = 0.${'0' * 4095}1').decimal;
      expect(magnitude(got.unscaled), BigInt.one);
      expect(got.scale, 4096);
      expect(() => decode('decimal = 0.${'0' * 4096}1'), limitError);
    });
  });

  test('an exponent is not counted', () {
    // A double field, so the literal reaches the decoder. Only the cap names
    // the limit; the mantissa here has one digit.
    final msg = FloatProbe.create();
    unmarshal('value = 1e${'0' * 5000}1', msg);
    expect(msg.getField(1), 10.0);
  });

  group('a literal no big-number helper reads', () {
    // A double field: only the lexer's cap stands in the way.
    void decodeFloat(String literal) =>
        unmarshal('value = $literal', FloatProbe.create());

    test('integer digits are capped at the bound', () {
      decodeFloat(atCap);
      expect(() => decodeFloat(pastCap), limitError);
    });

    test('digits either side of the point share the cap', () {
      decodeFloat('${'1' * 2048}.${'2' * 2048}');
      expect(() => decodeFloat('${'1' * 2048}.${'2' * 2049}'), limitError);
    });
  });

  group('input the cap no longer bounds stays a clean decode', () {
    // Ten million zeros count as no digits. The parsers behind the cap must
    // not see them: BigInt.parse overflows the stack on input this long.
    final zeros = '0' * 10000000;

    test('on a pxf.BigInt', () {
      expect(magnitude(decode('big_int = ${zeros}1').bigInt.abs), BigInt.one);
      expect(magnitude(decode('big_int = -${zeros}1').bigInt.abs), BigInt.one);
    });

    test('on a pxf.Decimal', () {
      final got = decode('decimal = $zeros.5').decimal;
      expect(magnitude(got.unscaled), BigInt.from(5));
      expect(got.scale, 1);
    });

    test('on a double', () {
      final msg = FloatProbe.create();
      unmarshal('value = ${zeros}1.5', msg);
      expect(msg.getField(1), 1.5);
    });

    test('on what lexes as a duration', () {
      expect(() => unmarshal('value = ${zeros}1s', FloatProbe.create()),
          limitError);
    });
  });

  group('a literal that never meets the lexer', () {
    pxf.BigInt bigInt(String raw) {
      final msg = pxf.BigInt();
      setBigIntFields(msg, raw);
      return msg;
    }

    test('setBigIntFields applies the same count', () {
      expect(magnitude(bigInt(atCap).abs), BigInt.parse(atCap));
      expect(magnitude(bigInt('0' * 5000 + atCap).abs), BigInt.parse(atCap));
      expect(() => bigInt(pastCap), limitError);
    });

    test('the count stops at an exponent', () {
      // A big-number parser refuses this, but not for its digit count.
      expect(
          () => setBigIntFields(pxf.BigInt(), '1e${'1' * 5000}'),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              isNot(contains('MaxNumericLiteralDigits')))));
    });

    test('setDecimalFields bounds the scale', () {
      final msg = pxf.Decimal();
      setDecimalFields(msg, '0.${'0' * 4095}1');
      expect(msg.scale, 4096);
      expect(() => setDecimalFields(pxf.Decimal(), '0.${'0' * 4096}1'),
          limitError);
    });
  });
}

// A producer of PXF text fails on a value past a bound, and five input bytes
// must not cost two gigabytes (HARDENING.md § Arbitrary-precision magnitudes).
void _producerTests() {
  BigNumHolder holder(List<int> unscaled, int scale) => BigNumHolder()
    ..decimal = (pxf.Decimal()
      ..unscaled = unscaled
      ..scale = scale);

  group('marshal a pxf.Decimal', () {
    for (final scale in [4097, -4097, 0x7fffffff, -0x80000000]) {
      test('refuses scale $scale', () {
        expect(
            () => marshal(holder([25], scale)),
            throwsA(isA<PxfError>().having((e) => e.message, 'message',
                contains('exceeds MaxNumericLiteralDigits'))));
      });
    }

    test('a negative scale is trailing zeros', () {
      expect(marshal(holder([5], -2)), contains('decimal = 500'));
      expect(marshal(holder([], -2)), contains('decimal = 0'));
    });

    test('scale 4096 renders, since leading zeros do not count', () {
      expect(
          marshal(holder([5], 4096)), contains('decimal = 0.${'0' * 4095}5'));
    });

    test('a literal past the cap is refused', () {
      expect(
          () => marshal(holder([10], -4096)),
          throwsA(isA<PxfError>().having((e) => e.message, 'message',
              contains('renders to 4098 digits'))));
    });
  });
}
