// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// formatPxf keeps every directive, with its dataset rows, in document order
// (#94, trendvidia/protowire#558). The cases are protowire-go's
// format_directives_test.go, whose expected texts are the ones protowire-go
// and protowire-typescript write for the same sources.
import 'dart:convert';

import 'package:protowire/protowire.dart';
import 'package:protowire/src/encoding/pxf/ast.dart';
import 'package:protowire/src/encoding/pxf/format.dart' show formatValue;
import 'package:protowire/src/encoding/pxf/parser.dart';
import 'package:test/test.dart';

/// Formats [src], checks that the output parses to the same directives and
/// is a fixed point of formatting, and returns it.
String formatRoundTrip(String src) {
  final out = formatPxf(src);
  expect(directiveShape(parse(out)), directiveShape(parse(src)), reason: out);
  expect(formatPxf(out), out, reason: 'formatting is a fixed point');
  return out;
}

/// What a document's directives say, without positions, in the order the
/// formatter writes them.
List<Object?> directiveShape(Document doc) => [
      doc.typeUrl,
      for (final d in doc.directives) ...[
        '@${d.name}',
        d.prefixes,
        d.body == null ? null : utf8.decode(d.body!),
      ],
      for (final d in doc.datasets) ...[
        '@dataset',
        d.type,
        d.columns,
        for (final r in d.rows)
          [for (final c in r.cells) c == null ? '<absent>' : formatValue(c)],
      ],
      for (final d in doc.protos) ...[
        '@proto',
        d.shape,
        d.typeName,
        d.shape == ProtoShape.descriptor
            ? base64.encode(d.body)
            : utf8.decode(d.body),
      ],
      doc.entries.length,
    ];

void main() {
  test('a dataset keeps its header and every row (#94 input A)', () {
    const src = '@dataset trades.v1.Trade (id, px)\n(1, 2.5)\n(2, 3.5)\n';
    expect(formatRoundTrip(src), src);
  });

  test('an absent cell stays empty and null stays null', () {
    const src =
        '@dataset trades.v1.Trade (id, px, note)\n(1, 2.5, )\n(2, , null)\n';
    expect(formatRoundTrip(src), src);
  });

  test('@entry and a named directive stay (#94 input B)', () {
    const b = '@type a.v1.M\n@entry x { a = 1 }\n\nname = "n"\n';
    expect(formatRoundTrip(b), b);
    const src = '@type a.v1.M\n@entry x { a = 1 }\n@header h.v1.H\n\n'
        'name = "n"\n';
    expect(formatRoundTrip(src), src);
  });

  group('@proto keeps its shape', () {
    for (final (src, want) in [
      ('@proto { string id = 1; }\n@dataset (id)\n("a")\n', null),
      ('@proto a.v1.R { string id = 1; }\n@dataset a.v1.R (id)\n("a")\n', null),
      // The triple quotes go on lines of their own (protowire-go#303).
      (
        '@proto """syntax = "proto3"; message R { string id = 1; }"""\n'
            '@dataset R (id)\n("a")\n',
        '@proto """\nsyntax = "proto3"; message R { string id = 1; }\n"""\n'
            '@dataset R (id)\n("a")\n'
      ),
      // @type moves to the front: it binds no @proto, so this changes nothing.
      (
        '@proto b"CgA="\n@type a.v1.M\n\nx = 1\n',
        '@type a.v1.M\n@proto b"CgA="\n\nx = 1\n'
      ),
    ]) {
      test(src, () => expect(formatRoundTrip(src), want ?? src));
    }
  });

  // An anonymous @proto binds the next typed directive, so a @proto written
  // after a dataset in the source stays after it.
  test('directives keep source order', () {
    const src = '@dataset t.v1.T (id)\n(1)\n@proto { string id = 1; }\n'
        '@dataset (id)\n("a")\n';
    expect(formatRoundTrip(src), src);
  });

  test('a directive keeps the comments before it', () {
    final out = formatRoundTrip('# about the rows\n@dataset t.v1.T (id)\n(1)\n'
        '# second\n@dataset t.v1.U (id)\n(2)\n');
    expect(out, contains('# about the rows\n@dataset t.v1.T (id)'));
    expect(out, contains('# second\n@dataset t.v1.U (id)'));
  });

  // A triple-quoted @proto is written with its delimiters on lines of their
  // own, and its body reads back byte for byte (protowire-go#303).
  group('a triple-quoted @proto', () {
    test('keeps the line breaks around its body', () {
      const src = '@proto """\n  syntax = "proto3";\n  package fmt.v1;\n'
          '  message Doc { string name = 1; }\n"""\n@type fmt.v1.Doc\n';
      expect(
          formatRoundTrip(src),
          '@type fmt.v1.Doc\n@proto """\n  syntax = "proto3";\n'
          '  package fmt.v1;\n  message Doc { string name = 1; }\n"""\n');
    });

    for (final (name, src, body) in [
      // On the closing delimiter's line, the last quote would open the
      // closing """ early, and the output would not parse.
      (
        'body ends in a quote',
        '@proto """\n  syntax = "proto3";\n'
            '  import "google/protobuf/empty.proto"\n  """\n',
        'syntax = "proto3";\nimport "google/protobuf/empty.proto"'
      ),
      // On the closing delimiter's line, a last line of only whitespace
      // would be taken for the delimiter's indent and dropped.
      (
        'whitespace-only last line',
        '@proto """syntax = "proto3";\n  \n"""\n',
        'syntax = "proto3";\n  '
      ),
      (
        'leading line break',
        '@proto """\n\nsyntax = "proto3";"""\n',
        '\nsyntax = "proto3";'
      ),
      (
        'trailing line break',
        '@proto """syntax = "proto3";\n\n"""\n',
        'syntax = "proto3";\n'
      ),
      ('empty body', '@proto """"""\n', ''),
    ]) {
      test(name, () {
        final doc = parse(src);
        expect(doc.protos, hasLength(1));
        expect(utf8.decode(doc.protos.single.body), body, reason: 'as read');
        expect(formatRoundTrip(src), '@proto """\n$body\n"""\n');
      });
    }
  });

  test('a document whose only directive is @type formats as before', () {
    expect(formatPxf('# c\n@type a.v1.M\n\nx = 1\n'),
        '@type a.v1.M\n\n# c\nx = 1\n');
  });
}
