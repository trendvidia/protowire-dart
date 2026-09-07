// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
// Cross-port wire-compatibility dumper, driven by protowire's
// scripts/cross_envelope_check.sh. Every port carries the same program and
// the script compares their output byte for byte. Mirrors
// protowire-go/scripts/dump_envelope.
//
//   dump_envelope                        canonical Envelope → pb hex
//   dump_envelope --sbe FDS MESSAGE DOC  PXF DOC decoded against MESSAGE → SBE hex
//   dump_envelope --pb  FDS MESSAGE DOC  PXF DOC decoded against MESSAGE → pb hex
//
// --pb is how the gate proves this port reads (pxf.required) = 1314 and
// (pxf.default) = 1315: `PxfAnnotations.fromBytes(FDS)` indexes them and
// `unmarshalFull` applies them while decoding into the generated type
// (settings.pb.dart, from protowire/testdata/annotations/settings.proto).
// A port looking for the wrong number accepts missing-required.pxf, or
// emits ok.pxf without its defaulted fields (#14, #13).
//
// The envelope is the generated `envelope.v1.Envelope` message: the port's
// `Envelope` class in lib/src/envelope/ is a value type with no pb codec,
// and the generated message is what a Dart program puts on the wire.
//
// --sbe is how the gate proves this port reads (sbe.schema_id) = 1319,
// (sbe.version) = 1320, (sbe.template_id) = 1321, (sbe.length) = 1322 and
// (sbe.encoding) = 1323 from a descriptor it did not compile itself
// (STABILITY.md promise 3, protowire#244): `Codec.registerFromDescriptorSet`
// reads them from FDS, and a port looking for the wrong number builds a
// different layout or refuses the file. This is a codegen port, so MESSAGE
// names a type generated ahead of time (sbe_bench.pb.dart, from
// protowire/testdata/sbe-bench.proto) rather than one built from FDS.
//
// Exit 0 with hex on stdout; 1 with "reject: <reason>" on stderr when the
// document cannot be decoded against the message; 2 for anything that is
// the harness's fault.

import 'dart:io';

import 'package:protobuf/protobuf.dart' as pb;
import 'package:protowire/protowire.dart' as pw;
import 'package:protowire/src/generated/proto/envelope/v1/envelope.pb.dart'
    as envpb;
import 'package:protowire/src/generated/proto/google/protobuf/descriptor.pb.dart'
    as pbd;

import 'sbe_bench.pb.dart' as bench;
import 'settings.pb.dart' as settings;

/// Generated types the fixture modes can name.
final Map<String, pb.GeneratedMessage Function()> generated = {
  'bench.v1.Order': bench.Order.create,
  'settings.v1.Settings': settings.Settings.create,
};

void main(List<String> args) {
  if (args.isEmpty) {
    dumpEnvelope();
    return;
  }
  if (args.length != 4 || !(args[0] == '--pb' || args[0] == '--sbe')) {
    fatal(2, 'usage: dump_envelope [--pb|--sbe FDS MESSAGE DOC]');
  }
  dumpFixture(args[0], args[1], args[2], args[3]);
}

Never fatal(int code, String msg) {
  stderr.writeln('dump_envelope: $msg');
  exit(code);
}

String hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

void dumpEnvelope() {
  final fe = envpb.FieldError()
    ..field_1 = 'amount'
    ..code = 'MIN_VALUE'
    ..message = 'below minimum'
    ..args.add('10.00');
  final ae = envpb.AppError()
    ..code = 'INSUFFICIENT_FUNDS'
    ..message = 'balance too low'
    ..args.addAll(['\$3.50', '\$10.00'])
    ..details.add(fe)
    ..metadata['request_id'] = 'req-123';
  final env = envpb.Envelope()
    ..status = 402
    ..data = [0xDE, 0xAD, 0xBE, 0xEF]
    ..error = ae;
  print(hex(env.writeToBuffer()));
}

void dumpPB(String fdsPath, String message, String docPath) {
  final make = generated[message];
  if (make == null) {
    fatal(2, '$message: no generated type in this dumper (see `generated`)');
  }

  late final pw.PxfAnnotations annotations;
  late final String doc;
  try {
    annotations = pw.PxfAnnotations.fromBytes(File(fdsPath).readAsBytesSync());
    doc = File(docPath).readAsStringSync();
  } catch (e) {
    fatal(2, '$e');
  }
  if (!annotations.hasMessage(message)) {
    fatal(2, '$fdsPath: $message not found');
  }

  final msg = make();
  try {
    pw.unmarshalFull(doc, msg,
        options: pw.UnmarshalOptions(annotations: annotations));
  } on pw.PxfError catch (e) {
    stderr.writeln('reject: $e');
    exit(1);
  } on FormatException catch (e) {
    stderr.writeln('reject: ${e.message}');
    exit(1);
  }
  print(hex(msg.writeToBuffer()));
}

void dumpFixture(String mode, String fdsPath, String message, String docPath) {
  if (mode == '--pb') {
    dumpPB(fdsPath, message, docPath);
    return;
  }
  final make = generated[message];
  if (make == null) {
    fatal(2, '$message: no generated type in this dumper (see `generated`)');
  }

  late final pbd.FileDescriptorSet fds;
  late final String doc;
  try {
    fds = pbd.FileDescriptorSet.fromBuffer(
        File(fdsPath).readAsBytesSync(), pw.sbeExtensionRegistry());
    doc = File(docPath).readAsStringSync();
  } catch (e) {
    fatal(2, '$e');
  }

  final codec = pw.Codec();
  try {
    codec.registerFromDescriptorSet(fds, make());
  } catch (e) {
    fatal(2, '$e');
  }

  final msg = make();
  try {
    pw.unmarshal(doc, msg);
  } on pw.PxfError catch (e) {
    stderr.writeln('reject: $e');
    exit(1);
  } on FormatException catch (e) {
    stderr.writeln('reject: ${e.message}');
    exit(1);
  }

  try {
    print(hex(codec.marshal(msg)));
  } catch (e) {
    fatal(2, '$e');
  }
}
