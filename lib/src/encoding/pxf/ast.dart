// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'token.dart';

class Comment {
  final Position pos;
  final String text;

  Comment(this.pos, this.text);
}

class Document {
  String? typeUrl;
  /// Generic `@<name> *(prefix) [{ ... }]` directives in source order
  /// (draft §3.4.2). Excludes `@type`, `@dataset`, `@proto`.
  final List<Directive> directives;
  /// `@dataset` directives in source order (draft §3.4.4). A document
  /// with any `@dataset` MUST NOT have `@type` or top-level body entries.
  final List<DatasetDirective> datasets;
  /// `@proto` directives in source order (draft §3.4.5).
  final List<ProtoDirective> protos;
  /// Byte offset where the schema-typed body begins, after all directives.
  int bodyOffset;
  final List<Entry> entries;
  final List<Comment> leadingComments;

  Document({
    this.typeUrl,
    List<Directive>? directives,
    List<DatasetDirective>? datasets,
    List<ProtoDirective>? protos,
    this.bodyOffset = 0,
    required this.entries,
    required this.leadingComments,
  })  : directives = directives ?? [],
        datasets = datasets ?? [],
        protos = protos ?? [];
}

/// Top-of-document `@<name> *(<prefix-id>) [{ ... }]` entry
/// (draft §3.4.2). Side-channel metadata that sits alongside the
/// schema-typed body — e.g. chameleon's
/// `@header chameleon.v1.LayerHeader { id = "x" }`.
class Directive {
  final Position pos;
  final String name;
  final List<String> prefixes;
  /// Back-compat single-prefix sugar: populated when exactly one prefix
  /// identifier was supplied. Empty for zero or 2+ prefixes; new code
  /// should read [prefixes] directly.
  final String type;
  /// Raw inner bytes of the block; `null` when the directive has no `{ ... }`.
  final List<int>? body;
  final List<Comment> leadingComments;

  Directive({
    required this.pos,
    required this.name,
    this.prefixes = const [],
    this.type = '',
    this.body,
    this.leadingComments = const [],
  });

  bool get hasBody => body != null;
}

/// `@dataset <type> ( col1, col2, ... ) row*` entry at document root
/// (draft §3.4.4). Carries many instances of one message type in a
/// single document — the protowire-native CSV. [type] MAY be empty when
/// an anonymous `@proto` precedes the `@dataset`.
class DatasetDirective {
  final Position pos;
  final String type;
  final List<String> columns;
  final List<DatasetRow> rows;
  final List<Comment> leadingComments;

  DatasetDirective({
    required this.pos,
    this.type = '',
    this.columns = const [],
    this.rows = const [],
    this.leadingComments = const [],
  });
}

/// One parenthesised cell tuple in a `@dataset` directive. [cells] has
/// the same length as the containing `DatasetDirective.columns`. A
/// `null` entry denotes an absent field; a `NullVal` denotes
/// present-but-null; any other value denotes a present field.
class DatasetRow {
  final Position pos;
  final List<Value?> cells;
  DatasetRow({required this.pos, required this.cells});
}

/// Lexical body shape of a `@proto` directive (draft §3.4.5).
enum ProtoShape {
  anonymous,
  named,
  source,
  descriptor;

  String get displayName {
    switch (this) {
      case ProtoShape.anonymous:
        return 'anonymous';
      case ProtoShape.named:
        return 'named';
      case ProtoShape.source:
        return 'source';
      case ProtoShape.descriptor:
        return 'descriptor';
    }
  }
}

/// `@proto <body>` entry at document root (draft §3.4.5). [body] holds
/// raw bytes interpreted per [shape]: for anonymous/named, the bytes
/// between `{` and matching `}`; for source, the dedented triple-quoted
/// string contents; for descriptor, the base64-decoded
/// `FileDescriptorSet`.
class ProtoDirective {
  final Position pos;
  final ProtoShape shape;
  /// Dotted message type name; non-empty only when `shape == named`.
  final String typeName;
  final List<int> body;
  final List<Comment> leadingComments;

  ProtoDirective({
    required this.pos,
    required this.shape,
    this.typeName = '',
    this.body = const [],
    this.leadingComments = const [],
  });
}

abstract class Entry {
  Position get pos;
}

class Assignment implements Entry {
  @override
  final Position pos;
  final String key;
  final Value value;
  final List<Comment> leadingComments;
  final String? trailingComment;

  Assignment({
    required this.pos,
    required this.key,
    required this.value,
    required this.leadingComments,
    this.trailingComment,
  });
}

class MapEntry implements Entry {
  @override
  final Position pos;
  final String key;
  final Value value;
  final List<Comment> leadingComments;
  final String? trailingComment;

  MapEntry({
    required this.pos,
    required this.key,
    required this.value,
    required this.leadingComments,
    this.trailingComment,
  });
}

class Block implements Entry {
  @override
  final Position pos;
  final String name;
  final List<Entry> entries;
  final List<Comment> leadingComments;

  Block({
    required this.pos,
    required this.name,
    required this.entries,
    required this.leadingComments,
  });
}

abstract class Value {
  Position get pos;
}

class StringVal implements Value {
  @override
  final Position pos;
  final String value;

  StringVal(this.pos, this.value);
}

class IntVal implements Value {
  @override
  final Position pos;
  final String raw;

  IntVal(this.pos, this.raw);
}

class FloatVal implements Value {
  @override
  final Position pos;
  final String raw;

  FloatVal(this.pos, this.raw);
}

class BoolVal implements Value {
  @override
  final Position pos;
  final bool value;

  BoolVal(this.pos, this.value);
}

class BytesVal implements Value {
  @override
  final Position pos;
  final List<int> value;

  BytesVal(this.pos, this.value);
}

class NullVal implements Value {
  @override
  final Position pos;

  NullVal(this.pos);
}

class IdentVal implements Value {
  @override
  final Position pos;
  final String name;

  IdentVal(this.pos, this.name);
}

class TimestampVal implements Value {
  @override
  final Position pos;
  final DateTime value;
  final String raw;

  TimestampVal(this.pos, this.value, this.raw);
}

class DurationVal implements Value {
  @override
  final Position pos;
  final Duration value;
  final String raw;

  DurationVal(this.pos, this.value, this.raw);
}

class ListVal implements Value {
  @override
  final Position pos;
  final List<Value> elements;

  ListVal(this.pos, this.elements);
}

class BlockVal implements Value {
  @override
  final Position pos;
  final List<Entry> entries;

  BlockVal(this.pos, this.entries);
}
