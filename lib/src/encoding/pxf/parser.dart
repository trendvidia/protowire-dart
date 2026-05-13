// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'dart:convert';
import 'dart:typed_data';
import 'ast.dart';
import 'brace_scan.dart';
import 'lexer.dart';
import 'schema.dart';
import 'token.dart';
import 'errors.dart';
import 'duration.dart';

/// HARDENING.md § Recursion — see decode.dart for the cross-port rationale.
const int _maxNestingDepth = 100;

class Parser {
  final Lexer lex;
  late Token current;
  List<Comment> comments = [];
  int _depth = 0;

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
    final directives = <Directive>[];
    final datasets = <DatasetDirective>[];
    final protos = <ProtoDirective>[];
    int bodyOffset = 0;

    // Top-of-document directives. @type, @<name>, @dataset, @proto may
    // interleave in any order. bodyOffset tracks the byte right after
    // the last directive token.
    directiveLoop:
    while (true) {
      switch (current.kind) {
        case TokenKind.atType:
          _advance();
          if (current.kind != TokenKind.ident) {
            throw PxfError(current.pos,
                'expected type name after @type, got ${current.kind.name}');
          }
          typeUrl = current.value;
          bodyOffset = lex.pos;
          _advance();
          break;
        case TokenKind.atDirective:
          final (d, end) = _parseDirective();
          directives.add(d);
          bodyOffset = end;
          break;
        case TokenKind.atDataset:
          final (ds, end) = _parseDatasetDirective();
          datasets.add(ds);
          bodyOffset = end;
          break;
        case TokenKind.atProto:
          final (pd, end) = _parseProtoDirective();
          protos.add(pd);
          bodyOffset = end;
          break;
        default:
          break directiveLoop;
      }
    }

    // Standalone constraint (draft §3.4.4): a document containing any
    // @dataset directive MUST NOT also carry @type or top-level field
    // entries — the @dataset header IS the document's type declaration.
    if (datasets.isNotEmpty) {
      if (typeUrl != null) {
        throw PxfError(datasets.first.pos,
            '@dataset directive cannot coexist with @type; the @dataset header declares the document\'s type (draft §3.4.4)');
      }
      if (current.kind != TokenKind.eof) {
        throw PxfError(current.pos,
            '@dataset directive cannot coexist with top-level field entries; the document\'s payload is the @dataset rows (draft §3.4.4)');
      }
    }

    var entries = <Entry>[];
    while (current.kind != TokenKind.eof) {
      entries.add(_parseEntry());
    }

