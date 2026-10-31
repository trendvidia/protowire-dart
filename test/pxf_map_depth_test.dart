// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// A map is nesting too (HARDENING.md § Recursion, protowire#449): a PXF map's
// own `{` is one descent, and every PB map entry is one, whatever the value's
// type. The documents are the shapes of the corpus rows `deep-nesting-maps`,
// `deep-nesting-scalar-map`, `deep-map` and `deep-scalar-map`.
//
// The PXF tests measure the bound from plain blocks instead of naming 100, so
// they say only what this file is about: a map costs what a block costs. Where
// the root sits is protowire-dart#24's business.
import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:protowire/src/encoding/pxf/parser.dart' show parse;
import 'package:test/test.dart';

import '../bin/adversarial.pb.dart';

const limit = 100;

String blocks(int depth) => 'child{' * depth + '}' * depth;

/// [depth] descents through `branches = { k: { ... } }`, two per pair.
String maps(int depth) {
  final pairs = depth ~/ 2;
  final inner = blocks(depth.isOdd ? 1 : 0);
  return '${'branches = {k: {' * pairs}$inner${'}}' * pairs}';
}

/// [depth] descents, the last of them a scalar-valued map's `{`.
String scalarMap(int depth) =>
    '${'child{' * (depth - 1)}tags = {k: "v"}${'}' * (depth - 1)}';

/// The deepest document of plain blocks [read] accepts.
int bound(void Function(String) read) {
  var depth = 0;
  try {
    while (depth <= limit + 1) {
      read(blocks(depth + 1));
      depth++;
    }
  } on PxfError {
    return depth;
  }
  fail('no bound found');
}

void decode(String doc) => unmarshal(doc, Tree());

final limitError = throwsA(isA<PxfError>().having(
    (e) => '$e', 'message', contains('exceeds MaxNestingDepth=$limit')));

void main() {
  for (final (name, read) in [
    ('decoder', decode),
    ('text parser', (String doc) => parse(doc)),
  ]) {
    group(name, () {
      final deepest = bound(read);

      test("a map's { costs what a block costs", () {
        read(maps(deepest));
        expect(() => read(maps(deepest + 1)), limitError);
      });

      test('so does the { of a map of scalars', () {
        read(scalarMap(deepest));
        expect(() => read(scalarMap(deepest + 1)), limitError);
      });

      test('an empty map is still a descent', () {
        String empty(int depth) =>
            '${'child{' * (depth - 1)}tags = {}${'}' * (depth - 1)}';
        read(empty(deepest));
        expect(() => read(empty(deepest + 1)), limitError);
      });

      test('sibling maps at the bound do not add up', () {
        final at = scalarMap(deepest);
        read('$at\n$at');
      });

      test('a deep rejected document does not overflow the stack', () {
        expect(() => read(maps(100000)), limitError);
      });
    });
  }

  group('PB wire', () {
    final recursion = throwsA(isA<InvalidProtocolBufferException>());

    /// [depth] descents, each pair a map entry and its message value.
    List<int> mapChain(int depth) {
      var tree = depth.isOdd ? Tree(child: Tree()) : Tree();
      for (var i = 0; i < depth ~/ 2; i++) {
        tree = Tree(branches: {'k': tree}.entries);
      }
      return tree.writeToBuffer();
    }

    /// [depth] descents, the last of them a scalar-valued map entry.
    List<int> scalarChain(int depth) {
      var tree = Tree(tags: {'k': 'v'}.entries);
      for (var i = 0; i < depth - 1; i++) {
        tree = Tree(child: tree);
      }
      return tree.writeToBuffer();
    }

    List<int> submessages(int depth) {
      var tree = Tree();
      for (var i = 0; i < depth; i++) {
        tree = Tree(child: tree);
      }
      return tree.writeToBuffer();
    }

    void merge(List<int> data) => mergeFromBufferChecked(Tree(), data);

    test('a map entry with a message value is a descent', () {
      merge(mapChain(limit));
      expect(() => merge(mapChain(limit + 1)), recursion);
    });

    test('a map entry with a scalar value is a descent', () {
      merge(scalarChain(limit));
      expect(() => merge(scalarChain(limit + 1)), recursion);
    });

    test('submessages keep their bound', () {
      merge(submessages(limit));
      expect(() => merge(submessages(limit + 1)), recursion);
    });

    // Why mergeFromBufferChecked exists. If this fails, package:protobuf has
    // started counting entries and the walk can go.
    test('mergeFromBuffer alone does not count entries', () {
      Tree().mergeFromBuffer(scalarChain(limit + 1));
    });

    test('the message is merged, not only walked', () {
      final tree = Tree();
      mergeFromBufferChecked(tree, scalarChain(3));
      expect(tree.child.child.tags, {'k': 'v'});
    });

    test('a field on the wrong wire type is skipped, as the merge does', () {
      // Field 4 (`branches`) as a varint.
      merge([0x20, 0x01]);
    });

    test("a truncated entry is the merge's error, not a crash", () {
      expect(() => merge([0x22, 0x05, 0x01]),
          throwsA(isA<InvalidProtocolBufferException>()));
    });
  });
}
