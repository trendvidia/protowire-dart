// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// A compiled program can use the main import (#52). `dart compile exe` is the
// proof: dart:mirrors does not exist there, and importing it is a build error.
@TestOn('vm')
library;

import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('dart compile exe builds and runs a PXF round trip', () {
    final dir = Directory.systemTemp.createTempSync('pw-compile');
    addTearDown(() => dir.deleteSync(recursive: true));
    final exe = '${dir.path}${Platform.pathSeparator}smoke.exe';

    final build = Process.runSync(Platform.resolvedExecutable,
        ['compile', 'exe', 'test/compile/smoke.dart', '-o', exe]);
    expect(build.exitCode, 0, reason: '${build.stdout}${build.stderr}');

    final run = Process.runSync(exe, const []);
    expect(run.exitCode, 0, reason: '${run.stderr}');
    expect((run.stdout as String).trim(), 'ok 7 X 1');
  }, timeout: const Timeout(Duration(minutes: 3)));
}
