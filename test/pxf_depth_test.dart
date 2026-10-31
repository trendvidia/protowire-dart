// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// MaxNestingDepth, both sides of the bound (HARDENING.md § Recursion,
// protowire#301, #24): the root is depth 0, every `{` or `[` in PXF and every
// submessage on the PB wire is one descent, a document exactly 100 descents
// deep is accepted and one more is rejected, the same for the text parser and
// the decoder. The documents are the ones the corpus generates
// (`deep-nesting-*`, `deep-submessage-*`).
import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:protowire/src/encoding/pxf/parser.dart' show parse;
import 'package:test/test.dart';

import '../bin/adversarial.pb.dart';

const limit = 100;

String blocks(int depth) => 'child{' * depth + '}' * depth;

/// `children = [{ ... }]`, a list and a block per pair, around [inner].
String lists(int pairs, [String inner = '']) =>
    'children = [{' * pairs + inner + '}]' * pairs;

void decode(String doc) => unmarshal(doc, Tree());

final limitError = throwsA(isA<PxfError>().having(
    (e) => '$e', 'message', contains('exceeds MaxNestingDepth=$limit')));

/// [depth] submessages under the root, on the PB wire.
List<int> submessages(int depth) {
  var tree = Tree();
  for (var i = 0; i < depth; i++) {
    tree = Tree(child: tree);
  }
  return tree.writeToBuffer();
}

void main() {
  group('decoder', () {
    test('the root is depth 0: 100 blocks are accepted, 101 are not', () {
      decode(blocks(limit));
      expect(() => decode(blocks(limit + 1)), limitError);
    });

    test('a list is a descent too: 50 pairs are accepted, one block more not',
        () {
      decode(lists(limit ~/ 2));
      expect(() => decode(lists(limit ~/ 2, blocks(1))), limitError);
    });

    test('a list on its own reaches the bound', () {
      decode('${'child{' * (limit - 1)}children = []${'}' * (limit - 1)}');
      expect(() => decode('${'child{' * limit}children = []${'}' * limit}'),
          limitError);
    });

    test('siblings at the bound do not add up', () {
      final deep = blocks(limit);
      decode('$deep\n$deep');
    });

    test('a deep rejected document does not overflow the stack', () {
      expect(() => decode(blocks(100000)), limitError);
    });
  });

  group('text parser', () {
    test('agrees with the decoder on blocks', () {
      parse(blocks(limit));
      expect(() => parse(blocks(limit + 1)), limitError);
    });

    test('agrees with the decoder on lists and blocks', () {
      parse(lists(limit ~/ 2));
      expect(() => parse(lists(limit ~/ 2, blocks(1))), limitError);
    });

    test('bounds a list of lists', () {
      String nested(int depth) => 'x = ${'[' * depth}${']' * depth}';
      parse(nested(limit));
      expect(() => parse(nested(limit + 1)), limitError);
      expect(() => parse(nested(100000)), limitError);
    });
  });

  group('PB wire', () {
    test('100 submessages are accepted, 101 are not', () {
      Tree().mergeFromBuffer(submessages(limit));
      expect(() => Tree().mergeFromBuffer(submessages(limit + 1)),
          throwsA(isA<InvalidProtocolBufferException>()));
    });
  });
}
