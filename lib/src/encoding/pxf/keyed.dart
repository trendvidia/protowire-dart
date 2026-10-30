// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// Keyed repeated fields (draft-trendvidia-protowire-01 "Keyed Repeated
// Fields"; protowire#116): a `repeated <Message>` field carrying the
// `(pxf.key)` option may be written as a block of named blocks, with entry
// name = key-field value and entry order = list order.
//
//     children {
//       greeting    { type = "Label" }
//       counter_row { type = "HBox"  }
//     }
//
// The pieces shared by the decoder, the encoder and the formatter live
// here. Mirrors protowire-go's encoding/pxf/keyed.go.
import 'package:protobuf/protobuf.dart';

import 'annotations.dart';
import 'errors.dart';
import 'token.dart';

/// The key field of [fi], a field of the message [owner] describes, or null
/// when [fi] is not a keyed repeated field. Generated Dart messages carry no
/// field options, so with no [annotations] nothing is keyed.
FieldInfo? keyFieldOf(
    PxfAnnotations? annotations, BuilderInfo owner, FieldInfo fi) {
  if (annotations == null || fi.type != PbFieldType.PM) return null;
  final name =
      annotations.keyFieldName(owner.qualifiedMessageName, fi.protoName);
  if (name == null) return null;
  for (final candidate in fi.subBuilder!().info_.fieldInfo.values) {
    if (candidate.protoName == name) return candidate;
  }
  return null;
}

/// Whether [s] can be written as an unquoted entry name: it matches the
/// *identifier* production and is not a value keyword. Canonical form emits
/// a name unquoted exactly when this holds.
bool isIdentSafeEntryName(String s) {
  if (s.isEmpty || s == 'true' || s == 'false' || s == 'null') return false;
  return _identifier.hasMatch(s);
}

final RegExp _identifier = RegExp(r'^[a-zA-Z_][a-zA-Z0-9._]*$');

PxfError keyedEmptyNameError(Position pos, String field) => PxfError(pos,
    'empty entry name in keyed field "$field": the empty string is not a valid key');

PxfError keyedDuplicateKeyError(Position pos, String field, String key) =>
    PxfError(pos, 'duplicate key "$key" in keyed field "$field"');

PxfError quotedNameUnkeyedError(Position pos, String name) => PxfError(pos,
    'quoted entry name "$name" is only valid inside a keyed repeated field\'s block (draft -01 §3.13)');

/// The key-field checks for the immediate body of one element of a keyed
/// repeated field: an explicit assignment to the key field must not be
/// empty, and in the named form must agree with the entry name.
class KeyedElemState {
  final String field;
  final String keyName;

  /// The entry name; null for an anonymous list element.
  final String? entryName;

  const KeyedElemState(
      {required this.field, required this.keyName, this.entryName});

  void checkExplicitKey(String value, Position pos) {
    if (value.isEmpty) {
      throw PxfError(pos,
          'explicit empty-string assignment to key field "$keyName" of keyed field "$field": the empty string is not a valid key');
    }
    if (entryName != null && value != entryName) {
      throw PxfError(pos,
          'key field "$keyName" = "$value" conflicts with entry name "$entryName" in keyed field "$field"');
    }
  }
}
