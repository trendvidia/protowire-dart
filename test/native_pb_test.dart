// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'package:test/test.dart';
import 'package:protowire/src/encoding/pb/native.dart';

class User {
  @ProtoTag(1)
  String? name;

  @ProtoTag(2)
  int? age;

  @ProtoTag(3)
  double? weight;
}

void main() {
  group('Native Binary Encoding', () {
    test('marshal and unmarshal native class', () {
      final user = User()
        ..name = 'Alice'
        ..age = 30
        ..weight = 65.5;

      final data = marshalNative(user);

      final decoded = User();
      unmarshalNative(data, decoded);

      expect(decoded.name, 'Alice');
      expect(decoded.age, 30);
      expect(decoded.weight, 65.5);
    });
  });
}
