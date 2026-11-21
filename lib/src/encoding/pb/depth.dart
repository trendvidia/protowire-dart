// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';

import '../../generated/proto/pxf/bignum.pb.dart' as bn;
import '../../limits.dart';

const _maxNestingDepth = 100;

/// The entry point for untrusted PB: merges [data] into [msg] under
/// HARDENING.md's limits. [limits] lowers them for the call.
///
/// Plain `GeneratedMessage.mergeFromBuffer` is not bounded this way. It takes
/// any input size, any element count, and does not count map entries toward
/// MaxNestingDepth, so a caller who uses it directly gets none of this
/// (protowire-dart#43).
///
/// `GeneratedMessage.mergeFromBuffer` stops at 100 submessages, but
/// package:protobuf does not count a map entry, and HARDENING.md § Recursion
/// makes every entry a descent whatever its value's type. So this walks [data]
/// against [msg]'s schema first, and past a bound throws an
/// [InvalidProtocolBufferException], the package's own for the depth. Use it
/// in place of `mergeFromBuffer` on untrusted input.
///
/// A `string` field that is not valid UTF-8 is rejected the same way, which
/// plain `mergeFromBuffer` does not do (HARDENING.md § UTF-8).
///
/// A tag's wire type is handled as protobuf handles it (protowire#614): wire
/// type 6 or 7 is refused on any field, and a known field whose wire type does
/// not match its type is an unknown field, skipped by its wire type, kept in
/// the message's unknown fields, and the field left as it was. A field that
/// cannot be skipped is refused in protowire-go's words, such as `corrupt
/// field 1: unexpected EOF`. Plain `mergeFromBuffer` reads a singular number,
/// bool or enum from a length-delimited record as if it were packed.
///
/// Malformed [data] throws [InvalidProtocolBufferException] and nothing else,
/// and leaves [msg] unmerged when the walk is what rejects it.
///
/// ```dart
/// final tree = Tree();
/// mergeFromBufferChecked(tree, bytes);
/// ```
void mergeFromBufferChecked(GeneratedMessage msg, List<int> data,
    [ExtensionRegistry registry = ExtensionRegistry.EMPTY,
    DecodeLimits limits = const DecodeLimits()]) {
  final tooBig = limits.checkSize(data.length);
  if (tooBig != null) throw _Rejected(tooBig);
  final bytes = data is Uint8List ? data : Uint8List.fromList(data);
  final walk = _Walk(bytes, registry, limits);
  try {
    walk.message(msg.info_, 0, bytes.length, 0, null, '');
    if (walk.routed.isEmpty) {
      msg.mergeFromBuffer(bytes, registry);
    } else {
      // Some record package:protobuf would read otherwise than protobuf does:
      // merge again, handing it only the records it reads alike.
      walk.message(msg.info_, 0, bytes.length, 0, null, '', into: msg);
    }
  } on ArgumentError catch (e) {
    // package:protobuf reads a length as a signed 32-bit varint and does not
    // reject a negative one with its own exception: it surfaces as this, or
    // as a RangeError, which is one. The walk refuses such a length first.
    throw _Rejected('malformed length: ${e.message}');
  }
}

/// protobuf-go's protowire.ParseError text for each way a value fails to
/// parse, which protowire-go names in `corrupt field N: ...`.
const _eof = 'unexpected EOF';
const _overflow = 'proto: variable length integer overflow';
const _fieldNumber = 'proto: invalid field number';
const _reserved = 'proto: cannot parse reserved wire type';
const _endGroup = 'proto: mismatching end group marker';

/// One pass over a message's records, against its schema.
///
/// The first pass checks the limits, UTF-8 and every skip, and notes in
/// [routed] where a record starts that package:protobuf would read otherwise
/// than protobuf does, or that holds one. Only when there is one does a second
/// pass run, with a message to merge [into]: it hands package:protobuf each
/// run of records it reads alike, and merges the noted ones itself.
class _Walk {
  final Uint8List b;
  final ExtensionRegistry registry;
  final DecodeLimits limits;
  final Set<int> routed = {};
  int pos = 0;

