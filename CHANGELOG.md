# Changelog

All notable changes to `protowire` (Dart port) are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The version number is kept aligned with the rest of the `protowire-*`
stack — releases bump in lockstep across language ports when the wire
format changes.

> **Note on the version number.** Earlier internal builds used
> `1.0.0` / `1.1.0`; the renumbering to `0.70.0` is a one-time
> realignment with the rest of the protowire-* stack ahead of the first
> coordinated public release. No published artifacts are affected (the
> earlier numbers were never tagged on the public registry).

## [Unreleased]

## [0.70.0]

Initial public release. The version number aligns this port with the rest
of the `protowire-*` stack, which targets the 0.70.x series for the first
coordinated public release. Consolidates everything previously tracked
under the internal `1.0.0` and `1.1.0` numbers.

### Added

- **PXF (Proto eXpressive Format)**: Lexer and Parser for the
  human-friendly text representation; decoder and encoder for
  `GeneratedMessage`.
- **SBE (Simple Binary Encoding)**: template builder from `BuilderInfo`,
  marshaler / unmarshaler, and a zero-allocation `View` API for fast
  binary reads.
- **Envelope**: `Envelope`, `AppError`, and `FieldError` for
  standardised API responses.
- Comprehensive unit tests, Go-interop verification, and performance
  benchmarks.

### Changed (breaking)

- **PXF parser stricter on key forms**, mirroring the upstream grammar
  tightening in
  [`trendvidia/protowire@8262bbb`](https://github.com/trendvidia/protowire/commit/8262bbb)
  (`docs/grammar.ebnf`, `docs/draft-trendvidia-protowire-00.txt`):
  - `=` (field assignment) and `{ … }` (submessage) now require an
    identifier key. Inputs like `123 = 234` or `child { 123 = 123 }`
    are now parse errors.
  - `:` (map entry) is rejected at document top level — the document
    represents a proto message, never a `map<K,V>`. Use `=` for
    top-level field assignments. Map literals (`field = { 1: "x" }`)
    still work because `:` remains valid inside `{ … }` blocks.
