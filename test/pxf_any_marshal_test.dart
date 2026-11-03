// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// marshal's half of draft -01 "Any Blocks", over the spec's testdata/any
// corpus. The expected documents are protowire-go's output for the same
// messages, measured at e22cf55.
import 'dart:convert';
import 'dart:io';

import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as wkt;
import 'package:protowire/protowire.dart';
import 'package:test/test.dart';

import 'generated/any.pb.dart' as anypb;

final registry = TypeRegistry([anypb.Leaf(), anypb.Holder()]);

anypb.Holder decode(String doc) {
  final h = anypb.Holder();
  unmarshal(doc, h, options: UnmarshalOptions(typeRegistry: registry));
  return h;
}

String write(GeneratedMessage m) =>
    marshal(m, options: MarshalOptions(typeRegistry: registry));

/// [value] under [url], as a Holder's payload.
anypb.Holder holding(String url, List<int> value) => anypb.Holder()
  ..payload = (wkt.Any()
    ..typeUrl = url
    ..value = value);

void expectRoundTrip(anypb.Holder m) {
  final back = decode(write(m));
  expect(back.writeToBuffer(), m.writeToBuffer());
}

void main() {
  group('with the type in the registry', () {
    const dir = 'test/testdata/any';
    String fixture(String n) =>
        File('$dir/$n.pxf').readAsStringSync().replaceAll('\r\n', '\n');

    const reference = {
      'block': 'payload {\n  @type = "any.v1.Leaf"\n  tag = "t"\n  n = 7\n}\n',
      'assignment': 'payload {\n  @type = "any.v1.Leaf"\n  tag = "t"\n}\n',
      'url-verbatim':
          'payload {\n  @type = "type.googleapis.com/any.v1.Leaf"\n  tag = "t"\n}\n',
      'plain-fields': 'payload {\n  @type = "any.v1.Leaf"\n  tag = "t"\n}\n',
      'list-element': 'anys = [\n  {\n    type_url = "any.v1.Leaf"\n'
          '    value = b"CgFh"\n  },\n  {\n    type_url = "any.v1.Leaf"\n'
          '    value = b"EAI="\n  }\n]\n',
      'map-value': 'by_key = {\n  k: {\n    type_url = "any.v1.Leaf"\n'
          '    value = b"CgF0"\n  }\n}\n',
    };

    reference.forEach((name, expected) {
      test('$name.pxf writes what the reference writes', () {
        final m = decode(fixture(name));
        expect(write(m), expected);
        expectRoundTrip(m);
      });
    });

    test('a body with no fields', () {
      final m = holding('any.v1.Leaf', const []);
      expect(write(m), 'payload {\n  @type = "any.v1.Leaf"\n}\n');
      expectRoundTrip(m);
    });

    // With emitDefaults a body spells out its zeros, and a reader packs a
    // written zero, so an empty value would come back as two fields: it is
    // written raw (protowire#501). A value with nothing at zero keeps its body.
    test('emitDefaults reaches the body, and only where it reads back', () {
      String write(anypb.Holder m) => marshal(m,
          options: MarshalOptions(typeRegistry: registry, emitDefaults: true));
      final full = holding(
          'any.v1.Leaf',
          (anypb.Leaf()
                ..tag = 't'
                ..n = 7)
              .writeToBuffer());
      expect(
          write(full),
          startsWith(
              'payload {\n  @type = "any.v1.Leaf"\n  tag = "t"\n  n = 7\n}\n'));
      final empty = holding('any.v1.Leaf', const []);
      expect(
          write(empty),
          startsWith(
              'payload {\n  type_url = "any.v1.Leaf"\n  value = b""\n}\n'));
    });

    test('an Any inside a body', () {
      final inner = anypb.Leaf()..tag = 't';
      final mid = holding('any.v1.Leaf', inner.writeToBuffer());
      final m = holding('any.v1.Holder', mid.writeToBuffer());
      expect(
          write(m),
          'payload {\n  @type = "any.v1.Holder"\n  payload {\n'
          '    @type = "any.v1.Leaf"\n    tag = "t"\n  }\n}\n');
      expectRoundTrip(m);
    });
  });

  group('falls back to the Any\'s own fields', () {
    test('with no registry', () {
      final m = holding('any.v1.Leaf', [0x0a, 0x01, 0x74]);
      expect(marshal(m),
          'payload {\n  type_url = "any.v1.Leaf"\n  value = b"CgF0"\n}\n');
    });

    test('for a type the registry does not hold', () {
      final m = holding('any.v1.Nope', [0x0a, 0x01, 0x74]);
      expect(write(m),
          'payload {\n  type_url = "any.v1.Nope"\n  value = b"CgF0"\n}\n');
      expectRoundTrip(m);
    });

    test('with no type URL', () {
      final m = anypb.Holder()..payload = (wkt.Any()..value = [0x0a, 1, 0x74]);
      expect(write(m), 'payload {\n  value = b"CgF0"\n}\n');
      expectRoundTrip(m);
    });

    test('for a value that does not parse', () {
      final m = holding('any.v1.Leaf', [0xff]);
      expect(write(m),
          'payload {\n  type_url = "any.v1.Leaf"\n  value = b"/w=="\n}\n');
      expectRoundTrip(m);
    });

    test('for a value the protobuf reader fails on with an Error', () {
      // A truncated field, and a length that overflows to a negative one.
      for (final value in const [
        [26, 27, 101, 34],
        [10, 208, 184, 175, 221, 11, 16],
      ]) {
        final m = holding('any.v1.Leaf', value);
        expect(write(m), contains('value = b"'));
        expectRoundTrip(m);
      }
    });

    test('for a value with an unknown field, unlike the reference', () {
      // protowire-go drops the field here, so its output is a different
      // message. Nothing a body can say would keep it.
      final m = holding('any.v1.Leaf', base64.decode('CgF0qAYB'));
      expect(write(m),
          'payload {\n  type_url = "any.v1.Leaf"\n  value = b"CgF0qAYB"\n}\n');
      expectRoundTrip(m);
    });

    test('for an unknown field in a message inside the value', () {
      // Holder{leaf: Leaf{tag: "t", field 101: 1}}
      final m =
          holding('any.v1.Holder', [0x22, 0x06, ...base64.decode('CgF0qAYB')]);
      expect(write(m), contains('value = b"'));
      expectRoundTrip(m);
    });

    test('for a value with its fields out of order, unlike the reference', () {
      final m = holding('any.v1.Leaf', base64.decode('EAEKAXQ='));
      expect(write(m), contains('value = b"EAEKAXQ="'));
      expectRoundTrip(m);
    });

    test('for a value whose string is not UTF-8', () {
      final m = holding('any.v1.Leaf', [0x0a, 0x01, 0xff]);
      expect(write(m), contains('value = b"CgH/"'));
      expectRoundTrip(m);
    });

    test('past the depth a reader accepts, and the document still reads', () {
      List<int> bytes = (anypb.Leaf()..tag = 'bottom').writeToBuffer();
      var url = 'any.v1.Leaf';
      for (var i = 0; i < 300; i++) {
        bytes = holding(url, bytes).writeToBuffer();
        url = 'any.v1.Holder';
      }
      final m = holding(url, bytes);
      final out = write(m);
      expect('@type = '.allMatches(out), hasLength(99));
      expect('type_url = '.allMatches(out), hasLength(1));
      expectRoundTrip(m);
    });

    test('a chain far past the stack is written, not a crash', () {
      List<int> bytes = const [];
      for (var i = 0; i < 3000; i++) {
        bytes = holding('any.v1.Holder', bytes).writeToBuffer();
      }
      final out = write(holding('any.v1.Holder', bytes));
      expect(out, contains('type_url = "any.v1.Holder"'));
    });
  });
}
