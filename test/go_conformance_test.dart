// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// Holds this port to protowire-go on the vendored spec corpora and on
// test/conformance: the same verdict on each document, the same bytes, and the
// same PXF written back. The Go side is tool/go_oracle, whose output GO_ORACLE
// names. Without it these tests do not exist, so the CI job that runs them
// sets REQUIRE_GO_ORACLE too.
//
// Every document runs with a descriptor set, as the oracle's schema supplies
// one. Without one a generated class cannot tell `int32` from `optional int32`,
// so a zero stays set and is written; see the README.
import 'dart:convert';
import 'dart:io';

import 'package:protobuf/protobuf.dart';
import 'package:protowire/protowire.dart';
import 'package:protowire/src/encoding/pxf/parser.dart';
import 'package:protowire/src/generated/proto/google/protobuf/descriptor.pb.dart'
    as pbd;
import 'package:test/test.dart';

import 'generated/any.pb.dart' as anypb;
import 'generated/bigfloat.pb.dart' as bigfloat;
import 'generated/blocks.pb.dart' as blocks;
import 'generated/bool_keys.pb.dart' as mapkeys;
import 'generated/conformance.pb.dart' as conformance;
import 'generated/duplicates.pb.dart' as duplicates;
import 'generated/duration.pb.dart' as duration;
import 'generated/keyed.pb.dart' as keyed;
import 'generated/nulls.pb.dart' as nulls;
import 'generated/nulls_editions.pb.dart' as editions;
import 'generated/nulls_proto2.pb.dart' as proto2;
import 'generated/paths.pb.dart' as paths;
import 'generated/strings.pb.dart' as strings;
import 'generated/test.pb.dart' as testpb;

/// settings.annotated.v1.Settings: its schema is vendored compiled, so it has
/// no generated class.
class Annotated extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Settings',
      package: const PackageName('settings.annotated.v1'),
      createEmptyInstance: create)
    ..aOS(1, 'name')
    ..a<int>(2, 'retries', PbFieldType.O3)
    ..aOS(3, 'region')
    ..aOB(4, 'verbose');
  Annotated._();
  @override
  BuilderInfo get info_ => _i;
  @override
  Annotated clone() => create()..mergeFromMessage(this);
  @override
  Annotated createEmptyInstance() => create();
  static Annotated create() => Annotated._();
}

final classes = <String, GeneratedMessage Function()>{
  'dataset.v1.Event': paths.Event.new,
  'conformance.v1.Values': conformance.Values.new,
  'any.v1.Holder': anypb.Holder.new,
  'settings.annotated.v1.Settings': Annotated.create,
  'bf.v1.H': bigfloat.H.new,
  'blocks.v1.Doc': blocks.Doc.new,
  'dup.v1.Holder': duplicates.Holder.new,
  'duration.v1.Holder': duration.Holder.new,
  'keyed.v1.Node': keyed.Node.new,
  'keyed.v1.Catalog': keyed.Catalog.new,
  'keyed.v1.Deployment': keyed.Deployment.new,
  'keyed.v1.Doc': keyed.Doc.new,
  'mapkeys.v1.Flags': mapkeys.Flags.new,
  'mapkeys.v1.Labels': mapkeys.Labels.new,
  'nulls.v1.Holder': nulls.Holder.new,
  'nulls.v1.Strict': proto2.Strict.new,
  'nulls.v1.Legacy': proto2.Legacy.new,
  'nulls.v1.Required': nulls.Required.new,
  'nulls.v1.Defaulted': nulls.Defaulted.new,
  'nulls.ed.v1.Ed': editions.Ed.new,
  'test.v1.AllTypes': testpb.AllTypes.new,
  'strings.v1.Holder': strings.Holder.new,
};

/// [m] with every map in key order, as the reference writes them: proto3 does
/// not fix map order on the wire, and Dart writes insertion order.
GeneratedMessage canonical(GeneratedMessage m) {
  for (final fi in m.info_.byIndex) {
    if (!m.hasField(fi.tagNumber)) continue;
    final value = m.getField(fi.tagNumber);
    if (value is PbMap) {
      final keys = value.keys.toList()..sort(_keyOrder);
      final entries = [for (final k in keys) MapEntry(k, value[k])];
      value.clear();
      for (final e in entries) {
        if (e.value is GeneratedMessage) {
          canonical(e.value as GeneratedMessage);
        }
        value[e.key] = e.value;
      }
    } else if (value is List) {
      value.whereType<GeneratedMessage>().forEach(canonical);
    } else if (value is GeneratedMessage) {
      canonical(value);
    }
  }
  return m;
}

