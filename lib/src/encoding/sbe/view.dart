// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'dart:typed_data';
import 'package:fixnum/fixnum.dart';
import 'sbe.dart';
import 'template.dart';

class View {
  final Uint8List data;
  final ByteData block;
  final ViewSchema schema;

  View({required this.data, required this.block, required this.schema});

  FieldTemplate _field(String name) {
    final ft = schema.fields[name];
    if (ft == null) {
      throw Exception('sbe: unknown field: $name');
    }
    return ft;
  }

  int getInt8(String name) => block.getInt8(_field(name).offset);
  int getInt16(String name) => block.getInt16(_field(name).offset, byteOrder);
  int getInt32(String name) => block.getInt32(_field(name).offset, byteOrder);
  Int64 getInt64(String name) =>
      Int64(block.getInt64(_field(name).offset, byteOrder));

  int getUint8(String name) => block.getUint8(_field(name).offset);
  int getUint16(String name) => block.getUint16(_field(name).offset, byteOrder);
  int getUint32(String name) => block.getUint32(_field(name).offset, byteOrder);
  Int64 getUint64(String name) =>
      Int64(block.getUint64(_field(name).offset, byteOrder));

  double getFloat32(String name) =>
      block.getFloat32(_field(name).offset, byteOrder);
  double getFloat64(String name) =>
      block.getFloat64(_field(name).offset, byteOrder);

  int getInt(String name) {
    final ft = _field(name);
    final off = ft.offset;
    switch (ft.encoding) {
      case encInt8:
        return block.getInt8(off);
      case encInt16:
        return block.getInt16(off, byteOrder);
      case encInt32:
        return block.getInt32(off, byteOrder);
      case encInt64:
        return block.getInt64(off, byteOrder);
      default:
        throw Exception('sbe: field $name is not a signed integer');
    }
  }

  int getUint(String name) {
    final ft = _field(name);
    final off = ft.offset;
    switch (ft.encoding) {
      case encUint8:
        return block.getUint8(off);
      case encUint16:
        return block.getUint16(off, byteOrder);
      case encUint32:
        return block.getUint32(off, byteOrder);
      case encUint64:
        return block.getUint64(off, byteOrder);
      default:
        throw Exception('sbe: field $name is not an unsigned integer');
    }
  }

  double getFloat(String name) {
    final ft = _field(name);
    final off = ft.offset;
    switch (ft.encoding) {
      case encFloat:
        return block.getFloat32(off, byteOrder);
      case encDouble:
        return block.getFloat64(off, byteOrder);
      default:
        throw Exception('sbe: field $name is not a float');
    }
  }

  bool getBool(String name) {
    final ft = _field(name);
    return block.getUint8(ft.offset) != 0;
  }

  String getString(String name) {
    final ft = _field(name);
    final off = ft.offset;
    final bytes = block.buffer.asUint8List(block.offsetInBytes + off, ft.size);
    int n = bytes.length;
    while (n > 0 && bytes[n - 1] == 0) {
      n--;
    }
    return String.fromCharCodes(bytes.take(n));
  }

  Uint8List getBytes(String name) {
    final ft = _field(name);
    final off = ft.offset;
    return block.buffer.asUint8List(block.offsetInBytes + off, ft.size);
  }

  View getComposite(String name) {
    final ft = _field(name);
    if (ft.compositeView == null) {
      throw Exception('sbe: field $name is not a composite');
    }
    return View(
      data: data,
      block:
          ByteData.view(block.buffer, block.offsetInBytes + ft.offset, ft.size),
      schema: ft.compositeView!,
    );
  }

  GroupView getGroup(String name) {
    int pos = headerSize + block.lengthInBytes;
    for (final gi in schema.groupOrder) {
      final bl = ByteData.view(data.buffer, data.offsetInBytes + pos, 2)
          .getUint16(0, byteOrder);
      final n = ByteData.view(data.buffer, data.offsetInBytes + pos + 2, 2)
          .getUint16(0, byteOrder);
      if (gi.name == name) {
        return GroupView(
          data: data, // Should be full data for absolute pos or sliced?
          startPos: pos,
          blockLength: bl,
          count: n,
          schema: gi.schema,
        );
      }
      pos += groupHeaderSize + n * bl;
    }
    throw Exception('sbe: unknown group: $name');
  }
}

class GroupView {
  final Uint8List data;
  final int startPos;
  final int blockLength;
  final int count;
  final ViewSchema schema;

  GroupView({
    required this.data,
    required this.startPos,
    required this.blockLength,
    required this.count,
    required this.schema,
  });

  int get length => count;

  View entry(int i) {
    final start = startPos + groupHeaderSize + i * blockLength;
    return View(
      data: data,
      block:
          ByteData.view(data.buffer, data.offsetInBytes + start, blockLength),
      schema: schema,
    );
  }
}
