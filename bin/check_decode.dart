// Per-port reference for the protowire HARDENING.md conformance corpus.
//
// Driven by `protowire/scripts/cross_security_check.sh`. See:
// - `protowire/docs/HARDENING.md`
// - `protowire/testdata/adversarial/README.md`
//
// Contract:
//
//   check_decode --format <pxf|pb|sbe|envelope> \
//                --schema <fully.qualified.MessageType> \
//                --proto  <path-to-adversarial.proto> \
//                --input  <path>
//
//   Exit 0 → input was accepted (decode succeeded)
//   Exit 1 → input was rejected (clean error; "reject: <msg>" on stderr)
//   Other  → bug in the decoder (uncaught exception, stack overflow, ...)
//
// The Dart port's PXF + PB decoders consume `GeneratedMessage` instances
// (BuilderInfo-driven), not runtime FileDescriptor descriptors. The four
// adversarial schemas are statically generated into adversarial.pb.dart
// next to this file via `protoc --dart_out=...`. Drift between the .proto
// and the generated file is caught by the conformance run itself: a wrong
// field number flips the manifest's accept/reject expectations.

import 'dart:io';
import 'dart:typed_data';

import 'package:protobuf/protobuf.dart' as pb;
import 'package:protowire/protowire.dart' as pw;

import 'adversarial.pb.dart' as adv;

void main(List<String> args) async {
  String? format;
  String? schema;
  String? proto;
  String? input;

  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    String? next() => (i + 1 < args.length) ? args[++i] : null;
    switch (a) {
      case '--format':
        format = next();
      case '--schema':
        schema = next();
      case '--proto':
        proto = next();
      case '--input':
        input = next();
      default:
        if (a.startsWith('--format=')) {
          format = a.substring('--format='.length);
        } else if (a.startsWith('--schema=')) {
          schema = a.substring('--schema='.length);
        } else if (a.startsWith('--proto=')) {
          proto = a.substring('--proto='.length);
        } else if (a.startsWith('--input=')) {
          input = a.substring('--input='.length);
        } else {
          stderr.writeln('check_decode: unknown arg "$a"');
          exit(2);
        }
    }
  }

  if (format == null || schema == null || input == null) {
    stderr.writeln(
        'usage: check_decode --format ... --schema ... --input ... [--proto ...]');
    exit(2);
  }

  try {
    await _run(format, schema, proto, input);
    exit(0);
  } on _Reject catch (e) {
    stderr.writeln('reject: ${e.message}');
    exit(1);
  } on pw.PxfError catch (e) {
    stderr.writeln('reject: pxf: $e');
    exit(1);
  } on pb.InvalidProtocolBufferException catch (e) {
    stderr.writeln('reject: pb: ${e.message}');
    exit(1);
  } on FormatException catch (e) {
    // Both PXF lexer numeric overflows and PB UTF-8 validation surface as
    // FormatException in the protobuf package — treat as a clean rejection.
    stderr.writeln('reject: format: ${e.message}');
    exit(1);
  } on ArgumentError catch (e) {
    stderr.writeln('reject: argument: ${e.message}');
    exit(1);
  }
}

Future<void> _run(
    String format, String schema, String? protoPath, String input) async {
  switch (format) {
    case 'pxf':
      final text = await File(input).readAsString();
      _pxfDecode(text, schema);
    case 'pb':
      final bytes = await File(input).readAsBytes();
      _pbDecode(bytes, schema);
    case 'envelope':
      throw _Reject('envelope decode not yet implemented in this reference');
    case 'sbe':
      throw _Reject('sbe decode not yet implemented in this reference');
    default:
      throw _Reject('unsupported format: $format');
  }
}

void _pxfDecode(String text, String schema) {
  final msg = _newMessage(schema);
  pw.unmarshal(text, msg);
}

void _pbDecode(Uint8List bytes, String schema) {
  final msg = _newMessage(schema);
  msg.mergeFromBuffer(bytes);
}

pb.GeneratedMessage _newMessage(String schema) {
  switch (schema) {
    case 'adversarial.v1.Tree':
      return adv.Tree();
    case 'adversarial.v1.StringHolder':
      return adv.StringHolder();
    case 'adversarial.v1.BytesHolder':
      return adv.BytesHolder();
    case 'adversarial.v1.BigIntHolder':
      return adv.BigIntHolder();
    default:
      throw _Reject('unknown schema: $schema');
  }
}

class _Reject implements Exception {
  final String message;
  _Reject(this.message);
  @override
  String toString() => message;
}
