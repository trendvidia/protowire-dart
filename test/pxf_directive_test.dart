// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// Parser-tier tests for the v1.0 directive grammar:
//   - `@<name> *(<prefix>) [{ ... }]`     (draft §3.4.2)
//   - `@entry  *(<prefix>) [{ ... }]`     (draft §3.4.3)
//   - `@dataset  <type> ( cols ) row*`    (draft §3.4.4)
//   - `@proto <body>` (4 shapes)          (draft §3.4.5)
//
// Mirrors the Go reference's directive_test.go + directive_proto_test.go
// and the Rust port's tests/directive.rs.
import 'dart:convert';
import 'package:test/test.dart';
import 'package:protowire/src/encoding/pxf/parser.dart';
import 'package:protowire/src/encoding/pxf/ast.dart';
import 'package:protowire/src/encoding/pxf/errors.dart';
import 'package:protowire/src/encoding/pxf/schema.dart';

void main() {
  group('Generic @<name> directive', () {
    test('bare directive: no prefix, no body', () {
      final doc = parse('@frob\nname = "x"\n');
      expect(doc.directives, hasLength(1));
      final d = doc.directives[0];
      expect(d.name, equals('frob'));
      expect(d.prefixes, isEmpty);
      expect(d.hasBody, isFalse);
      expect(d.type, equals(''));
      expect(doc.entries, hasLength(1));
    });

    test('single prefix populates legacy type', () {
      final doc = parse(
          '@header chameleon.v1.LayerHeader { id = "x" }\nbody = "z"\n');
      final d = doc.directives[0];
      expect(d.name, equals('header'));
      expect(d.prefixes, equals(['chameleon.v1.LayerHeader']));
      expect(d.type, equals('chameleon.v1.LayerHeader'));
      expect(d.hasBody, isTrue);
      final body = utf8.decode(d.body!);
      expect(body, contains('id = "x"'));
    });

    test('two prefixes leave type empty', () {
      final doc =
          parse('@entry mylabel pkg.MsgType { x = 1 }\nname = "z"\n');
      final d = doc.directives[0];
      expect(d.prefixes, equals(['mylabel', 'pkg.MsgType']));
      expect(d.type, equals(''));
    });

    test('prefix lookahead stops at body key', () {
      final doc = parse('@foo BarType\nbody_key = "x"\n');
      final d = doc.directives[0];
      expect(d.prefixes, equals(['BarType']));
      expect(doc.entries, hasLength(1));
    });

    test('multiple directives in source order', () {
      const src = '@type some.MsgType\n'
          '@header pkg.Header { id = "h1" }\n'
          '@frob alpha beta\n'
          'name = "z"\n';
      final doc = parse(src);
      expect(doc.typeUrl, equals('some.MsgType'));
      expect(doc.directives.map((d) => d.name).toList(),
          equals(['header', 'frob']));
      expect(doc.directives[1].prefixes, equals(['alpha', 'beta']));
      expect(doc.bodyOffset, greaterThan(0));
    });

    test('block body preserves raw bytes', () {
      final doc = parse('@hdr T { a = 1\n b = "x" }\nrest = 0\n');
      final d = doc.directives[0];
      expect(d.hasBody, isTrue);
      final body = utf8.decode(d.body!);
      expect(body, contains('a = 1'));
      expect(body, contains('b = "x"'));
      expect(body, isNot(contains('}')));
    });

    test('nested braces in body', () {
      final doc = parse('@nested T { inner { a = 1 } }\n');
      final body = utf8.decode(doc.directives[0].body!);
      expect(body, contains('inner { a = 1 }'));
    });

    test('braces inside strings not counted', () {
      final doc = parse('@s T { a = "}{" }\n');
      expect(doc.directives[0].hasBody, isTrue);
    });

    test('line comment inside body', () {
      final doc =
          parse('@h T { a = 1 # trailing } comment\n  b = 2\n}\n');
      expect(doc.directives[0].hasBody, isTrue);
    });

    test('block comment inside body', () {
      final doc = parse('@h T { a = 1 /* not a } close */ b = 2 }\n');
      expect(doc.directives[0].hasBody, isTrue);
    });

    test('@type without ident rejected', () {
      expect(() => parse('@type =\n'),
          throwsA(predicate((e) =>
              e is PxfError && e.toString().contains('expected type name'))));
    });

    test('bare @ is illegal', () {
      expect(() => parse('@\n'), throwsA(isA<PxfError>()));
    });
  });

  group('Future-reserved directive names (draft §3.4.6)', () {
    for (final name in [
      'table',
      'datasource',
      'view',
      'procedure',
      'function',
      'permissions'
    ]) {
      test('@$name rejected', () {
        expect(
          () => parse('@$name foo\nx = 1\n'),
          throwsA(predicate((e) =>
              e is PxfError &&
              e.toString().contains('spec-reserved') &&
              e.toString().contains('@$name'))),
        );
      });
    }

    test('isFutureReservedDirective lookup table', () {
      expect(isFutureReservedDirective('table'), isTrue);
      expect(isFutureReservedDirective('permissions'), isTrue);
      expect(isFutureReservedDirective('header'), isFalse);
      expect(isFutureReservedDirective('entry'), isFalse);
      expect(isFutureReservedDirective('dataset'), isFalse);
      expect(isFutureReservedDirective('proto'), isFalse);
      expect(isFutureReservedDirective('type'), isFalse);
    });
  });

  group('@dataset directive', () {
    test('basic two columns two rows', () {
      const src =
          '@dataset trades.v1.Trade ( px, qty )\n( 100, 5 )\n( 101, 7 )\n';
      final doc = parse(src);
      expect(doc.datasets, hasLength(1));
      final t = doc.datasets[0];
      expect(t.type, equals('trades.v1.Trade'));
      expect(t.columns, equals(['px', 'qty']));
      expect(t.rows, hasLength(2));
      expect(t.rows[0].cells, hasLength(2));
    });

    test('empty cell means absent', () {
      final doc = parse('@dataset x.Row ( a, b, c )\n( 1, , 3 )\n');
      final row = doc.datasets[0].rows[0];
      expect(row.cells[0], isNotNull);
      expect(row.cells[1], isNull);
      expect(row.cells[2], isNotNull);
    });

    test('null cell means present null', () {
      final doc = parse('@dataset x.Row ( a, b )\n( 1, null )\n');
      final row = doc.datasets[0].rows[0];
      expect(row.cells[1], isA<NullVal>());
    });

    test('zero rows valid', () {
      final doc = parse('@dataset x.Row ( a, b )\n');
      expect(doc.datasets, hasLength(1));
      expect(doc.datasets[0].rows, isEmpty);
    });

    test('arity mismatch rejected', () {
      expect(
        () => parse('@dataset x.Row ( a, b )\n( 1, 2, 3 )\n'),
        throwsA(predicate((e) =>
            e is PxfError && e.toString().contains('3 cells, expected 2'))),
      );
    });

    test('dotted column rejected', () {
      expect(
        () => parse('@dataset x.Row ( a.b )\n'),
        throwsA(predicate((e) =>
            e is PxfError && e.toString().contains('dotted column'))),
      );
    });

    test('list cell rejected', () {
      expect(
        () => parse('@dataset x.Row ( a )\n( [1, 2] )\n'),
        throwsA(predicate(
            (e) => e is PxfError && e.toString().contains('list values'))),
      );
    });

    test('block cell rejected', () {
      expect(
        () => parse('@dataset x.Row ( a )\n( { x = 1 } )\n'),
        throwsA(predicate(
            (e) => e is PxfError && e.toString().contains('block values'))),
      );
    });

    test('standalone rejects coexisting @type before', () {
      expect(
        () => parse('@type other\n@dataset x.Row ( a )\n( 1 )\n'),
        throwsA(predicate((e) =>
            e is PxfError && e.toString().contains('cannot coexist with @type'))),
      );
    });

    test('standalone rejects @type after dataset', () {
      expect(
        () => parse('@dataset x.Row ( a )\n@type other\n'),
        throwsA(predicate((e) =>
            e is PxfError && e.toString().contains('cannot coexist with @type'))),
      );
    });

    test('standalone rejects coexisting body entries', () {
      expect(
        () => parse('@dataset x.Row ( a )\n( 1 )\nextra = 5\n'),
        throwsA(predicate((e) =>
            e is PxfError &&
            e.toString().contains('cannot coexist with top-level field entries'))),
      );
    });

    test('missing type is permissive', () {
      // Type optional in v1 — binds to preceding anonymous @proto.
      final doc = parse('@dataset ( a )\n');
      expect(doc.datasets, hasLength(1));
      expect(doc.datasets[0].type, equals(''));
    });

    test('missing lparen rejected', () {
      expect(
        () => parse('@dataset x.Row a, b\n'),
        throwsA(predicate((e) =>
            e is PxfError && e.toString().contains('expected "(" to start'))),
      );
    });

    test('empty column list rejected', () {
      expect(
        () => parse('@dataset x.Row ( )\n'),
        throwsA(predicate((e) =>
            e is PxfError && e.toString().contains('at least one field name'))),
      );
    });

    test('bad column token rejected', () {
      expect(
        () => parse('@dataset x.Row ( a, 123 )\n'),
        throwsA(predicate((e) =>
            e is PxfError && e.toString().contains('expected column field name'))),
      );
    });

    test('missing comma in columns rejected', () {
      expect(
        () => parse('@dataset x.Row ( a b )\n'),
        throwsA(predicate((e) =>
            e is PxfError &&
            e.toString().contains('expected "," or ")" in @dataset column list'))),
      );
    });

    test('missing comma in row rejected', () {
      expect(
        () => parse('@dataset x.Row ( a, b )\n( 1 2 )\n'),
        throwsA(predicate((e) =>
            e is PxfError &&
            e.toString().contains('expected "," or ")" in @dataset row'))),
      );
    });
  });

  group('@proto directive', () {
    test('anonymous captures raw bytes', () {
      final doc =
          parse('@proto { int32 id = 1; string name = 2; }\n');
      expect(doc.protos, hasLength(1));
      final p = doc.protos[0];
      expect(p.shape, equals(ProtoShape.anonymous));
      expect(p.typeName, equals(''));
      final body = utf8.decode(p.body);
      expect(body, contains('int32 id = 1;'));
      expect(body, contains('string name = 2;'));
    });

    test('named captures raw bytes', () {
      final doc = parse(
          '@proto trades.v1.Trade { double px = 1; int64 qty = 2; }\n');
      final p = doc.protos[0];
      expect(p.shape, equals(ProtoShape.named));
      expect(p.typeName, equals('trades.v1.Trade'));
      final body = utf8.decode(p.body);
      expect(body, contains('double px = 1;'));
    });

    test('source triple-quoted', () {
      const src =
          '@proto """\n  syntax = "proto3";\n  message M { int32 id = 1; }\n  """\n';
      final doc = parse(src);
      final p = doc.protos[0];
      expect(p.shape, equals(ProtoShape.source));
      final body = utf8.decode(p.body);
      expect(body, contains('syntax = "proto3";'));
    });

    test('descriptor base64', () {
      final raw = [0x0a, 0x05, 0x68, 0x65, 0x6c, 0x6c, 0x6f];
      final b64 = base64.encode(raw);
      final doc = parse('@proto b"$b64"\n');
      final p = doc.protos[0];
      expect(p.shape, equals(ProtoShape.descriptor));
      expect(p.body, equals(raw));
    });

    test('named without brace rejected', () {
      expect(
        () => parse('@proto trades.v1.Trade\n'),
        throwsA(predicate(
            (e) => e is PxfError && e.toString().contains('expected "{"'))),
      );
    });

    test('bad shape rejected', () {
      expect(
        () => parse('@proto =\n'),
        throwsA(predicate((e) =>
            e is PxfError &&
            e.toString().contains('expected "{", dotted identifier'))),
      );
    });

    test('anonymous before dataset', () {
      const src = '@proto { int32 id = 1; }\n'
          '@dataset ( id )\n'
          '( 7 )\n';
      final doc = parse(src);
      expect(doc.protos, hasLength(1));
      expect(doc.protos[0].shape, equals(ProtoShape.anonymous));
      expect(doc.datasets, hasLength(1));
      expect(doc.datasets[0].type, equals(''));
      expect(doc.datasets[0].rows, hasLength(1));
    });

    test('ProtoShape displayName round-trip', () {
      expect(ProtoShape.anonymous.displayName, equals('anonymous'));
      expect(ProtoShape.named.displayName, equals('named'));
      expect(ProtoShape.source.displayName, equals('source'));
      expect(ProtoShape.descriptor.displayName, equals('descriptor'));
    });
  });
}