    return Document(
      typeUrl: typeUrl,
      directives: directives,
      datasets: datasets,
      protos: protos,
      bodyOffset: bodyOffset,
      entries: entries,
      leadingComments: leadingComments,
    );
  }

  /// Parses `@<name> *(<prefix-id>) [{ ... }]`. The `atDirective` token
  /// is current on entry. Returns the directive and the byte offset
  /// immediately after its last token.
  (Directive, int) _parseDirective() {
    final leading = _flushComments();
    final atPos = current.pos;
    final name = current.value;
    if (isFutureReservedDirective(name)) {
      throw PxfError(atPos,
          '@$name is a spec-reserved directive name with no v1 semantics (draft §3.4.6)');
    }
    final prefixes = <String>[];
    _advance();
    int endOffset = lex.pos;

    // Zero-or-more prefix identifiers. One-token lookahead disambiguates:
    // an identifier followed by `=` or `:` is a body field key, not a
    // directive prefix.
    while (current.kind == TokenKind.ident) {
      final pk = _peekKind();
      if (pk == TokenKind.equals || pk == TokenKind.colon) break;
      prefixes.add(current.value);
      _advance();
      endOffset = lex.pos;
    }

    List<int>? body;
    if (current.kind == TokenKind.lbrace) {
      final open = lex.pos - 1; // `{` already consumed into `current`
      final close = findMatchingBrace(lex.input, open);
      if (close < 0) {
        throw PxfError(atPos, 'directive @$name: unmatched "{"');
      }
      // Validate inner well-formedness by parsing the block.
      _parseBlockVal();
      body = Uint8List.fromList(utf8.encode(lex.input.substring(open + 1, close)));
      endOffset = close + 1;
    }

    final typeField = prefixes.length == 1 ? prefixes[0] : '';
    return (
      Directive(
        pos: atPos,
        name: name,
        prefixes: prefixes,
        type: typeField,
        body: body,
        leadingComments: leading,
      ),
      endOffset,
    );
  }

  /// Parses `@dataset <type> ( col1, col2, ... ) row*` per draft §3.4.4.
  /// `atDataset` is current on entry.
  (DatasetDirective, int) _parseDatasetDirective() {
    final leading = _flushComments();
    final atPos = current.pos;
    _advance();

    // Optional row message type (dotted identifier). MAY be omitted
    // when an anonymous @proto precedes the @dataset.
    var type = '';
    if (current.kind == TokenKind.ident) {
      type = current.value;
      _advance();
    }

    if (current.kind != TokenKind.lparen) {
      throw PxfError(current.pos,
          'expected "(" to start @dataset column list, got ${current.kind.name}');
    }
    _advance();

    if (current.kind != TokenKind.ident) {
      throw PxfError(current.pos,
          '@dataset column list must contain at least one field name, got ${current.kind.name}');
    }
    final columns = <String>[];
    while (true) {
      if (current.kind != TokenKind.ident) {
        throw PxfError(
            current.pos, 'expected column field name, got ${current.kind.name}');
      }
      final colName = current.value;
      if (colName.contains('.')) {
        throw PxfError(current.pos,
            '@dataset column "$colName": dotted column paths are not supported in v1 (draft §3.4.4)');
      }
      columns.add(colName);
      _advance();
      if (current.kind == TokenKind.comma) {
        _advance();
        continue;
      }
      if (current.kind == TokenKind.rparen) break;
      throw PxfError(current.pos,
          'expected "," or ")" in @dataset column list, got ${current.kind.name}');
    }
    int endOffset = lex.pos;
    _advance();

    final rows = <DatasetRow>[];
    while (current.kind == TokenKind.lparen) {
      final (row, rowEnd) = _parseDatasetRow(columns.length);
      rows.add(row);
      endOffset = rowEnd;
    }

    return (
      DatasetDirective(
        pos: atPos,
        type: type,
        columns: columns,
        rows: rows,
        leadingComments: leading,
      ),
      endOffset,
    );
  }

  (DatasetRow, int) _parseDatasetRow(int expected) {
    final pos = current.pos;
    _advance();

    final cells = <Value?>[];
    cells.add(_parseRowCell());
    while (current.kind == TokenKind.comma) {
      _advance();
      cells.add(_parseRowCell());
    }
    if (current.kind != TokenKind.rparen) {
      throw PxfError(current.pos,
          'expected "," or ")" in @dataset row, got ${current.kind.name}');
    }
    final endOffset = lex.pos;
    _advance();

    if (cells.length != expected) {
      throw PxfError(pos,
          '@dataset row has ${cells.length} cells, expected $expected (column count)');
    }
    return (DatasetRow(pos: pos, cells: cells), endOffset);
  }

  Value? _parseRowCell() {
    switch (current.kind) {
      case TokenKind.comma:
      case TokenKind.rparen:
        return null;
      case TokenKind.lbracket:
        throw PxfError(current.pos,
            '@dataset cells cannot contain list values in v1 (draft §3.4.4)');
      case TokenKind.lbrace:
        throw PxfError(current.pos,
            '@dataset cells cannot contain block values in v1 (draft §3.4.4)');
      default:
        return _parseValue();
    }
  }

  /// Parses `@proto <body>`. `atProto` is current on entry. Distinguishes
  /// four lexically-determined shapes (draft §3.4.5).
  (ProtoDirective, int) _parseProtoDirective() {
    final leading = _flushComments();
    final atPos = current.pos;
    _advance();

    switch (current.kind) {
      case TokenKind.lbrace:
        final (body, end) = _captureBraceBody('@proto (anonymous form)');
        return (
          ProtoDirective(
            pos: atPos,
            shape: ProtoShape.anonymous,
            body: body,
            leadingComments: leading,
          ),
          end,
        );
      case TokenKind.ident:
        final typeName = current.value;
        _advance();
        if (current.kind != TokenKind.lbrace) {
          throw PxfError(current.pos,
              'expected "{" after @proto $typeName, got ${current.kind.name}');
        }
        final (body, end) = _captureBraceBody('@proto $typeName');
        return (
          ProtoDirective(
            pos: atPos,
            shape: ProtoShape.named,
            typeName: typeName,
            body: body,
            leadingComments: leading,
          ),
          end,
        );
      case TokenKind.string:
        final bytes = Uint8List.fromList(utf8.encode(current.value));
        _advance();
        final end = lex.pos;
        return (
          ProtoDirective(
            pos: atPos,
            shape: ProtoShape.source,
            body: bytes,
            leadingComments: leading,
          ),
          end,
        );
      case TokenKind.bytes:
        final raw = current.value;
        List<int> decoded;
        try {
          decoded = base64.decode(raw);
        } on FormatException {
          // Try URL-safe alphabet (allowed per draft §3.7).
          try {
            decoded = base64Url.decode(raw);
          } on FormatException {
            // Try with padding.
            var padded = raw;
            final rem = padded.length % 4;
            if (rem != 0) padded = padded + ('=' * (4 - rem));
            try {
              decoded = base64Url.decode(padded);
            } on FormatException {
              throw PxfError(
                  current.pos, '@proto descriptor body: invalid base64');
            }
          }
        }
        _advance();
        final end = lex.pos;
        return (
          ProtoDirective(
            pos: atPos,
            shape: ProtoShape.descriptor,
            body: decoded,
            leadingComments: leading,
          ),
          end,
        );
      default:
        throw PxfError(current.pos,
            'expected "{", dotted identifier, triple-quoted string, or b"..." after @proto, got ${current.kind.name}');
    }
  }

  /// Slices the raw bytes between `{` and the matching `}` (both
  /// exclusive) without decoding the contents as PXF. Repositions the
  /// lexer past the closing `}` and primes the parser.
  (List<int>, int) _captureBraceBody(String label) {
    final open = lex.pos - 1; // `{` already consumed
    final close = findMatchingBrace(lex.input, open);
    if (close < 0) {
      throw PxfError(current.pos, '$label: unmatched "{"');
    }
    final body =
        Uint8List.fromList(utf8.encode(lex.input.substring(open + 1, close)));
    lex.repositionTo(close + 1);
    _advance();
    return (body, close + 1);
  }

  /// One-token lookahead with full state restore. Skips newlines /
  /// comments without disturbing pending-comment accumulation.
  TokenKind _peekKind() {
    final state = lex.save();
    final savedCurrent = current;
    final savedCount = comments.length;
    _advance();
    final peeked = current.kind;
    lex.restore(state);
    current = savedCurrent;
    if (comments.length > savedCount) {
      comments.removeRange(savedCount, comments.length);
    }
    return peeked;
  }

  Entry _parseEntry() {
    var leading = _flushComments();
    var pos = current.pos;

    if (current.kind != TokenKind.ident &&
        current.kind != TokenKind.string &&
        current.kind != TokenKind.int) {
      throw PxfError(pos,
          'expected identifier, string, or integer, got ${current.kind.name} ("${current.value}")');
    }

    var key = current.value;
    _advance();

    switch (current.kind) {
      case TokenKind.equals:
        _advance();
        var val = _parseValue();
        return Assignment(
          pos: pos,
          key: key,
          value: val,
          leadingComments: leading,
        );

      case TokenKind.colon:
        _advance();
        var val = _parseValue();
        return MapEntry(
          pos: pos,
          key: key,
          value: val,
          leadingComments: leading,
        );

      case TokenKind.lbrace:
        _advance();
        var entries = _parseBody();
        return Block(
          pos: pos,
          name: key,
          entries: entries,
          leadingComments: leading,
        );

      default:
        throw PxfError(current.pos,
            'expected "=", ":", or "{" after "$key", got ${current.kind.name}');
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
        throw PxfError(pos,
            'expected value, got ${current.kind.name} ("${current.value}")');
    }
  }

  Value _parseList() {
    var pos = current.pos;
    _advance(); // consume [

    var elems = <Value>[];
    while (
        current.kind != TokenKind.rbracket && current.kind != TokenKind.eof) {
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
    if (_depth >= _maxNestingDepth) {
      throw PxfError(current.pos,
          'message nesting exceeds MaxNestingDepth=$_maxNestingDepth');
    }
    _depth++;
    try {
      var entries = <Entry>[];
      while (
          current.kind != TokenKind.rbrace && current.kind != TokenKind.eof) {
        entries.add(_parseEntry());
      }

      if (current.kind != TokenKind.rbrace) {
        throw PxfError(current.pos, 'expected "}", got ${current.kind.name}');
      }
      _advance();
      return entries;
    } finally {
      _depth--;
    }
  }
}

Document parse(String input) {
  return Parser(input).parseDocument();
}
