// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'package:xml/xml.dart';
import 'xmlschema.dart';

String xmlToProto(String xmlData) {
  final document = XmlDocument.parse(xmlData);
  final schema = XMLSchema.fromXml(document);
  return generateProto(schema);
}

String generateProto(XMLSchema schema) {
  final typeMap = <String, XMLType>{};
  final compositeMap = <String, XMLComposite>{};
  final enumMap = <String, XMLEnum>{};

  for (final name in [
    'int8',
    'int16',
    'int32',
    'int64',
    'uint8',
    'uint16',
    'uint32',
    'uint64',
    'float',
    'double',
    'char'
  ]) {
    typeMap[name] = XMLType(name: name, primitiveType: name);
  }

  for (final t in schema.types) {
    typeMap[t.name] = t;
  }
  for (final c in schema.composites) {
    compositeMap[c.name] = c;
  }
  for (final e in schema.enums) {
    enumMap[e.name] = e;
  }

  final sb = StringBuffer();
  sb.writeln('syntax = "proto3";');
  sb.writeln();
  if (schema.package != null) {
    sb.writeln('package ${schema.package};');
    sb.writeln();
  }
  sb.writeln('import "sbe/annotations.proto";');
  sb.writeln();
  sb.writeln('option (sbe.schema_id) = ${schema.id};');
  sb.writeln('option (sbe.version) = ${schema.version};');
  sb.writeln();

  for (final e in schema.enums) {
    _writeProtoEnum(sb, e, '');
  }

  for (final c in schema.composites) {
    if (c.name == 'messageHeader' || c.name == 'groupSizeEncoding') {
      continue;
    }
    _writeProtoComposite(sb, c);
  }

  for (final msg in schema.messages) {
    _writeProtoMessage(sb, msg, typeMap, compositeMap, enumMap, '');
  }

  return sb.toString();
}

void _writeProtoEnum(StringBuffer sb, XMLEnum e, String indent) {
  sb.writeln('${indent}enum ${e.name} {');
  final prefix = camelToScreamingSnake(e.name);
  for (final v in e.validValues) {
    final name = '${prefix}_${camelToScreamingSnake(v.name)}';
    sb.writeln('$indent  $name = ${v.value};');
  }
  sb.writeln('$indent}');
  sb.writeln();
}

void _writeProtoComposite(StringBuffer sb, XMLComposite c) {
  sb.writeln('message ${c.name} {');
  int fieldNum = 1;
  for (final t in c.types) {
    final (protoType, opts, note) =
        _resolve(t, () => 'sbe: composite "${c.name}"');
    final name = camelToSnake(t.name);
    _writeNote(sb, '  ', note);
    if (opts.isNotEmpty) {
      sb.writeln('  $protoType $name = $fieldNum [$opts];');
    } else {
      sb.writeln('  $protoType $name = $fieldNum;');
    }
    fieldNum++;
  }
  for (final r in c.refs) {
    final name = camelToSnake(r.name);
    sb.writeln('  ${r.type} $name = $fieldNum;');
    fieldNum++;
  }
  sb.writeln('}');
  sb.writeln();
}

void _writeProtoMessage(
    StringBuffer sb,
    XMLMessage msg,
    Map<String, XMLType> typeMap,
    Map<String, XMLComposite> compositeMap,
    Map<String, XMLEnum> enumMap,
    String indent) {
  sb.writeln('${indent}message ${msg.name} {');
  sb.writeln('$indent  option (sbe.template_id) = ${msg.id};');
  sb.writeln();

  final where = 'sbe: message "${msg.name}"';
  for (final f in msg.fields) {
    _writeProtoField(sb, f, typeMap, compositeMap, enumMap, '$indent  ', where);
  }
  for (final g in msg.groups) {
    _writeProtoGroup(sb, g, typeMap, compositeMap, enumMap, '$indent  ', where);
  }
  sb.writeln('$indent}');
  sb.writeln();
}

void _writeProtoField(
    StringBuffer sb,
    XMLField f,
    Map<String, XMLType> typeMap,
    Map<String, XMLComposite> compositeMap,
    Map<String, XMLEnum> enumMap,
    String indent,
    String where) {
  final name = camelToSnake(f.name);

  if (enumMap.containsKey(f.type)) {
    sb.writeln('$indent${f.type} $name = ${f.id};');
    return;
  }

  if (compositeMap.containsKey(f.type)) {
    sb.writeln('$indent${f.type} $name = ${f.id};');
    return;
  }

  if (typeMap.containsKey(f.type)) {
    final t = typeMap[f.type]!;
    final (protoType, opts, note) =
        _resolve(t, () => '$where: field "${f.name}"');
    _writeNote(sb, indent, note);
    if (opts.isNotEmpty) {
      sb.writeln('$indent$protoType $name = ${f.id} [$opts];');
    } else {
      sb.writeln('$indent$protoType $name = ${f.id};');
    }
    return;
  }

  sb.writeln('$indent${f.type} $name = ${f.id};');
}

