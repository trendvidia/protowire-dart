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

  for (final name in ['int8', 'int16', 'int32', 'int64',
    'uint8', 'uint16', 'uint32', 'uint64', 'float', 'double', 'char']) {
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
    sb.writeln('${indent}  $name = ${v.value};');
  }
  sb.writeln('${indent}}');
  sb.writeln();
}

void _writeProtoComposite(StringBuffer sb, XMLComposite c) {
  sb.writeln('message ${c.name} {');
  int fieldNum = 1;
  for (final t in c.types) {
    final res = _resolveTypeToProto(t.primitiveType, t.length ?? 0);
    final protoType = res.$1;
    final opts = res.$2;
    final name = camelToSnake(t.name);
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

void _writeProtoMessage(StringBuffer sb, XMLMessage msg, Map<String, XMLType> typeMap, Map<String, XMLComposite> compositeMap, Map<String, XMLEnum> enumMap, String indent) {
  sb.writeln('${indent}message ${msg.name} {');
  sb.writeln('${indent}  option (sbe.template_id) = ${msg.id};');
  sb.writeln();

  for (final f in msg.fields) {
    _writeProtoField(sb, f, typeMap, compositeMap, enumMap, '$indent  ');
  }
  for (final g in msg.groups) {
    _writeProtoGroup(sb, g, typeMap, compositeMap, enumMap, '$indent  ');
  }
  sb.writeln('${indent}}');
  sb.writeln();
}

void _writeProtoField(StringBuffer sb, XMLField f, Map<String, XMLType> typeMap, Map<String, XMLComposite> compositeMap, Map<String, XMLEnum> enumMap, String indent) {
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
    final res = _resolveTypeToProto(t.primitiveType, t.length ?? 0);
    final protoType = res.$1;
    final opts = res.$2;
    if (opts.isNotEmpty) {
      sb.writeln('$indent$protoType $name = ${f.id} [$opts];');
    } else {
      sb.writeln('$indent$protoType $name = ${f.id};');
    }
    return;
  }

  sb.writeln('$indent${f.type} $name = ${f.id};');
}

void _writeProtoGroup(StringBuffer sb, XMLGroup g, Map<String, XMLType> typeMap, Map<String, XMLComposite> compositeMap, Map<String, XMLEnum> enumMap, String indent) {
  final msgName = singularPascal(g.name);
  sb.writeln('${indent}message $msgName {');
  for (final f in g.fields) {
    _writeProtoField(sb, f, typeMap, compositeMap, enumMap, '$indent  ');
  }
  sb.writeln('${indent}}');
  final fieldName = camelToSnake(g.name);
  sb.writeln('${indent}repeated $msgName $fieldName = ${g.id};');
}

(String, String) _resolveTypeToProto(String primitiveType, int length) {
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
    case 'char':
      if (length > 0) {
        return ('string', '(sbe.length) = $length');
      }
      return ('string', '(sbe.length) = 1');
    default:
      return (primitiveType, '');
  }
}
