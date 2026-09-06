// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// Descriptor-driven SBE registration. [Codec.registerMessage] takes the
// template, schema and version ids and the per-field length/encoding
// overrides by hand; this reads them from the `(sbe.*)` annotations in a
// compiled `FileDescriptorSet` instead, which is how the Go reference and
// every descriptor-driven port derive them, so one compiled schema drives
// this port's codec too.
//
// The descriptor set must have been parsed with [sbeExtensionRegistry];
// otherwise the annotations sit in unknown fields and every file looks as
// if it had no `(sbe.schema_id)`.

import 'package:protobuf/protobuf.dart';

import '../../generated/proto/google/protobuf/descriptor.pb.dart' as pbd;
import '../../generated/proto/sbe/annotations.pb.dart' as sbe_ann;
import 'sbe.dart';

/// The extensions a `FileDescriptorSet` must be parsed with for its
/// `(sbe.*)` options to be readable:
/// `FileDescriptorSet.fromBuffer(bytes, sbeExtensionRegistry())`.
ExtensionRegistry sbeExtensionRegistry() => ExtensionRegistry()
  ..add(sbe_ann.Annotations.schemaId)
  ..add(sbe_ann.Annotations.version)
  ..add(sbe_ann.Annotations.templateId)
  ..add(sbe_ann.Annotations.length)
  ..add(sbe_ann.Annotations.encoding);

extension CodecDescriptor on Codec {
  /// Registers [prototype]'s message type with the ids read from [fds]:
  /// `(sbe.schema_id)` and `(sbe.version)` from the options of the file that
  /// declares the message, `(sbe.template_id)` from the message's options,
  /// and `(sbe.length)` / `(sbe.encoding)` from the options of its fields
  /// and of its nested messages' fields, keyed by field number as
  /// [Codec.registerMessage] expects. That map is shared across nesting
  /// levels, which is the existing limitation of [registerMessage]: an
  /// override on a nested field applies to any field with the same number
  /// in the same template.
  ///
  /// The message is matched by [BuilderInfo.qualifiedMessageName]
  /// (`bench.v1.Order`); throws when it is not in [fds], when its file
  /// carries no `(sbe.schema_id)`, or when it carries no
  /// `(sbe.template_id)`.
  void registerFromDescriptorSet(
      pbd.FileDescriptorSet fds, GeneratedMessage prototype) {
    final info = prototype.info_;
    final name = info.qualifiedMessageName;
    for (final file in fds.file) {
      final prefix = file.package.isEmpty ? '' : '${file.package}.';
      final found = _findMessage(file.messageType, prefix, name);
      if (found == null) continue;

      if (!file.options.hasExtension(sbe_ann.Annotations.schemaId)) {
        throw Exception(
            'sbe: file ${file.name} missing (sbe.schema_id) option');
      }
      final schemaId =
          file.options.getExtension(sbe_ann.Annotations.schemaId) as int;
      final version = file.options.hasExtension(sbe_ann.Annotations.version)
          ? file.options.getExtension(sbe_ann.Annotations.version) as int
          : 0;
      if (!found.options.hasExtension(sbe_ann.Annotations.templateId)) {
        throw Exception('sbe: message $name missing (sbe.template_id)');
      }
      final templateId =
          found.options.getExtension(sbe_ann.Annotations.templateId) as int;

      final lengths = <int, int>{};
      final encodings = <int, String>{};
      _collectOverrides(found, lengths, encodings);
      registerMessage(info, templateId, schemaId, version,
          lengths: lengths.isEmpty ? null : lengths,
          encodings: encodings.isEmpty ? null : encodings);
      return;
    }
    throw Exception('sbe: message $name not found in descriptor set');
  }
}

pbd.DescriptorProto? _findMessage(
    List<pbd.DescriptorProto> messages, String prefix, String name) {
  for (final m in messages) {
    final full = '$prefix${m.name}';
    if (full == name) return m;
    final nested = _findMessage(m.nestedType, '$full.', name);
    if (nested != null) return nested;
  }
  return null;
}

void _collectOverrides(
    pbd.DescriptorProto m, Map<int, int> lengths, Map<int, String> encodings) {
  for (final f in m.field) {
    if (f.options.hasExtension(sbe_ann.Annotations.length)) {
      lengths[f.number] =
          f.options.getExtension(sbe_ann.Annotations.length) as int;
    }
    if (f.options.hasExtension(sbe_ann.Annotations.encoding)) {
      encodings[f.number] =
          f.options.getExtension(sbe_ann.Annotations.encoding) as String;
    }
  }
  for (final n in m.nestedType) {
    _collectOverrides(n, lengths, encodings);
  }
}
