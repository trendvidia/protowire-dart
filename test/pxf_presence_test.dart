import 'package:test/test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:protowire/src/generated/proto/google/protobuf/any.pb.dart';

// FieldMask comes from the WKT pool exposed by the protobuf package, but
// not via Any's pb file. Build a thin generated-style stub for the test.

class TestFieldMask extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('FieldMask',
      package: const PackageName('google.protobuf'))
    ..pPS(1, 'paths')
    ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  TestFieldMask createEmptyInstance() => TestFieldMask();
  @override
  TestFieldMask clone() => TestFieldMask()..mergeFromMessage(this);
  static TestFieldMask create() => TestFieldMask();
}

class WithNull extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('WithNull',
      package: const PackageName('test'))
    ..aOS(1, 'name')
    ..aOS(2, 'email')
    ..aOS(3, 'role')
    ..aOM<TestFieldMask>(99, '_null', subBuilder: TestFieldMask.create)
    ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  WithNull createEmptyInstance() => WithNull();
  @override
  WithNull clone() => WithNull()..mergeFromMessage(this);
  static WithNull create() => WithNull();
}

class WithoutNullMask extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('WithoutNullMask',
      package: const PackageName('test'))
    ..aOS(1, 'name')
    ..aOS(2, 'email')
    ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  WithoutNullMask createEmptyInstance() => WithoutNullMask();
  @override
  WithoutNullMask clone() => WithoutNullMask()..mergeFromMessage(this);
  static WithoutNullMask create() => WithoutNullMask();
}

void main() {
  group('PXF unmarshalFull (PR4)', () {
    test('returns Result with set / null / absent paths', () {
      const input = '''
name = "Alice"
email = null
''';
      final msg = WithoutNullMask();
      final result = unmarshalFull(input, msg);

      expect(result.isSet('name'), isTrue);
      expect(result.isNull('email'), isTrue);
      expect(result.isAbsent('role'), isTrue);
      expect(result.nullFields, ['email']);
    });

    test('plain unmarshal preserves null state via _null FieldMask', () {
      const input = '''
name = "Alice"
email = null
role = null
''';
      final msg = WithNull();
      // Explicitly NOT using unmarshalFull — plain unmarshal must still
      // populate the message's _null field so the null state survives a
      // protobuf-binary round-trip.
      unmarshal(input, msg);

      final fm = msg.getField(99) as TestFieldMask;
      expect(fm.getField(1), containsAll(['email', 'role']));
    });
  });

  group('PXF marshal: _null FieldMask round-trip (PR4)', () {
    test('encoder emits "field = null" for paths in the _null FieldMask', () {
      final msg = WithNull()
        ..setField(1, 'Alice');
      // Pre-populate the FieldMask, simulating "round-tripped through PB
      // and now being re-marshaled to text". Repeated fields must be
      // mutated via getField + .add — direct setField rejects.
      final fm = TestFieldMask();
      (fm.getField(1) as List<String>)
        ..add('email')
        ..add('role');
      msg.setField(99, fm);

      final out = marshal(msg);

      expect(out, contains('name = "Alice"'));
      expect(out, contains('email = null'));
      expect(out, contains('role = null'));
      // _null itself should not be emitted as a field — it's the metadata
      // mechanism, not user-visible state.
      expect(out, isNot(contains('_null')));
    });

    test('round-trip: PXF -> message -> PXF preserves null state', () {
      const input = '''
name = "Alice"
email = null
role = null
''';
      final msg = WithNull();
      unmarshal(input, msg);

      final out = marshal(msg);
      expect(out, contains('name = "Alice"'));
      expect(out, contains('email = null'));
      expect(out, contains('role = null'));
    });

    test('marshal without a populated _null FieldMask emits no nulls', () {
      final msg = WithNull()..setField(1, 'Alice');
      final out = marshal(msg);
      expect(out, contains('name = "Alice"'));
      expect(out, isNot(contains('null')));
    });
  });
}
