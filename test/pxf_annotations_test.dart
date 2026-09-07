// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// (pxf.required) / (pxf.default) from a descriptor set (#14), against a
// descriptor built here in the shape of protowire's
// testdata/annotations/settings.proto plus a nested message, a oneof and
// the well-known-type defaults. Semantics mirror protowire-go's
// postDecode.
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:protowire/src/generated/proto/google/protobuf/descriptor.pb.dart'
    as pbd;
import 'package:protowire/src/generated/proto/pxf/annotations.pb.dart'
    as pxf_ann;
import 'package:test/test.dart';

// -- descriptor ---------------------------------------------------------

pbd.FieldDescriptorProto field(
    String name, int number, pbd.FieldDescriptorProto_Type type,
    {String? typeName,
    bool repeated = false,
    bool required = false,
    String? defaultLiteral,
    int? oneofIndex}) {
  final f = pbd.FieldDescriptorProto()
    ..name = name
    ..number = number
    ..type = type
    ..label = repeated
        ? pbd.FieldDescriptorProto_Label.LABEL_REPEATED
        : pbd.FieldDescriptorProto_Label.LABEL_OPTIONAL;
  if (typeName != null) f.typeName = '.$typeName';
  if (oneofIndex != null) f.oneofIndex = oneofIndex;
  if (required || defaultLiteral != null) {
    final o = pbd.FieldOptions();
    if (required) o.setExtension(pxf_ann.Annotations.required, true);
    if (defaultLiteral != null) {
      o.setExtension(pxf_ann.Annotations.default_1315, defaultLiteral);
    }
    f.options = o;
  }
  return f;
}

final pbd.FileDescriptorSet descriptorSet = () {
  final limits = pbd.DescriptorProto()
    ..name = 'Limits'
    ..field.addAll([
      field('max', 1, pbd.FieldDescriptorProto_Type.TYPE_INT32, required: true),
      field('min', 2, pbd.FieldDescriptorProto_Type.TYPE_INT32,
          defaultLiteral: '1'),
    ]);
  final settings = pbd.DescriptorProto()
    ..name = 'Settings'
    ..oneofDecl.add(pbd.OneofDescriptorProto()..name = 'choice')
    ..field.addAll([
      field('name', 1, pbd.FieldDescriptorProto_Type.TYPE_STRING,
          required: true),
      field('retries', 2, pbd.FieldDescriptorProto_Type.TYPE_INT32,
          defaultLiteral: '3'),
      field('region', 3, pbd.FieldDescriptorProto_Type.TYPE_STRING,
          defaultLiteral: 'us-east-1'),
      field('verbose', 4, pbd.FieldDescriptorProto_Type.TYPE_BOOL,
          defaultLiteral: 'true'),
      field('limits', 5, pbd.FieldDescriptorProto_Type.TYPE_MESSAGE,
          typeName: 'settings.v1.Limits'),
      field('history', 6, pbd.FieldDescriptorProto_Type.TYPE_MESSAGE,
          typeName: 'settings.v1.Limits', repeated: true),
      field('level', 7, pbd.FieldDescriptorProto_Type.TYPE_ENUM,
          typeName: 'settings.v1.Level', defaultLiteral: 'LEVEL_HIGH'),
      field('token', 8, pbd.FieldDescriptorProto_Type.TYPE_BYTES,
          defaultLiteral: 'AQID'),
      field('ratio', 9, pbd.FieldDescriptorProto_Type.TYPE_DOUBLE,
          defaultLiteral: '0.5'),
      field('a', 11, pbd.FieldDescriptorProto_Type.TYPE_STRING,
          defaultLiteral: 'dflt-a', oneofIndex: 0),
      field('b', 12, pbd.FieldDescriptorProto_Type.TYPE_STRING, oneofIndex: 0),
      field('big', 13, pbd.FieldDescriptorProto_Type.TYPE_UINT64,
          defaultLiteral: '18446744073709551615'),
    ]);
  final file = pbd.FileDescriptorProto()
    ..name = 'settings.proto'
    ..package = 'settings.v1'
    ..messageType.addAll([settings, limits]);
  return pbd.FileDescriptorSet()..file.add(file);
}();

