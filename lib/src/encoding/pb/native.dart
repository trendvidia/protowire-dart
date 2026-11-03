// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'dart:collection';
import 'dart:mirrors';
import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';

import '../../generated/proto/pxf/bignum.pb.dart' as bn;
import '../../limits.dart';
import '../pxf/lexer.dart' show maxNumericLiteralDigits;
import '../pxf/wellknown.dart' show bigIntToBytes;
import 'depth.dart';
import 'proto_tag.dart';

/// Encodes [obj], whose fields carry [ProtoTag]s, as protobuf binary.
///
/// A field's Dart type says its proto type:
///
/// | Dart | proto |
/// |---|---|
/// | `int` | `int32`; `sint32` with `zigzag`, `uint32` with `unsigned` |
/// | `Int64` | `int64`; `sint64` with `zigzag`, `uint64` with `unsigned` |
/// | `double` | `double`; `float` with `float32` |
/// | `bool`, `String` | `bool`, `string` |
/// | `Uint8List` | `bytes` |
/// | `BigInt` | `pxf.BigInt` |
/// | a [GeneratedMessage] class | that message, e.g. `pxf.Decimal` or `pxf.BigFloat` |
/// | a class with `@ProtoTag` fields | a message of those fields |
/// | `List<T>` | `repeated T`, packed when T is numeric or `bool` |
/// | `Map<K, V>` | `map<K, V>` |
///
/// A singular scalar at its zero is not written, nor is a zero `BigInt`,
/// `pxf.Decimal` or `pxf.BigFloat`, as protowire-go's struct API writes
/// neither. A list element or map value is written whatever it is: a zero
/// big number, or a null one, is an empty message, so a list keeps its
/// length and a map entry its value (protowire#509's struct-binding table). A
/// null element of a list of scalars throws an [ArgumentError], since no
/// bytes can say it.
///
/// A `pxf.Decimal` is written reduced: `1.00` as unscaled 1 and scale 0, and
/// a negative scale multiplied out. A `pxf.BigFloat`'s mantissa is widened
/// to `prec` bits. That is how protowire-go writes the same values, whatever
/// form the message was built in; the message passed in is not changed.
///
/// A `Map<K, V>` field is a proto3 map: `repeated MapEntry { key = 1; value
/// = 2; }`, each entry carrying both, zero-valued or not.
///
/// An object nested more deeply than [maxNestingDepth] throws an
/// [ArgumentError], counted as a decoder reading the bytes counts: each
/// submessage, and each map entry whatever its value (HARDENING.md
/// § Recursion, protowire#502). An object that holds itself meets the same
/// limit. Raise it only where every reader takes the deeper message.
Uint8List marshalNative(Object obj, {int maxNestingDepth = 100}) =>
    _toMessage(obj, 0, maxNestingDepth).writeToBuffer();

void unmarshalNative(Uint8List data, Object obj,
    {DecodeLimits limits = const DecodeLimits()}) {
  final root = _DynamicMessage(_builderFor(obj.runtimeType));
  mergeFromBufferChecked(root, data, ExtensionRegistry.EMPTY, limits);
  _populateNativeObject(obj, root, _getStructInfo(obj.runtimeType));
}

class _StructInfo {
  final Map<int, _FieldInfo> byTag = {};
}

/// How a value of one Dart type is carried in a message.
enum _Carrier {
  /// As itself: a number, bool, string or bytes.
  scalar,

  /// A Dart [BigInt] as a `pxf.BigInt` message.
  bigInt,

  /// A [GeneratedMessage] as itself.
  generated,

  /// A class with `@ProtoTag` fields as a message of them.
  struct,
}

/// One value type: a singular field's, a list's element or a map's value.
class _ValueType {
  final Type type;
  final _Carrier carrier;

  /// The singular proto type, `PbFieldType.O*`.
  final int pbType;

  _ValueType(this.type, this.carrier, this.pbType);

  bool get isMessage => carrier != _Carrier.scalar;

  CreateBuilderFunc? get subBuilder => switch (carrier) {
        _Carrier.scalar => null,
        _Carrier.bigInt => bn.BigInt.create,
        _Carrier.generated => () => _newGenerated(type),
        _Carrier.struct => () => _DynamicMessage(_builderFor(type)),
      };

