// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// check_decode --format pxf-fmt, the mode protowire's format gate
// (scripts/cross_fmt_check.sh, protowire#584) drives: the document formatted
// with no schema, on stdout byte for byte. The gate holds the output to
// protowire-go's goldens; these pin the harness's side of the contract.
import 'dart:convert';
import 'dart:io';

import 'package:protowire/protowire.dart';
import 'package:test/test.dart';

void main() {
  late Directory dir;
  setUpAll(() => dir = Directory.systemTemp.createTempSync('pxf-fmt'));
  tearDownAll(() => dir.deleteSync(recursive: true));

  ProcessResult run(List<int> doc, {String format = 'pxf-fmt'}) {
    final input = File('${dir.path}/doc.pxf')..writeAsBytesSync(doc);
    return Process.runSync(
        Platform.resolvedExecutable,
        [
          'run',
          'bin/check_decode.dart',
          '--format',
          format,
          '--input',
          input.path
        ],
        stdoutEncoding: null);
  }

  test('writes the formatted document with no --schema or --proto', () {
    const doc = '# lead\nb{a=1 s="é"}\n';
    final r = run(utf8.encode(doc));
    expect(r.exitCode, 0, reason: '${r.stderr}');
    expect(r.stdout, utf8.encode(formatPxf(doc)));
    expect(utf8.decode(r.stdout as List<int>),
        '# lead\nb {\n  a = 1\n  s = "é"\n}\n');
  });

  test('an empty document is accepted and writes nothing', () {
    final r = run([]);
    expect(r.exitCode, 0, reason: '${r.stderr}');
    expect(r.stdout, isEmpty);
  });

  test('a document that does not parse is a rejection', () {
    expect(run(utf8.encode('b {')).exitCode, 1);
    expect(run([0x61, 0x20, 0x3d, 0x20, 0x22, 0xff, 0x22]).exitCode, 1);
  });

  test('every other format still needs --schema', () {
    expect(run(utf8.encode('a = 1'), format: 'pxf').exitCode, 2);
  });
}
