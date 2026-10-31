# Changelog

All notable changes to `protowire-dart` are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The version number is kept aligned with the rest of the `protowire-*`
stack — releases bump in lockstep across language ports when the wire
format changes.

## Unreleased

### Added

- **`(pxf.required)` and `(pxf.default)`** (#14), and `unmarshalFull`.
  `PxfAnnotations.fromDescriptorSet` / `fromBytes` index the two
  annotations (extension numbers 1314 and 1315) per message from a
  `FileDescriptorSet` — the same input `Codec.registerFromDescriptorSet`
  reads the SBE annotations from — and `UnmarshalOptions.annotations`
  hands them to the decoder. `unmarshalFull(input, msg, options:)` returns
  the `Result` presence every other full-tier port reports, and with
  annotations rejects an absent required field (`required field "path" is
  absent`) and applies defaults by field type, following the Go
  reference's `postDecode`: `null` counts as present, present non-null
  singular message fields are descended into, list elements and map
  values are not, and a defaulted field stays absent in the `Result`.
- `dump_envelope --pb FDS MESSAGE DOC`, the gate leg protowire's
  `cross_envelope_check.sh` had listed as a declared omission for this
  port (#13); `settings.v1.Settings` is generated into `bin/` from
  protowire's `testdata/annotations/settings.proto`.

### Fixed

- **`MaxNestingDepth` counts from a root at depth 0, and counts lists** (#24,
  protowire#301). The decoder counted the root as depth 1, so a document
  exactly 100 descents deep was rejected, and it did not count `[` at all;
  the text parser did not count `[` either, so `[[[[…` was unbounded there.
  Every `{` block and `[` list is one descent now, in both, and 100 are
  accepted and 101 rejected. `check_decode`'s `adversarial.v1.Tree` was
  stale: it lacked `children`, so the `deep-nesting-lists-*` rows rejected
  on an unknown field. It is regenerated with the field.
- **Map fields decode** (#17). `unmarshal` parsed a map block's
  `key: value` entries and discarded every value, so any `map<K, V>` field
  came back empty — since the initial release. Keys now convert by the
  entry's key type (string as written, integers in their width, `true` /
  `false` for bool) and values by its value type (scalars, enums by name
  or number, messages as `{ ... }` blocks with the same well-known-type
  shorthands a singular message value takes), last key wins, `null` is
  rejected — the Go reference's `decodeMapInline` / `decodeMapKey`.
- **`MaxNumericLiteralDigits` counts significant mantissa digits only**
  (#25, protowire#410). The cap counted leading zeros and an exponent, and
  measured the integer and fraction parts of a float apart. It now counts
  the mantissa's significant digits either side of the point, in the lexer
  and on the `(pxf.default)` path, so `0.000…1` at scale 4096 decodes, and
  a `pxf.Decimal` scale past 4096 is rejected on its own bound. The cap was
  already inclusive on a `pxf.BigInt` field: the rows failed because
  `check_decode` did not know `adversarial.v1.BigNumHolder` and rejected
  both of them as an unknown schema. It links that type now.

### Changed

- **The vendored shared schemas are re-synced with [trendvidia/protos](https://github.com/trendvidia/protos) v0.1.2** ([trendvidia/protowire#447](https://github.com/trendvidia/protowire/issues/447)). They gain protos' file options, and `envelope.proto`'s `go_package` now names a published package. Declarations and field numbers are unchanged, and so is this port's public API.

- **A map's `{` and every PB map entry count toward `MaxNestingDepth`**
  (protowire#449), as HARDENING.md says and protowire-go now does. The PXF
  decoder skipped the map's own `{`, so a document nesting maps past the bound
  decoded while `parse` refused it. package:protobuf does not count a map
  entry at all, so the new `mergeFromBufferChecked` walks the input first;
  `check_decode` calls it, and untrusted PB should go through it rather than
  `mergeFromBuffer`. `check_decode`'s `adversarial.v1.Tree` gains `children`,
  `branches` and `tags`.
- **PXF entries are proto field names on the way out, too** (#15). `marshal`
  wrote Dart field names (`orderId`, `fillPrice`), which no other port can
  read (draft -01 §3.2 makes entry names the proto field names,
  `order_id`); it writes `FieldInfo.protoName` now at the root, in nested
  blocks, list elements and map entries. The same change reaches the
  decoder's `Result` presence paths, the `_null` `FieldMask` paths it
  writes (a `FieldMask` carries proto names by definition), and the field
  names in its diagnostics. Documents in the Dart-name dialect still
  decode (#16); the benchmark and test fixtures written in it are moved
  to proto names.
- **`(pxf.required)` with `(pxf.default)` on one field fails at bind** (#41),
  as draft -01 "Required and Default" requires (protowire#453).
  `PxfAnnotations.fromDescriptorSet` and `fromBytes` throw a `PxfError` naming
  every such field, over every message of the descriptor set, nested ones
  included. Such a schema used to bind, and which option won depended on the
  engine. `(pxf.required) = false` beside a default stays accepted.

## 1.0.0

Lockstep release with the rest of the `protowire-*` stack at the v1.0.0
spec freeze. Catches the Dart port up from v0.70 to the full v0.72–v1.0
directive grammar (drafts §3.4.2–§3.4.6).

### Added

- **`@<name>` generic directives** (draft §3.4.2): top-of-document
  `@<name> *(<prefix-id>) [{ ... }]` blocks, e.g. chameleon's
  `@header chameleon.v1.LayerHeader { id = "x" }`. Captured on
  `Document.directives` and on `Result.directives` from `unmarshalFull`.
- **`@entry` named directive** (draft §3.4.3): zero/one/two-prefix
  shape, handled by the same generic mechanism.
- **`@dataset <type> ( cols ) row*`** (draft §3.4.4): the protowire-native
  CSV — many instances of one message type in a single document.
  Mutually exclusive with `@type` and top-level field entries.
  Exposed on `Document.datasets` / `Result.datasets`.
- **`@proto`** (draft §3.4.5): embedded protobuf schema with four
  lexically-distinguished body shapes — anonymous `{ ... }`, named
  `<dotted-name> { ... }`, source `""" ... """`, descriptor `b"..."`.
- **`isFutureReservedDirective`** (draft §3.4.6): v1 decoders reject
  `@table`, `@datasource`, `@view`, `@procedure`, `@function`,
  `@permissions` so applications cannot squat the names before the spec
  allocates semantics.

### Changed (breaking)

- **`@table` removed**; use `@dataset` (no alias period — same hard
  cutover the rest of the stack made for v1.0).
- **`Document` extended** with `directives`, `datasets`, `protos`,
  `bodyOffset` fields. Existing consumers of `typeUrl` / `entries`
  remain source-compatible.

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