  /// The repeated proto type: packed for numbers and bool.
  int get repeatedPbType => switch (pbType) {
        PbFieldType.O3 => PbFieldType.K3,
        PbFieldType.OS3 => PbFieldType.KS3,
        PbFieldType.OU3 => PbFieldType.KU3,
        PbFieldType.O6 => PbFieldType.K6,
        PbFieldType.OS6 => PbFieldType.KS6,
        PbFieldType.OU6 => PbFieldType.KU6,
        PbFieldType.OD => PbFieldType.KD,
        PbFieldType.OF => PbFieldType.KF,
        PbFieldType.OB => PbFieldType.KB,
        PbFieldType.OS => PbFieldType.PS,
        PbFieldType.OY => PbFieldType.PY,
        _ => PbFieldType.PM,
      };
}

class _FieldInfo {
  final Symbol symbol;
  final ProtoTag tag;
  final TypeMirror mirror;
  _FieldInfo(this.symbol, this.tag, this.mirror);

  int get number => tag.tag;
  String get name => MirrorSystem.getName(symbol);
  bool get isMap => mirror.qualifiedName == #dart.core.Map;
  bool get isList => mirror.qualifiedName == #dart.core.List;
}

final Map<Type, _StructInfo> _cache = {};
final Map<Type, BuilderInfo> _builders = {};
final _generatedMessage = reflectClass(GeneratedMessage);

