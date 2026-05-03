import 'package:test/test.dart';
import 'package:protowire/src/encoding/pxf/lexer.dart';
import 'package:protowire/src/encoding/pxf/token.dart';

Token _firstToken(String input) {
  final lex = Lexer(input);
  while (true) {
    final t = lex.next();
    if (t.kind == TokenKind.newline) continue;
    return t;
  }
}

void main() {
  group('PXF lexer escape set (PR2 — Go-aligned)', () {
    test('simple escapes \\" \\\\ \\\' \\?', () {
      // Lexer input: literal 8 characters between the outer quotes:
      //   \" \\ \' \?
      // (each two chars: backslash + the listed char).
      final t = _firstToken('"\\"\\\\\\\'\\?"');
      expect(t.kind, TokenKind.string);
      expect(t.value, '"\\\'?');
    });

    test('letter escapes \\a \\b \\f \\v \\n \\r \\t', () {
      final t = _firstToken(r'"\a\b\f\v\n\r\t"');
      expect(t.kind, TokenKind.string);
      expect(t.value.codeUnits,
          [0x07, 0x08, 0x0C, 0x0B, 0x0A, 0x0D, 0x09]);
    });

    test(r'\xHH hex byte escape', () {
      final t = _firstToken(r'"\x41\x7f"');
      expect(t.kind, TokenKind.string);
      expect(t.value, 'A\u{7F}');
    });

    test(r'\xHH invalid hex returns ILLEGAL', () {
      final t = _firstToken(r'"\xZZ"');
      expect(t.kind, TokenKind.illegal);
    });

    test(r'\nnn octal escape (3 digits, leading 0-3)', () {
      // \101 = 0x41 = 'A'; \040 = 0x20 = ' '
      final t = _firstToken(r'"\101\040"');
      expect(t.kind, TokenKind.string);
      expect(t.value, 'A ');
    });

    test(r'\nnn rejects leading 4-9', () {
      final t = _firstToken(r'"\401"');
      expect(t.kind, TokenKind.illegal);
    });

    test(r'\uHHHH 4-digit codepoint', () {
      // é = 'é' (latin small e with acute)
      final t = _firstToken(r'"é"');
      expect(t.kind, TokenKind.string);
      expect(t.value, 'é');
    });

    test(r'\uHHHH rejects too-few digits', () {
      final t = _firstToken(r'"\u12"');
      expect(t.kind, TokenKind.illegal);
    });

    test(r'\UHHHHHHHH 8-digit astral codepoint', () {
      // \U0001F600 = 😀
      final t = _firstToken(r'"\U0001f600"');
      expect(t.kind, TokenKind.string);
      expect(t.value, '😀');
    });

    test('unknown escape returns ILLEGAL with descriptive message', () {
      final t = _firstToken(r'"\q"');
      expect(t.kind, TokenKind.illegal);
      expect(t.value, contains('unknown escape'));
    });

    test('unterminated escape at end of input', () {
      final t = _firstToken('"\\');
      expect(t.kind, TokenKind.illegal);
      expect(t.value, contains('unterminated'));
    });

    test('UTF-8 bytes pass through verbatim outside escapes', () {
      // The string body contains literal UTF-8; preserve it.
      final t = _firstToken('"héllo"');
      expect(t.kind, TokenKind.string);
      expect(t.value, 'héllo');
    });
  });
}
