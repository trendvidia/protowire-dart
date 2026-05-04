/// Read-side support for the `(pxf.required)` and `(pxf.default)` field
/// options.
///
/// The Dart `package:protobuf` runtime — unlike Go's protoreflect or
/// Swift's swift-protobuf — does not expose `FieldOptions` extensions on
/// `BuilderInfo`. Custom field options live only in the binary
/// `DescriptorProto` blob that `protoc-gen-dart` emits as
/// `xxxDescriptor` Uint8Lists in each `*.pbjson.dart` file.
///
/// [PxfAnnotations] parses those blobs once at registration time and
/// indexes the per-field `(pxf.required)` and `(pxf.default)` extensions
/// so the decoder's post-decode pass can validate required fields and
/// apply declared defaults — matching the Go reference's
/// `UnmarshalFullDescriptor` behaviour.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';

import 'duration.dart';
import 'wellknown.dart';

/// Extension field numbers from `proto/pxf/annotations.proto`.
const int _extRequired = 50000;
const int _extDefault = 50001;

/// Wire types in the protobuf binary format.
const int _wireVarint = 0;
const int _wireFixed64 = 1;
const int _wireBytes = 2;
const int _wireFixed32 = 5;

/// FieldDescriptorProto field numbers we care about.
const int _fdName = 1;
const int _fdNumber = 3;
const int _fdOptions = 8;

/// DescriptorProto field numbers we care about.
const int _dpField = 2;

/// Per-field annotations resolved from a message's `DescriptorProto`.
class FieldAnnotations {
  final bool required;
  final String? defaultValue;
  const FieldAnnotations({this.required = false, this.defaultValue});

  bool get isEmpty => !required && defaultValue == null;
}

/// Registry of `(pxf.required)` / `(pxf.default)` field options.
///
/// Build one by calling [register] for every message type whose required
/// / default annotations should be enforced (typically the root and any
/// nested types that may appear at decode time), then pass it via
/// [`UnmarshalOptions.annotations`]. Entries are keyed by the runtime
/// `qualifiedMessageName` so the decoder can resolve them via
/// `GeneratedMessage.info_`.
class PxfAnnotations {
  final Map<String, Map<String, FieldAnnotations>> _byQualifiedName = {};

  PxfAnnotations();

  /// Registers per-field annotations for [info] using its `DescriptorProto`
  /// blob (the `xxxDescriptor` Uint8List emitted in `*.pbjson.dart`).
  ///
  /// Idempotent — re-registering the same message replaces the previous
  /// entry. Sub-messages must be registered separately; the decoder only
  /// recurses into types that are present in this registry.
  void register(BuilderInfo info, Uint8List descriptor) {
    final byProto = _parseDescriptor(descriptor);
    if (byProto.isEmpty) return;
    _byQualifiedName[info.qualifiedMessageName] = byProto;
  }

  /// Returns the per-proto-name annotation index for [qualifiedName], or
  /// null if no descriptor was registered for it.
  Map<String, FieldAnnotations>? lookup(String qualifiedName) =>
      _byQualifiedName[qualifiedName];

  bool get isEmpty => _byQualifiedName.isEmpty;
}

/// Walks a `DescriptorProto` and returns a map of proto-name →
/// FieldAnnotations for fields that carry at least one of the two
/// `(pxf.*)` extensions. Fields without annotations are omitted to keep
/// the registry small.
Map<String, FieldAnnotations> _parseDescriptor(Uint8List bytes) {
  final out = <String, FieldAnnotations>{};
  final r = _Reader(bytes);
  while (!r.atEnd) {
    final tag = r.readVarint();
    final fieldNum = tag >> 3;
    final wireType = tag & 0x7;
    if (fieldNum == _dpField && wireType == _wireBytes) {
      final fieldBytes = r.readLengthDelimited();
      final fa = _parseFieldDescriptor(fieldBytes);
      if (fa != null) {
        out[fa.$1] = fa.$2;
      }
    } else {
      r.skip(wireType);
    }
  }
  return out;
}

