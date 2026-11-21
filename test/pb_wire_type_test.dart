// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// A tag's wire type, against protobuf-go (protowire-dart#101, protowire#614).
//
// A PB decoder does what protobuf does with a tag's wire type: it rejects
// wire type 6 or 7 on any field, and handles a known field whose wire type
// does not match its type as an unknown field, skipped by its wire type with
// the field left as it was. package:protobuf reads a singular number, bool or
// enum from a length-delimited record as if it were packed, so `0a0101` on an
// int64 read the length byte as the value and then failed on the next byte.
//
// The oracle is protobuf-go v1.36.12. test/testdata/wire-types/oracle.json is
// what it did with each input, written by tool/go_oracle/wiretypes: every
// field of conf.All (protowire-go's conformance schema) and of
// wiretypes.v1.Base (an enum, a group, extensions) sent one record of every
// wire type, well formed and cut short, at the top level and inside each
// message, group, extension and map field. Each input must get protobuf-go's
// verdict; on accept, the same values, and the same bytes written back with
// the unknown fields kept.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:protowire/src/generated/proto/pxf/bignum.pb.dart' as bn;
import 'package:test/test.dart';

import '../bin/adversarial.pb.dart' as adv;
import 'generated/conf.pb.dart' as conf;
import 'generated/ext.pb.dart' as ext;

