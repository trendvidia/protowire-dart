// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
enum TokenKind {
  eof,
  illegal,
  newline,
  comment,

  ident,
  string,
  int,
  float,
  bool,
  null_,
  bytes,
  timestamp,
  duration,

  lbrace,
  rbrace,
  lbracket,
  rbracket,
  lparen,
  rparen,
  equals,
  colon,
  comma,

  atType,
  atDataset,
  atProto,
  atDirective,
}

extension TokenKindExtension on TokenKind {
  String get name {
    switch (this) {
      case TokenKind.eof:
        return 'EOF';
      case TokenKind.illegal:
        return 'ILLEGAL';
      case TokenKind.newline:
        return 'newline';
      case TokenKind.comment:
        return 'comment';
      case TokenKind.ident:
        return 'identifier';
      case TokenKind.string:
        return 'string';
      case TokenKind.int:
        return 'integer';
      case TokenKind.float:
        return 'float';
      case TokenKind.bool:
        return 'bool';
      case TokenKind.null_:
        return 'null';
      case TokenKind.bytes:
        return 'bytes';
      case TokenKind.timestamp:
        return 'timestamp';
      case TokenKind.duration:
        return 'duration';
      case TokenKind.lbrace:
        return '{';
      case TokenKind.rbrace:
        return '}';
      case TokenKind.lbracket:
        return '[';
      case TokenKind.rbracket:
        return ']';
      case TokenKind.lparen:
        return '(';
      case TokenKind.rparen:
        return ')';
      case TokenKind.equals:
        return '=';
      case TokenKind.colon:
        return ':';
      case TokenKind.comma:
        return ',';
      case TokenKind.atType:
        return '@type';
      case TokenKind.atDataset:
        return '@dataset';
      case TokenKind.atProto:
        return '@proto';
      case TokenKind.atDirective:
        return '@<name>';
    }
  }
}

class Position {
  final int line;
  final int column;

  Position(this.line, this.column);

  @override
  String toString() => '$line:$column';
}

class Token {
  final TokenKind kind;
  final String value;
  final Position pos;

  /// The digits of a number's precision suffix, `53` of `1.5p53`.
  final String? prec;

  Token(this.kind, this.value, this.pos, {this.prec});

  /// The token as written, precision suffix included.
  String get text => prec == null ? value : '${value}p$prec';

  @override
  String toString() => 'Token(${kind.name}, "$value", $pos)';
}