int _keyOrder(Object? a, Object? b) => a is bool
    ? (a ? 1 : 0).compareTo((b as bool) ? 1 : 0)
    : (a as Comparable).compareTo(b);

void main() {
  final path = Platform.environment['GO_ORACLE'];
  if (path == null) {
    if (Platform.environment['REQUIRE_GO_ORACLE'] != null) {
      test('GO_ORACLE is set', () => fail('REQUIRE_GO_ORACLE without one'));
    }
    return;
  }
  final oracle = jsonDecode(File(path).readAsStringSync()) as Map;
  final descriptors = oracle['descriptors'] as Map;
  final registry = TypeRegistry([anypb.Leaf()]);
  final annotations = <String, PxfAnnotations>{};
  PxfAnnotations annotationsFor(String corpus) => annotations[corpus] ??=
      PxfAnnotations.fromDescriptorSet(pbd.FileDescriptorSet.fromBuffer(
          base64.decode(descriptors[corpus] as String),
          pxfExtensionRegistry()));

  void same(GeneratedMessage m, Map r, String corpus) {
    expect(
        marshal(m,
            options: MarshalOptions(
                annotations: annotationsFor(corpus), typeRegistry: registry)),
        r['text'] as String? ?? '',
        reason: 'written PXF differs');
    expect(
        canonical(m).writeToBuffer(), base64.decode(r['pb'] as String? ?? ''),
        reason: 'PB differs');
  }

  void bindRows(Map r, String corpus, String text) {
    final want = (r['rows'] as List? ?? const []).cast<Map>();
    final accepted = r['accepted'] as bool;
    final got = <GeneratedMessage>[];
    Object? rejection;
    try {
      for (final ds in parse(text).datasets) {
        for (final row in ds.rows) {
          final m = classes[ds.type]!();
          bindDatasetRow(m, ds.columns, row,
              options: UnmarshalOptions(annotations: annotationsFor(corpus)));
          got.add(m);
        }
      }
    } on PxfError catch (e) {
      rejection = e;
    }
    expect(rejection == null, accepted,
        reason:
            accepted ? 'Go accepts, Dart: $rejection' : 'Go: ${r['error']}');
    if (!accepted) return;
    expect(got, hasLength(want.length));
    for (var i = 0; i < got.length; i++) {
      same(got[i], want[i], corpus);
    }
  }

  final results = (oracle['results'] as List).cast<Map>();
  test('the oracle covers every document', () {
    final seen = {for (final r in results) r['doc'] as String};
    for (final root in ['test/testdata', 'test/conformance']) {
      final docs = Directory(root)
          .listSync(recursive: true)
          .whereType<File>()
          .map((f) => f.path.replaceAll(r'\', '/'))
          .where((p) => p.endsWith('.pxf'))
          // Hostile input with its own verdicts, in CI's hardening job.
          .where((p) => !p.contains('/adversarial/'));
      for (final d in docs) {
        expect(seen, contains(d.substring('test/'.length)));
      }
    }
  });

  for (final r in results) {
    final doc = r['doc'] as String;
    test(doc, () {
      final corpus = doc.substring(0, doc.lastIndexOf('/'));
      final text = File('test/$doc').readAsStringSync();
      if (r['message'] == null) {
        bindRows(r, corpus, text);
        return;
      }
      final m = classes[r['message']]!();
      Object? rejection;
      try {
        unmarshalFull(text, m,
            options: UnmarshalOptions(
                annotations: annotationsFor(corpus), typeRegistry: registry));
      } on PxfError catch (e) {
        rejection = e;
      } on FormatException catch (e) {
        rejection = e;
      }
      final accepted = r['accepted'] as bool;
      expect(rejection == null, accepted,
          reason:
              accepted ? 'Go accepts, Dart: $rejection' : 'Go: ${r['error']}');
      if (accepted) same(m, r, corpus);
    });
  }
}
