// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// Formats an AST back to PXF source, preserving comments. Mirrors
// protowire-go's format.go: two-space indent, expanded blocks, and blank
// lines between entries are not kept. It differs in keeping comments after
// the last entry.
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
/// Every directive is kept, in document order; see [formatDocument]. A
/// document [annotations] cannot place is a [PxfError].
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
///
/// It keeps every directive, with its dataset rows, in document order
/// (draft -01 § Directives, trendvidia/protowire#558). `@type` is written
/// first: it binds no anonymous `@proto`, so moving it changes nothing. The
/// other directives follow in source order, each after its comments: a named
/// directive's body and a `@proto` body as written, and a dataset as its
/// header and then one row per line, an absent cell left empty. A document
/// whose only directive is `@type` formats as it always has. The output is
/// the one protowire-go's `FormatDocument` writes.
String formatDocument(Document doc) {
  final f = _Formatter();
  final type = doc.typeUrl;
  final hasType = type != null && type.isNotEmpty;
  final others = _topDirectives(doc);
  if (others.isEmpty) {
    if (hasType) f.buf.write('@type $type\n\n');
    f.comments(doc.leadingComments, 0);
    f.entries(doc.entries, 0);
    f.comments(doc.trailingComments, 0);
    return f.buf.toString();
  }

  if (hasType) f.buf.write('@type $type\n');
  f.comments(doc.leadingComments, 0);
  for (final d in others) {
    switch (d) {
      case Directive():
        f.comments(d.leadingComments, 0);
        f.namedDirective(d);
      case DatasetDirective():
        f.comments(d.leadingComments, 0);
        f.dataset(d);
      case ProtoDirective():
        f.comments(d.leadingComments, 0);
        f.proto(d);
    }
  }
  if (doc.entries.isNotEmpty) {
    f.buf.write('\n');
    f.entries(doc.entries, 0);
  }
  f.comments(doc.trailingComments, 0);
  return f.buf.toString();
}

/// [doc]'s directives other than `@type`, which the [Document] keeps in three
/// lists, merged back into source order: an anonymous `@proto` binds the
/// typed directive after it, so the order is part of the meaning. Each
/// element is a [Directive], [DatasetDirective] or [ProtoDirective].
List<Object> _topDirectives(Document doc) {
  final all = <(Position, Object)>[
    for (final d in doc.directives) (d.pos, d),
    for (final d in doc.datasets) (d.pos, d),
    for (final d in doc.protos) (d.pos, d),
  ];
  // List.sort is not stable, but no two directives start at one position.
  all.sort((a, b) {
    final byLine = a.$1.line.compareTo(b.$1.line);
    return byLine != 0 ? byLine : a.$1.column.compareTo(b.$1.column);
  });
  return [for (final a in all) a.$2];
}

/// [v] as PXF text at the top level.
String formatValue(Value v) {
  final f = _Formatter();
  f.value(v, 0);
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
      } else if (e is TypeEntry) {
        comments(e.leadingComments, level);
        indent(level);
        buf.write('@type = ${quotePxfString(e.url)}');
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

  /// `@<name> prefix* [{body}]`, the body as it was written: it is raw text,
  /// which the directive's consumer decodes.
  void namedDirective(Directive d) {
    buf.write('@${d.name}');
    for (final p in d.prefixes) {
      buf.write(' $p');
    }
    final body = d.body;
    if (body != null) buf.write(' {${utf8.decode(body)}}');
    buf.write('\n');
  }

  /// The header, then one row per line. A null cell is an absent field and
  /// is left empty; a [NullVal] is written.
  void dataset(DatasetDirective d) {
    buf.write('@dataset');
    if (d.type.isNotEmpty) buf.write(' ${d.type}');
    buf.write(' (${d.columns.join(', ')})\n');
    for (final row in d.rows) {
      buf.write('(');
      for (var i = 0; i < row.cells.length; i++) {
        if (i > 0) buf.write(', ');
        final cell = row.cells[i];
        if (cell != null) value(cell, 0);
      }
      buf.write(')\n');
    }
  }

  /// A `@proto` directive in the shape it was read in.
  void proto(ProtoDirective d) {
    buf.write('@proto');
    switch (d.shape) {
      case ProtoShape.anonymous:
        buf.write(' {${utf8.decode(d.body)}}');
      case ProtoShape.named:
        buf.write(' ${d.typeName} {${utf8.decode(d.body)}}');
      case ProtoShape.source:
        buf.write(' """${utf8.decode(d.body)}"""');
      case ProtoShape.descriptor:
        buf.write(' b"${base64.encode(d.body)}"');
    }
    buf.write('\n');
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
