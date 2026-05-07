# Changelog

All notable changes to `protowire-dart` are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The version number is kept aligned with the rest of the `protowire-*`
stack — releases bump in lockstep across language ports when the wire
format changes.

## 0.70.0

Initial public release. The version number aligns this port with the rest
of the `protowire-*` stack, which targets the 0.70.x series for the first
coordinated public release.

### Added

- **pub.dev distribution** as the `protowire` package.
- **HARDENING.md decoder safety** (M8): bounded recursion depth and
  PB length-prefix overflow rejection in `lib/src/encoding/pxf/` and
  `lib/src/encoding/pb/`. Verified by the `bin/check_decode.dart`
  adversarial corpus reference.
- **Comprehensive CI matrix**: `dart test` on stable + beta SDKs across
  Linux/macOS/Windows, plus `dart format --check` and `dart analyze
  --fatal-warnings` as separate gating jobs.
- **Governance scaffolding**: `LICENSE` (MIT), `CONTRIBUTING.md`,
  `SECURITY.md` (security@trendvidia.com), `GOVERNANCE.md`,
  `CODE_OF_CONDUCT.md`, `.github/CODEOWNERS`, issue + PR templates,
  Dependabot for pub + GitHub Actions.

### Changed (breaking)

- **PXF parser stricter on key forms**, mirroring the upstream grammar
  tightening in
  [`trendvidia/protowire@8262bbb`](https://github.com/trendvidia/protowire/commit/8262bbb)
  (`docs/grammar.ebnf`, `docs/draft-trendvidia-protowire-00.txt`):
  - `=` (field assignment) and `{ … }` (submessage) now require an
    identifier key. Inputs like `123 = 234` or `child { 123 = 123 }`
    now throw `PxfError` with
    `"field assignment with '=' requires an identifier key, got integer
    (\"123\"); use ':' for map entries"`.
  - `:` (map entry) is rejected at document top level — the document
    represents a proto message, never a `Map<K, V>`. Use `=` for
    top-level field assignments. Map literals (`field = { 1: "x" }`)
    still work because `:` remains valid inside `{ … }` blocks.
- **`lib/protowire.dart` umbrella library**: stopped re-exporting the
  protoc-generated bindings under `lib/src/generated/proto/`. Those
  re-exports caused name collisions — `Annotations` was defined twice
  (pxf vs sbe), and `BigInt` from `bignum.pb.dart` shadowed
  `dart:core.BigInt`, breaking any caller of `BigInt.parse`. Callers
  that need a generated binding directly can import the specific
  file: `import 'package:protowire/src/generated/...';`.