/// Returns (proto_name, FieldAnnotations) for a `FieldDescriptorProto`,
/// or null if the field carries no `(pxf.*)` extensions.
(String, FieldAnnotations)? _parseFieldDescriptor(Uint8List bytes) {
  String? name;
  FieldAnnotations? ann;
  final r = _Reader(bytes);
  while (!r.atEnd) {
    final tag = r.readVarint();
    final fieldNum = tag >> 3;
    final wireType = tag & 0x7;
    if (fieldNum == _fdName && wireType == _wireBytes) {
      name = utf8.decode(r.readLengthDelimited());
    } else if (fieldNum == _fdOptions && wireType == _wireBytes) {
      ann = _parseFieldOptions(r.readLengthDelimited());
    } else if (fieldNum == _fdNumber && wireType == _wireVarint) {
      // Consume but ignore — we key the registry by name, not number.
      r.readVarint();
    } else {
      r.skip(wireType);
    }
  }
  if (name == null || ann == null || ann.isEmpty) return null;
  return (name, ann);
}

FieldAnnotations _parseFieldOptions(Uint8List bytes) {
  var required = false;
  String? defaultValue;
  final r = _Reader(bytes);
  while (!r.atEnd) {
    final tag = r.readVarint();
    final fieldNum = tag >> 3;
    final wireType = tag & 0x7;
    if (fieldNum == _extRequired && wireType == _wireVarint) {
      required = r.readVarint() != 0;
    } else if (fieldNum == _extDefault && wireType == _wireBytes) {
      defaultValue = utf8.decode(r.readLengthDelimited());
    } else {
      r.skip(wireType);
    }
  }
  return FieldAnnotations(required: required, defaultValue: defaultValue);
}

/// Minimal protobuf-wire reader scoped to descriptor parsing. Public
/// `package:protobuf` does not export a reader, and pulling
/// `CodedBufferReader` from `src/` would lock us to a private API.
class _Reader {
  final Uint8List _bytes;
  int _pos = 0;
  _Reader(this._bytes);

  bool get atEnd => _pos >= _bytes.length;

  int readVarint() {
    var result = 0;
    var shift = 0;
    while (true) {
      if (_pos >= _bytes.length) {
        throw FormatException('truncated varint at $_pos');
      }
      final b = _bytes[_pos++];
      result |= (b & 0x7F) << shift;
      if ((b & 0x80) == 0) return result;
      shift += 7;
      if (shift >= 64) {
        throw FormatException('varint too long at $_pos');
      }
    }
  }

  Uint8List readLengthDelimited() {
    final len = readVarint();
    if (_pos + len > _bytes.length) {
      throw FormatException('length-delimited overrun at $_pos');
    }
    final out = Uint8List.sublistView(_bytes, _pos, _pos + len);
    _pos += len;
    return out;
  }

  void skip(int wireType) {
    switch (wireType) {
      case _wireVarint:
        readVarint();
        break;
      case _wireFixed64:
        _pos += 8;
        break;
      case _wireBytes:
        readLengthDelimited();
        break;
      case _wireFixed32:
        _pos += 4;
        break;
      default:
        throw FormatException('unsupported wire type $wireType');
    }
  }
}

// -----------------------------------------------------------------------
// Post-decode validation entry point.
// -----------------------------------------------------------------------

/// Walks [msg] after PXF decode, validates `(pxf.required)` annotations
/// against [presentFields] (proto-name dotted paths the decoder marked
/// present), and applies `(pxf.default)` for absent fields.
///
/// [pathPrefix] is the dotted path leading up to [msg] (empty at the
/// root). [annotations] is the user-supplied registry; messages whose
/// `qualifiedMessageName` is not registered are skipped silently — same
/// stance as the Go reference takes for descriptors that don't carry
/// any `(pxf.*)` extensions.
void postDecode(
  GeneratedMessage msg,
  Set<String> presentFields,
  PxfAnnotations annotations,
  String pathPrefix,
) {
  final info = msg.info_;
  final perField = annotations.lookup(info.qualifiedMessageName);

  // Sort by tag so error reporting is deterministic.
  final tags = info.fieldInfo.keys.toList()..sort();
  for (final tag in tags) {
    final fi = info.fieldInfo[tag]!;
    final wireName = fi.protoName;
    if (wireName == '_null') continue;
    final path = '$pathPrefix$wireName';
    final isPresent = presentFields.contains(path);

    if (!isPresent) {
      final ann = perField?[wireName];
      if (ann != null) {
        if (ann.required) {
          throw FormatException('required field "$path" is absent');
        }
        if (ann.defaultValue != null) {
          _applyDefault(msg, fi, ann.defaultValue!);
        }
      }
    } else if (fi.type == PbFieldType.OM &&
        !fi.isRepeated &&
        !fi.isMapField &&
        msg.hasField(tag)) {
      // Recurse into present, non-null nested messages.
      final sub = msg.getField(tag) as GeneratedMessage;
      postDecode(sub, presentFields, annotations, '$path.');
    }
  }
}

