// Cross-port PXF microbench: Dart implementation.
//
// Reads `testdata/bench-test.pxf` (text payload), times unmarshal + marshal
// of `bench.v1.Config` for at least `--seconds` (default 3), and prints
// one JSON line per op:
//
//   {"port":"dart","op":"unmarshal","ns_per_op":7045,"mib_per_sec":89.3,"iterations":429000,"bytes":624}
//   {"port":"dart","op":"marshal","ns_per_op":5280,"iterations":571000}
//
// The other ports' bench-pxf binaries print the same shape; the
// protowire/scripts/cross_pxf_bench.sh runner aggregates them.

import 'dart:convert';
import 'dart:io';

import 'package:protowire/protowire.dart';
import 'package:protowire/src/generated/proto/bench/v1/bench.pb.dart';

void main(List<String> args) {
  var seconds = 3.0;
  var dataDir = '';
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--seconds' && i + 1 < args.length) {
      seconds = double.parse(args[++i]);
    } else if (a.startsWith('--seconds=')) {
      seconds = double.parse(a.substring('--seconds='.length));
    } else if (a == '--testdata' && i + 1 < args.length) {
      dataDir = args[++i];
    } else if (a.startsWith('--testdata=')) {
      dataDir = a.substring('--testdata='.length);
    }
  }
  if (dataDir.isEmpty) {
    dataDir = '${Directory.current.path}/testdata';
  }

  final pxfText = File('$dataDir/bench-test.pxf').readAsStringSync();
  final pxfBytes = utf8.encode(pxfText).length;
  final target = Duration(microseconds: (seconds * 1e6).round());

  // Warm-up.
  unmarshal(pxfText, Config());

  final unmarshalLoop = _timeLoop(target, () {
    unmarshal(pxfText, Config());
  });
  _emit({
    'port': 'dart',
    'op': 'unmarshal',
    'ns_per_op': unmarshalLoop.elapsed.inMicroseconds * 1000 ~/ unmarshalLoop.iterations,
    'mib_per_sec': _mibPerSec(pxfBytes, unmarshalLoop.iterations, unmarshalLoop.elapsed),
    'iterations': unmarshalLoop.iterations,
    'bytes': pxfBytes,
  });

  final seed = Config();
  unmarshal(pxfText, seed);
  final marshalLoop = _timeLoop(target, () {
    marshal(seed);
  });
  _emit({
    'port': 'dart',
    'op': 'marshal',
    'ns_per_op': marshalLoop.elapsed.inMicroseconds * 1000 ~/ marshalLoop.iterations,
    'iterations': marshalLoop.iterations,
  });
}

class _LoopResult {
  final int iterations;
  final Duration elapsed;
  _LoopResult(this.iterations, this.elapsed);
}

_LoopResult _timeLoop(Duration target, void Function() fn) {
  final start = Stopwatch()..start();
  var iters = 0;
  while (true) {
    for (var i = 0; i < 64; i++) {
      fn();
    }
    iters += 64;
    if (start.elapsed >= target) break;
  }
  return _LoopResult(iters, start.elapsed);
}

double _mibPerSec(int payloadBytes, int iters, Duration elapsed) {
  final totalBytes = payloadBytes * iters;
  return (totalBytes / (1024 * 1024)) / (elapsed.inMicroseconds / 1e6);
}

void _emit(Map<String, Object?> result) {
  // Drop nulls so the wire shape matches Go's omitempty.
  result.removeWhere((_, v) => v == null);
  print(jsonEncode(result));
}
