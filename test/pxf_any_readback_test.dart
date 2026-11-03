// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// marshal writes an Any as `@type` and a body only when reading that body
// gives back the Any's value, byte for byte (draft -01 § Any Blocks,
// protowire#501, protowire-dart#74). Every case protowire-go measured as
// changing the message is here: each is written, read back, and its value
// compared.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as wkt;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as ts;
import 'package:protowire/protowire.dart';
import 'package:protowire/src/generated/proto/google/protobuf/descriptor.pb.dart'
    as pbd;
import 'package:protowire/src/generated/proto/pxf/annotations.pb.dart'
    as pxf_ann;
import 'package:test/test.dart';

import 'generated/any.pb.dart' as anypb;
import 'generated/test.pb.dart' as testpb;

final registry =
    TypeRegistry([anypb.Leaf(), anypb.Holder(), testpb.AllTypes()]);

anypb.Holder holding(String url, List<int> value) => anypb.Holder()
  ..payload = (wkt.Any()
    ..typeUrl = url
    ..value = value);

/// any.v1's Holder and Leaf, with Leaf.tag required, or defaulted to
/// [defaultTag].
PxfAnnotations leafSchema({String? defaultTag}) {
  pbd.FieldDescriptorProto f(
      String name, int n, pbd.FieldDescriptorProto_Type t,
      {String? typeName, pbd.FieldOptions? options}) {
    final d = pbd.FieldDescriptorProto()
      ..name = name
      ..number = n
      ..type = t
      ..label = pbd.FieldDescriptorProto_Label.LABEL_OPTIONAL;
    if (typeName != null) d.typeName = '.$typeName';
    if (options != null) d.options = options;
    return d;
  }

  final tag = pbd.FieldOptions();
  if (defaultTag == null) {
    tag.setExtension(pxf_ann.Annotations.required, true);
  } else {
    tag.setExtension(pxf_ann.Annotations.default_1315, defaultTag);
  }
  final file = pbd.FileDescriptorProto()
    ..name = 'any.proto'
    ..package = 'any.v1'
    ..syntax = 'proto3';
  file.messageType.addAll([
    pbd.DescriptorProto()
      ..name = 'Holder'
      ..field.addAll([
        f('payload', 1, pbd.FieldDescriptorProto_Type.TYPE_MESSAGE,
            typeName: 'google.protobuf.Any'),
        f('leaf', 4, pbd.FieldDescriptorProto_Type.TYPE_MESSAGE,
            typeName: 'any.v1.Leaf'),
      ]),
    pbd.DescriptorProto()
      ..name = 'Leaf'
      ..field.addAll([
        f('tag', 1, pbd.FieldDescriptorProto_Type.TYPE_STRING, options: tag),
        f('n', 2, pbd.FieldDescriptorProto_Type.TYPE_INT32),
      ]),
  ]);
  return PxfAnnotations.fromDescriptorSet(
      pbd.FileDescriptorSet()..file.add(file));
}

/// Writes [m] and reads it back with the same registry and annotations.
/// Returns the document.
String expectValueKept(anypb.Holder m, {PxfAnnotations? annotations}) {
  final out = marshal(m,
      options:
          MarshalOptions(typeRegistry: registry, annotations: annotations));
  final back = anypb.Holder();
  unmarshalFull(out, back,
      options:
          UnmarshalOptions(typeRegistry: registry, annotations: annotations));
  expect(back.payload.typeUrl, m.payload.typeUrl, reason: out);
  expect(back.payload.value, m.payload.value, reason: out);
  return out;
}

List<int> allTypesWithTimestamp(Int64 seconds, int nanos) => (testpb.AllTypes()
      ..tsField = (ts.Timestamp()
        ..seconds = seconds
        ..nanos = nanos))
    .writeToBuffer();

void main() {
  group('a value a body would change is written raw and kept', () {
    final cases = <String, (String, List<int>)>{
      'an unknown field': ('any.v1.Leaf', [0x0a, 0x01, 0x74, 0x48, 0x01]),
      'an unknown field in a nested message': (
        'any.v1.Holder',
        [0x22, 0x02, 0x48, 0x01]
      ),
      'fields out of order': ('any.v1.Leaf', [0x10, 0x07, 0x0a, 0x01, 0x74]),
      'an explicitly written zero': ('any.v1.Leaf', [0x10, 0x00]),
      'a Timestamp whose nanos no literal holds': (
        'test.v1.AllTypes',
        allTypesWithTimestamp(Int64(1), 2000000000)
      ),
      'a Timestamp past year 9999': (
        'test.v1.AllTypes',
        allTypesWithTimestamp(Int64(300000000000), 0)
      ),
    };
    cases.forEach((name, c) {
      test(name, () {
        final out = expectValueKept(holding(c.$1, c.$2));
        expect(out, contains('type_url = '));
        expect(out, isNot(contains('@type')));
      });
    });

    test('an unset @default field, which a reader would fill', () {
      final out = expectValueKept(holding('any.v1.Leaf', [0x10, 0x01]),
          annotations: leafSchema(defaultTag: 'dflt'));
      expect(out, contains('type_url = '));
    });

    test('an unset @required field, which a reader would refuse', () {
      final out = expectValueKept(holding('any.v1.Leaf', [0x10, 0x01]),
          annotations: leafSchema());
      expect(out, contains('type_url = '));
    });

    test('a chain of Anys past MaxNestingDepth', () {
      List<int> bytes = (anypb.Leaf()..tag = 'bottom').writeToBuffer();
      var url = 'any.v1.Leaf';
      for (var i = 0; i < 150; i++) {
        bytes = holding(url, bytes).writeToBuffer();
        url = 'any.v1.Holder';
      }
      final out = expectValueKept(holding(url, bytes));
      expect('type_url = '.allMatches(out), hasLength(1));
    });
  });

  group('a value a body keeps is written as a body', () {
    test('a plain value', () {
      final out = expectValueKept(
          holding('any.v1.Leaf', (anypb.Leaf()..tag = 't').writeToBuffer()));
      expect(out, 'payload {\n  @type = "any.v1.Leaf"\n  tag = "t"\n}\n');
    });

    test('a Timestamp a literal holds', () {
      final out = expectValueKept(holding(
          'test.v1.AllTypes', allTypesWithTimestamp(Int64(1), 500000000)));
      expect(out, contains('@type = "test.v1.AllTypes"'));
    });

    test('a set @required field', () {
      final out = expectValueKept(
          holding('any.v1.Leaf', (anypb.Leaf()..tag = 't').writeToBuffer()),
          annotations: leafSchema());
      expect(out, contains('@type = "any.v1.Leaf"'));
    });
  });
}
