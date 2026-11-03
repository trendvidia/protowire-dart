// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
// Per-port reference for the protowire HARDENING.md conformance corpus.
//
// Driven by `protowire/scripts/cross_security_check.sh`. See:
// - `protowire/docs/HARDENING.md`
// - `protowire/testdata/adversarial/README.md`
//
// Contract:
//
//   check_decode --format <pxf|pxf-pb|pb|pb-render|pb-text|sbe|envelope> \
//                --schema <fully.qualified.MessageType> \
//                --proto  <path-to-adversarial.proto> \
//                --input  <path> \
//                [--limit NAME=VALUE]...
//
// --limit lowers a HARDENING.md limit for the call, so the corpus can prove a
// 64 MiB cap with a small fixture: MaxMessageSize, MaxBytesLiteralLength,
// MaxRepeatedCount.
//
// pb-text reads a text.v1 message's PB bytes with the stock runtime and
// writes its PXF on stdout, for the text gate
// (protowire/scripts/cross_text_check.sh), so the comparison is of the
// marshaller alone.
//
// pxf-pb reads a PXF document of a text.v1 message and writes its PB bytes
// on stdout, map entries in key order, for the write gate
// (protowire/scripts/cross_write_check.sh). The schema's annotations come
// from the `.binpb` beside --proto, as for sbe.
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

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:protobuf/protobuf.dart' as pb;
import 'package:protowire/protowire.dart' as pw;

import 'package:protowire/src/generated/proto/google/protobuf/descriptor.pb.dart'
    as pbd;

import 'adversarial.pb.dart' as adv;
import 'text.pb.dart' as text;

