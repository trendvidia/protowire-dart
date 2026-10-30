// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// Formats an AST back to PXF source, preserving comments. Mirrors
// protowire-go's format.go: two-space indent, expanded blocks, and blank
// lines between entries are not kept. It differs in refusing a document
// with directives (the reference writes `@type` and drops the rest) and in
// keeping comments after the last entry.
import 'dart:convert';

import 'annotations.dart';
import 'ast.dart';
import 'errors.dart';
import 'keyed.dart';
import 'parser.dart';
import 'token.dart';

/// Formats PXF source. With [annotations] this is the full `fmt` pipeline:
/// keyed repeated fields are canonicalized against [messageName], which
/// defaults to the document's `@type`. Without them the document is only
/// pretty-printed, since a quoted entry name cannot be judged with no schema.
///
/// A document [annotations] cannot place is a [PxfError], as is one carrying
/// `@dataset`, `@proto` or `@<name>` directives, which this does not write.
///
/// ```dart
/// final ann = PxfAnnotations.fromBytes(descriptorSetBytes);
/// final text = formatPxf(source, annotations: ann);
/// ```
String formatPxf(String input,
    {PxfAnnotations? annotations, String? messageName}) {
  final doc = parse(input);
  if (annotations != null) {
    final type = doc.typeUrl;
    final name = messageName ?? type?.substring(type.lastIndexOf('/') + 1);
    if (name == null) {
      throw PxfError(Position(1, 1),
          'cannot canonicalize: no messageName and no @type in the document');
    }
    if (!annotations.hasMessage(name)) {
      throw PxfError(Position(1, 1),
          'cannot canonicalize: "$name" is not in the descriptor set');
    }
    canonicalizeKeyed(doc, name, annotations);
  }
  return formatDocument(doc);
}

/// Pretty-prints [doc]; see [formatPxf].
String formatDocument(Document doc) {
  for (final d in [...doc.directives, ...doc.datasets, ...doc.protos]) {
    final pos = d is Directive
        ? d.pos
        : (d is DatasetDirective ? d.pos : (d as ProtoDirective).pos);
    throw PxfError(pos, 'formatting a document with directives is unsupported');
  }
  final f = _Formatter();
  final type = doc.typeUrl;
  if (type != null && type.isNotEmpty) f.buf.write('@type $type\n\n');
  f.comments(doc.leadingComments, 0);
  f.entries(doc.entries, 0);
  f.comments(doc.trailingComments, 0);
  return f.buf.toString();
}

/// [s] as a PXF string literal.
String quotePxfString(String s) {
  final buf = StringBuffer('"');
  for (var i = 0; i < s.length; i++) {
    final char = s[i];
    switch (char) {
      case '"':
        buf.write(r'\"');
      case r'\':
        buf.write(r'\\');
      case '\n':
        buf.write(r'\n');
      case '\r':
        buf.write(r'\r');
      case '\t':
        buf.write(r'\t');
      default:
        final code = char.codeUnitAt(0);
        if (code < 0x20) {
          buf.write(r'\x');
          buf.write(code.toRadixString(16).padLeft(2, '0'));
        } else {
          buf.write(char);
        }
    }
  }
  buf.write('"');
  return buf.toString();
}

class _Formatter {
  final StringBuffer buf = StringBuffer();

  void indent(int level) => buf.write('  ' * level);

  void comments(List<Comment> list, int level) {
    for (final c in list) {
      indent(level);
      buf.write('${c.text}\n');
    }
  }

  void entries(List<Entry> list, int level) {
    for (final e in list) {
      if (e is Assignment) {
        comments(e.leadingComments, level);
        indent(level);
        buf.write(e.keyQuoted ? quotePxfString(e.key) : e.key);
        buf.write(' = ');
        value(e.value, level);
        trailing(e.trailingComment);
      } else if (e is MapEntry) {
        comments(e.leadingComments, level);
        indent(level);
        // A bare key stays bare, since bare `123` is an integer key. A quoted
        // one is unquoted only when bare it would denote the same key.
        final quote = e.keyQuoted && !isIdentSafeEntryName(e.key);
        buf.write(quote ? quotePxfString(e.key) : e.key);
        buf.write(': ');
        value(e.value, level);
        trailing(e.trailingComment);
      } else if (e is Block) {
        comments(e.leadingComments, level);
        indent(level);
        buf.write(e.nameQuoted ? quotePxfString(e.name) : e.name);
        buf.write(' {\n');
        entries(e.entries, level + 1);
        indent(level);
        buf.write('}\n');
      }
    }
  }

  void trailing(String? comment) {
    if (comment != null) buf.write(' $comment');
    buf.write('\n');
  }

  void value(Value v, int level) {
    switch (v) {
      case StringVal():
        buf.write(quotePxfString(v.value));
      case IntVal():
        buf.write(v.raw);
      case FloatVal():
        buf.write(v.raw);
      case BoolVal():
        buf.write(v.value ? 'true' : 'false');
      case BytesVal():
        buf.write('b"${base64.encode(v.value)}"');
      case NullVal():
        buf.write('null');
      case IdentVal():
        buf.write(v.name);
      case TimestampVal():
        buf.write(v.raw);
      case DurationVal():
        buf.write(v.raw);
      case ListVal():
        buf.write('[\n');
        for (var i = 0; i < v.elements.length; i++) {
          indent(level + 1);
          value(v.elements[i], level + 1);
          if (i < v.elements.length - 1) buf.write(',');
          buf.write('\n');
        }
        indent(level);
        buf.write(']');
      case BlockVal():
        buf.write('{\n');
        entries(v.entries, level + 1);
        indent(level);
        buf.write('}');
      default:
        throw ArgumentError('unknown value ${v.runtimeType}');
    }
  }
}