  /// Which of fields 1 and 2, as bits 1 and 2, the last message walked read
  /// on their own wire type: for a map entry, its key and value.
  int _read = 0;

  _Walk(this.b, this.registry, this.limits);

  /// Walks the records of one message in `[start, end)`, or of a group up to
  /// the end-group tag of field [group]. [where] names the message in an
  /// error, as protowire-go does: ` in map entry`, ` in BigInt`. Returns
  /// whether a record in it is routed, and leaves [pos] after it.
  bool message(
      BuilderInfo info, int start, int end, int depth, int? group, String where,
      {GeneratedMessage? into}) {
    pos = start;
    var dirty = false;
    var read = 0;
    // Elements of each repeated field or map of this message, by field
    // number: a field may be split across the wire.
    final counts = <int, int>{};
    void count(int number, int n) {
      final total = (counts[number] ?? 0) + n;
      if (total > limits.maxRepeatedCount) {
        throw _Rejected('field $number exceeds '
            'MaxRepeatedCount=${limits.maxRepeatedCount}');
      }
      counts[number] = total;
    }

    // The start of the run of records not yet merged into [into].
    var run = start;
    void flush(int upTo) {
      if (into != null && upTo > run) {
        into.mergeFromBuffer(Uint8List.sublistView(b, run, upTo), registry);
      }
    }

    while (true) {
      if (pos >= end) {
        // A group read to the end of its message never ended.
        if (group != null) throw InvalidProtocolBufferException.invalidEndTag();
        flush(end);
        _read = read;
        return dirty;
      }
      final at = pos;
      final tag = _tag(end);
      final number = tag >> 3;
      final wireType = tag & 7;
      if (wireType == WIRETYPE_END_GROUP) {
        if (number != group) throw _corrupt(number, where, _endGroup);
        flush(at);
        return dirty;
      }
      final route = into != null && routed.contains(at);
      if (route) {
        flush(at);
      }
      final fi = info.fieldInfo[number] ??
          registry.getExtension(info.qualifiedMessageName, number);

      if (fi == null || !_protobufReads(fi.type, wireType)) {
        // An unknown field, or a known one on a wire type its type is not
        // read from, which protobuf treats as unknown.
        if (fi != null && _packageReads(fi.type, wireType)) {
          routed.add(at);
          dirty = true;
        }
        final failed = _skip(number, wireType, end, depth, 1);
        if (failed != null) throw _corrupt(number, where, failed);
        if (route) {
          into.unknownFields.mergeFromCodedBufferReader(
              CodedBufferReader(Uint8List.sublistView(b, at, pos)));
          run = pos;
        }
        continue;
      }

      if (number <= 2) read |= 1 << number;
      final repeated = fi.isRepeated || fi.isMapField;
      final base = PbFieldType.baseType(fi.type);
      if (base == PbFieldType.GROUP_BIT || base == PbFieldType.MESSAGE_BIT) {
        if (repeated) count(number, 1);
        if (depth >= _maxNestingDepth) {
          throw InvalidProtocolBufferException.recursionLimitExceeded();
        }
        final entry = fi is MapFieldInfo;
        final child = entry ? fi.mapEntryBuilderInfo : fi.subBuilder!().info_;
        final GeneratedMessage? sub = route ? _target(into, fi, child) : null;
        bool inner;
        if (base == PbFieldType.GROUP_BIT) {
          inner = message(child, pos, end, depth + 1, number, '', into: sub);
        } else {
          final length = _length(end);
          if (length > end - pos) {
            throw InvalidProtocolBufferException.truncatedMessage();
          }
          final stop = pos + length;
          inner = message(child, pos, stop, depth + 1, null,
              entry ? ' in map entry' : _named(child),
              into: sub);
          pos = stop;
          // An entry without its 64-bit key or value: package:protobuf
          // stores the int 0 for it, which its typed map refuses.
          if (entry && !inner) inner = _lacks64Bit(child, _read);
        }
        if (inner) {
          routed.add(at);
          dirty = true;
        }
        if (sub != null) {
          _store(into!, fi, sub);
          run = pos;
        }
        continue;
      }

      if (wireType == WIRETYPE_LENGTH_DELIMITED) {
        // A string, bytes, or a packed list.
        final length = _length(end);
        if (length > end - pos) {
          throw InvalidProtocolBufferException.truncatedMessage();
        }
        final payload = Uint8List.sublistView(b, pos, pos + length);
        pos += length;
        final isString = base == PbFieldType.STRING_BIT;
        if (isString) _checkUtf8(number, payload);
        if (repeated) {
          final strings = isString || base == PbFieldType.BYTES_BIT;
          count(number, strings ? 1 : _packedCount(fi.type, payload));
        }
        continue;
      }
      if (repeated) count(number, 1);
      switch (wireType) {
        case WIRETYPE_VARINT:
          // At most ten bytes, as package:protobuf reads a varint.
          for (var i = 0;; i++) {
            if (i == 10) throw InvalidProtocolBufferException.malformedVarint();
            if (pos >= end) {
              throw InvalidProtocolBufferException.truncatedMessage();
            }
            if (b[pos++] < 0x80) break;
          }
        case WIRETYPE_FIXED32:
          if (end - pos < 4) {
            throw InvalidProtocolBufferException.truncatedMessage();
          }
          pos += 4;
        case WIRETYPE_FIXED64:
          if (end - pos < 8) {
            throw InvalidProtocolBufferException.truncatedMessage();
          }
          pos += 8;
      }
    }
  }

