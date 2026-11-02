// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// `@dataset` (draft -01 §3.4.4): the spec repo's testdata/dataset/ corpus,
// vendored verbatim under test/testdata/dataset/, against the verdict table
// of its cmd/pxf/dataset_test.go. paths.pb.dart and paths.binpb come from the
// vendored paths.proto:
//
//   protoc -I test/testdata/dataset -I <protowire>/proto --dart_out=<tmp> \
//     --include_imports --descriptor_set_out=test/testdata/dataset/paths.binpb \
//     test/testdata/dataset/paths.proto
import 'dart:io';

import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:protowire/src/encoding/pxf/ast.dart';
import 'package:protowire/src/encoding/pxf/parser.dart';
import 'package:test/test.dart';

import 'generated/paths.pb.dart' as paths;
import 'generated/test.pb.dart' as testpb;

const dir = 'test/testdata/dataset';

/// null accepts; otherwise a substring of the rejection.
const verdicts = <String, String?>{
  'empty-rows.pxf': null,
  'rows-end-at-directive.pxf': null,
  'list-cell.pxf': null,
  'block-cell.pxf': null,
  'nested-cells.pxf': null,
  'cell-framing.pxf': null,
  'arity-long.pxf': '3 cells, expected 2',
  'arity-short.pxf': '2 cells, expected 3',
  'junk-between-rows.pxf': 'top-level field entries',
  'truncated-row-eof.pxf': 'expected "," or ")"',
  'truncated-row-then-rows.pxf': 'expected "," or ")"',
  'with-body.pxf': 'top-level field entries',
  'with-type.pxf': '@type',
  'block-on-scalar.pxf': 'expected integer for field "int32_field"',
  'string-newline-in-cell.pxf': 'newline in string literal',
  'null-on-scalar-cell.pxf':
      'null is not allowed on scalar field "int32_field"',
  'null-on-optional-cell.pxf': null,
  'dotted-column.pxf': null,
  'dotted-grouping.pxf': null,
  'dotted-null-leaf.pxf': null,
  'dotted-oneof.pxf': null,
  'dotted-required.pxf': null,
  'dotted-with-value-cells.pxf': null,
  'dotted-oneof-two-members.pxf': 'conflicts with already-set field',
  'dotted-through-repeated.pxf': '"picks" is a repeated field',
  'dotted-through-map.pxf': '"by_name" is a map field',
  'dotted-into-timestamp.pxf': '"ts" is a google.protobuf.Timestamp',
  'dotted-into-wrapper.pxf': '"wrap" is a google.protobuf.Int32Value',
  'dotted-overlap.pxf': 'column "desc.energy" overlaps column "desc"',
  'duplicate-column.pxf': 'column "string_field" appears twice',
  'dotted-required-missing.pxf': 'required field "req.n" is absent',
  'dotted-empty-segment.pxf': 'a column path has an empty segment',
  'dotted-trailing-dot.pxf': 'a column path has an empty segment',
  'dotted-unknown-segment.pxf': 'has no field "nope"',
  'dotted-through-scalar.pxf': '"plain" is not a message field',
  'dotted-into-duration.pxf': '"dur" is a google.protobuf.Duration',
  'dotted-into-bignum.pxf': '"big" is a pxf.BigInt',
  'dotted-overlap-deep.pxf':
      'column "desc.tempo.min_bpm" overlaps column "desc.tempo"',
  'dotted-bad-header-empty-row.pxf': '"picks" is a repeated field',
  'dotted-into-secret.pxf': null,
  'dotted-into-any.pxf': null,
  'dotted-bad-header-no-rows.pxf': null,
};

/// Decided by the header or the document alone, so `parse` must reject them.
const parseRejects = {
  'arity-long.pxf',
  'arity-short.pxf',
  'junk-between-rows.pxf',
  'truncated-row-eof.pxf',
  'truncated-row-then-rows.pxf',
  'with-body.pxf',
  'with-type.pxf',
  'string-newline-in-cell.pxf',
  'dotted-overlap.pxf',
  'dotted-overlap-deep.pxf',
  'dotted-empty-segment.pxf',
  'dotted-trailing-dot.pxf',
  'duplicate-column.pxf',
};

final PxfAnnotations ann =
    PxfAnnotations.fromBytes(File('$dir/paths.binpb').readAsBytesSync());

