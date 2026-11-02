// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'dart:collection';
import 'dart:mirrors';
import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';

class ProtoTag {
  final int tag;
  final bool zigzag;
  const ProtoTag(this.tag, {this.zigzag = false});
}

/// Encodes [obj], whose fields carry [ProtoTag]s, as protobuf binary. A
/// `Map<K, V>` field is a proto3 map: `repeated MapEntry { key = 1; value = 2; }`,
/// each entry carrying both, zero-valued or not. Another annotated class is a
/// message field or a map's message value.
Uint8List marshalNative(Object obj) => _toMessage(obj).writeToBuffer();

void unmarshalNative(Uint8List data, Object obj) {
  final root = _DynamicMessage(_builderFor(obj.runtimeType));
  root.mergeFromBuffer(data);
  _populateNativeObject(obj, root, _getStructInfo(obj.runtimeType));
}

class _StructInfo {
  final Map<int, _FieldInfo> byTag = {};
  final Map<Symbol, _FieldInfo> bySymbol = {};
}

class _FieldInfo {
  final Symbol symbol;
  final int tag;
  final bool zigzag;
  final TypeMirror mirror;
  _FieldInfo(this.symbol, this.tag, this.zigzag, this.mirror);

  Type get type => mirror.reflectedType;
  String get name => MirrorSystem.getName(symbol);
  bool get isMap => mirror.qualifiedName == #dart.core.Map;
  TypeMirror get keyMirror => mirror.typeArguments[0];
  TypeMirror get valueMirror => mirror.typeArguments[1];
}

final Map<Type, _StructInfo> _cache = {};
final Map<Type, BuilderInfo> _builders = {};

_StructInfo _getStructInfo(Type type) {
  if (_cache.containsKey(type)) return _cache[type]!;

  final info = _StructInfo();
  final classMirror = reflectClass(type);

  for (final declaration in classMirror.declarations.values) {
    if (declaration is VariableMirror) {
      for (final instance in declaration.metadata) {
        final reflectee = instance.reflectee;
        if (reflectee is ProtoTag) {
          final fi = _FieldInfo(declaration.simpleName, reflectee.tag,
              reflectee.zigzag, declaration.type);
          info.byTag[fi.tag] = fi;
          info.bySymbol[fi.symbol] = fi;
        }
      }
    }
  }

  _cache[type] = info;
  return info;
}

/// One message's fields, cached before they are added so a recursive type
/// terminates.
BuilderInfo _builderFor(Type type) {
  final cached = _builders[type];
  if (cached != null) return cached;
  final builder = _builders[type] = BuilderInfo(type.toString());
  for (final fi in _getStructInfo(type).byTag.values) {
    if (fi.isMap) {
      _addMapField(builder, type, fi);
    } else {
      final pbType = _getPbType(fi.type, fi.zigzag, type, fi.name);
      builder.add(fi.tag, fi.name, pbType, _getDefault(fi.type),
          _subBuilder(pbType, fi.type), null, null);
    }
  }
  return builder;
}

void _addMapField(BuilderInfo builder, Type owner, _FieldInfo fi) {
  if (fi.mirror.typeArguments.length != 2) {
    throw ArgumentError('$owner.${fi.name}: a map field needs Map<K, V>');
  }
  final key = fi.keyMirror.reflectedType;
  final value = fi.valueMirror.reflectedType;
  final keyType = _getPbType(key, false, owner, fi.name);
  if (keyType == PbFieldType.OD ||
      keyType == PbFieldType.OY ||
      PbFieldType.isGroupOrMessage(keyType)) {
    throw ArgumentError('$owner.${fi.name}: $key is not a valid map key type');
  }
  final valueType = _getPbType(value, false, owner, fi.name);
  builder.m<dynamic, dynamic>(
    fi.tag,
    fi.name,
    entryClassName: '$owner.${fi.name}Entry',
    keyFieldType: keyType,
    valueFieldType: valueType,
    valueCreator: _subBuilder(valueType, value),
    valueDefaultOrMaker: _getDefault(value),
  );
}

