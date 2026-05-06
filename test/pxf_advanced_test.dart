import 'package:test/test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';

import 'package:protowire/src/generated/proto/pxf/bignum.pb.dart' as pxf;
import 'package:protowire/src/generated/proto/google/protobuf/any.pb.dart' as pb;

class OneofMessage extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('OneofMessage', package: const PackageName('test'))
    ..aOS(1, 'name')
    ..oo(0, [2, 3])
    ..aOS(2, 'stringVal')
    ..a<int>(3, 'intVal', PbFieldType.O3)
    ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  OneofMessage createEmptyInstance() => OneofMessage();
  @override
  OneofMessage clone() => OneofMessage()..mergeFromMessage(this);
}

class AnyContainer extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('AnyContainer', package: const PackageName('test'))
    ..aOM<pb.Any>(1, 'payload', subBuilder: pb.Any.create)
    ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  AnyContainer createEmptyInstance() => AnyContainer();
  @override
  AnyContainer clone() => AnyContainer()..mergeFromMessage(this);
}

class Payload extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Payload', package: const PackageName('test'), createEmptyInstance: () => Payload())
    ..aOS(1, 'data')
    ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  Payload createEmptyInstance() => Payload();
  @override
  Payload clone() => Payload()..mergeFromMessage(this);
  static Payload create() => Payload();
}

class BigNumContainer extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('BigNumContainer', package: const PackageName('test'))
    ..aOM<pxf.BigInt>(1, 'myInt', subBuilder: pxf.BigInt.create)
    ..aOM<pxf.Decimal>(2, 'myDecimal', subBuilder: pxf.Decimal.create)
    ..hasRequiredFields = false;
  @override
  BuilderInfo get info_ => _i;
  @override
  BigNumContainer createEmptyInstance() => BigNumContainer();
  @override
  BigNumContainer clone() => BigNumContainer()..mergeFromMessage(this);
  static BigNumContainer create() => BigNumContainer();
}

void main() {
  group('PXF Advanced Features', () {
    test('oneof exclusivity', () {
      final input = '''
        name = "test"
        stringVal = "hello"
        intVal = 42
      ''';
      final msg = OneofMessage();
      expect(() => unmarshal(input, msg), throwsA(predicate((e) => e.toString().contains('conflicts with already-set field'))));
    });

    test('Any sugar syntax', () {
      final input = '''
        payload {
          @type = "test.Payload"
          data = "secret"
        }
      ''';
      final msg = AnyContainer();
      final registry = TypeRegistry([Payload()]);
      
      unmarshal(input, msg, options: UnmarshalOptions(typeRegistry: registry));

      final any = msg.getField(1) as pb.Any;
      expect(any.typeUrl, 'test.Payload');
      
      final inner = Payload();
      inner.mergeFromBuffer(any.value);
      expect(inner.getField(1), 'secret');
    });

    test('Any sugar syntax (assignment style)', () {
      final input = '''
        payload = {
          @type = "test.Payload"
          data = "secret2"
        }
      ''';
      final msg = AnyContainer();
      final registry = TypeRegistry([Payload()]);
      
      unmarshal(input, msg, options: UnmarshalOptions(typeRegistry: registry));

      final any = msg.getField(1) as pb.Any;
      expect(any.typeUrl, 'test.Payload');
      
      final inner = Payload();
      inner.mergeFromBuffer(any.value);
      expect(inner.getField(1), 'secret2');
    });

    test('BigInt and Decimal literals', () {
      final input = '''
        myInt = 123456789012345678901234567890
        myDecimal = -123.450
      ''';
      final msg = BigNumContainer();
      unmarshal(input, msg);

      final bi = msg.getField(1) as pxf.BigInt;
      expect(bi.negative, false);
      final expectedAbs = BigInt.parse('123456789012345678901234567890');
      BigInt bytesToBigInt(List<int> bytes) {
        if (bytes.isEmpty) return BigInt.zero;
        var hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
        return BigInt.parse(hex, radix: 16);
      }
      expect(bytesToBigInt(bi.abs), expectedAbs);

      final dec = msg.getField(2) as pxf.Decimal;
      expect(dec.negative, true);
      expect(dec.scale, 3);
      final expectedUnscaled = BigInt.from(123450);
      expect(bytesToBigInt(dec.unscaled), expectedUnscaled);

      final output = marshal(msg);
      // PXF emits proto-canonical (snake_case) field names; the protoName
      // here is auto-derived from the camelCase Dart name `myInt`.
      expect(output, contains('my_int = 123456789012345678901234567890'));
      expect(output, contains('my_decimal = -123.450'));
    });
  });
}
