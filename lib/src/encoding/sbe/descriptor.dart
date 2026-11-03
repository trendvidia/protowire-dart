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
//
// A part of sbe.dart, so registration can hand the template builder
// overrides keyed by message without widening Codec's public API.
part of 'sbe.dart';

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
  /// and `(sbe.length)` / `(sbe.encoding)` from the options of the fields of
  /// every message the template reaches: its own, its groups', and its
  /// composites', whichever file declares them. Each message's options are
  /// its own, so a composite's field never takes the length of a field with
  /// the same number elsewhere (protowire-dart#87).
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

      final messages = _messagesByName(fds);
      final overrides =
          FieldOverrides(lengthsByMessage: {}, encodingsByMessage: {});
      _collectOverrides(name, found, messages, overrides);
      _register(info, templateId, schemaId, version, overrides);
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

/// Every message in [fds] by its qualified name, without a leading dot.
Map<String, pbd.DescriptorProto> _messagesByName(pbd.FileDescriptorSet fds) {
  final out = <String, pbd.DescriptorProto>{};
  void add(pbd.DescriptorProto m, String full) {
    out[full] = m;
    for (final n in m.nestedType) {
      add(n, '$full.${n.name}');
    }
  }

  for (final file in fds.file) {
    final prefix = file.package.isEmpty ? '' : '${file.package}.';
    for (final m in file.messageType) {
      add(m, '$prefix${m.name}');
    }
  }
  return out;
}

/// Records [m]'s field options under [name], then those of each message a
/// field of [m] holds, once each.
void _collectOverrides(String name, pbd.DescriptorProto m,
    Map<String, pbd.DescriptorProto> messages, FieldOverrides into) {
  if (into.lengthsByMessage.containsKey(name)) return;
  final lengths = into.lengthsByMessage[name] = <int, int>{};
  final encodings = into.encodingsByMessage[name] = <int, String>{};
  for (final f in m.field) {
    if (f.options.hasExtension(sbe_ann.Annotations.length)) {
      lengths[f.number] =
          f.options.getExtension(sbe_ann.Annotations.length) as int;
    }
    if (f.options.hasExtension(sbe_ann.Annotations.encoding)) {
      encodings[f.number] =
          f.options.getExtension(sbe_ann.Annotations.encoding) as String;
    }
    if (f.type == pbd.FieldDescriptorProto_Type.TYPE_MESSAGE ||
        f.type == pbd.FieldDescriptorProto_Type.TYPE_GROUP) {
      final sub =
          f.typeName.startsWith('.') ? f.typeName.substring(1) : f.typeName;
      final sm = messages[sub];
      if (sm != null) _collectOverrides(sub, sm, messages, into);
    }
  }
}
