// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'package:test/test.dart';
import 'package:protowire/src/encoding/pxf/lexer.dart';
import 'package:protowire/src/encoding/pxf/token.dart';
import 'package:protowire/src/encoding/pxf/parser.dart';
import 'package:protowire/src/encoding/pxf/ast.dart';

import 'package:protobuf/protobuf.dart';
import 'package:protowire/src/encoding/pxf/decode.dart';
import 'package:protowire/src/encoding/pxf/encode.dart';

class TestMessage extends GeneratedMessage {
  static final BuilderInfo _i =
      BuilderInfo('TestMessage', package: const PackageName('test'))
        ..aOS(1, 'name')
        ..a<int>(2, 'age', PbFieldType.O3)
        ..pPS(3, 'roles')
        ..aOM<Config>(4, 'config', subBuilder: Config.create)
        ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;

  @override
  TestMessage createEmptyInstance() => TestMessage();

  @override
  TestMessage clone() => TestMessage()..mergeFromMessage(this);

  static TestMessage create() => TestMessage();
}

class Config extends GeneratedMessage {
  static final BuilderInfo _i =
      BuilderInfo('Config', package: const PackageName('test'))
        ..aOB(1, 'enabled')
        ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;

  @override
  Config createEmptyInstance() => Config();

  @override
  Config clone() => Config()..mergeFromMessage(this);

  static Config create() => Config();
}

void main() {
  group('PXF Lexer', () {
    test('lex basic types', () {
      final input = '''
        name = "Alice"
        age = 30
        weight = 65.5
        enabled = true
        created_at = 2024-01-15T10:30:00Z
        timeout = 30s
      ''';
      final lexer = Lexer(input);
      final tokens = <Token>[];
      while (true) {
        final tok = lexer.next();
        if (tok.kind == TokenKind.eof) break;
        if (tok.kind == TokenKind.newline) continue;
        tokens.add(tok);
      }

      expect(tokens[0].kind, TokenKind.ident);
      expect(tokens[0].value, 'name');
      expect(tokens[1].kind, TokenKind.equals);
      expect(tokens[2].kind, TokenKind.string);
      expect(tokens[2].value, 'Alice');

      expect(tokens[3].kind, TokenKind.ident);
      expect(tokens[3].value, 'age');
      expect(tokens[4].kind, TokenKind.equals);
      expect(tokens[5].kind, TokenKind.int);
      expect(tokens[5].value, '30');
    });
  });

  group('PXF Parser', () {
    test('parse basic document', () {
      final input = '''
        @type my.v1.User
        name = "Alice"
        roles = ["admin", "user"]
        config {
          enabled = true
        }
      ''';
      final doc = parse(input);
      expect(doc.typeUrl, 'my.v1.User');
      expect(doc.entries.length, 3);

      final nameEntry = doc.entries[0] as Assignment;
      expect(nameEntry.key, 'name');
      expect((nameEntry.value as StringVal).value, 'Alice');

      final rolesEntry = doc.entries[1] as Assignment;
      expect(rolesEntry.key, 'roles');
      expect((rolesEntry.value as ListVal).elements.length, 2);

      final configEntry = doc.entries[2] as Block;
      expect(configEntry.name, 'config');
      expect(configEntry.entries.length, 1);
    });
  });

  group('PXF Decoder', () {
    test('unmarshal basic message', () {
      final input = '''
        name = "Alice"
        age = 30
        roles = ["admin", "user"]
        config {
          enabled = true
        }
      ''';
      final msg = TestMessage();
      unmarshal(input, msg);

      expect(msg.getField(1), 'Alice');
      expect(msg.getField(2), 30);
      expect(msg.getField(3), ['admin', 'user']);

      final config = msg.getField(4) as Config;
      expect(config.getField(1), true);
    });
  });

  group('PXF Encoder', () {
    test('marshal basic message', () {
      final msg = TestMessage()
        ..setField(1, 'Alice')
        ..setField(2, 30);
      (msg.getField(3) as List<String>).addAll(<String>['admin', 'user']);
      final config = Config()..setField(1, true);
      msg.setField(4, config);

      final output = marshal(msg);
      expect(output, contains('name = "Alice"'));
      expect(output, contains('age = 30'));
      expect(output, contains('roles = [\n  "admin",\n  "user"\n]'));
      expect(output, contains('config {\n  enabled = true\n}'));
    });
  });
}