  /// A tag, read as package:protobuf reads one: a varint of at most ten bytes
  /// kept to its low 32 bits, whose field number is not 0.
  int _tag(int end) {
    var bytes = end - pos;
    if (bytes > 10) bytes = 10;
    var result = 0;
    for (var i = 0; i < bytes; i++) {
      final byte = b[pos++];
      result |= (byte & 0x7f) << (i * 7);
      if ((byte & 0x80) == 0) {
        result &= 0xffffffff;
        if (result >> 3 == 0) throw InvalidProtocolBufferException.invalidTag();
        return result;
      }
    }
    throw InvalidProtocolBufferException.malformedVarint();
  }

  /// A varint, read as protobuf-go's ConsumeVarint reads one: at most ten
  /// bytes, the tenth no more than 1. Returns null and leaves [pos] after it,
  /// or the reason it does not parse. Its value goes to [_value], with bit 62
  /// standing in for every bit past 56, which no length or field number
  /// reaches, so the low bits stay exact.
  String? _varint(int end) {
    var v = 0;
    for (var i = 0; i < 10; i++) {
      if (pos >= end) return _eof;
      final c = b[pos++];
      if (i == 9 && c > 1) return _overflow;
      final bits = c & 0x7f;
      if (i < 8) {
        v |= bits << (7 * i);
      } else if (bits != 0) {
        v |= 1 << 62;
      }
      if (c < 0x80) {
        _value = v;
        return null;
      }
    }
    return _overflow; // not reached: the tenth byte above 1 returned
  }

  int _value = 0;

  /// The length of a known length-delimited field. A length past what is
  /// left, however it is written, is refused by the caller.
  int _length(int end) {
    final failed = _varint(end);
    if (failed == _eof) throw InvalidProtocolBufferException.truncatedMessage();
    if (failed != null) throw InvalidProtocolBufferException.malformedVarint();
    return _value;
  }