_StructInfo _getStructInfo(Type type) {
  final cached = _cache[type];
  if (cached != null) return cached;

  final info = _StructInfo();
  final classMirror = reflectClass(type);
  for (final declaration in classMirror.declarations.values) {
    if (declaration is! VariableMirror) continue;
    for (final instance in declaration.metadata) {
      final reflectee = instance.reflectee;
      if (reflectee is ProtoTag) {
        info.byTag[reflectee.tag] =
            _FieldInfo(declaration.simpleName, reflectee, declaration.type);
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
    } else if (fi.isList) {
      final elem = _valueType(_typeArg(fi, 0, 1, type), fi.tag, type, fi.name);
      final pbType = elem.repeatedPbType;
      if (elem.isMessage) {
        builder.pc<dynamic>(fi.number, fi.name, pbType,
            subBuilder: elem.subBuilder);
      } else {
        builder.p<dynamic>(fi.number, fi.name, pbType);
      }
    } else {
      final vt = _valueType(fi.mirror, fi.tag, type, fi.name);
      builder.add(fi.number, fi.name, vt.pbType, _getDefault(vt), vt.subBuilder,
          null, null);
    }
  }
  return builder;
}

TypeMirror _typeArg(_FieldInfo fi, int i, int count, Type owner) {
  if (fi.mirror.typeArguments.length != count ||
      fi.mirror.typeArguments[i] is! ClassMirror) {
    throw ArgumentError(
        '$owner.${fi.name}: a ${count == 1 ? 'list field needs List<T>' : 'map field needs Map<K, V>'}');
  }
  return fi.mirror.typeArguments[i];
}

void _addMapField(BuilderInfo builder, Type owner, _FieldInfo fi) {
  final keyMirror = _typeArg(fi, 0, 2, owner);
  final valueMirror = _typeArg(fi, 1, 2, owner);
  final key = _valueType(keyMirror, const ProtoTag(0), owner, fi.name);
  if (key.isMessage ||
      key.pbType == PbFieldType.OD ||
      key.pbType == PbFieldType.OY) {
    throw ArgumentError(
        '$owner.${fi.name}: ${key.type} is not a valid map key type');
  }
  final value = _valueType(valueMirror, fi.tag, owner, fi.name);
  builder.m<dynamic, dynamic>(
    fi.number,
    fi.name,
    entryClassName: '$owner.${fi.name}Entry',
    keyFieldType: key.pbType,
    valueFieldType: value.pbType,
    valueCreator: value.subBuilder,
    valueDefaultOrMaker: _getDefault(value),
  );
}

_ValueType _valueType(TypeMirror m, ProtoTag tag, Type owner, String field) {
  final type = m.reflectedType;
  Never refuse(String why) => throw ArgumentError('$owner.$field: $type $why');
  if (tag.zigzag && tag.unsigned) refuse('cannot be both zigzag and unsigned');
  if ((tag.zigzag || tag.unsigned) && type != int && type != Int64) {
    refuse('takes no zigzag or unsigned flag: only int and Int64 do');
  }
  if (tag.float32 && type != double) {
    refuse('takes no float32 flag: only double does');
  }
  final int pbType;
  if (type == int) {
    pbType = tag.zigzag
        ? PbFieldType.OS3
        : tag.unsigned
            ? PbFieldType.OU3
            : PbFieldType.O3;
  } else if (type == Int64) {
    pbType = tag.zigzag
        ? PbFieldType.OS6
        : tag.unsigned
            ? PbFieldType.OU6
            : PbFieldType.O6;
  } else if (type == double) {
    pbType = tag.float32 ? PbFieldType.OF : PbFieldType.OD;
  } else if (type == String) {
    pbType = PbFieldType.OS;
  } else if (type == bool) {
    pbType = PbFieldType.OB;
  } else if (type == Uint8List) {
    pbType = PbFieldType.OY;
  } else if (type == BigInt) {
    return _ValueType(type, _Carrier.bigInt, PbFieldType.OM);
  } else if (m is ClassMirror && m.isSubclassOf(_generatedMessage)) {
    return _ValueType(type, _Carrier.generated, PbFieldType.OM);
  } else if (_getStructInfo(type).byTag.isNotEmpty) {
    return _ValueType(type, _Carrier.struct, PbFieldType.OM);
  } else {
    refuse('is not a supported field type, and has no @ProtoTag fields to '
        'encode as a message');
  }
  return _ValueType(type, _Carrier.scalar, pbType);
}

dynamic _getDefault(_ValueType vt) => switch (vt.type) {
      const (int) => 0,
      const (Int64) => Int64.ZERO,
      const (String) => '',
      const (bool) => false,
      const (double) => 0.0,
      _ => null,
    };

GeneratedMessage _newGenerated(Type type) =>
    reflectClass(type).newInstance(Symbol.empty, const []).reflectee
        as GeneratedMessage;

bool _isZero(Object value) => switch (value) {
      int v => v == 0,
      Int64 v => v.isZero,
      String v => v.isEmpty,
      bool v => !v,
      double v => v == 0, // -0.0 too, as in protowire-go
      Uint8List v => v.isEmpty,
      _ => false,
    };

/// [obj] as a message at [depth] descents from the root.
GeneratedMessage _toMessage(Object obj, int depth, int maxDepth) {
  final msg = _DynamicMessage(_builderFor(obj.runtimeType));
  _populateGeneratedMessage(
      msg, obj, _getStructInfo(obj.runtimeType), depth, maxDepth);
  return msg;
}

void _descend(int depth, int maxDepth) {
  if (depth > maxDepth) {
    throw ArgumentError('nesting depth exceeds MaxNestingDepth=$maxDepth');
  }
}

/// [value], of [vt], as the message field's value at [depth]: itself for a
/// scalar, else a message. Null is the empty message.
Object _toPb(_ValueType vt, Object? value, int depth, int maxDepth) {
  switch (vt.carrier) {
    case _Carrier.scalar:
      return value!;
    case _Carrier.bigInt:
      return _bigIntMessage(value as BigInt?);
    case _Carrier.generated:
      if (value == null) return _newGenerated(vt.type);
      return _reduced(value as GeneratedMessage);
    case _Carrier.struct:
      if (value == null) return _DynamicMessage(_builderFor(vt.type));
      return _toMessage(value, depth, maxDepth);
  }
}

/// Whether [value] is a big number at zero, which a singular field omits.
bool _isZeroBigNumber(Object value) =>
    value is GeneratedMessage &&
    _isBigNumber(value.info_) &&
    value.writeToBuffer().isEmpty;

bool _isBigNumber(BuilderInfo info) => const {
      'pxf.BigInt',
      'pxf.Decimal',
      'pxf.BigFloat'
    }.contains(info.qualifiedMessageName);

void _populateGeneratedMessage(GeneratedMessage msg, Object obj,
    _StructInfo info, int depth, int maxDepth) {
  final instanceMirror = reflect(obj);
  final owner = obj.runtimeType;
  for (final fi in info.byTag.values) {
    final value = instanceMirror.getField(fi.symbol).reflectee;
    if (value == null) continue;
    if (fi.isMap) {
      final vt = _valueType(fi.mirror.typeArguments[1], fi.tag, owner, fi.name);
      final target = msg.getField(fi.number) as Map;
      // An entry is a descent, and a message value one more inside it.
      if ((value as Map).isNotEmpty) {
        _descend(depth + (vt.isMessage ? 2 : 1), maxDepth);
      }
      value.forEach((k, v) {
        if (v == null && !vt.isMessage) {
          throw ArgumentError('$owner.${fi.name}[$k]: a null map value '
              'of ${vt.type} has no bytes');
        }
        target[k] = _toPb(vt, v, depth + 2, maxDepth);
      });
    } else if (fi.isList) {
      final vt = _valueType(fi.mirror.typeArguments[0], fi.tag, owner, fi.name);
      final target = msg.getField(fi.number) as List;
      final list = value as List;
      if (list.isNotEmpty && vt.isMessage) _descend(depth + 1, maxDepth);
      for (var i = 0; i < list.length; i++) {
        final v = list[i];
        if (v == null && !vt.isMessage) {
          throw ArgumentError('$owner.${fi.name}[$i]: a null element of a '
              'list of ${vt.type} has no bytes');
        }
        target.add(_toPb(vt, v, depth + 1, maxDepth));
      }
    } else {
      final vt = _valueType(fi.mirror, fi.tag, owner, fi.name);
      if (!vt.isMessage) {
        // A singular scalar at its zero is not written, as protowire-go's
        // struct API does not write one (the struct-binding table's Zeros
        // row, protowire#509). A map entry or list element keeps its zeros.
        if (!_isZero(value)) msg.setField(fi.number, value);
        continue;
      }
      _descend(depth + 1, maxDepth);
      final sub = _toPb(vt, value, depth + 1, maxDepth);
      if (_isZeroBigNumber(sub)) continue;
      msg.setField(fi.number, sub);
    }
  }
}

/// A Dart BigInt as pxf.BigInt{abs = 1, negative = 2}; null and zero are
/// the empty message.
bn.BigInt _bigIntMessage(BigInt? v) {
  final m = bn.BigInt();
  if (v == null || v == BigInt.zero) return m;
  m.abs = bigIntToBytes(v.abs());
  if (v.isNegative) m.negative = true;
  return m;
}

BigInt _magnitude(List<int> bytes) {
  var v = BigInt.zero;
  for (final b in bytes) {
    v = (v << 8) | BigInt.from(b);
  }
  return v;
}

/// [m], or for a pxf.Decimal or pxf.BigFloat a reduced copy, written as
/// protowire-go writes the same value.
GeneratedMessage _reduced(GeneratedMessage m) {
  switch (m.info_.qualifiedMessageName) {
    case 'pxf.Decimal':
      return _reducedDecimal(m);
    case 'pxf.BigFloat':
      return _reducedBigFloat(m);
    default:
      return m;
  }
}

/// pxf.Decimal{unscaled = 1, scale = 2, negative = 3} with no trailing zero
/// in a positive scale and no negative scale: 1.00 is unscaled 1, scale 0;
/// 5E+2 is unscaled 500. Zero is the empty message.
GeneratedMessage _reducedDecimal(GeneratedMessage m) {
  var unscaled = _magnitude(m.getField(1) as List<int>);
  var scale = m.getField(2) as int;
  final out = m.createEmptyInstance();
  if (unscaled == BigInt.zero) return out;
  if (scale.abs() > maxNumericLiteralDigits) {
    throw ArgumentError('pxf.Decimal scale $scale exceeds '
        'MaxNumericLiteralDigits=$maxNumericLiteralDigits');
  }
  final ten = BigInt.from(10);
  while (scale > 0 && unscaled % ten == BigInt.zero) {
    unscaled ~/= ten;
    scale--;
  }
  if (scale < 0) {
    unscaled *= ten.pow(-scale);
    scale = 0;
  }
  out.setField(1, bigIntToBytes(unscaled));
  if (scale != 0) out.setField(2, scale);
  if (m.getField(3) as bool) out.setField(3, true);
  return out;
}

/// pxf.BigFloat{mantissa = 1, exponent = 2, prec = 3, negative = 4} with the
/// mantissa widened to prec bits, as protowire-go writes a big.Float. A prec
/// of 0 on a non-zero mantissa is the mantissa's own width. A mantissa wider
/// than prec would need rounding, which is refused rather than done here.
/// Zero is the empty message.
GeneratedMessage _reducedBigFloat(GeneratedMessage m) {
  var mantissa = _magnitude(m.getField(1) as List<int>);
  final out = m.createEmptyInstance();
  if (mantissa == BigInt.zero) return out;
  var exponent = m.getField(2) as int;
  var prec = m.getField(3) as int;
  final width = mantissa.bitLength;
  if (prec == 0) prec = width;
  if (width > prec) {
    throw ArgumentError('pxf.BigFloat mantissa has $width bits, more than '
        'its prec of $prec');
  }
  mantissa <<= prec - width;
  exponent -= prec - width;
  if (exponent < -0x80000000) {
    throw ArgumentError('pxf.BigFloat exponent $exponent does not fit int32');
  }
  out.setField(1, bigIntToBytes(mantissa));
  if (exponent != 0) out.setField(2, exponent);
  out.setField(3, prec);
  if (m.getField(4) as bool) out.setField(4, true);
  return out;
}

void _populateNativeObject(Object obj, GeneratedMessage msg, _StructInfo info) {
  final instanceMirror = reflect(obj);
  final owner = obj.runtimeType;
  for (final fi in info.byTag.values) {
    if (fi.isList) {
      final vt = _valueType(fi.mirror.typeArguments[0], fi.tag, owner, fi.name);
      final items = msg.getField(fi.number) as List;
      if (items.isEmpty) continue;
      final out = _newList(fi.mirror.typeArguments[0]);
      for (final v in items) {
        out.add(_fromPb(vt, v as Object));
      }
      instanceMirror.setField(fi.symbol, out);
      continue;
    }
    if (!msg.hasField(fi.number)) continue;
    final value = msg.getField(fi.number);
    if (fi.isMap) {
      instanceMirror.setField(fi.symbol, _nativeMap(fi, owner, value as Map));
    } else {
      final vt = _valueType(fi.mirror, fi.tag, owner, fi.name);
      instanceMirror.setField(fi.symbol, _fromPb(vt, value as Object));
    }
  }
}

/// A message field's [value] as the Dart value of [vt].
Object _fromPb(_ValueType vt, Object value) {
  switch (vt.carrier) {
    case _Carrier.scalar:
    case _Carrier.generated:
      return value;
    case _Carrier.bigInt:
      final m = value as GeneratedMessage;
      final abs = _magnitude(m.getField(1) as List<int>);
      return (m.getField(2) as bool) ? -abs : abs;
    case _Carrier.struct:
      return _nativeMessage(vt.type, value as GeneratedMessage);
  }
}

/// An empty growable `List<T>` for the element type [elem]: the field
/// rejects a `List<dynamic>`.
List _newList(TypeMirror elem) {
  final listType = reflectType(List, [elem.reflectedType]) as ClassMirror;
  return listType.newInstance(#empty, const [], {#growable: true}).reflectee
      as List;
}

/// A `Map<K, V>` of the field's own type: the field rejects a dynamic map.
Object _nativeMap(_FieldInfo fi, Type owner, Map entries) {
  final key = fi.mirror.typeArguments[0].reflectedType;
  final vt = _valueType(fi.mirror.typeArguments[1], fi.tag, owner, fi.name);
  final mapType = reflectType(LinkedHashMap, [key, vt.type]) as ClassMirror;
  final out = mapType.newInstance(Symbol.empty, const []);
  entries.forEach((k, v) {
    out.invoke(const Symbol('[]='), [k, _fromPb(vt, v as Object)]);
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
