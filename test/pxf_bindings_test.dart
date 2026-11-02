// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// What one message body may bind: the spec repo's testdata/duplicates/,
// repeated/, any/ and map-keys/ corpora, vendored verbatim under
// test/testdata/, plus the decoder gaps of #38. The generated classes come
// from the vendored schemas:
//
//   protoc -I test/testdata/<dir> -I proto --dart_out=test/generated <schema>
//
// bool-keys.pb.dart is renamed bool_keys.pb.dart.
import 'dart:io';

import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:protowire/src/encoding/pxf/parser.dart';
import 'package:test/test.dart';

import 'generated/any.pb.dart' as anypb;
import 'generated/bool_keys.pb.dart';
import 'generated/duplicates.pb.dart';
import 'generated/test.pb.dart' as testpb;

String read(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

/// Every `.pxf` directly under [dir], or fails if there are none: an empty
/// loop would pass every test below.
List<String> corpus(String dir) {
  final names = Directory(dir)
      .listSync()
      .map((e) => e.path.split(Platform.pathSeparator).last)
      .where((n) => n.endsWith('.pxf'))
      .toList()
    ..sort();
  if (names.isEmpty) throw StateError('no fixtures in $dir');
  return names;
}

Matcher pxfError(String text) => throwsA(
    isA<PxfError>().having((e) => e.toString(), 'message', contains(text)));

void main() {
  group('testdata/duplicates', () {
    const dir = 'test/testdata/duplicates';
    final names = corpus(dir);

    test('has the corpus size the spec states', () {
      expect(names.where((n) => n.startsWith('err-')), hasLength(15));
      expect(names.where((n) => !n.startsWith('err-')), hasLength(4));
    });

    for (final name in names) {
      test(name, () {
        final doc = read('$dir/$name');
        expect(() => parse(doc), returnsNormally,
            reason: 'a second binding is legal syntax');
        if (name.startsWith('err-')) {
          expect(() => unmarshal(doc, Holder()), throwsA(isA<PxfError>()));
        } else {
          unmarshal(doc, Holder());
        }
      });
    }

    test('map-twice-distinct-keys merges', () {
      final h = Holder();
      unmarshal(read('$dir/map-twice-distinct-keys.pxf'), h);
      expect(h.labels.length, greaterThan(1));
    });

    test('keys compare as values of the key type', () {
      expect(() => unmarshal('nums = { 1: "x" "1": "y" }', Holder()),
          pxfError('map field "nums": key 1 is already set'));
    });

    test('a key the caller set before decoding is not a second binding', () {
      final h = Holder()..labels['a'] = 'old';
      unmarshal('labels = { a: "new" }', h);
      expect(h.labels['a'], 'new');
    });

    test('names the field', () {
      expect(() => unmarshal('s = "a"\ns = "a"', Holder()),
          pxfError('field "s" is already set'));
    });
  });

  group('testdata/repeated', () {
    const dir = 'test/testdata/repeated';

    test('concat-lists.pxf concatenates', () {
      final m = testpb.AllTypes();
      unmarshal(read('$dir/concat-lists.pxf'), m);
      expect(m.repeatedString, ['a', 'b', 'c']);
      expect(m.repeatedNested.map((n) => n.name), ['n1', 'n2']);
    });

    for (final name in corpus(dir).where((n) => n.startsWith('err-'))) {
      test(name, () {
        expect(() => unmarshal(read('$dir/$name'), testpb.AllTypes()),
            throwsA(isA<PxfError>()));
      });
    }
  });

  group('testdata/any', () {
    const dir = 'test/testdata/any';
    final registry = TypeRegistry([anypb.Leaf()]);
    anypb.Holder decode(String name) {
      final h = anypb.Holder();
      unmarshal(read('$dir/$name'), h,
          options: UnmarshalOptions(typeRegistry: registry));
      return h;
    }

    // The fixture README's table: does the schema-less parse accept it?
    const rejects = {
      'err-not-first.pxf': false,
      'err-twice.pxf': false,
      'err-not-any.pxf': true,
      'err-unresolved.pxf': true,
      'err-unquoted-url.pxf': false,
    };

    test('corpus is fully classified', () {
      final names = corpus(dir);
      expect(names, hasLength(11));
      expect(names.where((n) => n.startsWith('err-')).toSet(),
          rejects.keys.toSet());
    });

    rejects.forEach((name, parses) {
      test(name, () {
        final doc = read('$dir/$name');
        if (parses) {
          expect(() => parse(doc), returnsNormally);
        } else {
          expect(() => parse(doc), throwsA(isA<PxfError>()));
        }
        expect(() => decode(name), throwsA(isA<PxfError>()));
      });
    });

    anypb.Leaf leaf(dynamic any) =>
        anypb.Leaf.fromBuffer((any.value as List<int>));

    test('block.pxf and assignment.pxf pack the body', () {
      final h = decode('block.pxf');
      expect(h.payload.typeUrl, endsWith('any.v1.Leaf'));
      expect(leaf(h.payload).tag, 't');
      expect(leaf(h.payload).n, 7);
      final assigned = decode('assignment.pxf');
      expect(assigned.payload.typeUrl, endsWith('any.v1.Leaf'));
      expect(leaf(assigned.payload).tag, isNotEmpty);
    });

    test('url-verbatim.pxf keeps the prefix', () {
      expect(decode('url-verbatim.pxf').payload.typeUrl,
          startsWith('type.googleapis.com/'));
    });

    test('list-element.pxf', () {
      final h = decode('list-element.pxf');
      expect(h.anys, isNotEmpty);
      for (final a in h.anys) {
        expect(a.typeUrl, endsWith('any.v1.Leaf'));
      }
    });

    test('map-value.pxf', () {
      final h = decode('map-value.pxf');
      expect(h.byKey, isNotEmpty);
      for (final a in h.byKey.values) {
        expect(a.typeUrl, endsWith('any.v1.Leaf'));
      }
    });

    test('plain-fields.pxf is the Any\'s own fields', () {
      expect(decode('plain-fields.pxf').payload.typeUrl, isNotEmpty);
    });

    test('the formatter keeps a type entry', () {
      final out = formatPxf('payload {\n  @type = "x.Y"\n  a = 1\n}\n');
      expect(out, 'payload {\n  @type = "x.Y"\n  a = 1\n}\n');
    });
  });

  group('testdata/map-keys', () {
    const dir = 'test/testdata/map-keys';

    GeneratedMessage message(String doc) =>
        doc.contains('mapkeys.v1.Labels') ? Labels() : Flags();

    for (final name in corpus(dir).where((n) => !n.endsWith('.expected.pxf'))) {
      test('binds $name', () {
        final doc = read('$dir/$name');
        expect(() => parse(doc), returnsNormally);
        unmarshal(doc, message(doc));
      });
    }

    for (final name in [
      'bool-keys',
      'bool-keys-integer',
      'bool-keys-keyword'
    ]) {
      test('$name.pxf has both keys', () {
        final f = Flags();
        unmarshal(read('$dir/$name.pxf'), f);
        expect(f.byFlag.keys.toSet(), {true, false});
      });
    }

    for (final pair in [
      'fmt-bare-keys',
      'fmt-dotted-keys',
      'fmt-keyword-keys'
    ]) {
      test('formats $pair', () {
        expect(
            formatPxf(read('$dir/$pair.pxf')), read('$dir/$pair.expected.pxf'));
      });
    }

    final invalid = corpus('$dir/invalid');
    test('has the invalid corpus', () => expect(invalid, hasLength(13)));
    for (final name in invalid) {
      test('rejects invalid/$name', () {
        final doc = read('$dir/invalid/$name');
        expect(() => unmarshal(doc, Flags()), pxfError('map key'));
      });
    }

    test('a bool or integer key takes ":", not "=" or "{"', () {
      expect(() => parse('true = 1'), pxfError('use ":" for map entries'));
      expect(() => parse('1 { }'), pxfError('submessage block requires'));
      expect(() => unmarshal('true = 1', Flags()),
          pxfError('use ":" for map entries'));
    });
  });

  group('decoder gaps of #38', () {
    test('a block on a scalar is an error, not a crash', () {
      expect(() => unmarshal('s { }', Holder()),
          pxfError('field "s" is not a message type'));
    });

    test('a block on a map is an error, not a crash', () {
      expect(() => unmarshal('labels { a: "1" }', Holder()),
          pxfError('map field "labels" must use assignment syntax'));
    });

    test('a list element records its fields on its own path', () {
      final r = unmarshalFull('items = [ { a = 1 } { b = 2 } ]', Holder());
      expect(r.isSet('items[0].a'), isTrue);
      expect(r.isSet('items[1].b'), isTrue);
      expect(r.isSet('a'), isFalse);
      expect(r.isSet('items.a'), isFalse);
    });

    test('a map value records its fields on its own path', () {
      final r = unmarshalFull('inners = { k: { a = 1 } }', Holder());
      expect(r.isSet('inners["k"].a'), isTrue);
      expect(r.isSet('a'), isFalse);
    });
  });
}
