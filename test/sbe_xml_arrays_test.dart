// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// The SBE XML converter's fixed-length arrays and character encodings
// (draft -01 § Fixed-Length Arrays and § Character Encoding,
// protowire-dart#79 and #86). The schemas are protowire-go's
// (encoding/sbe/convert_test.go), and each test mirrors one of Go's.
//
// test/testdata/sbe_xml/fixed_arrays.proto is what xmlToProto writes for
// fixed_arrays.xml, pinned by the first test, and fixed_arrays.binpb and
// test/generated/sbe_fixed_arrays.pb.dart are protoc's compilation of it:
//
//   protoc -I test/testdata/sbe_xml -I proto --include_imports \
//     --descriptor_set_out=test/testdata/sbe_xml/fixed_arrays.binpb \
//     --dart_out=<tmp> fixed_arrays.proto
import 'dart:io';
import 'dart:typed_data';

import 'package:protowire/protowire.dart';
import 'package:protowire/src/encoding/sbe/xmlschema.dart'
    show camelToSnake, camelToScreamingSnake;
import 'package:protowire/src/generated/proto/google/protobuf/descriptor.pb.dart'
    as pbd;
import 'package:protowire/src/generated/proto/sbe/annotations.pb.dart'
    as sbe_ann;
import 'package:test/test.dart';

import 'generated/sbe_fixed_arrays.pb.dart' as arr;

String _read(String name) =>
    File('test/testdata/sbe_xml/$name').readAsStringSync();

pbd.FileDescriptorSet _fixedArraysSet() => pbd.FileDescriptorSet.fromBuffer(
    File('test/testdata/sbe_xml/fixed_arrays.binpb').readAsBytesSync(),
    sbeExtensionRegistry());

/// The proto with its comment lines dropped: a note says why a field is
/// bytes, and the exported XML no longer carries the encoding it names.
String _code(String proto) =>
    proto.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');