// -- generated-style messages --------------------------------------------

class Level extends ProtobufEnum {
  static const Level LEVEL_LOW = Level._(0, 'LEVEL_LOW');
  static const Level LEVEL_HIGH = Level._(1, 'LEVEL_HIGH');
  static const List<Level> values = [LEVEL_LOW, LEVEL_HIGH];
  static Level? valueOf(int v) =>
      v >= 0 && v < values.length ? values[v] : null;
  const Level._(super.value, super.name);
}

class Limits extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Limits',
      package: const PackageName('settings.v1'), createEmptyInstance: create)
    ..a<int>(1, 'max', PbFieldType.O3)
    ..a<int>(2, 'min', PbFieldType.O3)
    ..hasRequiredFields = false;
  Limits._();
  @override
  BuilderInfo get info_ => _i;
  @override
  Limits clone() => Limits.create()..mergeFromMessage(this);
  @override
  Limits createEmptyInstance() => create();
  static Limits create() => Limits._();
}

class Settings extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Settings',
      package: const PackageName('settings.v1'), createEmptyInstance: create)
    ..aOS(1, 'name')
    ..a<int>(2, 'retries', PbFieldType.O3)
    ..aOS(3, 'region')
    ..aOB(4, 'verbose')
    ..aOM<Limits>(5, 'limits', subBuilder: Limits.create)
    ..pc<Limits>(6, 'history', PbFieldType.PM, subBuilder: Limits.create)
    ..e<Level>(7, 'level', PbFieldType.OE,
        defaultOrMaker: Level.LEVEL_LOW,
        valueOf: Level.valueOf,
        enumValues: Level.values)
    ..a<List<int>>(8, 'token', PbFieldType.OY)
    ..a<double>(9, 'ratio', PbFieldType.OD)
    ..a<int>(10, 'bad', PbFieldType.O3)
    ..oo(0, [11, 12])
    ..aOS(11, 'a')
    ..aOS(12, 'b')
    ..a<Int64>(13, 'big', PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
    ..hasRequiredFields = false;
  Settings._();
  @override
  BuilderInfo get info_ => _i;
  @override
  Settings clone() => Settings.create()..mergeFromMessage(this);
  @override
  Settings createEmptyInstance() => create();
  static Settings create() => Settings._();
}

// -- tests ------------------------------------------------------------------

final PxfAnnotations annotations =
    PxfAnnotations.fromDescriptorSet(descriptorSet);
UnmarshalOptions opts([PxfAnnotations? a]) =>
    UnmarshalOptions(annotations: a ?? annotations);

Settings full(String text, [PxfAnnotations? a]) {
  final s = Settings.create();
  unmarshalFull(text, s, options: opts(a));
  return s;
}