void _writeProtoGroup(
    StringBuffer sb,
    XMLGroup g,
    Map<String, XMLType> typeMap,
    Map<String, XMLComposite> compositeMap,
    Map<String, XMLEnum> enumMap,
    String indent,
    String where) {
  final msgName = singularPascal(g.name);
  sb.writeln('${indent}message $msgName {');
  for (final f in g.fields) {
    _writeProtoField(sb, f, typeMap, compositeMap, enumMap, '$indent  ',
        '$where: group "${g.name}"');
  }
  sb.writeln('$indent}');
  final fieldName = camelToSnake(g.name);
  sb.writeln('${indent}repeated $msgName $fieldName = ${g.id};');
}

/// [t]'s proto type, field options, and a note for the line above the field
/// (empty for none). An array no proto field can hold throws, naming it with
/// [where], rather than importing as one element and misplacing every later
/// field in the block (draft -01 § Fixed-Length Arrays).
(String, String, String) _resolve(XMLType t, String Function() where) {
  if (t.primitiveType == 'char') {
    final length = (t.length ?? 0) == 0 ? 1 : t.length!;
    final opts = '(sbe.length) = $length';
    if (!_isUtf8Compatible(t.characterEncoding ?? '')) {
      // A proto string holds UTF-8 only, and a decoder refuses a string that
      // is not, so text in another encoding is carried as bytes rather than
      // failing at run time (draft -01 § Character Encoding).
      return (
        'bytes',
        opts,
        'SBE characterEncoding "${t.characterEncoding}" is not UTF-8 '
            'compatible, so this field is bytes.'
      );
    }
    return ('string', opts, '');
  }
  final length = t.length ?? 0;
  if (length > 1) {
    if (t.primitiveType == 'uint8' || t.primitiveType == 'int8') {
      // A fixed-length array of octets is raw bytes, the same N bytes on the
      // wire as a bytes field with (sbe.length) = N.
      return ('bytes', '(sbe.length) = $length', '');
    }
    throw FormatException('${where()}: type "${t.name}" is an array of '
        '$length ${t.primitiveType}, which no proto field represents');
  }
  final (protoType, opts) = _resolvePrimitive(t.primitiveType);
  return (protoType, opts, '');
}

void _writeNote(StringBuffer sb, String indent, String note) {
  if (note.isNotEmpty) sb.writeln('$indent// $note');
}

/// Whether every string in a char array of the named [encoding] is valid
/// UTF-8: none named (FIX SBE's default is US-ASCII), a US-ASCII name, or a
/// UTF-8 name. Names are IANA charset names and their registered aliases,
/// compared ignoring case and punctuation. Mirrors protowire-go's
/// isUTF8Compatible.
bool _isUtf8Compatible(String encoding) {
  final name = encoding.trim().toLowerCase().replaceAll(RegExp(r'[-_.: ]'), '');
  return const {
    '',
    // US-ASCII and its IANA aliases.
    'usascii', 'ascii', 'ansix341968', 'ansix341986', 'iso646us',
    'isoir6', 'iso646irv1991', 'us', 'ibm367', 'cp367', 'csascii',
    // UTF-8.
    'utf8', 'csutf8',
  }.contains(name);
}

/// An SBE primitive type other than char.
(String, String) _resolvePrimitive(String primitiveType) {
  switch (primitiveType) {
    case 'int8':
      return ('int32', '(sbe.encoding) = "int8"');
    case 'int16':
      return ('int32', '(sbe.encoding) = "int16"');
    case 'int32':
      return ('int32', '');
    case 'int64':
      return ('int64', '');
    case 'uint8':
      return ('uint32', '(sbe.encoding) = "uint8"');
    case 'uint16':
      return ('uint32', '(sbe.encoding) = "uint16"');
    case 'uint32':
      return ('uint32', '');
    case 'uint64':
      return ('uint64', '');
    case 'float':
      return ('float', '');
    case 'double':
      return ('double', '');
    default:
      return (primitiveType, '');
  }
}
