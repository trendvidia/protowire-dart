// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';
import 'template.dart';
import 'marshal.dart';
import 'unmarshal.dart';
import 'view.dart';

const int headerSize = 8;
const int groupHeaderSize = 4;

const String encInt8 = "int8";
const String encInt16 = "int16";
const String encInt32 = "int32";
const String encInt64 = "int64";
const String encUint8 = "uint8";
const String encUint16 = "uint16";
const String encUint32 = "uint32";
const String encUint64 = "uint64";
const String encFloat = "float";
const String encDouble = "double";
const String encChar = "char";

final Endian byteOrder = Endian.little;

/// Codec provides high-level SBE (Simple Binary Encoding) marshaling and unmarshaling.
///
/// It maintains a registry of message templates built from Protobuf descriptors.
class Codec {
  final Map<String, MessageTemplate> _byName = {};
  final Map<int, MessageTemplate> _byID = {};

  Codec();

  /// Registers a message type with the codec.
  ///
  /// [info] is the Protobuf BuilderInfo.
  /// [templateId], [schemaId], and [version] are SBE-specific identifiers.
  /// [lengths] provides fixed lengths for string/bytes fields.
  /// [encodings] allows overriding default primitive encodings.
  void registerMessage(
      BuilderInfo info, int templateId, int schemaId, int version,
      {Map<int, int>? lengths, Map<int, String>? encodings}) {
    final tmpl = buildTemplate(info, templateId, schemaId, version,
        lengths: lengths, encodings: encodings);
    _byName[info.qualifiedMessageName] = tmpl;
    _byID[templateId] = tmpl;
  }

  /// Marshals a [msg] to SBE binary format.
  Uint8List marshal(GeneratedMessage msg) {
    final name = msg.info_.qualifiedMessageName;
    final tmpl = _byName[name];
    if (tmpl == null) {
      throw Exception('sbe: no template registered for $name');
    }
    return marshalMessage(msg, tmpl);
  }

  /// Unmarshals SBE binary [data] into the provided [msg].
  void unmarshal(Uint8List data, GeneratedMessage msg) {
    final name = msg.info_.qualifiedMessageName;
    final tmpl = _byName[name];
    if (tmpl == null) {
      throw Exception('sbe: no template registered for $name');
    }
    unmarshalMessage(data, msg, tmpl);
  }

  /// Creates a zero-allocation [View] over the SBE binary [data].
  View view(Uint8List data) {
    if (data.length < headerSize) {
      throw Exception('sbe: data too short for header');
    }
    final buffer = ByteData.view(data.buffer, data.offsetInBytes, data.length);
    final blockLength = buffer.getUint16(0, byteOrder);
    final templateID = buffer.getUint16(2, byteOrder);
    final tmpl = _byID[templateID];
    if (tmpl == null) {
      throw Exception('sbe: unknown template ID $templateID');
    }
    final end = headerSize + blockLength;
    if (data.length < end) {
      throw Exception('sbe: data too short for root block');
    }
    return View(
      data: data,
      block: ByteData.view(
          data.buffer, data.offsetInBytes + headerSize, blockLength),
      schema: tmpl.view,
    );
  }
}
