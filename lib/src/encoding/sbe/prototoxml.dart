// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'dart:convert';

import 'package:protobuf/protobuf.dart';

import '../../generated/proto/google/protobuf/descriptor.pb.dart' as pbd;
import '../../generated/proto/sbe/annotations.pb.dart' as sbe_ann;
import 'sbe.dart' show sbeExtensionRegistry;
import 'xmlschema.dart' show camelToScreamingSnake;

String protoToXml(BuilderInfo info, int schemaId, int version,
    {String? package}) {
  final strLengths = <int>{};
  final composites = <BuilderInfo>[];
  final compSeen = <String>{};
  final enums = <_EnumInfo>[];
  final enumSeen = <String>{};

  _collectTypes(info, strLengths, composites, compSeen, enums, enumSeen);

  final sb = StringBuffer();
  sb.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  sb.writeln('<sbe:messageSchema xmlns:sbe="http://fixprotocol.io/2016/sbe"');
  if (package != null) {
    sb.writeln('                   package="$package"');
  }
  sb.writeln('                   id="$schemaId"');
  sb.writeln('                   version="$version"');
  sb.writeln('                   byteOrder="littleEndian">');

  sb.writeln('    <types>');

  // Standard composites
  sb.writeln('        <composite name="messageHeader">');
  sb.writeln('            <type name="blockLength" primitiveType="uint16"/>');
  sb.writeln('            <type name="templateId" primitiveType="uint16"/>');
  sb.writeln('            <type name="schemaId" primitiveType="uint16"/>');
  sb.writeln('            <type name="version" primitiveType="uint16"/>');
  sb.writeln('        </composite>');
  sb.writeln('        <composite name="groupSizeEncoding">');
  sb.writeln('            <type name="blockLength" primitiveType="uint16"/>');
  sb.writeln('            <type name="numInGroup" primitiveType="uint16"/>');
  sb.writeln('        </composite>');

  final sortedLengths = strLengths.toList()..sort();
  for (final l in sortedLengths) {
    sb.writeln('        <type name="str$l" primitiveType="char" length="$l"/>');
  }

  for (final ei in enums) {
    _writeXmlEnum(sb, ei);
  }

  for (final ci in composites) {
    _writeXmlComposite(sb, ci);
  }

  sb.writeln('    </types>');

  // In this simplified version, we only encode the root message provided.
  // Real version might walk all messages in a FileDescriptor.
  _writeXmlMessage(sb, info, 1); // templateId=1 for simplicity if not provided

  sb.writeln('</sbe:messageSchema>');
  return sb.toString();
}

class _EnumInfo {
  final String name;
  final List<ProtobufEnum> values;
  _EnumInfo(this.name, this.values);
}

void _collectTypes(
    BuilderInfo info,
    Set<int> strLengths,
    List<BuilderInfo> composites,
    Set<String> compSeen,
    List<_EnumInfo> enums,
    Set<String> enumSeen) {
  for (final tag in info.fieldInfo.keys) {
    final fi = info.fieldInfo[tag]!;

    // String lengths require external info in this Dart port since annotations aren't easily readable at runtime
    // from BuilderInfo unless we store them.
    // For now, let's assume we don't know them or we skip them in collect.

    if ((fi.type & _ENUM_BIT) != 0) {
      final name =
          fi.name; // Use field name as hint for enum name if not available
      // In Dart, FieldInfo might not store the enum descriptor name.
      if (!enumSeen.contains(name)) {
        enumSeen.add(name);
        // values are in fi.enumValues
        if (fi.enumValues != null) {
          enums.add(_EnumInfo(name, fi.enumValues!));
        }
      }
    }

    if ((fi.type & _MESSAGE_BIT) != 0) {
      final subInfo = fi.subBuilder!().info_;
      final name = subInfo.qualifiedMessageName;
      if (!compSeen.contains(name)) {
        compSeen.add(name);
        composites.add(subInfo);
        _collectTypes(
            subInfo, strLengths, composites, compSeen, enums, enumSeen);
      }
    }
  }
}

void _writeXmlEnum(StringBuffer sb, _EnumInfo ei) {
  sb.writeln('        <enum name="${ei.name}" encodingType="uint8">');
  for (final v in ei.values) {
    sb.writeln(
        '            <validValue name="${v.name}">${v.value}</validValue>');
  }
  sb.writeln('        </enum>');
}

