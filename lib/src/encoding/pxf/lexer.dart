import 'dart:convert';
import 'token.dart';

class Lexer {
  final String input;
  int pos = 0;
  int line = 1;
  int col = 1;

  Lexer(this.input);

  int get _peekCode {
    if (pos >= input.length) return 0;
    return input.codeUnitAt(pos);
  }

  int _peekCodeAt(int offset) {
    int i = pos + offset;
    if (i >= input.length) return 0;
    return input.codeUnitAt(i);
  }

  int _advance() {
    if (pos >= input.length) return 0;
    int ch = input.codeUnitAt(pos);
    pos++;
    if (ch == 10) {
      // \n
      line++;
      col = 1;
    } else {
      col++;
    }
    return ch;
  }

  Position currentPos() => Position(line, col);

  void _skipSpaces() {
    while (pos < input.length) {
      int ch = input.codeUnitAt(pos);
      if (ch == 32 || ch == 9 || ch == 13) {
        // ' ', \t, \r
        _advance();
      } else {
        break;
      }
    }
  }

  Token next() {
    _skipSpaces();
    if (pos >= input.length) {
      return Token(TokenKind.eof, '', currentPos());
    }

    Position p = currentPos();
    int ch = _peekCode;

    if (ch == 10) {
      // \n
      _advance();
      return Token(TokenKind.newline, '\n', p);
    }

    if (ch == 35) {
      // #
      return _lexLineComment(p);
    }

    if (ch == 47 && _peekCodeAt(1) == 47) {
      // //
      return _lexLineComment(p);
    }

    if (ch == 47 && _peekCodeAt(1) == 42) {
      // /*
      return _lexBlockComment(p);
    }

    if (ch == 34) {
      // "
      if (_peekCodeAt(1) == 34 && _peekCodeAt(2) == 34) {
        return _lexTripleString(p);
      }
      return _lexString(p);
    }

    if (ch == 98 && _peekCodeAt(1) == 34) {
      // b"
      return _lexBytes(p);
    }

    switch (ch) {
      case 123: // {
        _advance();
        return Token(TokenKind.lbrace, '{', p);
      case 125: // }
        _advance();
        return Token(TokenKind.rbrace, '}', p);
      case 91: // [
        _advance();
        return Token(TokenKind.lbracket, '[', p);
      case 93: // ]
        _advance();
        return Token(TokenKind.rbracket, ']', p);
      case 61: // =
        _advance();
        return Token(TokenKind.equals, '=', p);
      case 58: // :
        _advance();
        return Token(TokenKind.colon, ':', p);
      case 44: // ,
        _advance();
        return Token(TokenKind.comma, ',', p);
      case 64: // @
        return _lexDirective(p);
    }

    if (ch == 45 || _isDigit(ch)) {
      // - or digit
      return _lexNumber(p);
    }

    if (_isIdentStart(ch)) {
      return _lexIdent(p);
    }

    _advance();
    return Token(TokenKind.illegal, String.fromCharCode(ch), p);
  }

  Token _lexLineComment(Position p) {
    int start = pos;
    while (pos < input.length && input.codeUnitAt(pos) != 10) {
      _advance();
    }
    return Token(TokenKind.comment, input.substring(start, pos), p);
  }

  Token _lexBlockComment(Position p) {
    int start = pos;
    _advance(); // /
    _advance(); // *
    while (pos + 1 < input.length) {
      if (input.codeUnitAt(pos) == 42 && input.codeUnitAt(pos + 1) == 47) {
        _advance(); // *
        _advance(); // /
        return Token(TokenKind.comment, input.substring(start, pos), p);
      }
      _advance();
    }
    return Token(TokenKind.illegal, 'unterminated block comment', p);
  }