/// Parses [def] under [fi]'s declared scalar / message kind and assigns
/// it to the message field. Mirrors the Go reference's `applyDefault` —
/// supports the same scalar types, enums by name or number, bytes
/// (base64), and the well-known message types Timestamp/Duration plus
/// the wrapper types.
void _applyDefault(GeneratedMessage msg, FieldInfo fi, String def) {
  if (fi.isRepeated || fi.isMapField) {
    throw FormatException(
        'default values are not supported for repeated/map field "${fi.protoName}"');
  }

  switch (fi.type & ~_repeatedMask & ~_packedMask) {
    case PbFieldType.OS:
      msg.setField(fi.tagNumber, def);
      return;
    case PbFieldType.OB:
      msg.setField(fi.tagNumber, def == 'true');
      return;
    case PbFieldType.O3:
    case PbFieldType.OS3:
    case PbFieldType.OSF3:
      msg.setField(fi.tagNumber, _parseInt32(def, fi));
      return;
    case PbFieldType.OU3:
    case PbFieldType.OF3:
      msg.setField(fi.tagNumber, _parseUint32(def, fi));
      return;
    case PbFieldType.O6:
    case PbFieldType.OS6:
    case PbFieldType.OSF6:
      msg.setField(fi.tagNumber, Int64.parseInt(def));
      return;
    case PbFieldType.OU6:
    case PbFieldType.OF6:
      msg.setField(fi.tagNumber, Int64.parseInt(def));
      return;
    case PbFieldType.OF:
      msg.setField(fi.tagNumber, double.parse(def));
      return;
    case PbFieldType.OD:
      msg.setField(fi.tagNumber, double.parse(def));
      return;
    case PbFieldType.OY:
      msg.setField(fi.tagNumber, base64.decode(def));
      return;
    case PbFieldType.OE:
      _applyEnumDefault(msg, fi, def);
      return;
    case PbFieldType.OM:
      _applyMessageDefault(msg, fi, def);
      return;
  }
  throw FormatException(
      'default value not supported for field "${fi.protoName}" (type 0x${fi.type.toRadixString(16)})');
}

const int _repeatedMask = PbFieldType.REPEATED_BIT;
const int _packedMask = PbFieldType.PACKED_BIT;

int _parseInt32(String s, FieldInfo fi) {
  final n = int.parse(s);
  if (n < -2147483648 || n > 2147483647) {
    throw FormatException(
        'invalid default int32 "$s" for field "${fi.protoName}"');
  }
  return n;
}

int _parseUint32(String s, FieldInfo fi) {
  final n = int.parse(s);
  if (n < 0 || n > 0xFFFFFFFF) {
    throw FormatException(
        'invalid default uint32 "$s" for field "${fi.protoName}"');
  }
  return n;
}

void _applyEnumDefault(GeneratedMessage msg, FieldInfo fi, String def) {
  // Try by enum value name first (the canonical PXF form), then fall
  // back to integer literal — same priority order the Go reference uses.
  final values = fi.enumValues;
  if (values != null) {
    for (final e in values) {
      if (e.name == def) {
        msg.setField(fi.tagNumber, e);
        return;
      }
    }
  }
  final n = int.tryParse(def);
  if (n != null) {
    final ev = fi.valueOf?.call(n);
    if (ev != null) {
      msg.setField(fi.tagNumber, ev);
      return;
    }
  }
  throw FormatException(
      'invalid default enum "$def" for field "${fi.protoName}"');
}

void _applyMessageDefault(GeneratedMessage msg, FieldInfo fi, String def) {
  final subInfo = fi.subBuilder!().info_;
  final sub = fi.subBuilder!();

  if (isTimestamp(subInfo)) {
    setTimestampFields(sub, DateTime.parse(def).toUtc());
    msg.setField(fi.tagNumber, sub);
    return;
  }
  if (isDuration(subInfo)) {
    setDurationFields(sub, parseGoDuration(def));
    msg.setField(fi.tagNumber, sub);
    return;
  }
  if (isWrapperType(subInfo)) {
    final inner = subInfo.fieldInfo[1]!;
    _applyDefault(sub, inner, def);
    msg.setField(fi.tagNumber, sub);
    return;
  }
  throw FormatException(
      'default value not supported for message field "${fi.protoName}" (type ${subInfo.qualifiedMessageName})');
}