void _writeXmlComposite(StringBuffer sb, BuilderInfo info) {
  sb.writeln('        <composite name="${info.messageName}">');
  final sortedTags = info.fieldInfo.keys.toList()..sort();
  for (final tag in sortedTags) {
    final fi = info.fieldInfo[tag]!;
    final sbeType = _protoFieldToSBEType(fi);
    final fieldName = snakeToCamel(fi.name);
    if (sbeType.length > 0) {
      sb.writeln(
          '            <type name="$fieldName" primitiveType="${sbeType.primitiveType}" length="${sbeType.length}"/>');
    } else {
      sb.writeln(
          '            <type name="$fieldName" primitiveType="${sbeType.primitiveType}"/>');
    }
  }
  sb.writeln('        </composite>');
}

void _writeXmlMessage(StringBuffer sb, BuilderInfo info, int templateId) {
  sb.writeln('    <sbe:message name="${info.messageName}" id="$templateId">');
  final sortedTags = info.fieldInfo.keys.toList()..sort();
  for (final tag in sortedTags) {
    final fi = info.fieldInfo[tag]!;
    final fieldName = snakeToCamel(fi.name);
    if (fi.isRepeated && (fi.type & _MESSAGE_BIT) != 0) {
      _writeXmlGroup(sb, fi, '        ');
    } else {
      _writeXmlField(sb, fi, '        ');
    }
  }
  sb.writeln('    </sbe:message>');
}

void _writeXmlField(StringBuffer sb, FieldInfo fi, String indent) {
  final fieldName = snakeToCamel(fi.name);
  final type = (fi.type & _ENUM_BIT) != 0
      ? fi.name
      : (fi.type & _MESSAGE_BIT) != 0
          ? fi.subBuilder!().info_.messageName
          : _protoFieldToSBEType(fi).xmlType;
  sb.writeln(
      '$indent<field name="$fieldName" id="${fi.tagNumber}" type="$type"/>');
}

void _writeXmlGroup(StringBuffer sb, FieldInfo fi, String indent) {
  final groupName = snakeToCamel(fi.name);
  sb.writeln('$indent<group name="$groupName" id="${fi.tagNumber}">');
  final subInfo = fi.subBuilder!().info_;
  final sortedTags = subInfo.fieldInfo.keys.toList()..sort();
  for (final tag in sortedTags) {
    _writeXmlField(sb, subInfo.fieldInfo[tag]!, '$indent    ');
  }
  sb.writeln('$indent</group>');
}

class _SbeTypeInfo {
  final String primitiveType;
  final String xmlType;
  final int length;
  _SbeTypeInfo(this.primitiveType, this.xmlType, this.length);
}

_SbeTypeInfo _protoFieldToSBEType(FieldInfo fi) {
  int type = fi.type;
  if ((type & _BOOL_BIT) != 0) return _SbeTypeInfo('uint8', 'uint8', 0);
  if ((type & _INT32_BIT) != 0 ||
      (type & _SINT32_BIT) != 0 ||
      (type & _SFIXED32_BIT) != 0) {
    return _SbeTypeInfo('int32', 'int32', 0);
  }
  if ((type & _INT64_BIT) != 0 ||
      (type & _SINT64_BIT) != 0 ||
      (type & _SFIXED64_BIT) != 0) {
    return _SbeTypeInfo('int64', 'int64', 0);
  }
  if ((type & _UINT32_BIT) != 0 || (type & _FIXED32_BIT) != 0) {
    return _SbeTypeInfo('uint32', 'uint32', 0);
  }
  if ((type & _UINT64_BIT) != 0 || (type & _FIXED64_BIT) != 0) {
    return _SbeTypeInfo('uint64', 'uint64', 0);
  }
  if ((type & _FLOAT_BIT) != 0) return _SbeTypeInfo('float', 'float', 0);
  if ((type & _DOUBLE_BIT) != 0) return _SbeTypeInfo('double', 'double', 0);

  // Strings/Bytes are tricky without annotations
  return _SbeTypeInfo('uint8', 'uint8', 0);
}

const int _BOOL_BIT = 0x10;
const int _FLOAT_BIT = 0x100;
const int _DOUBLE_BIT = 0x80;
const int _ENUM_BIT = 0x200;
const int _INT32_BIT = 0x800;
const int _INT64_BIT = 0x1000;
const int _SINT32_BIT = 0x2000;
const int _SINT64_BIT = 0x4000;
const int _UINT32_BIT = 0x8000;
const int _UINT64_BIT = 0x10000;
const int _FIXED32_BIT = 0x20000;
const int _FIXED64_BIT = 0x40000;
const int _SFIXED32_BIT = 0x80000;
const int _SFIXED64_BIT = 0x100000;
const int _MESSAGE_BIT = 0x200000;

