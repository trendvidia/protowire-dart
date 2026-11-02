// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// HARDENING.md § Mandatory limits (protowire#299): each limit has a default, a
// per-call override, and is enforced before the memory it bounds is allocated.
// The fixtures are the spec repo's testdata/adversarial/ rows that lower a
// limit, vendored verbatim, and bin/check_decode runs them as the corpus does.
import 'dart:io';

import 'package:protobuf/protobuf.dart' show ExtensionRegistry;
import 'package:protowire/protowire.dart';
import 'package:protowire/src/encoding/pxf/parser.dart';
import 'package:protowire/src/generated/proto/google/protobuf/descriptor.pb.dart'
    as pbd;
import 'package:test/test.dart';

import '../bin/adversarial.pb.dart' as adv;

const dir = 'test/testdata/adversarial';

Matcher limitError(String text) =>
    throwsA(predicate((e) => '$e'.contains(text)));

UnmarshalOptions opts(DecodeLimits l) => UnmarshalOptions(limits: l);

void main() {
  test('the defaults are the draft\'s', () {
    const l = DecodeLimits();
    expect(l.maxMessageSize, 64 * 1024 * 1024);
    expect(l.maxBytesLiteralLength, l.maxMessageSize);
    expect(l.maxRepeatedCount, l.maxMessageSize);
  });

  group('MaxMessageSize', () {
    final pxf = File('$dir/pxf/oversize-2kib.pxf').readAsStringSync();
    final pb = File('$dir/pb/oversize-2kib.binpb').readAsBytesSync();

    test('PXF: lowered, on every entry', () {
      const low = DecodeLimits(maxMessageSize: 1024);
      unmarshal(pxf, adv.StringHolder());
      unmarshal(pxf, adv.StringHolder(),
          options: opts(const DecodeLimits(maxMessageSize: 4096)));
      expect(() => unmarshal(pxf, adv.StringHolder(), options: opts(low)),
          limitError('exceeds MaxMessageSize=1024'));
      expect(() => unmarshalFull(pxf, adv.StringHolder(), options: opts(low)),
          limitError('exceeds MaxMessageSize=1024'));
      expect(
          () => parse(pxf, limits: low), limitError('exceeds MaxMessageSize'));
    });

    test('PXF counts bytes, not UTF-16 code units', () {
      final doc = 'value = "${'€' * 400}"';
      expect(doc.length, lessThan(1024));
      expect(
          () => unmarshal(doc, adv.StringHolder(),
              options: opts(const DecodeLimits(maxMessageSize: 1024))),
          limitError('exceeds MaxMessageSize=1024'));
    });

    test('PB', () {
      const low = DecodeLimits(maxMessageSize: 1024);
      mergeFromBufferChecked(adv.StringHolder(), pb);
      expect(
          () => mergeFromBufferChecked(
              adv.StringHolder(), pb, ExtensionRegistry.EMPTY, low),
          limitError('exceeds MaxMessageSize=1024'));
    });

    test('the default rejects 64 MiB + 1 and accepts 64 MiB', () {
      const max = 64 * 1024 * 1024;
      expect(() => unmarshal(' ' * (max + 1), adv.StringHolder()),
          limitError('exceeds MaxMessageSize=$max'));
      unmarshal(' ' * max, adv.StringHolder());
      final over = List<int>.filled(max + 1, 0);
      expect(() => mergeFromBufferChecked(adv.StringHolder(), over),
          limitError('exceeds MaxMessageSize=$max'));
    });
  });

  group('MaxBytesLiteralLength', () {
    final doc = File('$dir/pxf/giant-base64.pxf').readAsStringSync();

    test('is refused from the literal\'s length', () {
      unmarshal(doc, adv.BytesHolder());
      unmarshal(doc, adv.BytesHolder(),
          options: opts(const DecodeLimits(maxBytesLiteralLength: 256)));
      expect(
          () => unmarshal(doc, adv.BytesHolder(),
              options: opts(const DecodeLimits(maxBytesLiteralLength: 128))),
          limitError('exceeds MaxBytesLiteralLength=128'));
    });

    test('counts padding', () {
      const atBound = DecodeLimits(maxBytesLiteralLength: 1);
      unmarshal('value = b"QQ=="', adv.BytesHolder(), options: opts(atBound));
      expect(
          () => unmarshal('value = b"QUI="', adv.BytesHolder(),
              options: opts(atBound)),
          limitError('exceeds MaxBytesLiteralLength=1'));
    });
  });

  group('MaxRepeatedCount', () {
    final doc = File('$dir/pxf/many-elements-16.pxf').readAsStringSync();
    final pb = File('$dir/pb/many-elements-16.binpb').readAsBytesSync();
    const low = DecodeLimits(maxRepeatedCount: 8);
    const atBound = DecodeLimits(maxRepeatedCount: 16);

    test('a PXF list', () {
      final m = adv.ListHolder();
      unmarshal(doc, m, options: opts(atBound));
      expect(m.values, hasLength(16));
      expect(() => unmarshal(doc, adv.ListHolder(), options: opts(low)),
          limitError('exceeds MaxRepeatedCount=8'));
      expect(() => parse(doc, limits: low), limitError('MaxRepeatedCount=8'));
    });

    test('across two bindings of the field', () {
      expect(
          () => unmarshal('values = [1, 2]\nvalues = [3]', adv.ListHolder(),
              options: opts(const DecodeLimits(maxRepeatedCount: 2))),
          limitError('MaxRepeatedCount=2'));
    });

    test('a map', () {
      expect(
          () => unmarshal('branches = { a: {} b: {} }', adv.Tree(),
              options: opts(const DecodeLimits(maxRepeatedCount: 1))),
          limitError('MaxRepeatedCount=1'));
    });

    test('packed PB, without decoding the elements', () {
      final m = adv.ListHolder();
      mergeFromBufferChecked(m, pb, ExtensionRegistry.EMPTY, atBound);
      expect(m.values, hasLength(16));
      expect(
          () => mergeFromBufferChecked(
              adv.ListHolder(), pb, ExtensionRegistry.EMPTY, low),
          limitError('MaxRepeatedCount=8'));
    });

    group('an SBE group, before any entry', () {
      final bytes = File('$dir/sbe/group-count-16.sbe').readAsBytesSync();
      Codec codec() => Codec()
        ..registerFromDescriptorSet(
            pbd.FileDescriptorSet.fromBuffer(
                File('$dir/adversarial.binpb').readAsBytesSync(),
                sbeExtensionRegistry()),
            adv.SbeWithGroup());

      test('unmarshal', () {
        final m = adv.SbeWithGroup();
        codec().unmarshal(bytes, m, limits: atBound);
        expect(m.entries, hasLength(16));
        expect(() => codec().unmarshal(bytes, adv.SbeWithGroup(), limits: low),
            limitError('group count 16 exceeds MaxRepeatedCount=8'));
      });

      test('view', () {
        expect(codec().view(bytes, limits: atBound).getGroup('entries').length,
            16);
        expect(() => codec().view(bytes, limits: low).getGroup('entries'),
            limitError('group count 16 exceeds MaxRepeatedCount=8'));
      });

      test('the size limit', () {
        const tiny = DecodeLimits(maxMessageSize: 4);
        expect(() => codec().view(bytes, limits: tiny),
            limitError('exceeds MaxMessageSize=4'));
        expect(() => codec().unmarshal(bytes, adv.SbeWithGroup(), limits: tiny),
            limitError('exceeds MaxMessageSize=4'));
      });
    });
  });

  group('check_decode --limit', () {
    int run(String format, String schema, String input, List<String> limits) {
      final r = Process.runSync(Platform.resolvedExecutable, [
        'run',
        'bin/check_decode.dart',
        '--format',
        format,
        '--schema',
        'adversarial.v1.$schema',
        '--proto',
        '$dir/adversarial.proto',
        '--input',
        '$dir/$input',
        for (final l in limits) ...['--limit', l],
      ]);
      return r.exitCode;
    }

    for (final (format, schema, input, name, low, high) in [
      (
        'pxf',
        'StringHolder',
        'pxf/oversize-2kib.pxf',
        'MaxMessageSize',
        1024,
        4096
      ),
      (
        'pb',
        'StringHolder',
        'pb/oversize-2kib.binpb',
        'MaxMessageSize',
        1024,
        4096
      ),
      (
        'pxf',
        'BytesHolder',
        'pxf/giant-base64.pxf',
        'MaxBytesLiteralLength',
        128,
        256
      ),
      (
        'pxf',
        'ListHolder',
        'pxf/many-elements-16.pxf',
        'MaxRepeatedCount',
        8,
        16
      ),
      (
        'pb',
        'ListHolder',
        'pb/many-elements-16.binpb',
        'MaxRepeatedCount',
        8,
        16
      ),
      (
        'sbe',
        'SbeWithGroup',
        'sbe/group-count-16.sbe',
        'MaxRepeatedCount',
        8,
        16
      ),
    ]) {
      test('$input: $name=$low rejects, $high accepts', () {
        expect(run(format, schema, input, ['$name=$low']), 1);
        expect(run(format, schema, input, ['$name=$high']), 0);
      });
    }

    test('an unknown limit is the harness\'s fault', () {
      expect(
          run('pxf', 'StringHolder', 'pxf/oversize-2kib.pxf', ['Nope=1']), 2);
    });
  });
}
