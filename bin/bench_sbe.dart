// Cross-port SBE microbench: Dart implementation.
//
// Populates a canonical `bench.v1.Order` (10 scalars + 2-entry Fill group),
// times marshal + unmarshal for at least `--seconds` (default 3), and
// prints one JSON line per op:
//
//   {"port":"dart","op":"sbe-marshal","ns_per_op":1050,"iterations":...,"bytes":94}
//   {"port":"dart","op":"sbe-unmarshal","ns_per_op":6700,"mib_per_sec":13.4,"iterations":...,"bytes":94}
//
// The other ports' bench-sbe binaries print the same shape; the
// protowire/scripts/cross_sbe_bench.sh runner aggregates them.

import 'dart:convert';

import 'package:fixnum/fixnum.dart';
import 'package:protowire/protowire.dart';
import 'package:protowire/src/generated/proto/bench/v1/order.pb.dart';

void main(List<String> args) {
  var seconds = 3.0;
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--seconds' && i + 1 < args.length) {
      seconds = double.parse(args[++i]);
    } else if (a.startsWith('--seconds=')) {
      seconds = double.parse(a.substring('--seconds='.length));
    }
  }

  // SBE template wiring: schemaId / version / templateId match the
  // (sbe.*) annotations declared in proto/bench/v1/order.proto. The
  // length override pins `symbol` to a fixed 8-byte char[] — same value
  // every port wires up so the resulting payload is 94 bytes.
  final codec = Codec()
    ..registerMessage(
      Order.getDefault().info_,
      1, // templateId
      1, // schemaId
      0, // version
      lengths: {2: 8},
    );

  final order = _buildOrder();
  final target = Duration(microseconds: (seconds * 1e6).round());

  // Warm-up + payload size.
  final wireBytes = codec.marshal(order);

  final marshalLoop = _timeLoop(target, () {
    codec.marshal(order);
  });
  _emit({
    'port': 'dart',
    'op': 'sbe-marshal',
    'ns_per_op': marshalLoop.elapsed.inMicroseconds * 1000 ~/ marshalLoop.iterations,
    'iterations': marshalLoop.iterations,
    'bytes': wireBytes.length,
  });

  final unmarshalLoop = _timeLoop(target, () {
    codec.unmarshal(wireBytes, Order());
  });
  _emit({
    'port': 'dart',
    'op': 'sbe-unmarshal',
    'ns_per_op': unmarshalLoop.elapsed.inMicroseconds * 1000 ~/ unmarshalLoop.iterations,
    'mib_per_sec': _mibPerSec(wireBytes.length, unmarshalLoop.iterations, unmarshalLoop.elapsed),
    'iterations': unmarshalLoop.iterations,
    'bytes': wireBytes.length,
  });
}

/// Mirrors Go's `buildOrder` in scripts/bench_sbe/main.go. Same field values
/// as every other port's bench-sbe so the wire payload is byte-identical.
Order _buildOrder() {
  return Order()
    ..orderId = Int64(1001)
    ..symbol = 'AAPL'
    ..price = Int64(19150)
    ..quantity = 100
    ..side = Side.SIDE_SELL
    ..active = true
    ..weight = 0.85
    ..score = 2.5
    ..fills.addAll([
      Order_Fill()
        ..fillPrice = Int64(19155)
        ..fillQty = 25
        ..fillId = Int64(5001),
      Order_Fill()
        ..fillPrice = Int64(19160)
        ..fillQty = 50
        ..fillId = Int64(5002),
    ]);
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
  result.removeWhere((_, v) => v == null);
  print(jsonEncode(result));
}
