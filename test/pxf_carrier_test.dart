// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// `@required` and `@default` lower to the 1327 carrier (RFC-001 §8.1). The
// first group runs the spec repo's compiled image, vendored from
// testdata/annotations/; the rest build raw carrier bytes, as protowire-go's
// carrier_test.go does. Also here: the bind checks of draft -01 "Oneof
// Members" and "Default Placement", in both spellings, and the required and
// default rule in every message body.
import 'dart:convert';
import 'dart:io';

import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:protowire/src/generated/proto/google/protobuf/descriptor.pb.dart'
    as pbd;
import 'package:protowire/src/generated/proto/pxf/annotations.pb.dart'
    as pxf_ann;
import 'package:test/test.dart';

import 'generated/any.pb.dart' as anypb;

const dir = 'test/testdata/annotations';

class Annotated extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Settings',
      package: const PackageName('settings.annotated.v1'),
      createEmptyInstance: create)
    ..aOS(1, 'name')
    ..a<int>(2, 'retries', PbFieldType.O3)
    ..aOS(3, 'region')
    ..aOB(4, 'verbose');
  Annotated._();
  @override
  BuilderInfo get info_ => _i;
  @override
  Annotated clone() => create()..mergeFromMessage(this);
  @override
  Annotated createEmptyInstance() => create();
  static Annotated create() => Annotated._();
}

// -- raw carrier bytes ------------------------------------------------------

List<int> varint(int v) {
  final out = <int>[];
  while (v >= 0x80) {
    out.add((v & 0x7F) | 0x80);
    v >>= 7;
  }
  return out..add(v);
}

List<int> bytesField(int number, List<int> payload) =>
    [...varint(number << 3 | 2), ...varint(payload.length), ...payload];

List<int> stringField(int number, String s) =>
    bytesField(number, utf8.encode(s));

List<int> varintField(int number, int v) =>
    [...varint(number << 3), ...varint(v)];

/// One AnnotationList entry.
List<int> entry(String name, [List<int>? arg]) => bytesField(1, [
      ...stringField(1, name),
      if (arg != null) ...bytesField(2, arg),
    ]);

List<int> required_() => entry('protowire.schema.v1.required');
List<int> default_(List<int> arg) => entry('protowire.schema.v1.default', arg);

pbd.FieldOptions carrier(List<int> list, [pbd.FieldOptions? base]) {
  final o = base ?? pbd.FieldOptions();
  final unknown = o.unknownFields;
  unknown.addField(1327, UnknownFieldSetField()..addLengthDelimited(list));
  return o;
}

const tString = pbd.FieldDescriptorProto_Type.TYPE_STRING;
const tInt32 = pbd.FieldDescriptorProto_Type.TYPE_INT32;
const tUint64 = pbd.FieldDescriptorProto_Type.TYPE_UINT64;
const tMessage = pbd.FieldDescriptorProto_Type.TYPE_MESSAGE;

pbd.FieldDescriptorProto field(
    String name, int number, pbd.FieldDescriptorProto_Type type,
    {pbd.FieldOptions? options,
    String? typeName,
    bool repeated = false,
    int? oneofIndex}) {
  final f = pbd.FieldDescriptorProto()
    ..name = name
    ..number = number
    ..type = type
    ..label = repeated
        ? pbd.FieldDescriptorProto_Label.LABEL_REPEATED
        : pbd.FieldDescriptorProto_Label.LABEL_OPTIONAL;
  if (options != null) f.options = options;
  if (typeName != null) f.typeName = '.$typeName';
  if (oneofIndex != null) f.oneofIndex = oneofIndex;
  return f;
}

pbd.FieldOptions bracket({bool required = false, String? defaultLiteral}) {
  final o = pbd.FieldOptions();
  if (required) o.setExtension(pxf_ann.Annotations.required, true);
  if (defaultLiteral != null) {
    o.setExtension(pxf_ann.Annotations.default_1315, defaultLiteral);
  }
  return o;
}

