// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// Byte-level brace matching used by directive parsing to slice raw body
// content out of the input without re-lexing it as PXF. Mirrors the
// lexer's string / comment handling so braces inside literals don't
// confuse the brace count.

/// Returns the offset of the `}` matching the `{` at [openOffset], or
/// `-1` on unterminated input.
int findMatchingBrace(String input, int openOffset) {
  int depth = 1;
  int i = openOffset + 1;
  while (i < input.length) {
    final ch = input.codeUnitAt(i);
    if (ch == 0x7B) {
      // {
      depth++;
      i++;
    } else if (ch == 0x7D) {
      // }
      depth--;
      if (depth == 0) return i;
      i++;
    } else if (ch == 0x22) {
      // "
      final j = _skipString(input, i);
      if (j < 0) return -1;
      i = j;
    } else if (ch == 0x62 &&
        i + 1 < input.length &&
        input.codeUnitAt(i + 1) == 0x22) {
      // b"
      final j = _skipBytes(input, i);
      if (j < 0) return -1;
      i = j;
    } else if (ch == 0x23) {
      // #
      i = _skipEOL(input, i + 1);
    } else if (ch == 0x2F &&
        i + 1 < input.length &&
        input.codeUnitAt(i + 1) == 0x2F) {
      // //
      i = _skipEOL(input, i + 2);
    } else if (ch == 0x2F &&
        i + 1 < input.length &&
        input.codeUnitAt(i + 1) == 0x2A) {
      // /*
      int j = i + 2;
      bool closed = false;
      while (j + 1 < input.length) {
        if (input.codeUnitAt(j) == 0x2A && input.codeUnitAt(j + 1) == 0x2F) {
          j += 2;
          closed = true;
          break;
        }
        j++;
      }
      if (!closed) return -1;
      i = j;
    } else {
      i++;
    }
  }
  return -1;
}

int _skipString(String input, int i) {
  if (i + 2 < input.length &&
      input.codeUnitAt(i + 1) == 0x22 &&
      input.codeUnitAt(i + 2) == 0x22) {
    int j = i + 3;
    while (j + 2 < input.length) {
      if (input.codeUnitAt(j) == 0x22 &&
          input.codeUnitAt(j + 1) == 0x22 &&
          input.codeUnitAt(j + 2) == 0x22) {
        return j + 3;
      }
      j++;
    }
    return -1;
  }
  int k = i + 1;
  while (k < input.length) {
    final ch = input.codeUnitAt(k);
    if (ch == 0x5C) {
      // \
      if (k + 1 >= input.length) return -1;
      k += 2;
      continue;
    }
    if (ch == 0x22) return k + 1;
    if (ch == 0x0A) return -1;
    k++;
  }
  return -1;
}

int _skipBytes(String input, int i) {
  int j = i + 2;
  while (j < input.length) {
    final ch = input.codeUnitAt(j);
    if (ch == 0x22) return j + 1;
    if (ch == 0x0A) return -1;
    j++;
  }
  return -1;
}

int _skipEOL(String input, int i) {
  int k = i;
  while (k < input.length && input.codeUnitAt(k) != 0x0A) {
    k++;
  }
  return k;
}
