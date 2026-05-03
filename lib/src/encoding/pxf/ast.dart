import 'token.dart';

class Comment {
  final Position pos;
  final String text;

  Comment(this.pos, this.text);
}

class Document {
  String? typeUrl;
  final List<Entry> entries;
  final List<Comment> leadingComments;

  Document({this.typeUrl, required this.entries, required this.leadingComments});
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