String snakeToCamel(String s) {
  final parts = s.split('_');
  final sb = StringBuffer(parts[0]);
  for (int i = 1; i < parts.length; i++) {
    if (parts[i].isEmpty) continue;
    sb.write('${parts[i][0].toUpperCase()}${parts[i].substring(1)}');
  }
  return sb.toString();
}

/// Converts [fileName] in [fds] to an SBE XML schema, reading the `(sbe.*)`
/// options as protowire-go's `ProtoToXML` does: every message with a
/// `(sbe.template_id)` becomes an `<sbe:message>`, every other top-level
/// message and every message a field holds a composite, and a `string` or
/// `bytes` field with `(sbe.length) = N` a reference to a `strN` (char) or
/// `bytesN` (uint8) array type.
///
/// [protoToXml] sees only a [BuilderInfo], which carries no field options,
/// so it cannot write a fixed length. Use this one when the schema is
/// compiled: `protoc --descriptor_set_out=... --include_imports`.
///
/// [fds] may be parsed with or without [sbeExtensionRegistry]: an option
/// left in unknown fields is read from there. Throws [FormatException] when
/// [fileName] is not in [fds] or carries no `(sbe.schema_id)`.
String protoToXmlFromDescriptorSet(pbd.FileDescriptorSet fds, String fileName) {
  final fd = fds.file.where((f) => f.name == fileName).firstOrNull;
  if (fd == null) {
    throw FormatException('sbe: $fileName is not in the descriptor set');
  }
  final index = _DescriptorIndex(fds);
  final schemaId = _u32(fd.options, sbe_ann.Annotations.schemaId);
  if (schemaId == null) {
    throw FormatException('sbe: file $fileName missing (sbe.schema_id)');
  }
  final version = _u32(fd.options, sbe_ann.Annotations.version) ?? 0;
  final prefix = fd.package.isEmpty ? '.' : '.${fd.package}.';

  final strLengths = <int>{};
  final bytesLengths = <int>{};
  final composites = <pbd.DescriptorProto>[];
  final compSeen = <String>{};
  final enums = <pbd.EnumDescriptorProto>[];
  final enumSeen = <String>{};

  for (final ed in fd.enumType) {
    enums.add(ed);
    enumSeen.add('$prefix${ed.name}');
  }
  for (final md in fd.messageType) {
    final full = '$prefix${md.name}';
    if (_u32(md.options, sbe_ann.Annotations.templateId) != null) {
      _collect(md, full, index, strLengths, bytesLengths, composites, compSeen,
          enums, enumSeen);
    } else if (compSeen.add(full)) {
      composites.add(md);
    }
  }

  final sb = StringBuffer();
  sb.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  sb.writeln('<sbe:messageSchema xmlns:sbe="http://fixprotocol.io/2016/sbe"');
  sb.writeln('                   package="${fd.package}"');
  sb.writeln('                   id="$schemaId"');
  sb.writeln('                   version="$version"');
  sb.writeln('                   byteOrder="littleEndian">');
  sb.writeln('    <types>');
  sb.writeln('        <composite name="messageHeader">');
  sb.writeln('            <type name="blockLength" primitiveType="uint16"/>');
  sb.writeln('            <type name="templateId" primitiveType="uint16"/>');
  sb.writeln('            <type name="schemaId" primitiveType="uint16"/>');
  sb.writeln('            <type name="version" primitiveType="uint16"/>');
  sb.writeln('        </composite>');
  sb.writeln('        <composite name="groupSizeEncoding">');
  sb.writeln('            <type name="blockLength" primitiveType="uint16"/>');
  sb.writeln('            <type name="numInGroup" primitiveType="uint16"/>');
  sb.writeln('        </composite>');
  for (final l in strLengths.toList()..sort()) {
    sb.writeln('        <type name="str$l" primitiveType="char" length="$l"/>');
  }
  for (final l in bytesLengths.toList()..sort()) {
    sb.writeln(
        '        <type name="bytes$l" primitiveType="uint8" length="$l"/>');
  }
  for (final ed in enums) {
    sb.writeln('        <enum name="${ed.name}" encodingType="uint8">');
    for (final v in ed.value) {
      sb.writeln(
          '            <validValue name="${_stripEnumPrefix(v.name, ed.name)}">'
          '${v.number}</validValue>');
    }
    sb.writeln('        </enum>');
  }
  for (final md in composites) {
    sb.writeln('        <composite name="${md.name}">');
    for (final f in _byNumber(md)) {
      final t = _sbeType(f);
      final length = t.length > 0 ? ' length="${t.length}"' : '';
      sb.writeln('            <type name="${snakeToCamel(f.name)}" '
          'primitiveType="${t.primitiveType}"$length/>');
    }
    sb.writeln('        </composite>');
  }
  sb.writeln('    </types>');

  for (final md in fd.messageType) {
    final tid = _u32(md.options, sbe_ann.Annotations.templateId);
    if (tid == null) continue;
    sb.writeln('    <sbe:message name="${md.name}" id="$tid">');
    for (final f in _byNumber(md)) {
      if (_isList(f) && _isMessage(f)) {
        sb.writeln('        <group name="${snakeToCamel(f.name)}" '
            'id="${f.number}">');
        for (final g in _byNumber(index.message(f.typeName))) {
          _writeDescriptorField(sb, g, index, '            ');
        }
        sb.writeln('        </group>');
      } else {
        _writeDescriptorField(sb, f, index, '        ');
      }
    }
    sb.writeln('    </sbe:message>');
  }
  sb.writeln('</sbe:messageSchema>');
  return sb.toString();
}

