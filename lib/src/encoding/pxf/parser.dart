import 'dart:convert';
import 'ast.dart';
import 'lexer.dart';
import 'token.dart';
import 'errors.dart';
import 'duration.dart';

class Parser {
  final Lexer lex;
  late Token current;
  List<Comment> comments = [];

  Parser(String input) : lex = Lexer(input) {
    _advance();
  }

  void _advance() {
    while (true) {
      current = lex.next();
      if (current.kind == TokenKind.newline) {
        continue;
      }
      if (current.kind == TokenKind.comment) {
        comments.add(Comment(current.pos, current.value));
        continue;
      }
      return;
    }
  }

  List<Comment> _flushComments() {
    if (comments.isEmpty) return [];
    var c = List<Comment>.from(comments);
    comments.clear();
    return c;
  }

  Document parseDocument() {
    var leadingComments = _flushComments();
    String? typeUrl;

    if (current.kind == TokenKind.atType) {
      _advance();
      if (current.kind != TokenKind.ident) {
        throw PxfError(current.pos, 'expected type name after @type, got ${current.kind.name}');
      }
      typeUrl = current.value;
      _advance();
    }

    var entries = <Entry>[];
    while (current.kind != TokenKind.eof) {
      // Top-level: only field_entry is allowed. The document represents a
      // proto message, never a map<K,V>; map_entry (`:` form) is reserved
      // for the inside of a '{ ... }' block. See docs/grammar.ebnf -> document.
      entries.add(_parseEntry(allowMapEntry: false));
    }

    return Document(
      typeUrl: typeUrl,
      entries: entries,
      leadingComments: leadingComments,
    );
  }

  Entry _parseEntry({bool allowMapEntry = true}) {
    var leading = _flushComments();
    var pos = current.pos;

    if (current.kind != TokenKind.ident &&
        current.kind != TokenKind.string &&
        current.kind != TokenKind.int) {
      throw PxfError(pos, 'expected identifier, string, or integer, got ${current.kind.name} ("${current.value}")');
    }

    var keyKind = current.kind;
    var key = current.value;
    _advance();

    switch (current.kind) {
      case TokenKind.equals:
        // `=` denotes a field assignment on a proto message; the key must
        // be an identifier. Map-style keys (string / integer) are only
        // valid with `:`.
        if (keyKind != TokenKind.ident) {
          throw PxfError(pos,
              'field assignment with \'=\' requires an identifier key, got ${keyKind.name} ("$key"); use \':\' for map entries');
        }
        _advance();
        var val = _parseValue();
        return Assignment(
          pos: pos,
          key: key,
          value: val,
          leadingComments: leading,
        );

      case TokenKind.colon:
        // Map entry. Only allowed inside a '{ ... }' block, never at
        // document top level.
        if (!allowMapEntry) {
          throw PxfError(pos,
              'map entry (\':\' form) is only allowed inside a \'{ … }\' block; use \'=\' for top-level field assignments');
        }
        _advance();
        var val = _parseValue();
        return MapEntry(
          pos: pos,
          key: key,
          value: val,
          leadingComments: leading,
        );

      case TokenKind.lbrace:
        // `{ ... }` denotes a submessage field; same identifier-only rule
        // as `=` applies.
        if (keyKind != TokenKind.ident) {
          throw PxfError(pos,
              'submessage block requires an identifier key, got ${keyKind.name} ("$key")');
        }
        _advance();
        var entries = _parseBody();
        return Block(
          pos: pos,
          name: key,
          entries: entries,
          leadingComments: leading,
        );

      default:
        throw PxfError(current.pos, 'expected "=", ":", or "{" after "$key", got ${current.kind.name}');
    }
  }

  Value _parseValue() {
    var pos = current.pos;

    switch (current.kind) {
      case TokenKind.string:
        var v = StringVal(pos, current.value);
        _advance();
        return v;

      case TokenKind.int:
        var v = IntVal(pos, current.value);
        _advance();
        return v;

      case TokenKind.float:
        var v = FloatVal(pos, current.value);
        _advance();
        return v;

      case TokenKind.bool:
        var v = BoolVal(pos, current.value == 'true');
        _advance();
        return v;

      case TokenKind.bytes:
        var decoded = base64.decode(current.value);
        var v = BytesVal(pos, decoded);
        _advance();
        return v;

      case TokenKind.timestamp:
        var t = DateTime.parse(current.value);
        var v = TimestampVal(pos, t, current.value);
        _advance();
        return v;

      case TokenKind.duration:
        try {
          var d = parseGoDuration(current.value);
          var v = DurationVal(pos, d, current.value);
          _advance();
          return v;
        } catch (e) {
          throw PxfError(pos, 'invalid duration "${current.value}": $e');
        }

      case TokenKind.null_:
        var v = NullVal(pos);
        _advance();
        return v;

      case TokenKind.ident:
        var v = IdentVal(pos, current.value);
        _advance();
        return v;

      case TokenKind.lbracket:
        return _parseList();

      case TokenKind.lbrace:
        return _parseBlockVal();

      default:
        throw PxfError(pos, 'expected value, got ${current.kind.name} ("${current.value}")');
    }
  }

  Value _parseList() {
    var pos = current.pos;
    _advance(); // consume [

    var elems = <Value>[];
    while (current.kind != TokenKind.rbracket && current.kind != TokenKind.eof) {
      elems.add(_parseValue());
      if (current.kind == TokenKind.comma) {
        _advance();
      }
    }

    if (current.kind != TokenKind.rbracket) {
      throw PxfError(current.pos, 'expected "]", got ${current.kind.name}');
    }
    _advance();
    return ListVal(pos, elems);
  }

  Value _parseBlockVal() {
    var pos = current.pos;
    _advance(); // consume {
    var entries = _parseBody();
    return BlockVal(pos, entries);
  }

  List<Entry> _parseBody() {
    var entries = <Entry>[];
    while (current.kind != TokenKind.rbrace && current.kind != TokenKind.eof) {
      entries.add(_parseEntry());
    }

    if (current.kind != TokenKind.rbrace) {
      throw PxfError(current.pos, 'expected "}", got ${current.kind.name}');
    }
    _advance();
    return entries;
  }
}

Document parse(String input) {
  return Parser(input).parseDocument();
}