PxfAnnotations bind(List<pbd.FieldDescriptorProto> fields,
    {List<String> oneofs = const [],
    List<pbd.DescriptorProto> extra = const []}) {
  final m = pbd.DescriptorProto()..name = 'M';
  m.field.addAll(fields);
  m.oneofDecl.addAll(oneofs.map((n) => pbd.OneofDescriptorProto()..name = n));
  final file = pbd.FileDescriptorProto()
    ..name = 't.proto'
    ..package = 't'
    ..syntax = 'proto3';
  file.messageType
    ..add(m)
    ..addAll(extra);
  return PxfAnnotations.fromDescriptorSet(
      pbd.FileDescriptorSet()..file.add(file));
}

Matcher refused(String text) =>
    throwsA(isA<PxfError>().having((e) => '$e', 'message', contains(text)));

/// The literal a one-field carrier reduces [arg] to.
String? literalOf(List<int> arg,
    [pbd.FieldDescriptorProto_Type type = tString, String? typeName]) {
  final a = bind([
    field('f', 1, type, options: carrier(default_(arg)), typeName: typeName),
  ]);
  return a.field('t.M', 'f')?.defaultLiteral;
}

void main() {
  group('the compiled annotation-form schema', () {
    final ann = PxfAnnotations.fromBytes(
        File('$dir/settings_annotated.binpb').readAsBytesSync());

    test('carries the annotations, and no bracket options stand in', () {
      expect(ann.field('settings.annotated.v1.Settings', 'name')?.required,
          isTrue);
      expect(
          ann.field('settings.annotated.v1.Settings', 'region')?.defaultLiteral,
          'us-east-1');
    });

    test('ok.pxf takes every default', () {
      final m = Annotated.create();
      unmarshalFull(File('$dir/ok.pxf').readAsStringSync(), m,
          options: UnmarshalOptions(annotations: ann));
      expect(m.getField(1), 'svc');
      expect(m.getField(2), 3);
      expect(m.getField(3), 'us-east-1');
      expect(m.getField(4), true);
    });

    test('missing-required.pxf is rejected', () {
      expect(
          () => unmarshalFull(
              File('$dir/missing-required.pxf').readAsStringSync(),
              Annotated.create(),
              options: UnmarshalOptions(annotations: ann)),
          refused('required field "name" is absent'));
    });
  });

  group('carrier bytes', () {
    test('@required', () {
      final a = bind([field('f', 1, tString, options: carrier(required_()))]);
      expect(a.field('t.M', 'f')?.required, isTrue);
    });

    test('@default takes every argument member', () {
      expect(literalOf(stringField(10, 'x')), 'x');
      expect(literalOf(varintField(11, 7), tInt32), '7');
      expect(literalOf(varintField(13, 1)), 'true');
      expect(literalOf(varintField(13, 0)), 'false');
      expect(literalOf(bytesField(14, [1, 2, 3])), 'AQID');
    });

    test('a named `value` argument counts, another name does not', () {
      expect(literalOf([...stringField(1, 'value'), ...stringField(10, 'x')]),
          'x');
      expect(
          () =>
              literalOf([...stringField(1, 'other'), ...stringField(10, 'x')]),
          refused('@default carries no value argument'));
    });

    test('a negative int and an unsigned target', () {
      final neg = [
        ...varint(11 << 3),
        ...[0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x01]
      ];
      expect(literalOf(neg, tInt32), '-1');
      expect(literalOf(neg, tUint64), '18446744073709551615');
    });

    test('a double', () {
      final bits = [...varint(12 << 3 | 1), 0, 0, 0, 0, 0, 0, 0xE0, 0x3F];
      expect(literalOf(bits, pbd.FieldDescriptorProto_Type.TYPE_DOUBLE), '0.5');
    });

    test('a resolved enum literal', () {
      final enumLit = bytesField(1, stringField(2, 'LEVEL_HIGH'));
      expect(literalOf(bytesField(15, enumLit)), 'LEVEL_HIGH');
    });

    test('big numbers reduce to positional literals', () {
      expect(
          literalOf(
              bytesField(16, [
                ...bytesField(1, [1, 0]),
                ...varintField(2, 1)
              ]),
              tMessage,
              'pxf.BigInt'),
          '-256');
      expect(
          literalOf(
              bytesField(17, [
                ...bytesField(1, [0x30, 0x39]),
                ...varintField(2, 2)
              ]),
              tMessage,
              'pxf.Decimal'),
          '123.45');
    });

    test('a decimal scale past the bound is refused before any work', () {
      expect(
          () => literalOf(
              bytesField(17, [
                ...bytesField(1, [1]),
                ...varintField(2, 2147483647)
              ]),
              tMessage,
              'pxf.Decimal'),
          refused('MaxNumericLiteralDigits'));
    });

    test('truncated bytes keep what came before them', () {
      final list = [...required_(), 0x0A, 0x7F, 0x01];
      final a = bind([field('f', 1, tString, options: carrier(list))]);
      expect(a.field('t.M', 'f')?.required, isTrue);
    });

    test('a list or message literal is reported, not dropped', () {
      expect(() => literalOf(bytesField(15, [])),
          refused('a default is exactly one literal'));
      expect(() => literalOf(<int>[]), refused("@default's value is empty"));
    });

    test('a split carrier merges', () {
      final o = pbd.FieldOptions();
      o.unknownFields.addField(
          1327,
          UnknownFieldSetField()
            ..addLengthDelimited(required_())
            ..addLengthDelimited(default_(stringField(10, 'x'))));
      expect(() => bind([field('f', 1, tString, options: o)]),
          refused('are exclusive on one field'));
    });
  });

  group('both spellings bind alike', () {
    test('required with default, across spellings, names what was written', () {
      expect(
          () => bind([
                field('f', 1, tString,
                    options:
                        carrier(required_(), bracket(defaultLiteral: 'x'))),
              ]),
          refused('@required and (pxf.default) are exclusive'));
    });

    test('two spellings of one default agree or are refused', () {
      final same = bind([
        field('f', 1, tString,
            options: carrier(
                default_(stringField(10, 'x')), bracket(defaultLiteral: 'x'))),
      ]);
      expect(same.field('t.M', 'f')?.defaultLiteral, 'x');
      expect(
          () => bind([
                field('f', 1, tString,
                    options: carrier(default_(stringField(10, 'y')),
                        bracket(defaultLiteral: 'x'))),
              ]),
          refused('carry different values'));
    });

    for (final (name, options) in [
      ('(pxf.required)', () => bracket(required: true)),
      ('@required', () => carrier(required_())),
    ]) {
      test('$name on a oneof member is refused', () {
        expect(
            () => bind([
                  field('a', 1, tString, options: options(), oneofIndex: 0),
                  field('b', 2, tString, oneofIndex: 0),
                ], oneofs: [
                  'pick'
                ]),
            refused('$name is not valid on a member of oneof "pick"'));
      });
    }

    for (final (name, options) in [
      ('(pxf.default)', () => bracket(defaultLiteral: 'x')),
      ('@default', () => carrier(default_(stringField(10, 'x')))),
    ]) {
      test('two $name in one oneof are refused, each member named', () {
        expect(
            () => bind([
                  field('a', 1, tString, options: options(), oneofIndex: 0),
                  field('b', 2, tString, options: options(), oneofIndex: 0),
                ], oneofs: [
                  'pick'
                ]),
            refused('at most one member of oneof "pick" may carry a default; '
                '2 do (a, b)'));
      });

      test('$name on a repeated field is refused', () {
        expect(
            () => bind(
                [field('l', 1, tString, options: options(), repeated: true)]),
            refused('not valid on repeated fields'));
      });

      test('$name on a plain message is refused', () {
        expect(
            () => bind([
                  field('m', 1, tMessage,
                      options: options(), typeName: 't.Plain')
                ], extra: [
                  pbd.DescriptorProto()..name = 'Plain'
                ]),
            refused('not valid on message type t.Plain'));
      });

      test('$name on a nested message\'s field is refused too', () {
        final nested = pbd.DescriptorProto()
          ..name = 'Outer'
          ..nestedType.add(pbd.DescriptorProto()
            ..name = 'In'
            ..field.add(
                field('l', 1, tString, options: options(), repeated: true)));
        expect(
            () => bind([], extra: [nested]), refused('field "t.Outer.In.l"'));
      });
    }

    test('one default in a oneof, and a default on a well-known type, bind',
        () {
      bind([
        field('a', 1, tString,
            options: bracket(defaultLiteral: 'x'), oneofIndex: 0),
        field('b', 2, tString, oneofIndex: 0),
        field('w', 3, tMessage,
            options: bracket(defaultLiteral: '3'),
            typeName: 'google.protobuf.Int32Value'),
      ], oneofs: [
        'pick'
      ]);
    });

    test('a proto3 optional is not a oneof member', () {
      final f = field('o', 1, tString,
          options: bracket(required: true), oneofIndex: 0)
        ..proto3Optional = true;
      bind([f], oneofs: ['_o']);
    });
  });

  group('every message body', () {
    // Holder { Any payload; repeated Any anys; map<string, Any> by_key;
    // Leaf leaf } from testdata/any, with Leaf.tag required.
    PxfAnnotations schema({String? defaultTag}) {
      final leaf = pbd.DescriptorProto()
        ..name = 'Leaf'
        ..field.addAll([
          field('tag', 1, tString,
              options: bracket(
                  required: defaultTag == null, defaultLiteral: defaultTag)),
          field('n', 2, tInt32),
        ]);
      final any =
          field('payload', 1, tMessage, typeName: 'google.protobuf.Any');
      final holder = pbd.DescriptorProto()
        ..name = 'Holder'
        ..field.addAll([
          any,
          field('leaves', 2, tMessage, typeName: 'any.v1.Leaf', repeated: true),
          field('leaf', 4, tMessage, typeName: 'any.v1.Leaf'),
        ]);
      final file = pbd.FileDescriptorProto()
        ..name = 'any.proto'
        ..package = 'any.v1'
        ..syntax = 'proto3';
      file.messageType.addAll([holder, leaf]);
      return PxfAnnotations.fromDescriptorSet(
          pbd.FileDescriptorSet()..file.add(file));
    }

    final registry = TypeRegistry([anypb.Leaf()]);

    test('an Any body written with @type is checked under the Any\'s path', () {
      expect(
          () => unmarshalFull(
              'payload { @type = "any.v1.Leaf" n = 1 }', anypb.Holder(),
              options: UnmarshalOptions(
                  annotations: schema(), typeRegistry: registry)),
          refused('required field "payload.tag" is absent'));
    });

    test('an Any body takes its default before it is packed', () {
      final h = anypb.Holder();
      unmarshalFull('payload { @type = "any.v1.Leaf" n = 1 }', h,
          options: UnmarshalOptions(
              annotations: schema(defaultTag: 'dflt'), typeRegistry: registry));
      expect(anypb.Leaf.fromBuffer(h.payload.value).tag, 'dflt');
    });

    test('an Any list element and a map value', () {
      final a = schema();
      UnmarshalOptions o() =>
          UnmarshalOptions(annotations: a, typeRegistry: registry);
      expect(
          () => unmarshalFull(
              'anys = [{ @type = "any.v1.Leaf" }]', anypb.Holder(),
              options: o()),
          refused('required field "anys[0].tag" is absent'));
      expect(
          () => unmarshalFull(
              'by_key = { k: { @type = "any.v1.Leaf" } }', anypb.Holder(),
              options: o()),
          refused('required field "by_key["k"].tag" is absent'));
    });
  });
}
