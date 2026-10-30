// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// Keyed repeated fields and quoted entry names (#10, protowire#116): the
// spec repo's testdata/keyed/ corpus, vendored verbatim under
// test/testdata/keyed/, plus the edge cases protowire-go's keyed_test.go
// pins. keyed.binpb and test/generated/keyed.pb.dart are built from the
// vendored keyed.proto:
//
//   protoc -I test/testdata/keyed -I proto --dart_out=<tmp> \
//     --descriptor_set_out=test/testdata/keyed/keyed.binpb --include_imports \
//     test/testdata/keyed/keyed.proto
import 'dart:io';

import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:protowire/src/encoding/pxf/ast.dart';
import 'package:protowire/src/encoding/pxf/keyed.dart';
import 'package:protowire/src/encoding/pxf/parser.dart';
import 'package:protowire/src/generated/proto/google/protobuf/descriptor.pb.dart'
    as pbd;
import 'package:protowire/src/generated/proto/pxf/annotations.pb.dart'
    as pxf_ann;
import 'package:test/test.dart';

import 'generated/keyed.pb.dart';

const fixtureDir = 'test/testdata/keyed';

/// Every `.pxf` in the corpus, by verdict. A fixture that lands in the
/// directory without a verdict here fails `corpus is fully classified`.
const roundtrips = ['roundtrip-keyed.pxf', 'roundtrip-quoted.pxf'];
const fmtPairs = ['fmt-unquote', 'fmt-anonymous-to-keyed'];
const rejects = {
  'err-duplicate-key.pxf': 'duplicate key "greeting" in keyed field "children"',
  'err-duplicate-key-spelling.pxf':
      'duplicate key "greeting" in keyed field "children"',
  'err-key-conflict.pxf':
      'key field "id" = "farewell" conflicts with entry name "greeting" in keyed field "children"',
  'err-empty-key.pxf':
      'empty entry name in keyed field "children": the empty string is not a valid key',
  'err-empty-key-anonymous.pxf':
      'explicit empty-string assignment to key field "id" of keyed field "children"',
  'err-quoted-name-unkeyed.pxf':
      'quoted entry name "a" is only valid inside a keyed repeated field\'s block',
};

final PxfAnnotations ann =
    PxfAnnotations.fromBytes(File('$fixtureDir/keyed.binpb').readAsBytesSync());

String read(String name) => File('$fixtureDir/$name').readAsStringSync();

/// The fixture without comment lines and the blank runs they leave: the
/// document an encoder reproduces (comments are documentation, not content).
String clean(String data) {
  var s = data
      .split('\n')
      .where((l) => !l.trimLeft().startsWith('#'))
      .join('\n')
      .trimRight();
  while (s.contains('\n\n\n')) {
    s = s.replaceAll('\n\n\n', '\n\n');
  }
  return '$s\n';
}

GeneratedMessage newOf(String doc) {
  final type = parse(doc).typeUrl;
  switch (type) {
    case 'keyed.v1.Node':
      return Node();
    case 'keyed.v1.Deployment':
      return Deployment();
    case 'keyed.v1.Doc':
      return Doc();
  }
  throw StateError('fixture names no known @type: $type');
}

GeneratedMessage decode(String doc) {
  final m = newOf(doc);
  unmarshal(doc, m, options: UnmarshalOptions(annotations: ann));
  return m;
}

Node node(String doc) {
  final m = Node();
  unmarshal(doc, m, options: UnmarshalOptions(annotations: ann));
  return m;
}

String encode(GeneratedMessage m) => marshal(m,
    options: MarshalOptions(
        annotations: ann, typeUrl: m.info_.qualifiedMessageName));

String fmt(String doc) => formatPxf(doc, annotations: ann);

Matcher pxfError(String needle) => throwsA(
    isA<PxfError>().having((e) => e.message, 'message', contains(needle)));

