// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// HARDENING.md § Recursion, producers (protowire#502, protowire-dart#73): a
// PXF or PB producer refuses a message nested past MaxNestingDepth, counted
// as a decoder reading its output counts, rather than write what a reader at
// the same limit refuses. The limit is per call, and a message that holds
// itself meets it instead of the end of the stack.
import 'package:protobuf/protobuf.dart' show InvalidProtocolBufferException;
import 'package:protowire/protowire.dart' hide marshalNative, unmarshalNative;
import 'package:protowire/src/encoding/pb/native.dart';
import 'package:test/test.dart';

import '../bin/adversarial.pb.dart' as adv;

/// [n] child blocks under the root.
adv.Tree chain(int n) {
  final root = adv.Tree();
  var at = root;
  for (var i = 0; i < n; i++) {
    at = at.child = adv.Tree();
  }
  return root;
}

/// [pairs] map entries with message values, one inside the other: each is
/// the map's brace and the value's, two descents.
adv.Tree mapChain(int pairs, {int extraChildren = 0}) {
  final root = adv.Tree();
  var at = root;
  for (var i = 0; i < pairs; i++) {
    final next = adv.Tree();
    at.branches['k'] = next;
    at = next;
  }
  for (var i = 0; i < extraChildren; i++) {
    at = at.child = adv.Tree();
  }
  return root;
}

/// [n] child blocks, then a scalar map: its brace is descent n + 1.
adv.Tree scalarMapChain(int n) {
  final root = chain(n);
  var at = root;
  for (var i = 0; i < n; i++) {
    at = at.child;
  }
  at.tags['k'] = 'v';
  return root;
}

/// [pairs] list-then-block pairs, `children = [ { ... } ]`, then
/// [extraChildren] child blocks.
adv.Tree listChain(int pairs, {int extraChildren = 0}) {
  final root = adv.Tree();
  var at = root;
  for (var i = 0; i < pairs; i++) {
    final next = adv.Tree();
    at.children.add(next);
    at = next;
  }
  for (var i = 0; i < extraChildren; i++) {
    at = at.child = adv.Tree();
  }
  return root;
}

final tooDeep = throwsA(isA<PxfError>().having((e) => '$e', 'message',
    contains('nesting depth exceeds MaxNestingDepth=100')));

class Node {
  @ProtoTag(1)
  Node? child;
  @ProtoTag(2)
  Map<String, Node>? kids;
  @ProtoTag(3)
  Map<String, String>? tags;
}

Node nodeChain(int n) {
  final root = Node();
  var at = root;
  for (var i = 0; i < n; i++) {
    at = at.child = Node();
  }
  return root;
}

void main() {
  group('PXF', () {
    final shapes = <String, (adv.Tree, adv.Tree)>{
      'blocks': (chain(100), chain(101)),
      'list and block pairs': (listChain(50), listChain(50, extraChildren: 1)),
      'map entries with message values': (
        mapChain(50),
        mapChain(50, extraChildren: 1)
      ),
      'a scalar map at the deepest point': (
        scalarMapChain(99),
        scalarMapChain(100)
      ),
    };
    shapes.forEach((name, pair) {
      test('$name: 100 descents are written and read back', () {
        final text = marshal(pair.$1);
        final back = adv.Tree();
        unmarshal(text, back);
        expect(back, pair.$1);
      });
      test('$name: 101 descents are refused, as a reader refuses them', () {
        expect(() => marshal(pair.$2), tooDeep);
        final raised =
            marshal(pair.$2, options: MarshalOptions(maxNestingDepth: 101));
        expect(() => unmarshal(raised, adv.Tree()), throwsA(isA<PxfError>()));
      });
    });

    test('the limit is per call', () {
      expect(marshal(chain(101), options: MarshalOptions(maxNestingDepth: 101)),
          isNotEmpty);
      expect(
          () => marshal(chain(10), options: MarshalOptions(maxNestingDepth: 9)),
          throwsA(isA<PxfError>().having(
              (e) => '$e', 'message', contains('exceeds MaxNestingDepth=9'))));
    });

    test('a message that holds itself meets the limit', () {
      final loop = adv.Tree();
      loop.children.add(loop);
      expect(() => marshal(loop), tooDeep);
    });
  });

  group('PB, marshalNative', () {
    final tooDeepPb = throwsA(isA<ArgumentError>().having((e) => '${e.message}',
        'message', 'nesting depth exceeds MaxNestingDepth=100'));

    test('100 submessages are written and read back', () {
      final bytes = marshalNative(nodeChain(100));
      mergeFromBufferChecked(adv.Tree(), bytes);
      final back = Node();
      unmarshalNative(bytes, back);
      var depth = 0;
      for (var at = back.child; at != null; at = at.child) {
        depth++;
      }
      expect(depth, 100);
    });

    /// Written past the limit, [n] is refused by the reader too: the two
    /// count alike.
    void readerRefuses(Node n) {
      final raised = marshalNative(n, maxNestingDepth: 1000);
      expect(() => unmarshalNative(raised, Node()),
          throwsA(isA<InvalidProtocolBufferException>()));
    }

    test('101 submessages are refused', () {
      expect(() => marshalNative(nodeChain(101)), tooDeepPb);
      readerRefuses(nodeChain(101));
    });

    test('a map entry is a descent, and its message value another', () {
      Node withKids(int children) {
        final root = nodeChain(children);
        var at = root;
        for (var i = 0; i < children; i++) {
          at = at.child!;
        }
        at.kids = {'k': Node()};
        return root;
      }

      // 98 + entry + value = 100; 99 + entry + value = 101.
      unmarshalNative(marshalNative(withKids(98)), Node());
      expect(() => marshalNative(withKids(99)), tooDeepPb);
      readerRefuses(withKids(99));
    });

    test('a scalar map entry is a descent', () {
      Node withTags(int children) {
        final root = nodeChain(children);
        var at = root;
        for (var i = 0; i < children; i++) {
          at = at.child!;
        }
        at.tags = {'k': 'v'};
        return root;
      }

      unmarshalNative(marshalNative(withTags(99)), Node());
      expect(() => marshalNative(withTags(100)), tooDeepPb);
      readerRefuses(withTags(100));
    });

    test('the limit is per call', () {
      expect(marshalNative(nodeChain(101), maxNestingDepth: 101), isNotEmpty);
      expect(() => marshalNative(nodeChain(10), maxNestingDepth: 9),
          throwsArgumentError);
    });

    test('an object that holds itself meets the limit', () {
      final loop = Node();
      loop.child = loop;
      expect(() => marshalNative(loop), tooDeepPb);
    });
  });
}