  Token _lexString(Position p) {
    _advance(); // opening "
    final sb = StringBuffer();
    while (pos < input.length) {
      final ch = _advance();
      if (ch == 0x22) {
        // closing "
        return Token(TokenKind.string, sb.toString(), p);
      }
      if (ch != 0x5C) {
        // not \, append the original code unit
        sb.writeCharCode(ch);
        continue;
      }
      if (pos >= input.length) {
        return Token(TokenKind.illegal, 'unterminated escape sequence', p);
      }
      final esc = _advance();
      switch (esc) {
        case 0x22: // \"
        case 0x5C: // \\
        case 0x27: // \'
        case 0x3F: // \?
          sb.writeCharCode(esc);
          break;
        case 0x61: sb.writeCharCode(0x07); break; // \a
        case 0x62: sb.writeCharCode(0x08); break; // \b
        case 0x66: sb.writeCharCode(0x0C); break; // \f
        case 0x6E: sb.writeCharCode(0x0A); break; // \n
        case 0x72: sb.writeCharCode(0x0D); break; // \r
        case 0x74: sb.writeCharCode(0x09); break; // \t
        case 0x76: sb.writeCharCode(0x0B); break; // \v
        case 0x78: // \xHH
          final b = _readHexByte();
          if (b == null) {
            return Token(TokenKind.illegal,
                r'invalid \x escape: expected 2 hex digits', p);
          }
          sb.writeCharCode(b);
          break;
        case 0x30: case 0x31: case 0x32: case 0x33: // \nnn (3 octal, 0-3 first)
          final b = _readOctRest(esc);
          if (b == null) {
            return Token(TokenKind.illegal,
                'invalid octal escape: expected 3 octal digits', p);
          }
          sb.writeCharCode(b);
          break;
        case 0x75: // \uHHHH
          final r = _readHexRune(4);
          if (r == null || !_isValidRune(r)) {
            return Token(TokenKind.illegal,
                r'invalid \u escape: expected 4 hex digits forming a valid codepoint',
                p);
          }
          sb.writeCharCode(r);
          break;
        case 0x55: // \UHHHHHHHH
          final r = _readHexRune(8);
          if (r == null || !_isValidRune(r)) {
            return Token(TokenKind.illegal,
                r'invalid \U escape: expected 8 hex digits forming a valid codepoint',
                p);
          }
          if (r > 0xFFFF) {
            // Astral plane: encode as a UTF-16 surrogate pair so the
            // resulting Dart string round-trips through codeUnits.
            sb.writeCharCode(0xD800 + ((r - 0x10000) >> 10));
            sb.writeCharCode(0xDC00 + ((r - 0x10000) & 0x3FF));
          } else {
            sb.writeCharCode(r);
          }
          break;
        default:
          return Token(TokenKind.illegal,
              'unknown escape sequence \\${String.fromCharCode(esc)}', p);
      }
    }
    return Token(TokenKind.illegal, 'unterminated string', p);
  }

  /// Reads exactly two hex digits and returns the assembled byte.
  int? _readHexByte() {
    if (pos + 1 >= input.length) return null;
    final hi = _hexVal(input.codeUnitAt(pos));
    final lo = _hexVal(input.codeUnitAt(pos + 1));
    if (hi == null || lo == null) return null;
    _advance();
    _advance();
    return (hi << 4) | lo;
  }

  /// Reads exactly `n` hex digits and returns the assembled code point.
  int? _readHexRune(int n) {
    if (pos + n > input.length) return null;
    var value = 0;
    for (var i = 0; i < n; i++) {
      final v = _hexVal(input.codeUnitAt(pos));
      if (v == null) return null;
      value = (value << 4) | v;
      _advance();
    }
    return value;
  }

  /// Reads two more octal digits after the leading one already consumed.
  /// `first` is restricted to ASCII '0'-'3' so the value never overflows
  /// a byte.
  int? _readOctRest(int first) {
    if (pos + 1 >= input.length) return null;
    final d1 = _octVal(input.codeUnitAt(pos));
    final d2 = _octVal(input.codeUnitAt(pos + 1));
    if (d1 == null || d2 == null) return null;
    _advance();
    _advance();
    return ((first - 0x30) << 6) | (d1 << 3) | d2;
  }

  static int? _hexVal(int ch) {
    if (ch >= 0x30 && ch <= 0x39) return ch - 0x30;
    if (ch >= 0x61 && ch <= 0x66) return ch - 0x61 + 10;
    if (ch >= 0x41 && ch <= 0x46) return ch - 0x41 + 10;
    return null;
  }

  static int? _octVal(int ch) =>
      (ch >= 0x30 && ch <= 0x37) ? ch - 0x30 : null;

  /// Mirrors Go's utf8.ValidRune: in [0, 0x10FFFF] and not a UTF-16 surrogate.
  static bool _isValidRune(int r) =>
      r >= 0 && r <= 0x10FFFF && (r < 0xD800 || r > 0xDFFF);

  Token _lexTripleString(Position p) {
    _advance(); // "
    _advance(); // "
    _advance(); // "
    int start = pos;
    while (pos + 2 < input.length) {
      if (input.codeUnitAt(pos) == 34 &&
          input.codeUnitAt(pos + 1) == 34 &&
          input.codeUnitAt(pos + 2) == 34) {
        String raw = input.substring(start, pos);
        _advance(); // "
        _advance(); // "
        _advance(); // "
        return Token(TokenKind.string, _dedent(raw), p);
      }
      _advance();
    }
    return Token(TokenKind.illegal, 'unterminated triple-quoted string', p);
  }

