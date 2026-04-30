import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';
import 'sbe.dart';
import 'template.dart';

Uint8List marshalMessage(GeneratedMessage msg, MessageTemplate tmpl) {
  int totalSize = headerSize + tmpl.blockLength;
  for (final gt in tmpl.groups) {
    final list = msg.getField(gt.fi.tagNumber) as List;
    totalSize += groupHeaderSize + list.length * gt.blockLength;
  }

  final data = Uint8List(totalSize);
  final buffer = ByteData.view(data.buffer);

  // Write header
  buffer.setUint16(0, tmpl.blockLength, byteOrder);
  buffer.setUint16(2, tmpl.templateID, byteOrder);
  buffer.setUint16(4, tmpl.schemaID, byteOrder);
  buffer.setUint16(6, tmpl.version, byteOrder);

  // Write root block
  for (final ft in tmpl.fields) {
    _writeField(buffer, headerSize + ft.offset, ft, msg);
  }

  // Write groups
  int pos = headerSize + tmpl.blockLength;
  for (final gt in tmpl.groups) {
    final list = msg.getField(gt.fi.tagNumber) as List;
    buffer.setUint16(pos, gt.blockLength, byteOrder);
    buffer.setUint16(pos + 2, list.length, byteOrder);
    pos += groupHeaderSize;

    for (final entry in list) {
      for (final ft in gt.fields) {
        _writeField(buffer, pos + ft.offset, ft, entry as GeneratedMessage);
      }
      pos += gt.blockLength;
    }
  }

  return data;
}

void _writeField(ByteData buffer, int baseOffset, FieldTemplate ft, GeneratedMessage msg) {
  if (ft.composite != null) {
    final subMsg = msg.getField(ft.fi.tagNumber) as GeneratedMessage;
    for (final sf in ft.composite!) {
      _writeField(buffer, baseOffset + sf.offset, sf, subMsg);
    }
    return;
  }

  final val = msg.getField(ft.fi.tagNumber);
  final off = baseOffset;

  switch (ft.encoding) {
    case encInt8:
      buffer.setInt8(off, val as int);
      break;
    case encInt16:
      buffer.setInt16(off, val as int, byteOrder);
      break;
    case encInt32:
      buffer.setInt32(off, val as int, byteOrder);
      break;
    case encInt64:
      buffer.setInt64(off, (val as Int64).toInt(), byteOrder); 
      break;
    case encUint8:
      buffer.setUint8(off, _uintVal(ft.fi, val));
      break;
    case encUint16:
      buffer.setUint16(off, _uintVal(ft.fi, val), byteOrder);
      break;
    case encUint32:
      buffer.setUint32(off, _uintVal(ft.fi, val), byteOrder);
      break;
    case encUint64:
      final v = _uintVal64(ft.fi, val);
      buffer.setUint64(off, v.toInt(), byteOrder);
      break;
    case encFloat:
      buffer.setFloat32(off, val as double, byteOrder);
      break;
    case encDouble:
      buffer.setFloat64(off, val as double, byteOrder);
      break;
    case encChar:
      final bytes = (val is String) ? Uint8List.fromList(val.codeUnits) : (val as Uint8List);
      final len = ft.size;
      for (int i = 0; i < len; i++) {
        if (i < bytes.length) {
          buffer.setUint8(off + i, bytes[i]);
        } else {
          buffer.setUint8(off + i, 0);
        }
      }
      break;
  }
}

int _uintVal(FieldInfo fi, Object val) {
  if (val is bool) return val ? 1 : 0;
  if (val is ProtobufEnum) return val.value;
  if (val is int) return val;
  if (val is Int64) return val.toInt();
  return 0;
}

Int64 _uintVal64(FieldInfo fi, Object val) {
  if (val is bool) return val ? Int64.ONE : Int64.ZERO;
  if (val is ProtobufEnum) return Int64(val.value);
  if (val is int) return Int64(val);
  if (val is Int64) return val;
  return Int64.ZERO;
}
