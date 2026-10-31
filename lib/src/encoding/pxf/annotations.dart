// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'package:protobuf/protobuf.dart';

import '../../generated/proto/google/protobuf/descriptor.pb.dart' as pbd;
import '../../generated/proto/pxf/annotations.pb.dart' as pxf_ann;
import 'errors.dart';
import 'token.dart';

/// An [ExtensionRegistry] that knows `(pxf.required)` = 1314,
/// `(pxf.default)` = 1315 and `(pxf.key)` = 1316, for parsing a `FileDescriptorSet` whose field
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

  /// `[(pxf.key) = "..."]`: the element field that keys this repeated
  /// field. Placement is checked when the descriptor set is bound.
  final String? key;

  const PxfFieldAnnotations(
      {this.required = false, this.defaultLiteral, this.key});
}

/// The shape of one schema field, as far as the keyed canonicalizer needs
/// it (`canonicalizeKeyed` works on a document, with no generated class in
/// hand, so this comes from the descriptor set).
class PxfSchemaField {
  /// `repeated`, map fields excluded.
  final bool isList;

  /// A `map<K, V>` field.
  final bool isMap;

  /// The full name of the singular message type, the element message of a
  /// list, or the value message of a map. Null for anything else.
  final String? messageType;

  const PxfSchemaField(
      {required this.isList, required this.isMap, this.messageType});
}

/// The schema-side half of `(pxf.required)` / `(pxf.default)` / `(pxf.key)`
/// (protowire `proto/pxf/annotations.proto`), indexed from a descriptor set
/// for the decoder, the encoder and `formatPxf` to consult (#14, #10).
///
/// Generated Dart messages carry no field options, so the annotations
/// come from a `FileDescriptorSet` — the same input `Codec.
/// registerFromDescriptorSet` reads the SBE annotations from — and attach
/// by `(qualified message name, proto field name)`, which is what the
/// decoder has in hand at every field (`BuilderInfo.qualifiedMessageName`,
/// `FieldInfo.protoName`).
///
/// ```dart
/// final ann = PxfAnnotations.fromBytes(File('keyed.binpb').readAsBytesSync());
/// final doc = marshal(node, options: MarshalOptions(annotations: ann));
/// ```
class PxfAnnotations {
  final Map<String, Map<String, PxfFieldAnnotations>> _byMessage = {};
  final List<String> _violations = [];

  PxfAnnotations._();

  /// Indexes every message of [fds], nested ones included. [fds] must
  /// have been parsed with [pxfExtensionRegistry] (or built in memory
  /// with the extensions set); see [PxfAnnotations.fromBytes].
  ///
  /// This is the bind: `(pxf.required)` with `(pxf.default)` on one field,
  /// anywhere in [fds], is a [PxfError] naming every such field (draft -01
  /// "Required and Default"), whatever a document says. The scope the draft
  /// fixes for this check is the bound file's import closure, so [fds]
  /// should be built with `protoc --include_imports`.
  factory PxfAnnotations.fromDescriptorSet(pbd.FileDescriptorSet fds) {
    final a = PxfAnnotations._();
    for (final file in fds.file) {
      final prefix = file.package.isEmpty ? '' : '${file.package}.';
      for (final m in file.messageType) {
        a._index(m, prefix, file.name);
      }
    }
    if (a._violations.isNotEmpty) {
      throw PxfError(Position(1, 1), a._violations.join('; '));
    }
    return a;
  }

  /// Parses a serialized `FileDescriptorSet` with the pxf extensions
  /// registered and indexes it.
  factory PxfAnnotations.fromBytes(List<int> bytes) =>
      PxfAnnotations.fromDescriptorSet(
          pbd.FileDescriptorSet.fromBuffer(bytes, pxfExtensionRegistry()));

  void _index(pbd.DescriptorProto m, String prefix, String fileName) {
    final fullName = '$prefix${m.name}';
    _descriptors[fullName] = m;
    _declaringFile[fullName] = fileName;
    final fields = <String, PxfFieldAnnotations>{};
    for (final fd in m.field) {
      final o = fd.options;
      final required = o.hasExtension(pxf_ann.Annotations.required) &&
          o.getExtension(pxf_ann.Annotations.required) as bool;
      final def = o.hasExtension(pxf_ann.Annotations.default_1315)
          ? o.getExtension(pxf_ann.Annotations.default_1315) as String
          : null;
      if (required && def != null) {
        _violations.add('$fileName: field "$fullName.${fd.name}": '
            '(pxf.required) and (pxf.default) are exclusive on one field: '
            'the first rejects a document where the field is absent, and '
            'the second treats it as supplied');
      }
      if (required || def != null) {
        fields[fd.name] =
            PxfFieldAnnotations(required: required, defaultLiteral: def);
      }
    }
    _byMessage[fullName] = fields;
    for (final n in m.nestedType) {
      _index(n, '$fullName.', fileName);
    }
    return value.typeName.startsWith('.')
        ? value.typeName.substring(1)
        : value.typeName;
  }

  /// Why `(pxf.key) = key` cannot stand on this field, or null if it can.
  String? _keyPlacementProblem(bool repeatedMessage, String elemName,
      pbd.DescriptorProto? elem, String key) {
    if (!repeatedMessage) {
      return '(pxf.key) is valid only on repeated message-typed fields';
    }
    if (elem == null) {
      return 'element message $elemName is not in the descriptor set';
    }
    final kf = elem.field.where((f) => f.name == key).firstOrNull;
    if (kf == null) return 'element message $elemName has no field "$key"';
    if (kf.label == pbd.FieldDescriptorProto_Label.LABEL_REPEATED ||
        kf.type != pbd.FieldDescriptorProto_Type.TYPE_STRING) {
      return 'key field $elemName.$key must be a singular string field';
    }
    return null;
  }

  /// True when the descriptor set declares [messageFullName].
  bool hasMessage(String messageFullName) =>
      _byMessage.containsKey(messageFullName);

  /// The annotations on [protoFieldName] of [messageFullName], or null when
  /// the field carries none of them (or the message is unknown).
  PxfFieldAnnotations? field(String messageFullName, String protoFieldName) =>
      _byMessage[messageFullName]?[protoFieldName];

  /// The element field keying [protoFieldName] of [messageFullName], or
  /// null when that field is not a keyed repeated field.
  String? keyFieldName(String messageFullName, String protoFieldName) =>
      field(messageFullName, protoFieldName)?.key;

  /// The shape of [protoFieldName] of [messageFullName], or null when the
  /// descriptor set does not declare it.
  PxfSchemaField? schemaField(String messageFullName, String protoFieldName) =>
      _shapes[messageFullName]?[protoFieldName];

  /// Indexed message names, sorted.
  List<String> get messageNames => _byMessage.keys.toList()..sort();
}
