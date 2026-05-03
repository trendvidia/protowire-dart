/// Reflection-driven Protobuf binary codec for arbitrary Dart classes
/// annotated with `@ProtoTag`.
///
/// **JIT / development only.** This file uses `dart:mirrors`, which Dart
/// explicitly does not support on Flutter or in any AOT-compiled binary
/// (`dart compile exe`, `dart compile aot-snapshot`). It must not be used
/// in production. The umbrella `package:protowire/protowire.dart` does
/// not re-export it; importing it requires opting in via the explicit
/// path `package:protowire/src/encoding/pb/native.dart`.
///
/// The signatures it relies on inside `package:protobuf` (notably
/// `BuilderInfo.add` with positional arguments) are not part of the
/// protobuf package's documented public API and may break across minor
/// version bumps.
library;

import 'dart:mirrors';
import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';

class ProtoTag {
  final int tag;
  final bool zigzag;
  const ProtoTag(this.tag, {this.zigzag = false});
}

Uint8List marshalNative(Object obj) {
  final info = _getStructInfo(obj.runtimeType);
  final root = _createGeneratedMessage(obj.runtimeType, info);
  _populateGeneratedMessage(root, obj, info);
  return root.writeToBuffer();
}

void unmarshalNative(Uint8List data, Object obj) {
  final info = _getStructInfo(obj.runtimeType);
  final root = _createGeneratedMessage(obj.runtimeType, info);
  root.mergeFromBuffer(data);
  _populateNativeObject(obj, root, info);
}

class _StructInfo {
  final Map<int, _FieldInfo> byTag = {};
  final Map<Symbol, _FieldInfo> bySymbol = {};
}

class _FieldInfo {
  final Symbol symbol;
  final int tag;
  final bool zigzag;
  final Type type;
  _FieldInfo(this.symbol, this.tag, this.zigzag, this.type);
}

final Map<Type, _StructInfo> _cache = {};

_StructInfo _getStructInfo(Type type) {
  if (_cache.containsKey(type)) return _cache[type]!;

  final info = _StructInfo();
  final classMirror = reflectClass(type);
  
  for (final declaration in classMirror.declarations.values) {
    if (declaration is VariableMirror) {
      for (final instance in declaration.metadata) {
        final reflectee = instance.reflectee;
        if (reflectee is ProtoTag) {
          final fi = _FieldInfo(declaration.simpleName, reflectee.tag, reflectee.zigzag, declaration.type.reflectedType);
          info.byTag[fi.tag] = fi;
          info.bySymbol[fi.symbol] = fi;
        }
      }
    }
  }
  
  _cache[type] = info;
  return info;
}

GeneratedMessage _createGeneratedMessage(Type type, _StructInfo info) {
  final builder = BuilderInfo(type.toString());
  for (final fi in info.byTag.values) {
    final pbType = _getPbType(fi.type, fi.zigzag);
    builder.add(fi.tag, MirrorSystem.getName(fi.symbol), pbType, _getDefault(fi.type), null, null, null);
  }
  return _DynamicMessage(builder);
}

int _getPbType(Type type, bool zigzag) {
  if (type == int) return zigzag ? PbFieldType.OS3 : PbFieldType.O3;
  if (type == Int64) return zigzag ? PbFieldType.OS6 : PbFieldType.O6;
  if (type == String) return PbFieldType.OS;
  if (type == bool) return PbFieldType.OB;
  if (type == double) return PbFieldType.OD;
  if (type == Uint8List) return PbFieldType.OY;
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

void _populateGeneratedMessage(GeneratedMessage msg, Object obj, _StructInfo info) {
  final instanceMirror = reflect(obj);
  for (final fi in info.bySymbol.values) {
    final value = instanceMirror.getField(fi.symbol).reflectee;
    if (value != null) {
      msg.setField(fi.tag, value);
    }
  }
}

void _populateNativeObject(Object obj, GeneratedMessage msg, _StructInfo info) {
  final instanceMirror = reflect(obj);
  for (final fi in info.byTag.values) {
    if (msg.hasField(fi.tag)) {
      instanceMirror.setField(fi.symbol, msg.getField(fi.tag));
    }
  }
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