  /// Skips the value of a field read as unknown, as protobuf-go's
  /// ConsumeFieldValue does, and returns why it cannot, or null. [groups]
  /// counts the groups this one is inside, toward MaxNestingDepth as
  /// package:protobuf counts them.
  String? _skip(int number, int wireType, int end, int depth, int groups) {
    switch (wireType) {
      case WIRETYPE_VARINT:
        return _varint(end);
      case WIRETYPE_FIXED32:
        if (end - pos < 4) return _eof;
        pos += 4;
        return null;
      case WIRETYPE_FIXED64:
        if (end - pos < 8) return _eof;
        pos += 8;
        return null;
      case WIRETYPE_LENGTH_DELIMITED:
        final failed = _varint(end);
        if (failed != null) return failed;
        if (_value > end - pos) return _eof;
        pos += _value;
        return null;
      case WIRETYPE_START_GROUP:
        if (depth + groups > _maxNestingDepth) {
          throw InvalidProtocolBufferException.recursionLimitExceeded();
        }
        while (true) {
          final failed = _varint(end);
          if (failed != null) return failed;
          final inner = _value >> 3;
          final type = _value & 7;
          if (inner == 0 || inner > 0x7fffffff) return _fieldNumber;
          if (type == WIRETYPE_END_GROUP) {
            return inner == number ? null : _endGroup;
          }
          final skipped = _skip(inner, type, end, depth, groups + 1);
          if (skipped != null) return skipped;
        }
      case WIRETYPE_END_GROUP:
        return _endGroup;
      default:
        return _reserved;
    }
  }

  /// The message a routed record of [fi] merges into: the one [into] holds
  /// already, for a singular field, or a new one.
  GeneratedMessage _target(
      GeneratedMessage into, FieldInfo fi, BuilderInfo child) {
    if (fi is MapFieldInfo) return _Entry(child);
    if (fi is Extension) {
      return !fi.isRepeated && into.hasExtension(fi)
          ? into.getExtension(fi) as GeneratedMessage
          : fi.subBuilder!();
    }
    return !fi.isRepeated && into.hasField(fi.tagNumber)
        ? into.getField(fi.tagNumber) as GeneratedMessage
        : fi.subBuilder!();
  }

  /// Stores [sub], merged from a routed record of [fi], in [into]: a map
  /// entry as package:protobuf stores one, with a key or value it did not
  /// read as its zero.
  void _store(GeneratedMessage into, FieldInfo fi, GeneratedMessage sub) {
    if (fi is MapFieldInfo) {
      final entry = sub.info_;
      (into.getField(fi.tagNumber) as Map)[_entryField(sub, entry.byIndex[0])] =
          _entryField(sub, entry.byIndex[1]);
    } else if (fi is Extension) {
      fi.isRepeated ? into.addExtension(fi, sub) : into.setExtension(fi, sub);
    } else if (fi.isRepeated) {
      (into.getField(fi.tagNumber) as List).add(sub);
    } else {
      into.setField(fi.tagNumber, sub);
    }
  }
}

/// Whether a map entry of [info] lacks a 64-bit key or value, given the
/// fields it [read] as bits 1 and 2.
bool _lacks64Bit(BuilderInfo info, int read) =>
    (read & 2 == 0 && _is64Bit(info.byIndex[0].type)) ||
    (read & 4 == 0 && _is64Bit(info.byIndex[1].type));

/// A map entry's key or value, or its zero. package:protobuf makes an absent
/// 64-bit integer the `int` 0, which its typed map refuses, so that zero is
/// Int64's.
Object _entryField(GeneratedMessage entry, FieldInfo fi) {
  final number = fi.tagNumber;
  if (entry.hasField(number)) return entry.getField(number) as Object;
  if (_is64Bit(fi.type)) return Int64.ZERO;
  return fi.makeDefault!() as Object;
}

bool _is64Bit(int type) => switch (PbFieldType.baseType(type)) {
      PbFieldType.INT64_BIT ||
      PbFieldType.SINT64_BIT ||
      PbFieldType.UINT64_BIT ||
      PbFieldType.FIXED64_BIT ||
      PbFieldType.SFIXED64_BIT =>
        true,
      _ => false,
    };

/// Whether protobuf reads a field of [type] from a tag of [wireType]: its own
/// wire type, and a repeated number or bool also packed.
bool _protobufReads(int type, int wireType) {
  if (PbFieldType.isMapField(type)) {
    return wireType == WIRETYPE_LENGTH_DELIMITED;
  }
  final own = _ownWireType(PbFieldType.baseType(type));
  if (wireType == own) return true;
  return PbFieldType.isRepeated(type) &&
      wireType == WIRETYPE_LENGTH_DELIMITED &&
      own != WIRETYPE_LENGTH_DELIMITED &&
      own != WIRETYPE_START_GROUP;
}

