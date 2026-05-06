// Cross-port envelope wire-compatibility dumper.
//
// Constructs a canonical Envelope, encodes it via the protobuf package's
// writeToBuffer(), and prints the bytes as a hex string. The same canonical
// value is constructed in every other port; the spec repo's
// `scripts/cross_envelope_check.sh` asserts that all ports' hex output is
// byte-identical.
//
// Mirrors `protowire-go/scripts/dump_envelope/main.go` and the C# /
// Swift implementations. Uses the proto-generated Envelope (not the
// hand-written one) since byte-equivalence is the contract.

import 'dart:typed_data';

import 'package:protowire/src/generated/proto/envelope/v1/envelope.pb.dart';

void main() {
  final env = Envelope(
    status: 402,
    data: Uint8List.fromList([0xDE, 0xAD, 0xBE, 0xEF]),
    error: AppError(
      code: 'INSUFFICIENT_FUNDS',
      message: 'balance too low',
      args: [r'$3.50', r'$10.00'],
      details: [
        // The proto field is `field`, but `field` is reserved in the
        // dart codegen pb output, so the field is renamed to `field_1`.
        FieldError(
          field_1: 'amount',
          code: 'MIN_VALUE',
          message: 'below minimum',
          args: ['10.00'],
        ),
      ],
      metadata: const [MapEntry('request_id', 'req-123')],
    ),
  );

  final bytes = env.writeToBuffer();
  final hex = StringBuffer();
  for (final b in bytes) {
    hex.write(b.toRadixString(16).padLeft(2, '0'));
  }
  print(hex.toString());
}