void main() {
  group('index', () {
    test('reads the options, including through serialized bytes', () {
      for (final a in [
        annotations,
        PxfAnnotations.fromBytes(descriptorSet.writeToBuffer()),
      ]) {
        expect(a.field('settings.v1.Settings', 'name')?.required, isTrue);
        expect(a.field('settings.v1.Settings', 'name')?.defaultLiteral, isNull);
        expect(a.field('settings.v1.Settings', 'retries')?.required, isFalse);
        expect(a.field('settings.v1.Settings', 'retries')?.defaultLiteral, '3');
        expect(a.field('settings.v1.Settings', 'limits'), isNull);
        expect(a.field('settings.v1.Limits', 'max')?.required, isTrue);
        expect(a.hasMessage('settings.v1.Limits'), isTrue);
        expect(a.hasMessage('settings.v1.Missing'), isFalse);
      }
    });

    test('bytes parsed without the registry see nothing', () {
      final plain =
          pbd.FileDescriptorSet.fromBuffer(descriptorSet.writeToBuffer());
      final a = PxfAnnotations.fromDescriptorSet(plain);
      expect(a.hasMessage('settings.v1.Settings'), isTrue);
      expect(a.field('settings.v1.Settings', 'name'), isNull);
    });
  });

  group('required', () {
    test('absent is rejected with the reference message', () {
      expect(
          () => full('retries = 5\n'),
          throwsA(predicate(
              (e) => '$e' == '1:1: required field "name" is absent')));
    });

    test('set to null counts as present', () {
      final s = Settings.create();
      final r = unmarshalFull('name = null\n', s, options: opts());
      expect(r.isNull('name'), isTrue);
      expect(s.hasField(1), isFalse);
    });

    test('is checked inside present singular messages, by path', () {
      expect(
          () => full('name = "svc"\nlimits { min = 2 }\n'),
          throwsA(predicate(
              (e) => '$e' == '1:1: required field "limits.max" is absent')));
      expect(full('name = "svc"\nlimits { max = 2 }\n').getField(5),
          isA<Limits>());
      expect(full('name = "svc"\nlimits = { max = 2 }\n').getField(5),
          isA<Limits>());
      // Absent or null nested messages are not descended into.
      full('name = "svc"\n');
      full('name = "svc"\nlimits = null\n');
    });

    test('list elements are not validated (as in the reference)', () {
      final s = full('name = "svc"\nhistory = [ { min = 2 } ]\n');
      expect((s.getField(6) as List).length, 1);
    });
  });

  group('default', () {
    test('fills absent fields of every kind; Result still says absent', () {
      final s = Settings.create();
      final r = unmarshalFull('name = "svc"\n', s, options: opts());
      expect(s.getField(1), 'svc');
      expect(s.getField(2), 3);
      expect(s.getField(3), 'us-east-1');
      expect(s.getField(4), true);
      expect(s.getField(7), Level.LEVEL_HIGH);
      expect(s.getField(8), Uint8List.fromList([1, 2, 3]));
      expect(s.getField(9), 0.5);
      expect(s.getField(11), 'dflt-a');
      expect(s.getField(13), Int64.parseInt('18446744073709551615'));
      expect(r.isSet('name'), isTrue);
      for (final p in ['retries', 'region', 'verbose', 'level', 'token']) {
        expect(r.isAbsent(p), isTrue, reason: p);
      }
    });

    test('present values are not overridden', () {
      final s =
          full('name = "svc"\nretries = 7\nverbose = false\nregion = "eu"\n');
      expect(s.getField(2), 7);
      expect(s.getField(4), false);
      expect(s.getField(3), 'eu');
    });

    test('null is not defaulted', () {
      final s = full('name = "svc"\nretries = null\n');
      expect(s.hasField(2), isFalse);
    });

    test('applies inside present singular messages, not list elements', () {
      final s =
          full('name = "svc"\nlimits { max = 9 }\nhistory = [ { max = 9 } ]\n');
      expect((s.getField(5) as Limits).getField(2), 1);
      expect(((s.getField(6) as List).first as Limits).hasField(2), isFalse);
    });

    test('is skipped for a oneof member when another member is set', () {
      expect(full('name = "svc"\nb = "x"\n').hasField(11), isFalse);
      expect(full('name = "svc"\nb = null\n').hasField(11), isFalse);
      expect(full('name = "svc"\n').getField(11), 'dflt-a');
    });

    test('a literal that does not read as the field type is its own error', () {
      final fds = descriptorSet.clone();
      fds.file.first.messageType.first.field.add(field(
          'bad', 10, pbd.FieldDescriptorProto_Type.TYPE_INT32,
          defaultLiteral: 'many'));
      final a = PxfAnnotations.fromDescriptorSet(fds);
      expect(
          () => full('name = "svc"\n', a),
          throwsA(predicate((e) =>
              '$e' == '1:1: invalid default int32 "many" for field "bad"')));
    });
  });

  test('without annotations nothing changes; unknown root is inert', () {
    final s = Settings.create();
    final r = unmarshalFull('retries = 5\n', s);
    expect(s.hasField(1), isFalse);
    expect(s.getField(2), 5);
    expect(r.isSet('retries'), isTrue);
    final empty = PxfAnnotations.fromDescriptorSet(pbd.FileDescriptorSet());
    unmarshalFull('retries = 5\n', Settings.create(), options: opts(empty));
  });
}
