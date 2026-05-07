// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'package:protobuf/protobuf.dart';

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