  String _dedent(String s) {
    if (s.isNotEmpty && s[0] == '\n') {
      s = s.substring(1);
    }
    List<String> lines = s.split('\n');
    if (lines.isEmpty) return '';
    String last = lines.last;
    if (last.trim().isEmpty) {
      String indent = last;
      lines.removeLast();
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].startsWith(indent)) {
          lines[i] = lines[i].substring(indent.length);
        }
      }
    }
    return lines.join('\n');
  }

  Token _lexBytes(Position p) {
    _advance(); // b
    Token tok = _lexString(p);
    if (tok.kind != TokenKind.string) {
      return tok;
    }
    try {
      base64.decode(tok.value);
    } catch (e) {
      return Token(TokenKind.illegal, 'invalid base64 in bytes literal', p);
    }
    return Token(TokenKind.bytes, tok.value, p);
  }

  Token _lexDirective(Position p) {
    _advance(); // @
    int start = pos;
    while (pos < input.length && _isIdentPart(input.codeUnitAt(pos))) {
      _advance();
    }
    String name = input.substring(start, pos);
    if (name == 'type') {
      return Token(TokenKind.atType, '@type', p);
    }
    return Token(TokenKind.illegal, '@$name', p);
  }

  Token _lexNumber(Position p) {
    int start = pos;
    bool neg = false;
    if (_peekCode == 45) {
      // -
      neg = true;
      _advance();
      if (pos >= input.length || !_isDigit(_peekCode)) {
        return Token(TokenKind.illegal, '-', p);
      }
    }

    int digitStart = pos;
    while (pos < input.length && _isDigit(_peekCode)) {
      _advance();
    }
    int digitCount = pos - digitStart;

    // Timestamp: exactly 4 digits followed by '-', only non-negative
    if (!neg && digitCount == 4 && pos < input.length && _peekCode == 45) {
      return _lexTimestamp(p, start);
    }
    // Float: '.' or 'e'/'E'
    if (pos < input.length &&
        (_peekCode == 46 || _peekCode == 101 || _peekCode == 69)) {
      // ., e, E
      return _lexFloat(p, start);
    }
    // Duration: digits followed by a time unit letter
    if (pos < input.length && _isDurationUnit(_peekCode)) {
      return _lexDuration(p, start);
    }

    return Token(TokenKind.int, input.substring(start, pos), p);
  }

  Token _lexFloat(Position p, int start) {
    if (_peekCode == 46) {
      // .
      _advance();
      while (pos < input.length && _isDigit(_peekCode)) {
        _advance();
      }
    }
    if (pos < input.length && (_peekCode == 101 || _peekCode == 69)) {
      // e, E
      _advance();
      if (pos < input.length && (_peekCode == 43 || _peekCode == 45)) {
        // +, -
        _advance();
      }
      while (pos < input.length && _isDigit(_peekCode)) {
        _advance();
      }
    }
    return Token(TokenKind.float, input.substring(start, pos), p);
  }

  Token _lexTimestamp(Position p, int start) {
    while (pos < input.length) {
      int ch = _peekCode;
      if (ch == 32 ||
          ch == 10 ||
          ch == 9 ||
          ch == 13 ||
          ch == 44 ||
          ch == 93 ||
          ch == 125 ||
          ch == 35) {
        // ' ', \n, \t, \r, ,, ], }, #
        break;
      }
      if (ch == 47 && (_peekCodeAt(1) == 47 || _peekCodeAt(1) == 42)) {
        // // or /*
        break;
      }
      _advance();
    }
    String raw = input.substring(start, pos);
    try {
      DateTime.parse(raw);
    } catch (e) {
      return Token(TokenKind.illegal, 'invalid timestamp: $raw', p);
    }
    return Token(TokenKind.timestamp, raw, p);
  }

  Token _lexDuration(Position p, int start) {
    while (pos < input.length && (_isDigit(_peekCode) || _isLowerAlpha(_peekCode))) {
      _advance();
    }
    String raw = input.substring(start, pos);
    if (!_isValidDuration(raw)) {
      return Token(TokenKind.illegal, 'invalid duration: $raw', p);
    }
    return Token(TokenKind.duration, raw, p);
  }

  bool _isValidDuration(String s) {
    // Basic validation for Go-style duration
    // Regex for duration: ([-+]?([0-9.]+[a-z]+)+)
    // We'll just do a simple check for now, or maybe port a more robust one.
    final durationRegex = RegExp(r'^([-+]?([0-9]+(\.[0-9]+)?(ns|us|µs|ms|s|m|h))+)$');
    return durationRegex.hasMatch(s);
  }

  Token _lexIdent(Position p) {
    int start = pos;
    while (pos < input.length && _isIdentPart(input.codeUnitAt(pos))) {
      _advance();
    }
    String val = input.substring(start, pos);
    if (val == 'true' || val == 'false') {
      return Token(TokenKind.bool, val, p);
    }
    if (val == 'null') {
      return Token(TokenKind.null_, val, p);
    }
    return Token(TokenKind.ident, val, p);
  }

  bool _isDigit(int ch) => ch >= 48 && ch <= 57;
  bool _isIdentStart(int ch) =>
      (ch >= 97 && ch <= 122) || (ch >= 65 && ch <= 90) || ch == 95; // a-z, A-Z, _
  bool _isIdentPart(int ch) => _isIdentStart(ch) || _isDigit(ch) || ch == 46; // ., digits
  bool _isDurationUnit(int ch) =>
      ch == 104 || ch == 109 || ch == 115 || ch == 110 || ch == 117; // h, m, s, n, u
  bool _isLowerAlpha(int ch) => ch >= 97 && ch <= 122;
}
