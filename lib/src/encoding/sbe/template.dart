import 'package:protobuf/protobuf.dart';
import 'sbe.dart';

class MessageTemplate {
  final int templateID;
  final int schemaID;
  final int version;
  final int blockLength;
  final List<FieldTemplate> fields;
  final List<GroupTemplate> groups;
  late final ViewSchema view;

  MessageTemplate({
    required this.templateID,
    required this.schemaID,
    required this.version,
    required this.blockLength,
    required this.fields,
    required this.groups,
  }) {
    view = buildViewSchema(this);
  }
}

class FieldTemplate {
  final FieldInfo fi;
  final int offset;
  final int size;
  final String? encoding;
  final List<FieldTemplate>? composite;
  ViewSchema? compositeView;

  FieldTemplate({
    required this.fi,
    required this.offset,
    required this.size,
    this.encoding,
    this.composite,
  });
}

class GroupTemplate {
  final FieldInfo fi;
  final int blockLength;
  final List<FieldTemplate> fields;

  GroupTemplate({
    required this.fi,
    required this.blockLength,
    required this.fields,
  });
}

class ViewSchema {
  final Map<String, FieldTemplate> fields;
  final List<ViewGroupInfo> groupOrder;

  ViewSchema({required this.fields, required this.groupOrder});
}

class ViewGroupInfo {
  final String name;
  final ViewSchema schema;

  ViewGroupInfo({required this.name, required this.schema});
}

ViewSchema buildViewSchema(MessageTemplate tmpl) {
  final fieldMap = <String, FieldTemplate>{};
  for (final ft in tmpl.fields) {
    fieldMap[ft.fi.name] = ft;
    if (ft.composite != null) {
      ft.compositeView = _buildFieldsViewSchema(ft.composite!);
    }
  }
  final groupOrder = <ViewGroupInfo>[];
  for (final gt in tmpl.groups) {
    groupOrder.add(ViewGroupInfo(
      name: gt.fi.name,
      schema: _buildFieldsViewSchema(gt.fields),
    ));
  }
  return ViewSchema(fields: fieldMap, groupOrder: groupOrder);
}

ViewSchema _buildFieldsViewSchema(List<FieldTemplate> fields) {
  final fieldMap = <String, FieldTemplate>{};
  for (final ft in fields) {
    fieldMap[ft.fi.name] = ft;
    if (ft.composite != null) {
      ft.compositeView = _buildFieldsViewSchema(ft.composite!);
    }
  }
  return ViewSchema(fields: fieldMap, groupOrder: []);
}

// buildTemplate creates an SBE layout for a message.
MessageTemplate buildTemplate(
  BuilderInfo info,
  int templateId,
  int schemaId,
  int version, {
  Map<int, int>? lengths,
  Map<int, String>? encodings,
}) {
  final sortedTags = info.fieldInfo.keys.toList()..sort();
  
  final fields = <FieldTemplate>[];
  final groups = <GroupTemplate>[];
  int offset = 0;

  for (final tag in sortedTags) {
    final fi = info.fieldInfo[tag]!;

    if (fi.isRepeated && (fi.type & _MESSAGE_BIT) != 0) {
      final gt = _buildGroupTemplate(fi, lengths: lengths, encodings: encodings);
      groups.add(gt);
      continue;
    }

    if (fi.isRepeated) {
      throw Exception('sbe: repeated scalar field ${info.qualifiedMessageName}.${fi.name} not supported');
    }

    if ((fi.type & _MESSAGE_BIT) != 0) {
      final subInfo = fi.subBuilder!().info_;
      final composite = _buildCompositeFields(subInfo, lengths: lengths, encodings: encodings);
      int size = 0;
      for (final f in composite) {
        size += f.size;
      }
      fields.add(FieldTemplate(
        fi: fi,
        offset: offset,
        size: size,
        composite: composite,
      ));
      offset += size;
      continue;
    }

    final res = _fieldEncodingSize(fi, lengths?[tag], encodings?[tag]);
    final enc = res.$1;
    final size = res.$2;

    fields.add(FieldTemplate(
      fi: fi,
      offset: offset,
      size: size,
      encoding: enc,
    ));
    offset += size;
  }

  return MessageTemplate(
    templateID: templateId,
    schemaID: schemaId,
    version: version,
    blockLength: offset,
    fields: fields,
    groups: groups,
  );
}