String read(String name) =>
    File('$dir/$name').readAsStringSync().replaceAll('\r\n', '\n');

GeneratedMessage rowOf(String type) =>
    type == 'test.v1.AllTypes' ? testpb.AllTypes() : paths.Event();

final PxfAnnotations allTypes = PxfAnnotations.fromBytes(
    File('test/testdata/repeated/test.binpb').readAsBytesSync());

void bindAll(DatasetDirective ds) {
  final schema = ds.type == 'test.v1.AllTypes' ? allTypes : ann;
  for (final row in ds.rows) {
    bindDatasetRow(rowOf(ds.type), ds.columns, row,
        options: UnmarshalOptions(annotations: schema));
  }
}

void main() {
  final bound = <String>{};

  verdicts.forEach((name, expected) {
    test(name, () {
      final doc = read(name);
      void run() {
        parse(doc).datasets.forEach(bindAll);
      }

      if (parseRejects.contains(name)) {
        expect(() => parse(doc), throwsA(isA<PxfError>()), reason: 'parse');
        expect(
            () => unmarshalFull(doc, paths.Event()), throwsA(isA<PxfError>()),
            reason: 'the streaming path');
      } else {
        expect(() => parse(doc), returnsNormally, reason: 'parse');
        // The decoder reads the rows the parser does.
        final viaDecoder = unmarshalFull(doc, paths.Event()).datasets;
        final viaParser = parse(doc).datasets;
        expect(viaDecoder.map((d) => d.rows.length),
            viaParser.map((d) => d.rows.length));
      }

      if (expected == null) {
        run();
      } else {
        expect(
            run,
            throwsA(isA<PxfError>()
                .having((e) => '$e', 'message', contains(expected))));
      }
      bound.add(name);
    });
  });

  test('every fixture has a verdict and ran', () {
    final onDisk = Directory(dir)
        .listSync()
        .map((e) => e.uri.pathSegments.last)
        .where((n) => n.endsWith('.pxf'))
        .toSet();
    expect(onDisk, hasLength(42));
    expect(verdicts.keys.toSet(), onDisk);
    expect(bound, onDisk);
  });

  group('bindDatasetRow', () {
    paths.Event bind(String doc, [int index = 0]) {
      final ds = parse(doc).datasets.single;
      final e = paths.Event();
      bindDatasetRow(e, ds.columns, ds.rows[index],
          options: UnmarshalOptions(annotations: ann));
      return e;
    }

    test('groups cells by prefix into one block', () {
      final e = bind('@dataset dataset.v1.Event '
          '(id, desc.energy, desc.tempo.min_bpm)\n("a", 0.5, 120)\n');
      expect(e.id, 'a');
      expect(e.desc.energy, 0.5);
      expect(e.desc.tempo.minBpm, 120);
    });

    test('all-empty cells leave the sub-message absent', () {
      final e = bind('@dataset dataset.v1.Event (id, desc.energy)\n("a", )\n');
      expect(e.hasDesc(), isFalse);
    });

    test('a list and a block cell bind as a body would', () {
      final e = bind('@dataset dataset.v1.Event (id, picks, a)\n'
          '("a", [{ name = "x" }, { name = "y" }], { n = 1 })\n');
      expect(e.picks.map((p) => p.name), ['x', 'y']);
      expect(e.a.n, 1);
    });

    test('{} is a present empty message, and an empty cell is absent', () {
      expect(
          bind('@dataset dataset.v1.Event (desc)\n({})\n').hasDesc(), isTrue);
    });

    test('a null leaf leaves the parent present', () {
      final e = bind('@dataset dataset.v1.Event (desc.label)\n(null)\n');
      expect(e.hasDesc(), isTrue);
      expect(e.desc.hasLabel(), isFalse);
    });

    test('a string keeps its escapes', () {
      final e =
          bind(r'@dataset dataset.v1.Event (id)' '\n' r'("a\nb\"c")' '\n');
      expect(e.id, 'a\nb"c');
    });

    test('an arity mismatch is an error, not a crash', () {
      final row = DatasetRow(pos: parse('a = 1').entries.first.pos, cells: []);
      expect(() => bindDatasetRow(paths.Event(), ['id'], row),
          throwsA(isA<PxfError>()));
    });
  });
}