CreateBuilderFunc? _subBuilder(int pbType, Type type) =>
    PbFieldType.isGroupOrMessage(pbType)
        ? () => _DynamicMessage(_builderFor(type))
        : null;

int _getPbType(Type type, bool zigzag, Type owner, String field) {
  if (type == int) return zigzag ? PbFieldType.OS3 : PbFieldType.O3;
  if (type == Int64) return zigzag ? PbFieldType.OS6 : PbFieldType.O6;
  if (type == String) return PbFieldType.OS;
  if (type == bool) return PbFieldType.OB;
  if (type == double) return PbFieldType.OD;
  if (type == Uint8List) return PbFieldType.OY;
  if (_getStructInfo(type).byTag.isEmpty) {
    throw ArgumentError(
        '$owner.$field: $type is not a supported field type, and has no '
        '@ProtoTag fields to encode as a message');
  }
  return PbFieldType.OM;
}

dynamic _getDefault(Type type) {
  if (type == int) return 0;
  if (type == Int64) return Int64.ZERO;
  if (type == String) return '';
  if (type == bool) return false;
  if (type == double) return 0.0;
  return null;
}

bool _isScalar(Type type) => _getDefault(type) != null || type == Uint8List;

GeneratedMessage _toMessage(Object obj) {
  final msg = _DynamicMessage(_builderFor(obj.runtimeType));
  _populateGeneratedMessage(msg, obj, _getStructInfo(obj.runtimeType));
  return msg;
}

void _populateGeneratedMessage(
    GeneratedMessage msg, Object obj, _StructInfo info) {
  final instanceMirror = reflect(obj);
  for (final fi in info.bySymbol.values) {
    final value = instanceMirror.getField(fi.symbol).reflectee;
    if (value == null) continue;
    if (fi.isMap) {
      final target = msg.getField(fi.tag) as Map;
      final scalar = _isScalar(fi.valueMirror.reflectedType);
      (value as Map).forEach((k, v) {
        target[k] = scalar ? v : _toMessage(v as Object);
      });
    } else {
      msg.setField(fi.tag, _isScalar(fi.type) ? value : _toMessage(value));
    }
  }
}

void _populateNativeObject(Object obj, GeneratedMessage msg, _StructInfo info) {
  final instanceMirror = reflect(obj);
  for (final fi in info.byTag.values) {
    if (!msg.hasField(fi.tag)) continue;
    final value = msg.getField(fi.tag);
    if (fi.isMap) {
      instanceMirror.setField(fi.symbol, _nativeMap(fi, value as Map));
    } else if (_isScalar(fi.type)) {
      instanceMirror.setField(fi.symbol, value);
    } else {
      instanceMirror.setField(
          fi.symbol, _nativeMessage(fi.type, value as GeneratedMessage));
    }
  }
}

/// A `Map<K, V>` of the field's own type: the field rejects a dynamic map.
Object _nativeMap(_FieldInfo fi, Map entries) {
  final key = fi.keyMirror.reflectedType;
  final value = fi.valueMirror.reflectedType;
  final mapType = reflectType(LinkedHashMap, [key, value]) as ClassMirror;
  final out = mapType.newInstance(Symbol.empty, const []);
  final scalar = _isScalar(value);
  entries.forEach((k, v) {
    out.invoke(const Symbol('[]='),
        [k, scalar ? v : _nativeMessage(value, v as GeneratedMessage)]);
  });
  return out.reflectee as Object;
}

Object _nativeMessage(Type type, GeneratedMessage msg) {
  final obj = reflectClass(type).newInstance(Symbol.empty, const []).reflectee
      as Object;
  _populateNativeObject(obj, msg, _getStructInfo(type));
  return obj;
}

class _DynamicMessage extends GeneratedMessage {
  final BuilderInfo _info;
  _DynamicMessage(this._info);

  @override
  BuilderInfo get info_ => _info;

  @override
  GeneratedMessage createEmptyInstance() => _DynamicMessage(_info);

  @override
  GeneratedMessage clone() => _DynamicMessage(_info)..mergeFromMessage(this);
}