GroupTemplate _buildGroupTemplate(FieldInfo fi, {Map<int, int>? lengths, Map<int, String>? encodings}) {
  final subInfo = fi.subBuilder!().info_;
  final sortedTags = subInfo.fieldInfo.keys.toList()..sort();
  
  final fields = <FieldTemplate>[];
  int offset = 0;

  for (final tag in sortedTags) {
    final sfi = subInfo.fieldInfo[tag]!;
    if ((sfi.type & _MESSAGE_BIT) != 0) {
        final composite = _buildCompositeFields(sfi.subBuilder!().info_, lengths: lengths, encodings: encodings);
        int size = 0;
        for (final f in composite) size += f.size;
        fields.add(FieldTemplate(fi: sfi, offset: offset, size: size, composite: composite));
        offset += size;
        continue;
    }

    final res = _fieldEncodingSize(sfi, lengths?[tag], encodings?[tag]);
    final enc = res.$1;
    final size = res.$2;

    fields.add(FieldTemplate(fi: sfi, offset: offset, size: size, encoding: enc));
    offset += size;
  }

  return GroupTemplate(fi: fi, blockLength: offset, fields: fields);
}

List<FieldTemplate> _buildCompositeFields(BuilderInfo info, {Map<int, int>? lengths, Map<int, String>? encodings}) {
  final sortedTags = info.fieldInfo.keys.toList()..sort();
  final fields = <FieldTemplate>[];
  int offset = 0;

  for (final tag in sortedTags) {
    final fi = info.fieldInfo[tag]!;
    if ((fi.type & _MESSAGE_BIT) != 0) {
        final composite = _buildCompositeFields(fi.subBuilder!().info_, lengths: lengths, encodings: encodings);
        int size = 0;
        for (final f in composite) size += f.size;
        fields.add(FieldTemplate(fi: fi, offset: offset, size: size, composite: composite));
        offset += size;
        continue;
    }

    final res = _fieldEncodingSize(fi, lengths?[tag], encodings?[tag]);
    final enc = res.$1;
    final size = res.$2;

    fields.add(FieldTemplate(fi: fi, offset: offset, size: size, encoding: enc));
    offset += size;
  }
  return fields;
}

(String, int) _fieldEncodingSize(FieldInfo fi, int? lengthOverride, String? encodingOverride) {
  if (encodingOverride != null) {
    switch (encodingOverride) {
      case encInt8:
      case encUint8:
        return (encodingOverride, 1);
      case encInt16:
      case encUint16:
        return (encodingOverride, 2);
      case encInt32:
      case encUint32:
      case encFloat:
        return (encodingOverride, 4);
      case encInt64:
      case encUint64:
      case encDouble:
        return (encodingOverride, 8);
      default:
        throw Exception('unknown encoding $encodingOverride');
    }
  }

  int type = fi.type;
  if ((type & _BOOL_BIT) != 0) return (encUint8, 1);
  if ((type & _INT32_BIT) != 0 || 
      (type & _SINT32_BIT) != 0 || 
      (type & _SFIXED32_BIT) != 0) return (encInt32, 4);
  if ((type & _INT64_BIT) != 0 || 
      (type & _SINT64_BIT) != 0 || 
      (type & _SFIXED64_BIT) != 0) return (encInt64, 8);
  if ((type & _UINT32_BIT) != 0 || 
      (type & _FIXED32_BIT) != 0) return (encUint32, 4);
  if ((type & _UINT64_BIT) != 0 || 
      (type & _FIXED64_BIT) != 0) return (encUint64, 8);
  if ((type & _FLOAT_BIT) != 0) return (encFloat, 4);
  if ((type & _DOUBLE_BIT) != 0) return (encDouble, 8);
  if ((type & _ENUM_BIT) != 0) return (encUint8, 1);
  
  if ((type & _STRING_BIT) != 0 || (type & _BYTES_BIT) != 0) {
    if (lengthOverride == null) {
      throw Exception('sbe: string/bytes field ${fi.name} requires length override/annotation');
    }
    return (encChar, lengthOverride);
  }

  throw Exception('unsupported proto type for ${fi.name}');
}

// Redefine private bits for convenience
const int _BOOL_BIT = 0x10;
const int _BYTES_BIT = 0x20;
const int _STRING_BIT = 0x40;
const int _DOUBLE_BIT = 0x80;
const int _FLOAT_BIT = 0x100;
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