void main() {
  test('the fixture is what xmlToProto writes, so protoc compiled it', () {
    expect(xmlToProto(_read('fixed_arrays.xml')), _read('fixed_arrays.proto'));
    expect(
        xmlToProto(_read('char_encoding.xml')), _read('char_encoding.proto'));
  });

  test('a uint8 or int8 array imports as bytes of its length', () {
    final proto = xmlToProto(_read('fixed_arrays.xml'));
    for (final line in [
      'bytes uuid = 2 [(sbe.length) = 16];',
      'bytes signed = 3 [(sbe.length) = 3];',
      'bytes raw = 1 [(sbe.length) = 6];',
      'uint32 tail = 5;',
    ]) {
      expect(proto, contains(line));
    }

    // The block keeps its layout: tail sits after all 16 bytes of uuid.
    final codec = Codec()
      ..registerFromDescriptorSet(_fixedArraysSet(), arr.Record());
    final uuid = Uint8List.fromList(
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 0xFF]);
    final data = codec.marshal(arr.Record()
      ..uuid = uuid
      ..tail = 0xA1B2C3D4);
    // Header(8) + name(4) + uuid(16) + signed(3) + key(6+4) + tail(4), as
    // protowire-go writes it. key.raw is 6 bytes, Key's own length, not
    // the 4 of Record's field 1 (protowire-dart#87).
    expect(data.length, 8 + 4 + 16 + 3 + 10 + 4);
    expect(data.sublist(12, 28), uuid);
    expect(data.sublist(data.length - 4), [0xD4, 0xC3, 0xB2, 0xA1]);

    final got = arr.Record();
    codec.unmarshal(data, got);
    expect(got.uuid, uuid);
    expect(got.tail, 0xA1B2C3D4);
  });

  test("a composite's fixed-length field keeps its own length", () {
    final codec = Codec()
      ..registerFromDescriptorSet(_fixedArraysSet(), arr.Record());
    final record = arr.Record()
      ..name = [0x63, 0x61, 0x66, 0xE9]
      ..key = (arr.Key()
        ..raw = 'abcdef'.codeUnits
        ..seq = 7)
      ..tail = 9;
    final data = codec.marshal(record);
    // key.raw starts after header, name, uuid and signed: 8+4+16+3 = 31.
    expect(String.fromCharCodes(data.sublist(31, 37)), 'abcdef');
    expect(data.sublist(37, 41), [7, 0, 0, 0]);
    expect(data.sublist(41), [9, 0, 0, 0]);
    final got = arr.Record();
    codec.unmarshal(data, got);
    expect(got.key.raw, 'abcdef'.codeUnits);
    expect(got.key.seq, 7);
    expect(got.name, [0x63, 0x61, 0x66, 0xE9]);
  });

  test('an array of a wider primitive is refused, named', () {
    for (final (types, field) in [
      (
        '<type name="Quad" primitiveType="int32" length="4"/>',
        '<field name="q" id="1" type="Quad"/>'
      ),
      (
        '<composite name="Box"><type name="sides" primitiveType="uint16" '
            'length="2"/></composite>',
        '<field name="b" id="1" type="Box"/>'
      ),
    ]) {
      final schema = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<sbe:messageSchema xmlns:sbe="http://fixprotocol.io/2016/sbe" '
          'package="w" id="1" version="0" byteOrder="littleEndian">\n'
          '    <types>$types</types>\n'
          '    <sbe:message name="M" id="1">$field</sbe:message>\n'
          '</sbe:messageSchema>';
      expect(
          () => xmlToProto(schema),
          throwsA(isA<FormatException>().having((e) => e.message, 'message',
              contains('which no proto field represents'))));
    }
    final wide = _read('fixed_arrays.xml').replaceFirst(
        'primitiveType="uint8" length="16"',
        'primitiveType="uint64" length="2"');
    expect(
        () => xmlToProto(wide),
        throwsA(isA<FormatException>().having(
            (e) => e.message,
            'message',
            'sbe: message "Record": field "uuid": type "Uuid" is an array of '
                '2 uint64, which no proto field represents')));
  });

  test('a char in a non-UTF-8 encoding imports as bytes', () {
    final proto = xmlToProto(_read('char_encoding.xml'));
    for (final line in [
      'string plain = 1 [(sbe.length) = 4];',
      'string ascii = 2 [(sbe.length) = 4];',
      'string us_ascii = 3 [(sbe.length) = 4];',
      'string utf8 = 4 [(sbe.length) = 4];',
      '  // SBE characterEncoding "ISO-8859-1" is not UTF-8 compatible, so '
          'this field is bytes.\n  bytes latin1 = 5 [(sbe.length) = 4];',
      '  // SBE characterEncoding "windows-1252" is not UTF-8 compatible, so '
          'this field is bytes.\n  bytes code = 1 [(sbe.length) = 2];',
      'string tag = 2 [(sbe.length) = 2];',
    ]) {
      expect(proto, contains(line));
    }
  });

  test('XML → proto → XML → proto keeps every field and the bytes', () {
    final proto1 = xmlToProto(_read('fixed_arrays.xml'));
    final xml2 =
        protoToXmlFromDescriptorSet(_fixedArraysSet(), 'fixed_arrays.proto');
    expect(xml2,
        contains('<type name="bytes16" primitiveType="uint8" length="16"/>'));
    expect(xml2, contains('<field name="name" id="1" type="bytes4"/>'));
    expect(
        xml2, contains('<type name="raw" primitiveType="uint8" length="6"/>'));

    // Same fields, types and options, so protoc compiles it to the same
    // descriptor and the codec writes the same bytes.
    final proto2 = xmlToProto(xml2);
    expect(_code(proto2), _code(proto1));
    expect(proto2, isNot(contains('string')));
  });

  test('the export reads options a set parsed without the registry holds', () {
    final bare = pbd.FileDescriptorSet.fromBuffer(
        File('test/testdata/sbe_xml/fixed_arrays.binpb').readAsBytesSync());
    expect(protoToXmlFromDescriptorSet(bare, 'fixed_arrays.proto'),
        protoToXmlFromDescriptorSet(_fixedArraysSet(), 'fixed_arrays.proto'));
  });

  test('a bytes field of length 1 comes back as one uint8', () {
    final file = pbd.FileDescriptorProto(
      name: 'one.proto',
      package: 'one.v1',
      syntax: 'proto3',
      options: pbd.FileOptions()..setExtension(sbe_ann.Annotations.schemaId, 1),
      messageType: [
        pbd.DescriptorProto(
          name: 'M',
          options: pbd.MessageOptions()
            ..setExtension(sbe_ann.Annotations.templateId, 1),
          field: [
            pbd.FieldDescriptorProto(
              name: 'b',
              number: 1,
              type: pbd.FieldDescriptorProto_Type.TYPE_BYTES,
              label: pbd.FieldDescriptorProto_Label.LABEL_OPTIONAL,
              options: pbd.FieldOptions()
                ..setExtension(sbe_ann.Annotations.length, 1),
            ),
          ],
        ),
      ],
    );
    final xml = protoToXmlFromDescriptorSet(
        pbd.FileDescriptorSet(file: [file]), 'one.proto');
    expect(xml,
        contains('<type name="bytes1" primitiveType="uint8" length="1"/>'));
    expect(
        xmlToProto(xml), contains('uint32 b = 1 [(sbe.encoding) = "uint8"];'));
  });

  test('an sbe:message element is imported', () {
    final proto = xmlToProto(_read('fixed_arrays.xml'));
    expect(proto, contains('message Record {'));
    expect(proto, contains('option (sbe.template_id) = 1;'));
  });

  test('names convert as protowire-go converts them', () {
    expect(camelToSnake('orderId'), 'order_id');
    expect(camelToSnake('utf8'), 'utf8');
    expect(camelToSnake('latin1Name'), 'latin1_name');
    expect(camelToSnake('HTTPCode'), 'http_code');
    expect(camelToScreamingSnake('OrdType'), 'ORD_TYPE');
    expect(camelToScreamingSnake('HTTPCode'), 'HTTPCODE');
  });
}
