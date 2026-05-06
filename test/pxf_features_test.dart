import 'package:test/test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protowire/protowire.dart';
import 'package:protowire/src/encoding/pxf/wellknown.dart';

class Status extends ProtobufEnum {
  static const Status STATUS_UNSPECIFIED = Status._(0, 'STATUS_UNSPECIFIED');
  static const Status STATUS_SERVING = Status._(1, 'STATUS_SERVING');
  static const Status STATUS_DRAINING = Status._(2, 'STATUS_DRAINING');

  static const List<Status> values = [
    STATUS_UNSPECIFIED,
    STATUS_SERVING,
    STATUS_DRAINING,
  ];
  static final Map<int, Status> _byValue = ProtobufEnum.initByValue(values);
  static Status? valueOf(int value) => _byValue[value];

  const Status._(super.v, super.n);
}

class WithEnum extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('WithEnum',
      package: const PackageName('test'))
    ..e<Status>(1, 'status', PbFieldType.OE,
        defaultOrMaker: Status.STATUS_UNSPECIFIED,
        valueOf: Status.valueOf,
        enumValues: Status.values)
    ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  WithEnum createEmptyInstance() => WithEnum();
  @override
  WithEnum clone() => WithEnum()..mergeFromMessage(this);
}

class WithMap extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('WithMap',
      package: const PackageName('test'))
    ..m<String, String>(1, 'labels',
        entryClassName: 'WithMap.LabelsEntry',
        keyFieldType: PbFieldType.OS, valueFieldType: PbFieldType.OS)
    ..m<String, int>(2, 'counts',
        entryClassName: 'WithMap.CountsEntry',
        keyFieldType: PbFieldType.OS, valueFieldType: PbFieldType.O3)
    ..m<int, String>(3, 'byId',
        entryClassName: 'WithMap.ByIdEntry',
        keyFieldType: PbFieldType.O3, valueFieldType: PbFieldType.OS)
    ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  WithMap createEmptyInstance() => WithMap();
  @override
  WithMap clone() => WithMap()..mergeFromMessage(this);
}

class WithTs extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('WithTs',
      package: const PackageName('test'))
    ..a<Int64>(1, 'seconds', PbFieldType.O6, defaultOrMaker: Int64.ZERO)
    ..a<int>(2, 'nanos', PbFieldType.O3)
    ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  WithTs createEmptyInstance() => WithTs();
  @override
  WithTs clone() => WithTs()..mergeFromMessage(this);
}

void main() {
  group('PXF enum-by-name decoding (PR2)', () {
    test('decodes enum by name', () {
      final msg = WithEnum();
      unmarshal('status = STATUS_SERVING\n', msg);
      expect(msg.getField(1), Status.STATUS_SERVING);
    });

    test('still accepts enum by number', () {
      final msg = WithEnum();
      unmarshal('status = 2\n', msg);
      expect(msg.getField(1), Status.STATUS_DRAINING);
    });

    test('rejects unknown enum name', () {
      final msg = WithEnum();
      expect(() => unmarshal('status = STATUS_UNKNOWN\n', msg),
          throwsA(isA<Exception>()));
    });
  });

  group('PXF map decoder (PR2)', () {
    test('string -> string map round-trips', () {
      final msg = WithMap();
      const input = '''
labels = {
  env: "production"
  team: "platform"
}
''';
      unmarshal(input, msg);
      final m = msg.getField(1) as Map;
      expect(m['env'], 'production');
      expect(m['team'], 'platform');
    });

    test('string -> int32 map decodes typed values', () {
      final msg = WithMap();
      const input = '''
counts = {
  hits: 42
  misses: 7
}
''';
      unmarshal(input, msg);
      final m = msg.getField(2) as Map;
      expect(m['hits'], 42);
      expect(m['misses'], 7);
    });

    test('int32 -> string map coerces the key type', () {
      final msg = WithMap();
      const input = '''
byId = {
  1: "alice"
  2: "bob"
}
''';
      unmarshal(input, msg);
      final m = msg.getField(3) as Map;
      expect(m[1], 'alice');
      expect(m[2], 'bob');
    });

    test('rejects null map values', () {
      final msg = WithMap();
      expect(
          () => unmarshal('labels = { foo: null }\n', msg),
          throwsA(isA<PxfError>()));
    });
  });

  group('Timestamp / Duration microsecond precision (PR2)', () {
    test('timestamp round-trips at microsecond resolution', () {
      // 1.5µs past the second: tests that 500µs survives the round-trip
      // (the previous millisecond-only path would round it to zero).
      final t = DateTime.utc(2024, 1, 15, 10, 30, 0, 0, 500);
      final m = WithTs();
      setTimestampFields(m, t);
      // nanos should be 500 * 1000 = 500_000
      expect(m.getField(2), 500000);
      expect(readTimestamp(m), t);
    });

    test('duration round-trips at microsecond resolution', () {
      const d = Duration(seconds: 5, microseconds: 250);
      final m = WithTs();
      setDurationFields(m, d);
      expect(m.getField(2), 250 * 1000);
      expect(readDuration(m), d);
    });

    test('zero stays zero', () {
      final t = DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true);
      final m = WithTs();
      setTimestampFields(m, t);
      expect(m.getField(1), Int64.ZERO);
      expect(m.getField(2), 0);
    });
  });
}
