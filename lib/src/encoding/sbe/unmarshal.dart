import 'dart:convert';
import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';
import 'sbe.dart';
import 'template.dart';

void unmarshalMessage(Uint8List data, GeneratedMessage msg, MessageTemplate tmpl) {
  if (data.length < headerSize) {
    throw Exception('sbe: data too short for header');
  }

  final buffer = ByteData.view(data.buffer, data.offsetInBytes, data.length);
  final blockLength = buffer.getUint16(0, byteOrder);
  final templateID = buffer.getUint16(2, byteOrder);

  if (templateID != tmpl.templateID) {
    throw Exception('sbe: template ID mismatch: got $templateID, want ${tmpl.templateID}');
  }

  final end = headerSize + blockLength;
  if (data.length < end) {
    throw Exception('sbe: data too short for root block');
  }

  for (final ft in tmpl.fields) {
    _readField(buffer, headerSize + ft.offset, ft, msg);
  }

  int pos = end;
  for (final gt in tmpl.groups) {
    if (data.length < pos + groupHeaderSize) {
      throw Exception('sbe: data too short for group header');
    }
    final gBlockLength = buffer.getUint16(pos, byteOrder);
    final numInGroup = buffer.getUint16(pos + 2, byteOrder);
    pos += groupHeaderSize;

    // HARDENING.md § SBE: reject zero block-length with non-empty count —
    // adversarial input can set count=0xFFFF here, and a zero-block-length
    // group would otherwise allocate that many entries from a zero-byte
    // window. Also reject when the declared payload overruns the buffer:
    // `numInGroup * gBlockLength` is bounded by 0xFFFF*0xFFFF (well inside
    // Dart's 64-bit int range), so the multiply itself is safe.
    if (gBlockLength == 0 && numInGroup > 0) {
      throw Exception(
          'sbe: group has zero block-length with non-zero count $numInGroup');
    }
    final groupBytes = numInGroup * gBlockLength;
    if (pos + groupBytes > data.length) {
      throw Exception(
          'sbe: group payload (${numInGroup}x$gBlockLength=$groupBytes B) '
          'overruns buffer');
    }

    final list = msg.getField(gt.fi.tagNumber) as List;
    list.clear();

    for (int i = 0; i < numInGroup; i++) {
      final entry = gt.fi.subBuilder!();
      for (final ft in gt.fields) {
        _readField(buffer, pos + ft.offset, ft, entry);
      }
      list.add(entry);
      pos += gBlockLength;
    }
  }
}

void _readField(ByteData buffer, int baseOffset, FieldTemplate ft, GeneratedMessage msg) {
  if (ft.composite != null) {
    final subMsg = msg.getField(ft.fi.tagNumber) as GeneratedMessage;
    GeneratedMessage mutableSubMsg = subMsg;
    if (subMsg.isFrozen) {
        mutableSubMsg = ft.fi.subBuilder!();
        msg.setField(ft.fi.tagNumber, mutableSubMsg);
    }
    for (final sf in ft.composite!) {
      _readField(buffer, baseOffset + sf.offset, sf, mutableSubMsg);
    }
    return;
  }

  final off = baseOffset;
  final fi = ft.fi;

  switch (ft.encoding) {
    case encInt8:
      _setIntField(msg, fi, buffer.getInt8(off));
      break;
    case encInt16:
      _setIntField(msg, fi, buffer.getInt16(off, byteOrder));
      break;
    case encInt32:
      _setIntField(msg, fi, buffer.getInt32(off, byteOrder));
      break;
    case encInt64:
      _setIntField(msg, fi, buffer.getInt64(off, byteOrder));
      break;
    case encUint8:
      _setUintField(msg, fi, buffer.getUint8(off));
      break;
    case encUint16:
      _setUintField(msg, fi, buffer.getUint16(off, byteOrder));
      break;
    case encUint32:
      _setUintField(msg, fi, buffer.getUint32(off, byteOrder));
      break;
    case encUint64:
      _setUintField(msg, fi, buffer.getUint64(off, byteOrder));
      break;
    case encFloat:
      msg.setField(fi.tagNumber, buffer.getFloat32(off, byteOrder));
      break;
    case encDouble:
      msg.setField(fi.tagNumber, buffer.getFloat64(off, byteOrder));
      break;
    case encChar:
      final bytes = Uint8List(ft.size);
      for (int i = 0; i < ft.size; i++) {
        bytes[i] = buffer.getUint8(off + i);
      }
      if ((fi.type & _STRING_BIT) != 0) {
        int n = bytes.length;
        while (n > 0 && bytes[n - 1] == 0) n--;
        // HARDENING.md § UTF-8: proto3 string fields must hold valid UTF-8.
        // utf8.decode (default `allowMalformed: false`) throws on bad input.
        msg.setField(fi.tagNumber,
            utf8.decode(Uint8List.sublistView(bytes, 0, n)));
      } else {
        msg.setField(fi.tagNumber, bytes);
      }
      break;
  }
}

void _setIntField(GeneratedMessage msg, FieldInfo fi, int v) {
  if ((fi.type & _INT64_BIT) != 0 || 
      (fi.type & _SINT64_BIT) != 0 || 
      (fi.type & _SFIXED64_BIT) != 0) {
    msg.setField(fi.tagNumber, Int64(v));
  } else {
    msg.setField(fi.tagNumber, v);
  }
}

void _setUintField(GeneratedMessage msg, FieldInfo fi, int v) {
  if ((fi.type & _BOOL_BIT) != 0) {
    msg.setField(fi.tagNumber, v != 0);
  } else if ((fi.type & _ENUM_BIT) != 0) {
    // protobuf-dart's FieldSet validates enum fields as ProtobufEnum, not
    // raw ints. Map through the FieldInfo.valueOf callback that codegen
    // attaches to every enum field.
    final ev = fi.valueOf?.call(v) ?? fi.defaultEnumValue;
    if (ev != null) msg.setField(fi.tagNumber, ev);
  } else if ((fi.type & _UINT64_BIT) != 0 ||
             (fi.type & _FIXED64_BIT) != 0) {
    msg.setField(fi.tagNumber, Int64(v));
  } else {
    msg.setField(fi.tagNumber, v);
  }
}

const int _BOOL_BIT = 0x10;
const int _STRING_BIT = 0x40;
const int _ENUM_BIT = 0x200;
const int _INT64_BIT = 0x1000;
const int _SINT64_BIT = 0x4000;
const int _UINT64_BIT = 0x10000;
const int _FIXED64_BIT = 0x40000;
const int _SFIXED64_BIT = 0x100000;