void main() {
  // The positive marker: a fixture is recorded only after its last
  // assertion passed, and the final test compares this with the directory.
  final ran = <String>{};

  group('accept fixtures', () {
    for (final name in roundtrips) {
      test(name, () {
        final data = read(name);
        final m = decode(data);
        expect(encode(m), clean(data), reason: 'decode -> encode');
        final full = newOf(data);
        unmarshalFull(data, full, options: UnmarshalOptions(annotations: ann));
        expect(full.writeToBuffer(), m.writeToBuffer());
        ran.add(name);
      });
    }

    test('roundtrip-keyed.pxf: entry name is the key, order is list order', () {
      final n = decode(read('roundtrip-keyed.pxf')) as Node;
      expect(n.children.map((c) => c.id), ['greeting', 'counter_row']);
      expect(n.children.map((c) => c.weight), [1, 2]);
    });

    test('roundtrip-quoted.pxf: keys come back unquoted in the message', () {
      final d = decode(read('roundtrip-quoted.pxf')) as Deployment;
      expect(d.regions.map((r) => r.name), ['us-east-1', 'eu-west-2']);
    });

    test('anonymous-equivalence.pxf', () {
      final data = read('anonymous-equivalence.pxf');
      final keyed = read('roundtrip-keyed.pxf');
      final m = decode(data);
      expect(m.writeToBuffer(), decode(keyed).writeToBuffer(),
          reason: 'the same message');
      expect(encode(m), clean(keyed), reason: 'encode picks the keyed form');
      expect(clean(fmt(data)), clean(keyed), reason: 'fmt canonicalizes');
      ran.add('anonymous-equivalence.pxf');
    });

    test('redundant-key-ok.pxf', () {
      final data = read('redundant-key-ok.pxf');
      final n = decode(data) as Node;
      expect(n.children.single.id, 'greeting');
      final out = fmt(data);
      expect(out, isNot(contains('id = "greeting"')));
      expect(out, contains('  greeting {\n'));
      expect(encode(n), isNot(contains('id = "greeting"')));
      ran.add('redundant-key-ok.pxf');
    });

    test('anonymous-duplicate-ok.pxf', () {
      final data = read('anonymous-duplicate-ok.pxf');
      final n = decode(data) as Node;
      expect(n.children.map((c) => c.id), ['dup', 'dup']);
      expect(encode(n), contains('children = [\n'));
      expect(fmt(data), contains('children = [\n'));
      ran.add('anonymous-duplicate-ok.pxf');
    });
  });

  group('fmt pairs', () {
    for (final pair in fmtPairs) {
      test(pair, () {
        final expected = read('$pair.expected.pxf');
        expect(fmt(read('$pair.pxf')), expected, reason: 'input -> expected');
        expect(fmt(expected), expected, reason: 'expected is a fixed point');
        expect(decode(read('$pair.pxf')).writeToBuffer(),
            decode(expected).writeToBuffer(),
            reason: 'formatting keeps the message');
        ran
          ..add('$pair.pxf')
          ..add('$pair.expected.pxf');
      });
    }
  });

  group('reject fixtures', () {
    rejects.forEach((name, needle) {
      test(name, () {
        final data = read(name);
        expect(parse(data).entries, isNotEmpty, reason: 'the grammar accepts');
        expect(() => decode(data), pxfError(needle));
        ran.add(name);
      });
    });
  });

  // Declared last: tests run in order, so `ran` is complete here.
  test('corpus is fully classified and every fixture ran', () {
    final onDisk = Directory(fixtureDir)
        .listSync()
        .map((e) => e.uri.pathSegments.last)
        .where((n) => n.endsWith('.pxf'))
        .toSet();
    expect(onDisk, hasLength(15));
    expect(ran, onDisk);
    // ignore: avoid_print
    print('keyed fixtures run: ${ran.length} of ${onDisk.length}');
  });

  group('decode', () {
    test('both spellings of the block and of an entry', () {
      final n = node('id = "root"\nchildren = {\n'
          '  greeting = { type = "Label" }\n  counter_row { type = "HBox" }\n}\n');
      expect(n.children.map((c) => c.id), ['greeting', 'counter_row']);
    });

    test('a non-block value on an entry is an error', () {
      expect(() => node('children { greeting = 42 }'),
          pxfError('must have a block value'));
    });

    test('bindings concatenate; duplicates are per block', () {
      final n = node('children {\n  a { type = "1" }\n}\n'
          'children {\n  a { type = "2" }\n}\nchildren = [ { id = "a" } ]\n');
      expect(n.children.map((c) => c.id), ['a', 'a', 'a']);
      expect(n.children.map((c) => c.type), ['1', '2', '']);
    });

    test('duplicates compare the denoted string, escapes included', () {
      expect(() => node(r'children { greeting { } "gre\x65ting" { } }'),
          pxfError('duplicate key "greeting"'));
    });

    test('a triple-quoted entry name is a string like any other', () {
      expect(node('children { """a b""" { } }').children.single.id, 'a b');
    });

    test('a dotted name is one opaque key', () {
      expect(
          node('children { user.name { } }').children.single.id, 'user.name');
    });

    test('keyword names take quotes; bare they are not names', () {
      expect(node('children { "true" { } }').children.single.id, 'true');
      expect(
          () => node('children { true { } }'), pxfError('expected entry name'));
      expect(
          () => node('children { 12 { } }'), pxfError('expected entry name'));
    });

    test('empty keys in the other positions', () {
      expect(() => node('children { "" = { } }'),
          pxfError('empty entry name in keyed field "children"'));
      expect(() => node('children { a { id = "" } }'),
          pxfError('explicit empty-string assignment to key field "id"'));
    });

    test('key checks reach only the immediate body', () {
      final n = node('children { a { children = [ { id = "x" } ] } }');
      expect(n.children.single.children.single.id, 'x');
      expect(() => node('children { a { children { "" { } } } }'),
          pxfError('empty entry name'));
    });

    test('nested keyed blocks round-trip', () {
      final n = node('id = "root"\nchildren {\n  outer {\n    type = "VBox"\n'
          '    children {\n      inner { type = "Label" }\n    }\n  }\n}\n');
      expect(n.children.single.children.single.id, 'inner');
      final out = marshal(n, options: MarshalOptions(annotations: ann));
      expect(out, isNot(contains('id = "outer"')));
      expect(out, isNot(contains('id = "inner"')));
      expect(out, contains('      inner {\n'));
    });

    test('the nesting limit covers keyed blocks', () {
      final deep = StringBuffer();
      for (var i = 0; i < 60; i++) {
        deep.write('children { a$i { ');
      }
      expect(() => node(deep.toString()), pxfError('MaxNestingDepth'));
    });

    test('presence: the field, and elements at their own paths', () {
      final doc = 'children { a { type = "x" } b { type = null } }\n';
      final r = unmarshalFull(doc, Node(),
          options: UnmarshalOptions(annotations: ann));
      expect(r.isSet('children'), isTrue);
      expect(r.isSet('children[0].type'), isTrue);
      expect(r.isNull('children[1].type'), isTrue);
      expect(r.isAbsent('type'), isTrue, reason: 'not the root field');
    });

    test('the anonymous form reports the same paths', () {
      final r = unmarshalFull('children = [ { id = "a" type = "x" } ]', Node(),
          options: UnmarshalOptions(annotations: ann));
      expect(r.isSet('children[0].type'), isTrue);
      expect(r.isAbsent('type'), isTrue);
    });

    test('with no annotations nothing is keyed, and quoted names still fail',
        () {
      expect(() => unmarshal('children { greeting { } }', Node()),
          pxfError('unknown field "greeting"'));
      expect(() => unmarshal('"id" = "x"', Node()),
          pxfError('quoted entry name "id"'));
      expect(() => unmarshal('"children" { }', Node()),
          pxfError('quoted entry name "children"'));
    });

    test('a quoted name is rejected before unknown fields are discarded', () {
      expect(
          () => unmarshal('"nope" = 1', Node(),
              options: UnmarshalOptions(discardUnknown: true)),
          pxfError('quoted entry name "nope"'));
    });

    test('an unkeyed block keeps working', () {
      final d = Doc();
      unmarshal('items { id = "a" label = "b" }', d,
          options: UnmarshalOptions(annotations: ann));
      expect(d.items.single.label, 'b');
    });
  });

  group('encode', () {
    test('falls back to the list on an absent, empty or duplicate key', () {
      String out(Node n) =>
          marshal(n, options: MarshalOptions(annotations: ann));
      final dup = Node()..children.addAll([Node()..id = 'd', Node()..id = 'd']);
      expect(out(dup), contains('children = [\n'));
      final absent = Node()..children.add(Node()..type = 'x');
      expect(out(absent), contains('children = [\n'));
      final mixed = Node()
        ..children.addAll([Node()..id = 'a', Node()..type = 'x']);
      expect(out(mixed), contains('children = [\n'));
    });

    test('quotes exactly what is not identifier-safe', () {
      final n = Node()
        ..children.addAll([
          for (final k in ['a.b', 'true', 'null', '1a', 'a-b', 'a"b'])
            Node()..id = k
        ]);
      final out = marshal(n, options: MarshalOptions(annotations: ann));
      expect(out, contains('  a.b {\n'));
      for (final q in [r'"true"', r'"null"', r'"1a"', r'"a-b"', r'"a\"b"']) {
        expect(out, contains('  $q {\n'));
      }
      expect(node(out).writeToBuffer(), n.writeToBuffer());
    });

    test('with no annotations the list form is emitted', () {
      final n = Node()..children.add(Node()..id = 'a');
      expect(marshal(n), contains('children = [\n'));
    });

    test('the wire is untouched: keyed text and list text are one message', () {
      final viaList = Node()
        ..children.add(Node()
          ..id = 'a'
          ..weight = 2);
      expect(node('children { a { weight = 2 } }').writeToBuffer(),
          viaList.writeToBuffer());
    });
  });

  group('parser', () {
    test('keeps the unquoted value and whether it was quoted', () {
      final doc = parse('"a b" = 1\nc = 2\n"d" { }\ne { }\n"f": 1\n');
      final a = doc.entries[0] as Assignment;
      expect((a.key, a.keyQuoted), ('a b', true));
      final c = doc.entries[1] as Assignment;
      expect((c.key, c.keyQuoted), ('c', false));
      final d = doc.entries[2] as Block;
      expect((d.name, d.nameQuoted), ('d', true));
      final e = doc.entries[3] as Block;
      expect((e.name, e.nameQuoted), ('e', false));
      final f = doc.entries[4] as MapEntry;
      expect((f.key, f.keyQuoted), ('f', true));
    });
  });

  group('fmt', () {
    test('without a schema a quoted name is left as written', () {
      const doc = '"greeting" {\n  a = 1\n}\n';
      expect(formatPxf(doc), doc);
    });

    test('a quoted name on an unkeyed field stays quoted', () {
      const doc =
          '@type keyed.v1.Doc\n\nitems {\n  "a" {\n    id = "a"\n  }\n}\n';
      expect(fmt(doc), doc);
    });

    test('assignment spellings normalize', () {
      expect(
          formatPxf('children = {\n  greeting = { type = "Label" }\n}\n',
              annotations: ann, messageName: 'keyed.v1.Node'),
          'children {\n  greeting {\n    type = "Label"\n  }\n}\n');
    });

    test('a disagreeing key is kept: the document stays invalid', () {
      const doc = '@type keyed.v1.Node\n\n'
          'children {\n  greeting {\n    id = "farewell"\n  }\n}\n';
      expect(fmt(doc), doc);
    });

    test('nested anonymous bindings canonicalize, inside a kept list too', () {
      const doc = '@type keyed.v1.Node\n\nchildren = [\n  {\n    id = "d"\n'
          '    children = [\n      {\n        id = "x"\n      }\n    ]\n  },\n'
          '  {\n    id = "d"\n  }\n]\n';
      final out = fmt(doc);
      expect(out, contains('children = [\n'), reason: 'outer has duplicates');
      expect(out, contains('    children {\n      x {\n      }\n    }\n'));
    });

    test('a key that is not a plain string stays anonymous', () {
      const doc =
          '@type keyed.v1.Node\n\nchildren = [\n  {\n    type = "x"\n  }\n]\n';
      expect(fmt(doc), doc);
    });

    test('comments survive canonicalization', () {
      const doc = '@type keyed.v1.Node\n\n'
          'children = [ # list\n'
          '  {\n'
          '    # about the key\n'
          '    id = "a" # trailing\n'
          '    # about type\n'
          '    type = "x"\n'
          '  }\n'
          ']\n'
          '# the end\n';
      final out = fmt(doc);
      for (final c in [
        '# list',
        '# about the key',
        '# trailing',
        '# about type',
        '# the end'
      ]) {
        expect(out, contains(c));
      }
      expect(fmt(out), out, reason: 'a fixed point');
    });

    test('a comment on the only entry of a block survives its removal', () {
      const doc = 'children {\n  a {\n    # why\n    id = "a"\n  }\n}\n';
      final out =
          formatPxf(doc, annotations: ann, messageName: 'keyed.v1.Node');
      expect(out, contains('# why'));
      expect(out, isNot(contains('id = "a"')));
    });

    test('values, trailing comments and map entries print', () {
      const doc = 'a = "x\\n" # one\nb = [\n  1,\n  2\n]\nc = {\n  k: 1\n'
          '  "l m": 2\n  "n": 3\n}\nd = b"AQ=="\ne = null\nf = true\ng = 1.5\n'
          'h = 2024-01-02T03:04:05Z\ni = 5s\nj = NAME\n';
      expect(formatPxf(doc), doc.replaceFirst('"n": 3', 'n: 3'));
    });

    test('refuses what it would otherwise drop', () {
      expect(() => formatPxf('@header x { a = 1 }\nb = 1\n'),
          pxfError('directives'));
      expect(() => formatPxf('a = 1\n', annotations: ann),
          pxfError('no messageName'));
      expect(() => formatPxf('@type no.Such\n\na = 1\n', annotations: ann),
          pxfError('not in the descriptor set'));
    });

    test('identifier safety matches the entry-name rule', () {
      for (final s in ['a', '_a', 'a.b', 'a1', 'A_b.c']) {
        expect(isIdentSafeEntryName(s), isTrue, reason: s);
      }
      for (final s in ['', 'true', 'false', 'null', '1a', '.a', 'a-b', 'é']) {
        expect(isIdentSafeEntryName(s), isFalse, reason: s);
      }
    });
  });

  group('(pxf.key) placement', () {
    const str = pbd.FieldDescriptorProto_Type.TYPE_STRING;
    const msg = pbd.FieldDescriptorProto_Type.TYPE_MESSAGE;
    const rep = pbd.FieldDescriptorProto_Label.LABEL_REPEATED;
    const opt = pbd.FieldDescriptorProto_Label.LABEL_OPTIONAL;

    pbd.FieldDescriptorProto f(
        String name,
        int number,
        pbd.FieldDescriptorProto_Type type,
        pbd.FieldDescriptorProto_Label label,
        {String? typeName,
        String? key}) {
      final fd = pbd.FieldDescriptorProto()
        ..name = name
        ..number = number
        ..type = type
        ..label = label;
      if (typeName != null) fd.typeName = '.$typeName';
      if (key != null) {
        fd.options = pbd.FieldOptions()
          ..setExtension(pxf_ann.Annotations.key, key);
      }
      return fd;
    }

    PxfAnnotations bind(pbd.FieldDescriptorProto field) {
      final entry = pbd.DescriptorProto()
        ..name = 'MEntry'
        ..field.addAll([
          f('key', 1, str, opt),
          f('value', 2, msg, opt, typeName: 'p.v1.E'),
        ])
        ..options = (pbd.MessageOptions()..mapEntry = true);
      final elem = pbd.DescriptorProto()
        ..name = 'E'
        ..field.addAll([
          f('id', 1, str, opt),
          f('n', 2, pbd.FieldDescriptorProto_Type.TYPE_INT32, opt),
          f('tags', 3, str, rep),
        ]);
      final holder = pbd.DescriptorProto()
        ..name = 'H'
        ..field.add(field)
        ..nestedType.add(entry);
      final file = pbd.FileDescriptorProto()
        ..name = 'p.proto'
        ..package = 'p.v1'
        ..messageType.addAll([holder, elem]);
      return PxfAnnotations.fromDescriptorSet(
          pbd.FileDescriptorSet()..file.add(file));
    }

    test('a well-placed key binds', () {
      final a = bind(f('f', 1, msg, rep, typeName: 'p.v1.E', key: 'id'));
      expect(a.keyFieldName('p.v1.H', 'f'), 'id');
    });

    const onlyRepeated = 'valid only on repeated message-typed fields';
    final cases = {
      'scalar': (f('f', 1, str, opt, key: 'id'), onlyRepeated),
      'repeated scalar': (f('f', 1, str, rep, key: 'id'), onlyRepeated),
      'singular message': (
        f('f', 1, msg, opt, typeName: 'p.v1.E', key: 'id'),
        onlyRepeated
      ),
      'map': (
        f('f', 1, msg, rep, typeName: 'p.v1.H.MEntry', key: 'id'),
        onlyRepeated
      ),
      'unknown key field': (
        f('f', 1, msg, rep, typeName: 'p.v1.E', key: 'nope'),
        'element message p.v1.E has no field "nope"'
      ),
      'empty annotation': (
        f('f', 1, msg, rep, typeName: 'p.v1.E', key: ''),
        'has no field ""'
      ),
      'non-string key': (
        f('f', 1, msg, rep, typeName: 'p.v1.E', key: 'n'),
        'key field p.v1.E.n must be a singular string field'
      ),
      'repeated key': (
        f('f', 1, msg, rep, typeName: 'p.v1.E', key: 'tags'),
        'key field p.v1.E.tags must be a singular string field'
      ),
      'element outside the set': (
        f('f', 1, msg, rep, typeName: 'other.Elem', key: 'id'),
        'element message other.Elem is not in the descriptor set'
      ),
    };
    cases.forEach((name, c) {
      test(name, () {
        expect(() => bind(c.$1), pxfError(c.$2));
        expect(() => bind(c.$1), pxfError('p.proto: field "p.v1.H.f"'));
      });
    });

    test('the fixture schema binds, with the import closure in the set', () {
      expect(ann.keyFieldName('keyed.v1.Node', 'children'), 'id');
      expect(ann.keyFieldName('keyed.v1.Deployment', 'regions'), 'name');
      expect(ann.keyFieldName('keyed.v1.Doc', 'items'), isNull);
    });
  });
}