String hexOf(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

Uint8List unhex(String s) => Uint8List.fromList([
      for (var i = 0; i < s.length; i += 2)
        int.parse(s.substring(i, i + 2), radix: 16)
    ]);

final registry = ExtensionRegistry()
  ..add(ext.Ext.e64)
  ..add(ext.Ext.sub)
  ..add(ext.Ext.subs);

GeneratedMessage newMessage(String name) => switch (name) {
      'conf.All' => conf.All(),
      'wiretypes.v1.Base' => ext.Base(),
      _ => throw ArgumentError(name),
    };

/// Why decoding [input] into [into] was refused, or null. Anything but an
/// InvalidProtocolBufferException is a failure of its own: it is all that
/// mergeFromBufferChecked may throw.
String? decode(GeneratedMessage into, List<int> input) {
  try {
    mergeFromBufferChecked(into, input, registry);
    return null;
  } on InvalidProtocolBufferException catch (e) {
    return e.message;
  } catch (e) {
    return 'threw ${e.runtimeType}: $e';
  }
}

/// [m] as protobuf-go holds it, at every level: a proto3 field (conf.*) set to
/// its zero cleared, as Go does not keep one outside a oneof, and with
/// [unknown] false, the unknown fields dropped. A generated class does not say
/// whether its file is proto3, so package:protobuf keeps `s = ""` set and
/// writes it back; that is not a wire type's doing.
void normalize(GeneratedMessage m, {required bool unknown}) {
  if (m.isFrozen) return;
  if (!unknown) m.unknownFields.clear();
  void visit(Object? v) {
    if (v is GeneratedMessage) {
      normalize(v, unknown: unknown);
    } else if (v is List) {
      v.forEach(visit);
    } else if (v is Map) {
      v.values.forEach(visit);
    }
  }

  final proto3 = m.info_.qualifiedMessageName.startsWith('conf.');
  for (final fi in m.info_.fieldInfo.values) {
    final n = fi.tagNumber;
    // hasField is false for empty bytes, which are still held and written.
    final singular = !fi.isRepeated && !fi.isMapField && !fi.isGroupOrMessage;
    if (!singular && !m.hasField(n)) continue;
    final v = m.getField(n);
    final zero = switch (v) {
      final String s => s.isEmpty,
      final List<int> l when singular => l.isEmpty,
      final int i => i == 0,
      final Int64 i => i.isZero,
      final double d => d == 0 && !d.isNegative,
      final bool b => !b,
      _ => false,
    };
    if (proto3 && singular && zero && !m.info_.oneofs.containsKey(n)) {
      m.clearField(n);
    } else {
      visit(v);
    }
  }
  for (final e in [ext.Ext.sub, ext.Ext.subs]) {
    if (m.hasExtension(e)) visit(m.getExtension(e));
  }
}

class OracleRow {
  final String message, input, error, known, all;
  final bool accepted;
  OracleRow(Map<String, dynamic> j)
      : message = j['message'] as String,
        input = j['input'] as String,
        accepted = j['accepted'] as bool,
        error = (j['error'] ?? '') as String,
        known = (j['known'] ?? '') as String,
        all = (j['all'] ?? '') as String;
}

class Holder {
  @ProtoTag(1)
  int? p;
  @ProtoTag(2)
  List<String>? l;
  @ProtoTag(3)
  String? kept;
}

class BigHolder {
  @ProtoTag(1)
  BigInt? i;
  @ProtoTag(2)
  bn.Decimal? r;
  @ProtoTag(3)
  bn.BigFloat? f;
}

void main() {
  final rows = [
    for (final j in jsonDecode(
            File('test/testdata/wire-types/oracle.json').readAsStringSync())
        as List)
      OracleRow(j as Map<String, dynamic>)
  ];

  test('every input gets protobuf-go\'s verdict and values', () {
    final failures = <String>[];
    var accepted = 0, rejected = 0;
    for (final r in rows) {
      final input = unhex(r.input);
      final got = newMessage(r.message);
      final err = decode(got, input);
      if (err != null && err.startsWith('threw ')) {
        failures.add('${r.message} ${r.input}: $err');
        r.accepted ? accepted++ : rejected++;
        continue;
      }
      if (!r.accepted) {
        rejected++;
        if (err == null) {
          failures.add('${r.message} ${r.input}: protobuf-go rejects it '
              '(${r.error}), accepted here');
        }
        continue;
      }
      accepted++;
      if (err != null) {
        failures.add('${r.message} ${r.input}: protobuf-go accepts it, '
            'rejected here: $err');
        continue;
      }
      final kept = got.deepCopy();
      normalize(kept, unknown: true);
      final all = hexOf(kept.writeToBuffer());
      if (all != r.all) {
        failures.add('${r.message} ${r.input}: written back as $all, '
            'protobuf-go writes ${r.all}');
      }
      final want = newMessage(r.message);
      final wantErr = decode(want, unhex(r.known));
      if (wantErr != null) {
        failures.add('${r.message} ${r.input}: protobuf-go\'s message '
            '${r.known} rejected here: $wantErr');
        continue;
      }
      final values = got.deepCopy();
      normalize(values, unknown: false);
      normalize(want, unknown: false);
      if (values != want) {
        failures.add('${r.message} ${r.input}: values differ from '
            'protobuf-go\'s: got $values, want $want');
      }
    }
    // A positive marker that both verdicts were exercised, and on how many.
    printOnFailure(failures.join('\n'));
    print('${rows.length} inputs: protobuf-go accepts $accepted, rejects '
        '$rejected; ${failures.length} differ here');
    expect(rows.where((r) => r.message == 'conf.All').length, 606);
    expect(accepted, greaterThan(300));
    expect(rejected, greaterThan(300));
    expect(failures, isEmpty);
  });

  // The rows of protowire-dart#101's table, and the spec corpus's
  // pb/wiretype-* rows, on the corpus's own messages. A rejection gives
  // protowire-go's text, as `check-decode --format pb` prints it there.
  group('the corpus rows', () {
    for (final (name, hex, str, error) in [
      (
        'int64, wire type 6',
        '0e01',
        false,
        'corrupt field 1: proto: cannot parse reserved wire type'
      ),
      (
        'string, wire type 7',
        '0f0161',
        true,
        'corrupt field 1: proto: cannot parse reserved wire type'
      ),
      (
        'string, wire type 6',
        '0e0161',
        true,
        'corrupt field 1: proto: cannot parse reserved wire type'
      ),
      (
        'unknown field 99, wire type 7',
        '9f06',
        false,
        'corrupt field 99: proto: cannot parse reserved wire type'
      ),
      (
        'unknown field 99, wire type 6',
        '9e0601',
        false,
        'corrupt field 99: proto: cannot parse reserved wire type'
      ),
      ('int64 sent as wire type 2', '0a0101', false, null),
      ('int64 sent as wire type 5', '0d01000000', false, null),
      ('string sent as wire type 0', '0801', true, null),
      (
        'int64 as wire type 2, cut short',
        '0a01',
        false,
        'corrupt field 1: unexpected EOF'
      ),
      (
        'int64 as wire type 5, cut short',
        '0d01',
        false,
        'corrupt field 1: unexpected EOF'
      ),
      (
        'int64, an end-group that ends nothing',
        '0c',
        false,
        'corrupt field 1: proto: mismatching end group marker'
      ),
    ]) {
      test(name, () {
        final GeneratedMessage m =
            str ? adv.StringHolder() : adv.BigIntHolder();
        expect(decode(m, unhex(hex)), error);
        expect(m.hasField(1), isFalse);
        if (error == null) {
          // Kept as an unknown field, and written back as it came.
          expect(hexOf(m.writeToBuffer()), hex);
        }
      });
    }
  });

  test('a skipped field is not touched: no value, no list element', () {
    final m = Holder();
    unmarshalNative(unhex('0d01000000' '1001' '1a0161'), m);
    expect(m.p, isNull);
    expect(m.l, isNull);
    expect(m.kept, 'a');
  });

  test('a mismatch inside a map entry leaves the entry\'s value alone', () {
    // conf.All.m, map<string, int64>: key "k", value 7 sent as wire type 2.
    final m = conf.All();
    expect(decode(m, unhex('9201' '06' '0a016b' '120107')), isNull);
    expect(m.m, {'k': Int64.ZERO});
  });

  // package:protobuf stores the int 0 for a map entry's absent 64-bit key or
  // value, and its typed map then throws a TypeError, out of
  // mergeFromBufferChecked too. Such an entry is now merged here, with
  // Int64.ZERO, as protobuf-go reads it. A mismatched key or value is absent.
  group('a map entry without its 64-bit key or value', () {
    test('no value', () {
      final m = conf.All();
      expect(decode(m, unhex('9201' '03' '0a016b')), isNull);
      expect(m.m, {'k': Int64.ZERO});
    });
    test('an empty entry', () {
      final m = conf.All();
      expect(decode(m, unhex('920100')), isNull);
      expect(m.m, {'': Int64.ZERO});
    });
    test('no key', () {
      final m = ext.Base();
      expect(decode(m, unhex('3a02' '1001')), isNull);
      expect(m.em, {Int64.ZERO: ext.Color.COLOR_RED});
    });
    test('the value on another wire type', () {
      final m = conf.All();
      expect(decode(m, unhex('9201' '08' '0a016b' '1501000000')), isNull);
      expect(m.m, {'k': Int64.ZERO});
    });
  });

  // protowire-go's TestUnmarshal_WireTypeBigNumbers: the big-number messages
  // follow the same rule. A rejection names the message as Go's does.
  group('the big-number messages', () {
    for (final (name, hex, check, error) in [
      (
        // BigInt{abs: 5, negative sent as wire type 2}: negative is skipped.
        'BigInt negative as bytes',
        '0a06'
            '0a0105'
            '120101',
        (BigHolder m) => expect(m.i, BigInt.from(5)),
        null
      ),
      (
        // BigInt{abs sent as a varint}: abs is skipped, the value is 0.
        'BigInt abs as varint',
        '0a02'
            '0805',
        (BigHolder m) => expect(m.i, BigInt.zero),
        null
      ),
      (
        // Decimal{unscaled: 15, scale sent as fixed32}: scale stays 0.
        'Decimal scale as fixed32',
        '1208'
            '0a010f'
            '1501000000',
        (BigHolder m) {
          expect(m.r!.unscaled, [15]);
          expect(m.r!.scale, 0);
        },
        null
      ),
      (
        // BigFloat{mantissa: 1, exponent sent as bytes, prec 53}: exponent
        // stays 0.
        'BigFloat exponent as bytes',
        '1a08'
            '0a0101'
            '120101'
            '1835',
        (BigHolder m) {
          expect(m.f!.mantissa, [1]);
          expect(m.f!.exponent, 0);
          expect(m.f!.prec, 53);
        },
        null
      ),
      (
        'BigInt, wire type 6',
        '0a02' '0e01',
        null,
        'corrupt field 1 in BigInt: proto: cannot parse reserved wire type'
      ),
      (
        'Decimal, wire type 7',
        '1203' '1f0101',
        null,
        'corrupt field 3 in Decimal: proto: cannot parse reserved wire type'
      ),
      (
        'BigFloat, wire type 6',
        '1a02' '2601',
        null,
        'corrupt field 4 in BigFloat: proto: cannot parse reserved wire type'
      ),
    ]) {
      test(name, () {
        final m = BigHolder();
        if (error != null) {
          expect(
              () => unmarshalNative(unhex(hex), m),
              throwsA(isA<InvalidProtocolBufferException>()
                  .having((e) => e.message, 'message', error)));
          return;
        }
        unmarshalNative(unhex(hex), m);
        check!(m);
      });
    }
  });

  test('a map entry\'s skipped field names the entry', () {
    // conf.All.m: key "k", then field 3 with wire type 7.
    expect(decode(conf.All(), unhex('9201' '05' '0a016b' '1f01')),
        'corrupt field 3 in map entry: proto: cannot parse reserved wire type');
  });
}