/// The messages and enums of a descriptor set by fully-qualified name
/// (`.pkg.Outer.Inner`), as a field's `type_name` names them.
class _DescriptorIndex {
  final messages = <String, pbd.DescriptorProto>{};
  final enums = <String, pbd.EnumDescriptorProto>{};

  _DescriptorIndex(pbd.FileDescriptorSet fds) {
    for (final f in fds.file) {
      final prefix = f.package.isEmpty ? '.' : '.${f.package}.';
      for (final e in f.enumType) {
        enums['$prefix${e.name}'] = e;
      }
      for (final m in f.messageType) {
        _add(m, '$prefix${m.name}');
      }
    }
  }

  void _add(pbd.DescriptorProto m, String full) {
    messages[full] = m;
    for (final e in m.enumType) {
      enums['$full.${e.name}'] = e;
    }
    for (final n in m.nestedType) {
      _add(n, '$full.${n.name}');
    }
  }

  pbd.DescriptorProto message(String name) =>
      messages[name] ??
      (throw FormatException(
          'sbe: message $name is not in the descriptor set'));

  pbd.EnumDescriptorProto enumType(String name) =>
      enums[name] ??
      (throw FormatException('sbe: enum $name is not in the descriptor set'));
}

void _collect(
    pbd.DescriptorProto md,
    String full,
    _DescriptorIndex index,
    Set<int> strLengths,
    Set<int> bytesLengths,
    List<pbd.DescriptorProto> composites,
    Set<String> compSeen,
    List<pbd.EnumDescriptorProto> enums,
    Set<String> enumSeen) {
  for (final ed in md.enumType) {
    if (enumSeen.add('$full.${ed.name}')) enums.add(ed);
  }
  for (final f in md.field) {
    final length = _u32(f.options, sbe_ann.Annotations.length);
    if (length != null) {
      if (f.type == pbd.FieldDescriptorProto_Type.TYPE_STRING) {
        strLengths.add(length);
      } else if (f.type == pbd.FieldDescriptorProto_Type.TYPE_BYTES) {
        bytesLengths.add(length);
      }
    }
    if (f.type == pbd.FieldDescriptorProto_Type.TYPE_ENUM &&
        enumSeen.add(f.typeName)) {
      enums.add(index.enumType(f.typeName));
    }
    if (_isMessage(f)) {
      final sub = index.message(f.typeName);
      if (_isList(f)) {
        _collect(sub, f.typeName, index, strLengths, bytesLengths, composites,
            compSeen, enums, enumSeen);
      } else if (compSeen.add(f.typeName)) {
        composites.add(sub);
        _collect(sub, f.typeName, index, strLengths, bytesLengths, composites,
            compSeen, enums, enumSeen);
      }
    }
  }
}

void _writeDescriptorField(StringBuffer sb, pbd.FieldDescriptorProto f,
    _DescriptorIndex index, String indent) {
  final String type;
  if (f.type == pbd.FieldDescriptorProto_Type.TYPE_ENUM) {
    type = index.enumType(f.typeName).name;
  } else if (_isMessage(f) && !_isList(f)) {
    type = index.message(f.typeName).name;
  } else {
    type = _sbeType(f).xmlType;
  }
  sb.writeln('$indent<field name="${snakeToCamel(f.name)}" '
      'id="${f.number}" type="$type"/>');
}

