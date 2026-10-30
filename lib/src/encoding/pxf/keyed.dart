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
import 'ast.dart';
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

/// Rewrites [doc] in place to the canonical keyed form, with [messageName]
/// as the document's message. Per keyed repeated field binding it converts
/// an eligible anonymous list to the block form, normalizes `name = { ... }`
/// entries to `name { ... }`, unquotes identifier-safe entry names and drops
/// redundant agreeing key assignments.
///
/// Ineligible bindings stay anonymous and entries the schema does not
/// resolve are left alone, so formatting an invalid document never destroys
/// information. Comments of a removed entry move to the nearest survivor.
/// Mirrors the reference's `CanonicalizeKeyed`.
void canonicalizeKeyed(
    Document doc, String messageName, PxfAnnotations annotations) {
  final out = _Canonicalizer(annotations).entries(doc.entries, messageName);
  doc.entries
    ..clear()
    ..addAll(out);
}

class _Canonicalizer {
  final PxfAnnotations ann;

  _Canonicalizer(this.ann);

  List<Entry> entries(List<Entry> list, String message) =>
      [for (final e in list) entry(e, message)];

  Entry entry(Entry e, String message) {
    if (e is Assignment && !e.keyQuoted) {
      final sf = ann.schemaField(message, e.key);
      if (sf != null) return assignment(e, sf, message);
    } else if (e is Block && !e.nameQuoted) {
      final sf = ann.schemaField(message, e.name);
      if (sf != null) return block(e, sf, message);
    }
    return e;
  }

  Entry block(Block b, PxfSchemaField sf, String message) {
    final keyName = ann.keyFieldName(message, b.name);
    if (keyName != null) {
      return _withEntries(b, keyedEntries(b.entries, sf, keyName));
    }
    // This port reads an unkeyed `items { ... }` as one list element, so the
    // body is a message either way.
    final inner = sf.messageType;
    if (inner == null || sf.isMap) return b;
    return _withEntries(b, entries(b.entries, inner));
  }

  Entry assignment(Assignment a, PxfSchemaField sf, String message) {
    final inner = sf.messageType;
    final value = a.value;
    if (inner == null) return a;
    if (sf.isMap) {
      if (value is! BlockVal) return a;
      return _withValue(
          a,
          BlockVal(
              value.pos, [for (final e in value.entries) mapEntry(e, inner)]));
    }
    if (sf.isList) {
      final keyName = ann.keyFieldName(message, a.key);
      if (value is ListVal) {
        if (keyName != null) {
          final converted = anonymous(a, value, sf, keyName);
          if (converted != null) return converted;
        }
        return _withValue(
            a,
            ListVal(value.pos, [
              for (final v in value.elements)
                v is BlockVal ? BlockVal(v.pos, entries(v.entries, inner)) : v
            ]));
      }
      if (value is BlockVal && keyName != null) {
        // `children = { ... }` -> `children { ... }`.
        return Block(
          pos: a.pos,
          name: a.key,
          entries: keyedEntries(value.entries, sf, keyName),
          leadingComments: _commentsOf(a),
        );
      }
      return a;
    }
    if (value is BlockVal) {
      return _withValue(a, BlockVal(value.pos, entries(value.entries, inner)));
    }
    return a;
  }

  Entry mapEntry(Entry e, String valueMessage) {
    if (e is! MapEntry) return e;
    final value = e.value;
    if (value is! BlockVal) return e;
    return MapEntry(
      pos: e.pos,
      key: e.key,
      keyQuoted: e.keyQuoted,
      value: BlockVal(value.pos, entries(value.entries, valueMessage)),
      leadingComments: e.leadingComments,
      trailingComment: e.trailingComment,
    );
  }

  /// The entries of a keyed block, normalized. An entry that is neither a
  /// block nor `name = { ... }` is malformed and stays as it is.
  List<Entry> keyedEntries(
      List<Entry> list, PxfSchemaField sf, String keyName) {
    final out = <Entry>[];
    for (final e in list) {
      if (e is Block) {
        out.add(named(e.pos, e.name, e.nameQuoted, e.entries, e.leadingComments,
            sf, keyName));
      } else if (e is Assignment && e.value is BlockVal) {
        out.add(named(e.pos, e.key, e.keyQuoted, (e.value as BlockVal).entries,
            _commentsOf(e), sf, keyName));
      } else {
        out.add(e);
      }
    }
    return out;
  }

