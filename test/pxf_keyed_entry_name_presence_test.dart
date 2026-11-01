// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// An entry name of a keyed block populates the element's key field (draft -01
// §3.13), so it counts as the document supplying that field
// (protowire-go#214). The Result has to say so: anything reading presence,
// the required/default pass included, would otherwise take the key as absent.
//
// This port's required/default pass does not yet walk list elements, so a
// default on the key cannot replace the name today, and these tests pin the
// values as well as the presence. Mirrors protowire-go's
// keyed_entry_name_presence_test.go. The messages are written by hand, as in
// pxf_annotations_test.dart: the schema is:
//
//   message P {
//     repeated WithDefault kd = 1 [(pxf.key) = "name"];
//     repeated WithRequired kr = 2 [(pxf.key) = "name"];
//     repeated InOneof ko = 3 [(pxf.key) = "name"];
//     repeated Nests kn = 4 [(pxf.key) = "name"];
//     google.protobuf.Any payload = 5;
//   }
//   message WithDefault { string name = 1 [(pxf.default) = "dflt"]; }
//   message WithRequired { string name = 1 [(pxf.required) = true]; }
//   message InOneof {
//     oneof pick {
//       string name = 1;
//       string other = 2 [(pxf.default) = "other-dflt"];
//     }
//   }
//   message Nests {
//     string name = 1;
//     repeated WithDefault inner = 2 [(pxf.key) = "name"];
//   }
import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:protowire/src/generated/proto/google/protobuf/any.pb.dart'
    as any_pb;
import 'package:protowire/src/generated/proto/google/protobuf/descriptor.pb.dart'
    as pbd;
import 'package:protowire/src/generated/proto/pxf/annotations.pb.dart'
    as pxf_ann;
import 'package:test/test.dart';

const pkg = 'keyedname.v1';

pbd.FieldDescriptorProto field(
    String name, int number, pbd.FieldDescriptorProto_Type type,
    {String? typeName,
    bool repeated = false,
    bool required = false,
    String? defaultLiteral,
    String? key,
    int? oneofIndex}) {
  final o = pbd.FieldOptions();
  if (required) o.setExtension(pxf_ann.Annotations.required, true);
  if (defaultLiteral != null) {
    o.setExtension(pxf_ann.Annotations.default_1315, defaultLiteral);
  }
  if (key != null) o.setExtension(pxf_ann.Annotations.key, key);
  final f = pbd.FieldDescriptorProto()
    ..name = name
    ..number = number
    ..type = type
    ..label = repeated
        ? pbd.FieldDescriptorProto_Label.LABEL_REPEATED
        : pbd.FieldDescriptorProto_Label.LABEL_OPTIONAL
    ..options = o;
  if (typeName != null) f.typeName = '.$typeName';
  if (oneofIndex != null) f.oneofIndex = oneofIndex;
  return f;
}

pbd.FieldDescriptorProto keyed(String name, int number, String element) =>
    field(name, number, pbd.FieldDescriptorProto_Type.TYPE_MESSAGE,
        typeName: '$pkg.$element', repeated: true, key: 'name');

final PxfAnnotations annotations =
    PxfAnnotations.fromDescriptorSet(pbd.FileDescriptorSet()
      ..file.add(pbd.FileDescriptorProto()
        ..name = 'keyedname.proto'
        ..package = pkg
        ..messageType.addAll([
          pbd.DescriptorProto()
            ..name = 'P'
            ..field.addAll([
              keyed('kd', 1, 'WithDefault'),
              keyed('kr', 2, 'WithRequired'),
              keyed('ko', 3, 'InOneof'),
              keyed('kn', 4, 'Nests'),
              field('payload', 5, pbd.FieldDescriptorProto_Type.TYPE_MESSAGE,
                  typeName: 'google.protobuf.Any'),
            ]),
          pbd.DescriptorProto()
            ..name = 'WithDefault'
            ..field.add(field(
                'name', 1, pbd.FieldDescriptorProto_Type.TYPE_STRING,
                defaultLiteral: 'dflt')),
          pbd.DescriptorProto()
            ..name = 'WithRequired'
            ..field.add(field(
                'name', 1, pbd.FieldDescriptorProto_Type.TYPE_STRING,
                required: true)),
          pbd.DescriptorProto()
            ..name = 'InOneof'
            ..oneofDecl.add(pbd.OneofDescriptorProto()..name = 'pick')
            ..field.addAll([
              field('name', 1, pbd.FieldDescriptorProto_Type.TYPE_STRING,
                  oneofIndex: 0),
              field('other', 2, pbd.FieldDescriptorProto_Type.TYPE_STRING,
                  defaultLiteral: 'other-dflt', oneofIndex: 0),
            ]),
          pbd.DescriptorProto()
            ..name = 'Nests'
            ..field.addAll([
              field('name', 1, pbd.FieldDescriptorProto_Type.TYPE_STRING),
              keyed('inner', 2, 'WithDefault'),
            ]),
        ])));

class WithDefault extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('WithDefault',
      package: const PackageName(pkg), createEmptyInstance: create)
    ..aOS(1, 'name')
    ..hasRequiredFields = false;
  WithDefault._();
  @override
  BuilderInfo get info_ => _i;
  @override
  WithDefault clone() => create()..mergeFromMessage(this);
  @override
  WithDefault createEmptyInstance() => create();
  static WithDefault create() => WithDefault._();
}

