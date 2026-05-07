// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'package:xml/xml.dart';

class XMLSchema {
  final String? package;
  final int id;
  final int version;
  final String? byteOrder;
  final String? description;
  final List<XMLType> types;
  final List<XMLComposite> composites;
  final List<XMLEnum> enums;
  final List<XMLMessage> messages;

  XMLSchema({
    this.package,
    required this.id,
    required this.version,
    this.byteOrder,
    this.description,
    required this.types,
    required this.composites,
    required this.enums,
    required this.messages,
  });

  factory XMLSchema.fromXml(XmlDocument document) {
    final root = document.rootElement;
    if (root.name.local != 'messageSchema') {
      throw Exception('sbe: invalid root element: ${root.name.local}');
    }

    final typesElement = root.findElements('types').firstOrNull;
    final types = <XMLType>[];
    final composites = <XMLComposite>[];
    final enums = <XMLEnum>[];

    if (typesElement != null) {
      for (final node in typesElement.children) {
        if (node is XmlElement) {
          switch (node.name.local) {
            case 'type':
              types.add(XMLType.fromXml(node));
              break;
            case 'composite':
              composites.add(XMLComposite.fromXml(node));
              break;
            case 'enum':
              enums.add(XMLEnum.fromXml(node));
              break;
          }
        }
      }
    }

    final messages =
        root.findElements('message').map((e) => XMLMessage.fromXml(e)).toList();

    return XMLSchema(
      package: root.getAttribute('package'),
      id: int.parse(root.getAttribute('id') ?? '0'),
      version: int.parse(root.getAttribute('version') ?? '0'),
      byteOrder: root.getAttribute('byteOrder'),
      description: root.getAttribute('description'),
      types: types,
      composites: composites,
      enums: enums,
      messages: messages,
    );
  }
}

class XMLType {
  final String name;
  final String primitiveType;
  final int? length;
  final String? description;

  XMLType({
    required this.name,
    required this.primitiveType,
    this.length,
    this.description,
  });

  factory XMLType.fromXml(XmlElement element) {
    return XMLType(
      name: element.getAttribute('name') ?? '',
      primitiveType: element.getAttribute('primitiveType') ?? '',
      length: int.tryParse(element.getAttribute('length') ?? ''),
      description: element.getAttribute('description'),
    );
  }
}

class XMLComposite {
  final String name;
  final String? description;
  final List<XMLType> types;
  final List<XMLRef> refs;

  XMLComposite({
    required this.name,
    this.description,
    required this.types,
    required this.refs,
  });

  factory XMLComposite.fromXml(XmlElement element) {
    final types =
        element.findElements('type').map((e) => XMLType.fromXml(e)).toList();
    final refs =
        element.findElements('ref').map((e) => XMLRef.fromXml(e)).toList();
    return XMLComposite(
      name: element.getAttribute('name') ?? '',
      description: element.getAttribute('description'),
      types: types,
      refs: refs,
    );
  }
}

class XMLRef {
  final String name;
  final String type;

  XMLRef({required this.name, required this.type});

  factory XMLRef.fromXml(XmlElement element) {
    return XMLRef(
      name: element.getAttribute('name') ?? '',
      type: element.getAttribute('type') ?? '',
    );
  }
}

class XMLEnum {
  final String name;
  final String encodingType;
  final String? description;
  final List<XMLValidValue> validValues;

  XMLEnum({
    required this.name,
    required this.encodingType,
    this.description,
    required this.validValues,
  });

  factory XMLEnum.fromXml(XmlElement element) {
    final validValues = element
        .findElements('validValue')
        .map((e) => XMLValidValue.fromXml(e))
        .toList();
    return XMLEnum(
      name: element.getAttribute('name') ?? '',
      encodingType: element.getAttribute('encodingType') ?? '',
      description: element.getAttribute('description'),
      validValues: validValues,
    );
  }
}

class XMLValidValue {
  final String name;
  final String value;

  XMLValidValue({required this.name, required this.value});

  factory XMLValidValue.fromXml(XmlElement element) {
    return XMLValidValue(
      name: element.getAttribute('name') ?? '',
      value: element.innerText,
    );
  }
}

class XMLMessage {
  final String name;
  final int id;
  final String? description;
  final List<XMLField> fields;
  final List<XMLGroup> groups;

  XMLMessage({
    required this.name,
    required this.id,
    this.description,
    required this.fields,
    required this.groups,
  });

  factory XMLMessage.fromXml(XmlElement element) {
    final fields =
        element.findElements('field').map((e) => XMLField.fromXml(e)).toList();
    final groups =
        element.findElements('group').map((e) => XMLGroup.fromXml(e)).toList();
    return XMLMessage(
      name: element.getAttribute('name') ?? '',
      id: int.parse(element.getAttribute('id') ?? '0'),
      description: element.getAttribute('description'),
      fields: fields,
      groups: groups,
    );
  }
}

class XMLField {
  final String name;
  final int id;
  final String type;

  XMLField({required this.name, required this.id, required this.type});

  factory XMLField.fromXml(XmlElement element) {
    return XMLField(
      name: element.getAttribute('name') ?? '',
      id: int.parse(element.getAttribute('id') ?? '0'),
      type: element.getAttribute('type') ?? '',
    );
  }
}

class XMLGroup {
  final String name;
  final int id;
  final List<XMLField> fields;

  XMLGroup({required this.name, required this.id, required this.fields});

  factory XMLGroup.fromXml(XmlElement element) {
    final fields =
        element.findElements('field').map((e) => XMLField.fromXml(e)).toList();
    return XMLGroup(
      name: element.getAttribute('name') ?? '',
      id: int.parse(element.getAttribute('id') ?? '0'),
      fields: fields,
    );
  }
}

String camelToSnake(String s) {
  final sb = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final char = s[i];
    if (char.toUpperCase() == char && i > 0) {
      sb.write('_');
    }
    sb.write(char.toLowerCase());
  }
  return sb.toString();
}

String camelToScreamingSnake(String s) {
  final sb = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final char = s[i];
    if (char.toUpperCase() == char && i > 0) {
      sb.write('_');
    }
    sb.write(char.toUpperCase());
  }
  return sb.toString();
}

String singularPascal(String s) {
  if (s.isEmpty) return s;
  String res = s;
  if (res.endsWith('ies') && res.length > 3) {
    res = '${res.substring(0, res.length - 3)}y';
  } else if (res.endsWith('s') && !res.endsWith('ss') && res.length > 1) {
    res = res.substring(0, res.length - 1);
  }
  return '${res[0].toUpperCase()}${res.substring(1)}';
}
