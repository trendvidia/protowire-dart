import 'package:test/test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:fixnum/fixnum.dart';

class Any extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Any', package: const PackageName('google.protobuf'))
    ..aOS(1, 'typeUrl')
    ..a<List<int>>(2, 'value', PbFieldType.OY)
    ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  Any createEmptyInstance() => Any();
  @override
  Any clone() => Any()..mergeFromMessage(this);
  static Any create() => Any();
  
  String get typeUrl => getField(1);
  List<int> get value => getField(2);
}

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
    ..aOM<Any>(1, 'payload', subBuilder: Any.create)
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

class BigIntMsg extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('BigInt', package: const PackageName('pxf'), createEmptyInstance: () => BigIntMsg())
    ..a<List<int>>(1, 'abs', PbFieldType.OY)
    ..aOB(2, 'negative')
    ..hasRequiredFields = false;
  @override
  BuilderInfo get info_ => _i;
  @override
  BigIntMsg createEmptyInstance() => BigIntMsg();
  @override
  BigIntMsg clone() => BigIntMsg()..mergeFromMessage(this);
  static BigIntMsg create() => BigIntMsg();
}

class DecimalMsg extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Decimal', package: const PackageName('pxf'), createEmptyInstance: () => DecimalMsg())
    ..a<List<int>>(1, 'unscaled', PbFieldType.OY)
    ..a<int>(2, 'scale', PbFieldType.O3)
    ..aOB(3, 'negative')
    ..hasRequiredFields = false;
  @override
  BuilderInfo get info_ => _i;
  @override
  DecimalMsg createEmptyInstance() => DecimalMsg();
  @override
  DecimalMsg clone() => DecimalMsg()..mergeFromMessage(this);
  static DecimalMsg create() => DecimalMsg();
}

class BigNumContainer extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('BigNumContainer', package: const PackageName('test'))
    ..aOM<BigIntMsg>(1, 'myInt', subBuilder: BigIntMsg.create)
    ..aOM<DecimalMsg>(2, 'myDecimal', subBuilder: DecimalMsg.create)
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

      final any = msg.getField(1) as Any;
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

      final any = msg.getField(1) as Any;
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

      final bi = msg.getField(1) as BigIntMsg;
      expect(bi.getField(2), false); // negative
      final expectedAbs = BigInt.parse('123456789012345678901234567890');
      BigInt bytesToBigInt(List<int> bytes) {
        if (bytes.isEmpty) return BigInt.zero;
        var hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
        return BigInt.parse(hex, radix: 16);
      }
      expect(bytesToBigInt(bi.getField(1)), expectedAbs);

      final dec = msg.getField(2) as DecimalMsg;
      expect(dec.getField(3), true); // negative
      expect(dec.getField(2), 3); // scale
      final expectedUnscaled = BigInt.from(123450);
      expect(bytesToBigInt(dec.getField(1)), expectedUnscaled);

      final output = marshal(msg);
      expect(output, contains('myInt = 123456789012345678901234567890'));
      expect(output, contains('myDecimal = -123.450'));
    });
  });
}
