// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'package:protobuf/protobuf.dart';

import '../../generated/proto/google/protobuf/descriptor.pb.dart' as pbd;
import '../../generated/proto/pxf/annotations.pb.dart' as pxf_ann;

/// An [ExtensionRegistry] that knows `(pxf.required)` = 1314 and
/// `(pxf.default)` = 1315, for parsing a `FileDescriptorSet` whose field
/// options carry them. Without it the options are unknown fields and
/// [PxfAnnotations] sees nothing.
ExtensionRegistry pxfExtensionRegistry() {
  final r = ExtensionRegistry();
  pxf_ann.Annotations.registerAllExtensions(r);
  return r;
}

/// What a schema says about one field, as far as decoding needs it.
class PxfFieldAnnotations {
  /// `[(pxf.required) = true]`: an absent field is a decode error.
  final bool required;

  /// `[(pxf.default) = "..."]`: the literal an absent field takes, read by
  /// the field's type — see `unmarshalFull`.
  final String? defaultLiteral;

  const PxfFieldAnnotations({this.required = false, this.defaultLiteral});
}

/// The schema-side half of `(pxf.required)` / `(pxf.default)` (protowire
/// `proto/pxf/annotations.proto`), indexed from a descriptor set for the
/// decoder to consult (#14).
///
/// Generated Dart messages carry no field options, so the annotations
/// come from a `FileDescriptorSet` — the same input `Codec.
/// registerFromDescriptorSet` reads the SBE annotations from — and attach
/// by `(qualified message name, proto field name)`, which is what the
/// decoder has in hand at every field (`BuilderInfo.qualifiedMessageName`,
/// `FieldInfo.protoName`).
class PxfAnnotations {
  final Map<String, Map<String, PxfFieldAnnotations>> _byMessage = {};

  PxfAnnotations._();

  /// Indexes every message of [fds], nested ones included. [fds] must
  /// have been parsed with [pxfExtensionRegistry] (or built in memory
  /// with the extensions set); see [PxfAnnotations.fromBytes].
  factory PxfAnnotations.fromDescriptorSet(pbd.FileDescriptorSet fds) {
    final a = PxfAnnotations._();
    for (final file in fds.file) {
      final prefix = file.package.isEmpty ? '' : '${file.package}.';
      for (final m in file.messageType) {
        a._index(m, prefix);
      }
    }
    return a;
  }

  /// Parses a serialized `FileDescriptorSet` with the pxf extensions
  /// registered and indexes it.
  factory PxfAnnotations.fromBytes(List<int> bytes) =>
      PxfAnnotations.fromDescriptorSet(
          pbd.FileDescriptorSet.fromBuffer(bytes, pxfExtensionRegistry()));

  void _index(pbd.DescriptorProto m, String prefix) {
    final fullName = '$prefix${m.name}';
    final fields = <String, PxfFieldAnnotations>{};
    for (final fd in m.field) {
      final o = fd.options;
      final required = o.hasExtension(pxf_ann.Annotations.required) &&
          o.getExtension(pxf_ann.Annotations.required) as bool;
      final def = o.hasExtension(pxf_ann.Annotations.default_1315)
          ? o.getExtension(pxf_ann.Annotations.default_1315) as String
          : null;
      if (required || def != null) {
        fields[fd.name] =
            PxfFieldAnnotations(required: required, defaultLiteral: def);
      }
    }
    _byMessage[fullName] = fields;
    for (final n in m.nestedType) {
      _index(n, '$fullName.');
    }
  }

  /// True when the descriptor set declares [messageFullName].
  bool hasMessage(String messageFullName) =>
      _byMessage.containsKey(messageFullName);

  /// The annotations on [protoFieldName] of [messageFullName], or null when
  /// the field carries neither annotation (or the message is unknown).
  PxfFieldAnnotations? field(String messageFullName, String protoFieldName) =>
      _byMessage[messageFullName]?[protoFieldName];

  /// Indexed message names, sorted.
  List<String> get messageNames => _byMessage.keys.toList()..sort();
}