class WithRequired extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('WithRequired',
      package: const PackageName(pkg), createEmptyInstance: create)
    ..aOS(1, 'name')
    ..hasRequiredFields = false;
  WithRequired._();
  @override
  BuilderInfo get info_ => _i;
  @override
  WithRequired clone() => create()..mergeFromMessage(this);
  @override
  WithRequired createEmptyInstance() => create();
  static WithRequired create() => WithRequired._();
}

class InOneof extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('InOneof',
      package: const PackageName(pkg), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOS(1, 'name')
    ..aOS(2, 'other')
    ..hasRequiredFields = false;
  InOneof._();
  @override
  BuilderInfo get info_ => _i;
  @override
  InOneof clone() => create()..mergeFromMessage(this);
  @override
  InOneof createEmptyInstance() => create();
  static InOneof create() => InOneof._();
}

class Nests extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Nests',
      package: const PackageName(pkg), createEmptyInstance: create)
    ..aOS(1, 'name')
    ..pPM<WithDefault>(2, 'inner', subBuilder: WithDefault.create)
    ..hasRequiredFields = false;
  Nests._();
  @override
  BuilderInfo get info_ => _i;
  @override
  Nests clone() => create()..mergeFromMessage(this);
  @override
  Nests createEmptyInstance() => create();
  static Nests create() => Nests._();
}

class P extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('P',
      package: const PackageName(pkg), createEmptyInstance: create)
    ..pPM<WithDefault>(1, 'kd', subBuilder: WithDefault.create)
    ..pPM<WithRequired>(2, 'kr', subBuilder: WithRequired.create)
    ..pPM<InOneof>(3, 'ko', subBuilder: InOneof.create)
    ..pPM<Nests>(4, 'kn', subBuilder: Nests.create)
    ..aOM<any_pb.Any>(5, 'payload', subBuilder: any_pb.Any.create)
    ..hasRequiredFields = false;
  P._();
  @override
  BuilderInfo get info_ => _i;
  @override
  P clone() => create()..mergeFromMessage(this);
  @override
  P createEmptyInstance() => create();
  static P create() => P._();
}

final UnmarshalOptions opts = UnmarshalOptions(
    annotations: annotations, typeRegistry: TypeRegistry([Nests.create()]));

GeneratedMessage element(P m, int tag, int index) =>
    (m.getField(tag) as List)[index] as GeneratedMessage;

void main() {
  // The document, the list it fills, the element, the key the entry name
  // carries and the presence path it records.
  const cases = <(String, int, int, String, String)>[
    ('kd { alpha {} }', 1, 0, 'alpha', 'kd[0].name'),
    ('kd { "not ident" {} }', 1, 0, 'not ident', 'kd[0].name'),
    ('kd { alpha = {} }', 1, 0, 'alpha', 'kd[0].name'),
    ('kd = { alpha {} }', 1, 0, 'alpha', 'kd[0].name'),
    ('kd { a {} alpha {} }', 1, 1, 'alpha', 'kd[1].name'),
    ('kd { alpha { name = "alpha" } }', 1, 0, 'alpha', 'kd[0].name'),
    ('kr { alpha {} }', 2, 0, 'alpha', 'kr[0].name'),
    ('ko { alpha {} }', 3, 0, 'alpha', 'ko[0].name'),
  ];

  group('the entry name supplies the key field', () {
    for (final (doc, tag, index, key, mark) in cases) {
      test(doc, () {
        final m = P.create();
        final r = unmarshalFull(doc, m, options: opts);
        expect(element(m, tag, index).getField(1), key);
        expect(r.isSet(mark), isTrue, reason: mark);
        expect(r.isAbsent(mark), isFalse, reason: mark);
      });
    }

    test('in a keyed block nested in a keyed block', () {
      final m = P.create();
      final r =
          unmarshalFull('kn { a { inner { alpha {} } } }', m, options: opts);
      final inner = (element(m, 4, 0).getField(2) as List).single;
      expect((inner as WithDefault).getField(1), 'alpha');
      expect(r.isSet('kn[0].name'), isTrue);
      expect(r.isSet('kn[0].inner[0].name'), isTrue);
    });

    test('inside an Any body, under the Any\'s path', () {
      final m = P.create();
      final r = unmarshalFull(
          'payload { @type = "keyedname.v1.Nests" inner { alpha {} } }', m,
          options: opts);
      final any = m.getField(5) as any_pb.Any;
      final body = Nests.create()..mergeFromBuffer(any.value);
      expect((body.getField(2) as List).single.getField(1), 'alpha');
      expect(r.isSet('payload.inner[0].name'), isTrue);
    });
  });

  // Only an entry name counts: the anonymous form leaves a keyless element's
  // key absent.
  test('an anonymous element does not mark its key', () {
    for (final (doc, mark) in const [
      ('kd = [{}]', 'kd[0].name'),
      ('ko = [{}]', 'ko[0].name'),
    ]) {
      final r = unmarshalFull(doc, P.create(), options: opts);
      expect(r.isAbsent(mark), isTrue, reason: doc);
    }
  });

  test('a oneof sibling of the key stays unset', () {
    final m = P.create();
    unmarshalFull('ko { alpha {} }', m, options: opts);
    final e = element(m, 3, 0);
    expect(e.hasField(1), isTrue);
    expect(e.hasField(2), isFalse);
  });
}