void main(List<String> args) async {
  String? format;
  String? schema;
  String? proto;
  String? input;
  final overrides = <String, int>{};

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
      case '--limit':
        _addLimit(overrides, next());
      default:
        if (a.startsWith('--format=')) {
          format = a.substring('--format='.length);
        } else if (a.startsWith('--schema=')) {
          schema = a.substring('--schema='.length);
        } else if (a.startsWith('--proto=')) {
          proto = a.substring('--proto='.length);
        } else if (a.startsWith('--input=')) {
          input = a.substring('--input='.length);
        } else if (a.startsWith('--limit=')) {
          _addLimit(overrides, a.substring('--limit='.length));
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
    final limits = pw.DecodeLimits(
      maxMessageSize: overrides['MaxMessageSize'] ?? pw.defaultMaxMessageSize,
      maxBytesLiteralLength:
          overrides['MaxBytesLiteralLength'] ?? pw.defaultMaxMessageSize,
      maxRepeatedCount:
          overrides['MaxRepeatedCount'] ?? pw.defaultMaxMessageSize,
    );
    await _run(format, schema, proto, input, limits);
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

Future<void> _run(String format, String schema, String? protoPath, String input,
    pw.DecodeLimits limits) async {
  switch (format) {
    case 'pxf':
      final text = await File(input).readAsString();
      _pxfDecode(text, schema, limits);
    case 'pxf-pb':
      final doc = await File(input).readAsString();
      stdout.add(_pxfPb(doc, schema, protoPath, limits));
      await stdout.flush();
    case 'pb':
      final bytes = await File(input).readAsBytes();
      _pbDecode(bytes, schema, limits);
    case 'pb-render':
      final bytes = await File(input).readAsBytes();
      _pbRender(bytes, schema);
    case 'pb-text':
      final bytes = await File(input).readAsBytes();
      stdout.write(_pbText(bytes, schema, protoPath));
      await stdout.flush();
    case 'envelope':
      throw _Reject('envelope decode not yet implemented in this reference');
    case 'sbe':
      final bytes = await File(input).readAsBytes();
      _sbeDecode(bytes, schema, protoPath, limits);
    default:
      throw _Reject('unsupported format: $format');
  }
}

void _pxfDecode(String text, String schema, pw.DecodeLimits limits) {
  final msg = _newMessage(schema);
  pw.unmarshal(text, msg, options: pw.UnmarshalOptions(limits: limits));
}

/// The PB bytes of a PXF document, as protowire-go's check-decode writes
/// them: decoded with the schema's annotations (`@default`, `@required`), and
/// written with map entries in key order.
List<int> _pxfPb(
    String doc, String schema, String? protoPath, pw.DecodeLimits limits) {
  if (protoPath == null) throw _Reject('pxf-pb needs --proto');
  final msg = _newMessage(schema);
  final annotations = pw.PxfAnnotations.fromBytes(
      File(protoPath.replaceFirst(RegExp(r'\.proto$'), '.binpb'))
          .readAsBytesSync());
  pw.unmarshalFull(doc, msg,
      options: pw.UnmarshalOptions(annotations: annotations, limits: limits));
  _sortMaps(msg);
  return msg.writeToBuffer();
}

/// The PXF protowire-go's check-decode writes for a message's PB bytes: read
/// with the stock runtime, written with the schema's annotations, which
/// carry the keyed-list form.
String _pbText(Uint8List bytes, String schema, String? protoPath) {
  if (protoPath == null) throw _Reject('pb-text needs --proto');
  final annotations = pw.PxfAnnotations.fromBytes(
      File(protoPath.replaceFirst(RegExp(r'\.proto$'), '.binpb'))
          .readAsBytesSync());
  return pw.marshal(_newMessage(schema)..mergeFromBuffer(bytes),
      options: pw.MarshalOptions(annotations: annotations));
}

/// Puts every map of [msg], and of the messages under it, in key order.
/// package:protobuf writes a map in insertion order.
void _sortMaps(pb.GeneratedMessage msg) {
  for (final fi in msg.info_.fieldInfo.values) {
    if (!msg.hasField(fi.tagNumber)) continue;
    final val = msg.getField(fi.tagNumber);
    if (val is Map) {
      final keys = val.keys.toList()..sort(_compareKeys);
      final entries = [for (final k in keys) MapEntry(k, val[k])];
      val.clear();
      for (final e in entries) {
        val[e.key] = e.value;
      }
      for (final v in val.values) {
        if (v is pb.GeneratedMessage) _sortMaps(v);
      }
    } else if (val is List) {
      for (final v in val) {
        if (v is pb.GeneratedMessage) _sortMaps(v);
      }
    } else if (val is pb.GeneratedMessage) {
      _sortMaps(val);
    }
  }
}

/// Go's deterministic order: false before true, numbers by value, strings by
/// their UTF-8 bytes.
int _compareKeys(Object? a, Object? b) {
  if (a is bool && b is bool) return a == b ? 0 : (a ? 1 : -1);
  if (a is String && b is String) {
    final x = utf8.encode(a), y = utf8.encode(b);
    for (var i = 0; i < x.length && i < y.length; i++) {
      if (x[i] != y[i]) return x[i] - y[i];
    }
    return x.length - y.length;
  }
  return (a as Comparable).compareTo(b);
}

/// A `.binpb` beside the `--proto` file holds its compiled descriptor set, as
/// this port has no .proto compiler.
void _sbeDecode(
    Uint8List bytes, String schema, String? protoPath, pw.DecodeLimits limits) {
  if (protoPath == null) throw _Reject('sbe needs --proto');
  final fds = pbd.FileDescriptorSet.fromBuffer(
      File(protoPath.replaceFirst(RegExp(r'\.proto$'), '.binpb'))
          .readAsBytesSync(),
      pw.sbeExtensionRegistry());
  final msg = _newMessage(schema);
  final codec = pw.Codec()..registerFromDescriptorSet(fds, msg);
  try {
    codec.unmarshal(bytes, msg, limits: limits);
  } on Exception catch (e) {
    throw _Reject('$e');
  }
}

/// The producer's side of the bounds (HARDENING.md § Arbitrary-precision
/// magnitudes, § Recursion): plain `mergeFromBuffer` stores the fields and
/// bounds nothing, and they are then written as PXF (protowire#448). The
/// reader takes nesting well past MaxNestingDepth, so a message the producer
/// must refuse reaches it rather than stopping at the stock limit of 100
/// (protowire#502).
void _pbRender(Uint8List bytes, String schema) {
  final msg = _newMessage(schema)
    ..mergeFromCodedBufferReader(pb.CodedBufferReader(bytes,
        recursionLimit: _renderReadDepth, sizeLimit: bytes.length));
  pw.marshal(msg);
}

/// Deeper than any pb-render row, and far below the native stack.
const _renderReadDepth = 1000;

void _pbDecode(Uint8List bytes, String schema, pw.DecodeLimits limits) {
  final msg = _newMessage(schema);
  pw.mergeFromBufferChecked(msg, bytes, pb.ExtensionRegistry.EMPTY, limits);
}

void _addLimit(Map<String, int> overrides, String? arg) {
  final parts = (arg ?? '').split('=');
  final value = parts.length == 2 ? int.tryParse(parts[1]) : null;
  const known = {'MaxMessageSize', 'MaxBytesLiteralLength', 'MaxRepeatedCount'};
  if (value == null || !known.contains(parts[0])) {
    stderr.writeln('check_decode: bad --limit "$arg"');
    exit(2);
  }
  overrides[parts[0]] = value;
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
    case 'adversarial.v1.BigNumHolder':
      return adv.BigNumHolder();
    case 'adversarial.v1.ListHolder':
      return adv.ListHolder();
    case 'adversarial.v1.SbeWithGroup':
      return adv.SbeWithGroup();
    case 'adversarial.v1.SbeText':
      return adv.SbeText();
    case 'text.v1.Scalars':
      return text.Scalars();
    case 'text.v1.Shapes':
      return text.Shapes();
    case 'text.v1.WellKnown':
      return text.WellKnown();
    case 'text.v1.Keyed':
      return text.Keyed();
    case 'text.v1.Item':
      return text.Item();
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