int _ownWireType(int base) => switch (base) {
      PbFieldType.FLOAT_BIT ||
      PbFieldType.FIXED32_BIT ||
      PbFieldType.SFIXED32_BIT =>
        WIRETYPE_FIXED32,
      PbFieldType.DOUBLE_BIT ||
      PbFieldType.FIXED64_BIT ||
      PbFieldType.SFIXED64_BIT =>
        WIRETYPE_FIXED64,
      PbFieldType.BYTES_BIT ||
      PbFieldType.STRING_BIT ||
      PbFieldType.MESSAGE_BIT =>
        WIRETYPE_LENGTH_DELIMITED,
      PbFieldType.GROUP_BIT => WIRETYPE_START_GROUP,
      _ => WIRETYPE_VARINT,
    };

/// Whether package:protobuf's merge reads a field of [type] from a tag of
/// [wireType]: its `_wireTypeMatches`, which takes a length-delimited record
/// for any number, bool or enum, repeated or not.
bool _packageReads(int type, int wireType) {
  final own = _ownWireType(PbFieldType.baseType(type));
  return wireType == own ||
      (wireType == WIRETYPE_LENGTH_DELIMITED && own != WIRETYPE_START_GROUP);
}

/// How protowire-go names the big-number messages in an error.
String _named(BuilderInfo info) {
  if (identical(info, _bigIntInfo)) return ' in BigInt';
  if (identical(info, _decimalInfo)) return ' in Decimal';
  if (identical(info, _bigFloatInfo)) return ' in BigFloat';
  return '';
}

final _bigIntInfo = bn.BigInt().info_;
final _decimalInfo = bn.Decimal().info_;
final _bigFloatInfo = bn.BigFloat().info_;

/// protowire-go's error for a field that cannot be skipped.
_Rejected _corrupt(int number, String where, String why) =>
    _Rejected('corrupt field $number$where: $why');

/// HARDENING.md § UTF-8: a decoder validates a `string` field strictly, and
/// package:protobuf decodes one with `allowMalformed: true`, putting U+FFFD
/// where the bad bytes were. A generated class does not say whether its file
/// is proto2 or proto3, so this checks every `string` field, proto2's too,
/// where protowire-go checks proto3 and editions only.
void _checkUtf8(int number, Uint8List payload) {
  try {
    _strictUtf8.convert(payload);
  } on FormatException {
    throw _Rejected('field $number: string is not valid UTF-8');
  }
}

const _strictUtf8 = Utf8Decoder();

/// The elements a packed field's [payload] holds, read without decoding them.
int _packedCount(int fieldType, Uint8List payload) {
  switch (PbFieldType.baseType(fieldType)) {
    case PbFieldType.FIXED32_BIT:
    case PbFieldType.SFIXED32_BIT:
    case PbFieldType.FLOAT_BIT:
      return payload.length ~/ 4;
    case PbFieldType.FIXED64_BIT:
    case PbFieldType.SFIXED64_BIT:
    case PbFieldType.DOUBLE_BIT:
      return payload.length ~/ 8;
    default:
      // One varint per byte with the continuation bit clear.
      return payload.where((b) => b < 0x80).length;
  }
}

/// A map entry, merged field by field when one of its records is routed.
class _Entry extends GeneratedMessage {
  final BuilderInfo _info;
  _Entry(this._info);

  @override
  BuilderInfo get info_ => _info;

  @override
  GeneratedMessage createEmptyInstance() => _Entry(_info);

  @override
  GeneratedMessage clone() => _Entry(_info)..mergeFromMessage(this);
}

/// A limit broken or a length refused on the PB path, as the package reports
/// a malformed message.
class _Rejected implements InvalidProtocolBufferException {
  @override
  final String message;
  _Rejected(this.message);

  @override
  String toString() => 'InvalidProtocolBufferException: $message';
}