List<pbd.FieldDescriptorProto> _byNumber(pbd.DescriptorProto md) =>
    md.field.toList()..sort((a, b) => a.number.compareTo(b.number));

bool _isList(pbd.FieldDescriptorProto f) =>
    f.label == pbd.FieldDescriptorProto_Label.LABEL_REPEATED;

bool _isMessage(pbd.FieldDescriptorProto f) =>
    f.type == pbd.FieldDescriptorProto_Type.TYPE_MESSAGE ||
    f.type == pbd.FieldDescriptorProto_Type.TYPE_GROUP;

/// A field's SBE type, as protowire-go's protoFieldToSBEType reads it.
_SbeTypeInfo _sbeType(pbd.FieldDescriptorProto f) {
  final enc = _str(f.options, sbe_ann.Annotations.encoding);
  if (enc != null) return _SbeTypeInfo(enc, enc, 0);

  // A bytes field is a uint8 array, not a char array: a char array imports
  // back as a string. Both are the same N bytes on the wire.
  final isString = f.type == pbd.FieldDescriptorProto_Type.TYPE_STRING;
  final isBytes = f.type == pbd.FieldDescriptorProto_Type.TYPE_BYTES;
  if (isString || isBytes) {
    final length = _u32(f.options, sbe_ann.Annotations.length) ?? 0;
    if (length == 0) return _SbeTypeInfo('char', 'char', 0);
    return isBytes
        ? _SbeTypeInfo('uint8', 'bytes$length', length)
        : _SbeTypeInfo('char', 'str$length', length);
  }
  switch (f.type) {
    case pbd.FieldDescriptorProto_Type.TYPE_BOOL:
      return _SbeTypeInfo('uint8', 'uint8', 0);
    case pbd.FieldDescriptorProto_Type.TYPE_INT32:
    case pbd.FieldDescriptorProto_Type.TYPE_SINT32:
    case pbd.FieldDescriptorProto_Type.TYPE_SFIXED32:
      return _SbeTypeInfo('int32', 'int32', 0);
    case pbd.FieldDescriptorProto_Type.TYPE_INT64:
    case pbd.FieldDescriptorProto_Type.TYPE_SINT64:
    case pbd.FieldDescriptorProto_Type.TYPE_SFIXED64:
      return _SbeTypeInfo('int64', 'int64', 0);
    case pbd.FieldDescriptorProto_Type.TYPE_UINT32:
    case pbd.FieldDescriptorProto_Type.TYPE_FIXED32:
      return _SbeTypeInfo('uint32', 'uint32', 0);
    case pbd.FieldDescriptorProto_Type.TYPE_UINT64:
    case pbd.FieldDescriptorProto_Type.TYPE_FIXED64:
      return _SbeTypeInfo('uint64', 'uint64', 0);
    case pbd.FieldDescriptorProto_Type.TYPE_FLOAT:
      return _SbeTypeInfo('float', 'float', 0);
    case pbd.FieldDescriptorProto_Type.TYPE_DOUBLE:
      return _SbeTypeInfo('double', 'double', 0);
    default:
      return _SbeTypeInfo('uint8', 'uint8', 0);
  }
}

/// A uint32 option, from the extension or, when [options] was parsed
/// without [sbeExtensionRegistry], from its unknown fields.
int? _u32(GeneratedMessage options, Extension ext) {
  if (options.hasExtension(ext)) return options.getExtension(ext) as int;
  final field = options.unknownFields.getField(ext.tagNumber);
  if (field == null || field.varints.isEmpty) return null;
  return field.varints.last.toInt() & 0xFFFFFFFF;
}

/// A string option, read as [_u32] reads one.
String? _str(GeneratedMessage options, Extension ext) {
  if (options.hasExtension(ext)) return options.getExtension(ext) as String;
  final field = options.unknownFields.getField(ext.tagNumber);
  if (field == null || field.lengthDelimited.isEmpty) return null;
  return utf8.decode(field.lengthDelimited.last);
}

/// An enum value's name without the enum's SCREAMING_SNAKE prefix, in
/// PascalCase, as protowire-go's stripEnumPrefix writes it.
String _stripEnumPrefix(String valueName, String enumName) {
  final prefix = '${camelToScreamingSnake(enumName)}_';
  final rest = valueName.startsWith(prefix)
      ? valueName.substring(prefix.length)
      : valueName;
  return rest
      .toLowerCase()
      .split('_')
      .where((p) => p.isNotEmpty)
      .map((p) => '${p[0].toUpperCase()}${p.substring(1)}')
      .join();
}