  Block named(Position pos, String name, bool quoted, List<Entry> body,
      List<Comment> comments, PxfSchemaField sf, String keyName) {
    final (kept, orphans) = _dropKeyAssignments(body, keyName, name);
    return Block(
      pos: pos,
      name: name,
      nameQuoted: quoted && !isIdentSafeEntryName(name),
      entries: entries(kept, sf.messageType!),
      leadingComments: [...comments, ...orphans],
    );
  }

  /// The keyed block for an anonymous list, or null when it is not eligible:
  /// every element must be a block with exactly one non-empty, distinct
  /// explicit string key.
  Block? anonymous(
      Assignment a, ListVal list, PxfSchemaField sf, String keyName) {
    final keys = <String>[];
    final seen = <String>{};
    for (final v in list.elements) {
      if (v is! BlockVal) return null;
      final key = _explicitKeyOf(v.entries, keyName);
      if (key == null || key.isEmpty || !seen.add(key)) return null;
      keys.add(key);
    }
    final out = <Entry>[];
    for (var i = 0; i < keys.length; i++) {
      final v = list.elements[i] as BlockVal;
      out.add(named(v.pos, keys[i], true, v.entries, const [], sf, keyName));
    }
    return Block(
      pos: a.pos,
      name: a.key,
      entries: out,
      leadingComments: _commentsOf(a),
    );
  }
}

Block _withEntries(Block b, List<Entry> entries) => Block(
      pos: b.pos,
      name: b.name,
      nameQuoted: b.nameQuoted,
      entries: entries,
      leadingComments: b.leadingComments,
    );

Assignment _withValue(Assignment a, Value value) => Assignment(
      pos: a.pos,
      key: a.key,
      keyQuoted: a.keyQuoted,
      value: value,
      leadingComments: a.leadingComments,
      trailingComment: a.trailingComment,
    );

/// [a]'s comments, for the [Block] replacing it: a block has nowhere to keep
/// a trailing comment, so that one moves above it.
List<Comment> _commentsOf(Assignment a) => [
      ...a.leadingComments,
      if (a.trailingComment != null) Comment(a.pos, a.trailingComment!),
    ];

/// Removes `keyName = "entryName"`, the redundant agreeing spelling of an
/// entry's key. A disagreeing or non-string assignment stays: the document
/// is invalid, and formatting must not change what it says. The removed
/// entry's comments go to the next survivor, or come back as the second
/// value when there is none.
(List<Entry>, List<Comment>) _dropKeyAssignments(
    List<Entry> list, String keyName, String entryName) {
  var pending = <Comment>[];
  final out = <Entry>[];
  for (final e in list) {
    if (e is Assignment &&
        !e.keyQuoted &&
        e.key == keyName &&
        e.value is StringVal &&
        (e.value as StringVal).value == entryName) {
      pending.addAll(_commentsOf(e));
      continue;
    }
    if (pending.isNotEmpty) {
      out.add(_prependComments(e, pending));
      pending = [];
    } else {
      out.add(e);
    }
  }
  return (out, pending);
}

Entry _prependComments(Entry e, List<Comment> comments) {
  if (e is Assignment) {
    return Assignment(
      pos: e.pos,
      key: e.key,
      keyQuoted: e.keyQuoted,
      value: e.value,
      leadingComments: [...comments, ...e.leadingComments],
      trailingComment: e.trailingComment,
    );
  }
  if (e is Block) {
    return Block(
      pos: e.pos,
      name: e.name,
      nameQuoted: e.nameQuoted,
      entries: e.entries,
      leadingComments: [...comments, ...e.leadingComments],
    );
  }
  final m = e as MapEntry;
  return MapEntry(
    pos: m.pos,
    key: m.key,
    keyQuoted: m.keyQuoted,
    value: m.value,
    leadingComments: [...comments, ...m.leadingComments],
    trailingComment: m.trailingComment,
  );
}

/// The value of the single explicit string assignment to [keyName], or null
/// when there is none, more than one, a quoted spelling, or a non-string.
String? _explicitKeyOf(List<Entry> list, String keyName) {
  String? found;
  for (final e in list) {
    if (e is! Assignment || e.key != keyName) continue;
    final value = e.value;
    if (value is! StringVal || e.keyQuoted || found != null) return null;
    found = value.value;
  }
  return found;
}
