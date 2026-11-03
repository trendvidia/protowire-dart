# Changelog

All notable changes to `protowire-dart` are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The version number is kept aligned with the rest of the `protowire-*`
stack — releases bump in lockstep across language ports when the wire
format changes.

## Unreleased

### Changed

- **`marshal` writes an Any as `@type` and a body only when reading the body
  gives back the Any's exact `value` bytes** (#74, draft -01 § Any Blocks,
  protowire#501). Otherwise it writes `type_url` and `value`. The writer
  renders the body, decodes it with its own registry and annotations, and
  compares the bytes. That catches a Timestamp no literal holds, an unset
  `@default` or `@required` field, unknown fields, field order and a chain of
  Anys past MaxNestingDepth. A value with a singular scalar written at its
  zero is also kept raw: a reader that knows the field has no presence drops
  it, and a generated class does not say which. `@default` and `@required` are
  seen only with `MarshalOptions.annotations`. With `emitDefaults`, a body
  that would spell out zeros is written raw.

- **The PXF and PB producers refuse a message nested past MaxNestingDepth**
  (#73, HARDENING.md § Recursion, protowire#502). `marshal` throws a
  `PxfError` and `marshalNative` an `ArgumentError`, "nesting depth exceeds
  MaxNestingDepth=100", rather than write what a reader at the same limit
  refuses. Depth is counted as a decoder counts it: every `{` and `[` in PXF,
  and in PB each submessage plus each map entry. A message that holds itself
  meets the limit instead of overflowing the stack. The limit is per call:
  `MarshalOptions(maxNestingDepth: ...)` and
  `marshalNative(obj, maxNestingDepth: ...)`.
- **`mergeFromBufferChecked` rejects a `string` field that is not valid
  UTF-8** (#70, HARDENING.md § UTF-8, protowire#496). That includes a lone
  surrogate and an overlong encoding, in any repeated element, map key or
  value, or nested message. It used to accept them, as package:protobuf does,
  with U+FFFD in place of the bad bytes. A `bytes` field still takes any
  bytes. A generated Dart class does not say whether its file is proto2 or
  proto3, so a proto2 `string` field is checked too, where protowire-go
  checks proto3 and editions only.
- **`marshalNative` no longer writes a singular scalar set to its zero**
  (`0`, `""`, `false`, `0.0`, empty bytes), as protowire-go's struct API
  does not (the spec's struct-binding table, protowire#509). A map entry
  keeps its zeros.
- **A double literal past the double range is refused** (`1e400`: "invalid
  double"), as draft -01 § Numeric Literals says, instead of reading as
  infinity. A float field rounds to float32 as it reads, so `3.4028235e38` is
  float32's largest value and `1e-46` is zero.

### Fixed

- **SBE writes a `string` field as UTF-8, and cuts an overlong one on a
  character boundary** (#71, protowire#495). The emitter used to write the
  string's UTF-16 code units, one byte each, so any character past U+007F
  came out wrong. An overlong string is now cut at the last whole UTF-8
  character at or before `(sbe.length)` and NUL-padded. A `bytes` field is
  still cut at the limit.
- **A `@default` BigFloat's `prec` keeps its low 32 bits**, as a protobuf
  reader of a `uint32` does (#72). A prec of 2^63 or more used to read as a
  negative number and run the VM out of memory. Prec 0 is now reported as
  "@default's big_float_value declares no precision", as protowire-go does,
  instead of binding the literal `0`.
- **`inf`, `+inf`, `-inf` and `nan` read into float and double fields**
  (draft -01 § Numeric Literals). `marshal` wrote them, but `unmarshal`
  refused them. `nan` is the canonical quiet NaN.
- **A string literal reads into a `pxf.Secret` field**, list element or map
  value: `pw = "x"` is `pw { value = "x" }`.

### Added

- `check_decode --format pxf-pb`, the harness for the spec's write gate
  (`scripts/cross_write_check.sh`, protowire#509), which found the three
  entries above. One gate case, an unknown number on an open enum, waits on
  #82.

## 1.2.0

### Changed

Each of these rejects a document that used to decode.

- **A singular field bound twice in one body is rejected** (protowire#347,
  option a). That covers two values, the same value twice, `null` then a
  value, and two blocks for one message field, which no longer merge. Each
  body is its own scope.
- **A map key bound twice in one body is rejected** (protowire#396, option b),
  inside one literal or across two bindings of the field. Keys compare as
  values of the key type, so `1:` and `"1":` are one key of an integer-keyed
  map. Distinct keys across two bindings still merge.
- **A repeated field written as blocks is rejected** (protowire#337). Use a
  list. Only a keyed repeated field has a block form.
- **`null` binds only to a field with explicit presence** (protowire#339).
  On a repeated or map field and on a proto2 `required` field it is always
  rejected. On a proto3 scalar without `optional`, or an editions scalar with
  implicit presence, it is rejected when `UnmarshalOptions.annotations` is
  set. Generated classes write `int32` and `optional int32` identically, so
  with no descriptor set a null on a plain scalar is still accepted.
- **A raw line feed in a simple string is rejected** (protowire#350), by the
  decoder, `parse` and `@dataset` cells. Write `\n` or use a triple-quoted
  string.
- **A `,` between map entries is rejected** (protowire#312). A comma separates
  list elements only.
- **`(pxf.required)` and `(pxf.default)` apply in every message body**
  (protowire#352): list elements, map values and Any bodies, not only singular
  fields. A missing required field in an element is now an error, reported at
  its own path, such as `required field "kr[0].name" is absent`.
- **More schemas are refused at bind** (draft -01 "Oneof Members", "Default
  Placement"): a required oneof member, two defaults in one oneof, and a
  default on a repeated, map, group or plain message field.
- **A named keyed entry cannot undo its name** (protowire#480): `null` on the
  key field, or a binding of another member of the key field's oneof, is a key
  conflict.
- **`@type` after a block's first entry, or with an unquoted URL, is
  rejected.** An integer or bool key before `=` or `{` is rejected too, by the
  parser and the decoder.

### Added

- **`marshal` writes a `google.protobuf.Any` field with a type entry**, as
  protowire-go does, when `MarshalOptions.typeRegistry` holds its type:
  `@type = "..."` and a body of that type. It writes the block of the Any's
  own fields when the type is missing, as before, and also when a body could
  not reproduce the value, or past the depth a reader takes. A list element or
  map value of type Any stays its own fields, matching the reference.

- **`pxf.BigFloat` reads and writes as a literal** (protowire#393, #406): `marshal`
  writes N significant digits with a precision suffix, `1.79769313486231590773e+308p64`,
  and a literal is read at its suffix's precision, or 256 bits, round half even.
  A precision suffix on any other field is rejected, naming the field, and an
  exponent past `MaxBigFloatExponent` is refused on both paths. It also works
  as a `(pxf.default)` or `@default`, a list element and a map value.
- **`MaxMessageSize`, `MaxBytesLiteralLength` and `MaxRepeatedCount` are
  enforced** (protowire#299), each 64 MiB by default and lowered per call with
  `DecodeLimits`: on PXF through `UnmarshalOptions.limits` and `parse`, on PB
  through `mergeFromBufferChecked` and `unmarshalNative`, and on SBE through
  `Codec.unmarshal` and `Codec.view`. Input past a limit used to decode.
  `check_decode` gains `--limit NAME=VALUE` and SBE decoding.
- **`@required` and `@default` are read** from the 1327 annotation carrier, and
  every bind check applies to both spellings. Two spellings of one default that
  disagree are refused. A `@default` on a `pxf.BigFloat` is refused at bind
  until the BigFloat encoder lands (#33).
- **`@dataset` rows bind:** `bindDatasetRow` binds a row to a message, so a
  cell means what `column = <value>` means in a body. Empty cells stay absent,
  and with annotations they take the default or are rejected as required.
- **`@dataset` cells may hold a list or a block** (protowire#341), and **a
  column may be a dotted path into a sub-message** (protowire#342). The header
  rejects a path named twice, a field beside a path inside it, and an empty
  segment. So `(a, a)` is now an error.
- **The Any type entry works everywhere a body is written** (protowire#354):
  list elements and map values as well as singular fields, and through `parse`
  and the formatter, which keep it as a `TypeEntry`.
- **`parse` accepts bool map keys,** and a `map<bool, V>` takes a bare `1` or
  `0` as well as `true`, `false`, `"true"` and `"false"`.
- **The native `pb` codec handles `Map<K, V>` fields** as proto3 maps, each
  entry carrying its key and value, zero-valued or not, and **a nested
  `@ProtoTag` class as a message field.** A field type it cannot encode now
  fails with an error naming the field. Both used to trip an assertion inside
  `package:protobuf`.
- **`dump_envelope --vector zero-map-entry`** prints the map-entry vector of
  protowire#295. An unknown vector exits 3 with `not-implemented: <name>`.

- **`marshal` writes a Duration as `time.Duration.String()` does:** `1h` is
  now `1h0m0s`, as every other port writes it.

### Fixed

- **Output now matches protowire-go on every document of the spec corpora**
  (protowire-dart#67), found by comparing the two live:
  - `marshal` threw on a `map<bool, ...>`, and wrote a map key containing `"`
    unescaped, which does not parse back.
  - `marshal` orders map keys by their written form, as the reference does:
    `"10"` before `"9"`, and a quoted key before a bare one.
  - A map value of a well-known type is written as a literal, not a block.
  - A Timestamp keeps its nanoseconds on decode, where it kept milliseconds,
    and is written with only the fraction it needs: `05Z`, not `05.000Z`. One
    before the epoch has the right seconds and non-negative nanos.
  - A zero inside a well-known type is unset, so `writeToBuffer` no longer adds
    `nanos = 0`, and zero `pxf.BigInt` and `pxf.Decimal` have an empty
    magnitude. `bigIntToBytes(BigInt.zero)` is now empty.
  - With a descriptor set, a zero on a scalar with implicit presence is unset.
    Without one it stays set; see the README.

- **`mergeFromBufferChecked` no longer hangs on, or leaks a `RangeError` from,
  a negative length** (protowire-dart#64). Seven bytes naming an unknown
  length-delimited field with a length that rewinds onto its own tag looped for
  ever; a length that overflows 32 bits threw `RangeError`. Both now throw
  `InvalidProtocolBufferException`. The `1327` carrier reader takes the same
  lengths as garbled input and keeps what came before.

- **The main import compiles with `dart compile exe`** (and for the web). It
  pulled in `dart:mirrors` through the native `pb` codec. The codec stays where
  it was on the Dart VM, and elsewhere `marshalNative` and `unmarshalNative`
  throw `UnsupportedError`.
- **Fractional and `µs` durations read** (`1.5ms`, `312.5µs`, `1h30m0.5s`),
  the forms the other ports write for any measured latency.
- **A Duration keeps its nanoseconds and its sign,** both ways. Parsing went
  through Dart's microsecond `Duration`, so `100ns` was lost, and `-1.5s` got
  positive nanos. `marshal` dropped everything below a millisecond.
- **A packed repeated scalar decodes from a list.** Any non-empty list failed
  with `unsupported type 2054`.
- **A block on a scalar or map field is a `PxfError`,** not a null-check crash.
- **List elements and map values record presence on their own paths,**
  `items[0].a` and `inners["k"].a`. Their fields were recorded at the parent's
  path, so an element could mark a root field as present and hide a required
  or default field. A `null` inside one stays out of the `_null` mask.

- **`Result` reports a keyed entry's name as setting the key field**
  (protowire-go#214). After `kd { alpha {} }`, `isSet('kd[0].name')` is true
  and `isAbsent('kd[0].name')` is false; both said the opposite, although the
  element's key was `alpha`. Decoded messages do not change.

## 1.1.0

### Fixed

- **`marshal` refuses a `pxf.Decimal` past the bounds** (protowire#448). A scale
  near 2^31 built a 2 GB string from five input bytes. A scale past
  `MaxNumericLiteralDigits` on either sign now fails before any work, as does a
  `BigInt` or `Decimal` literal past the digit cap.
- **A negative `Decimal` scale keeps its value.** It was dropped, so `5` at
  scale `-2` was written as `5` rather than `500`.

### Added

- **`pxf.BigFloat` reads and writes as a literal** (protowire#393, #406): `marshal`
  writes N significant digits with a precision suffix, `1.79769313486231590773e+308p64`,
  and a literal is read at its suffix's precision, or 256 bits, round half even.
  A precision suffix on any other field is rejected, naming the field, and an
  exponent past `MaxBigFloatExponent` is refused on both paths. It also works
  as a `(pxf.default)` or `@default`, a list element and a map value.
- **`MaxMessageSize`, `MaxBytesLiteralLength` and `MaxRepeatedCount` are
  enforced** (protowire#299), each 64 MiB by default and lowered per call with
  `DecodeLimits`: on PXF through `UnmarshalOptions.limits` and `parse`, on PB
  through `mergeFromBufferChecked` and `unmarshalNative`, and on SBE through
  `Codec.unmarshal` and `Codec.view`. Input past a limit used to decode.
  `check_decode` gains `--limit NAME=VALUE` and SBE decoding.
- **Keyed repeated fields and quoted entry names** (draft `-01` "Keyed
  Repeated Fields"; #10, protowire#116). A `repeated <Message>` field with
  `(pxf.key)` can be written as a block of named blocks: the entry name is
  the key, entry order is list order. Generated Dart messages carry no field
  options, so the option comes from `PxfAnnotations`, which now indexes
  extension number 1316 and rejects a misplaced `(pxf.key)` when the
  descriptor set is bound; without annotations nothing is keyed.
  `UnmarshalOptions.annotations` decodes both surface forms and rejects
  duplicate, empty and conflicting keys. The new
  `MarshalOptions.annotations` emits the keyed form when every key is
  present, non-empty and distinct, and the list form otherwise.
  `formatPxf` is new: it pretty-prints a document and, given annotations,
  canonicalizes keyed fields (anonymous form to keyed where eligible,
  identifier-safe names unquoted, redundant key assignments dropped). It
  refuses documents with directives rather than dropping them. The AST
  records whether an entry name was quoted. The spec repo's `testdata/keyed/`
  corpus is vendored under `test/testdata/keyed/`. This port has no tolerant
  parse mode, so the keyed errors are always hard errors.
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

- A quoted entry name outside a keyed repeated field's block is now a
  decode error, as the draft requires (`"id" = "x"` used to bind `id`).

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

- **`pxf.BigFloat` reads and writes as a literal** (protowire#393, #406): `marshal`
  writes N significant digits with a precision suffix, `1.79769313486231590773e+308p64`,
  and a literal is read at its suffix's precision, or 256 bits, round half even.
  A precision suffix on any other field is rejected, naming the field, and an
  exponent past `MaxBigFloatExponent` is refused on both paths. It also works
  as a `(pxf.default)` or `@default`, a list element and a map value.
- **`MaxMessageSize`, `MaxBytesLiteralLength` and `MaxRepeatedCount` are
  enforced** (protowire#299), each 64 MiB by default and lowered per call with
  `DecodeLimits`: on PXF through `UnmarshalOptions.limits` and `parse`, on PB
  through `mergeFromBufferChecked` and `unmarshalNative`, and on SBE through
  `Codec.unmarshal` and `Codec.view`. Input past a limit used to decode.
  `check_decode` gains `--limit NAME=VALUE` and SBE decoding.
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

- **`pxf.BigFloat` reads and writes as a literal** (protowire#393, #406): `marshal`
  writes N significant digits with a precision suffix, `1.79769313486231590773e+308p64`,
  and a literal is read at its suffix's precision, or 256 bits, round half even.
  A precision suffix on any other field is rejected, naming the field, and an
  exponent past `MaxBigFloatExponent` is refused on both paths. It also works
  as a `(pxf.default)` or `@default`, a list element and a map value.
- **`MaxMessageSize`, `MaxBytesLiteralLength` and `MaxRepeatedCount` are
  enforced** (protowire#299), each 64 MiB by default and lowered per call with
  `DecodeLimits`: on PXF through `UnmarshalOptions.limits` and `parse`, on PB
  through `mergeFromBufferChecked` and `unmarshalNative`, and on SBE through
  `Codec.unmarshal` and `Codec.view`. Input past a limit used to decode.
  `check_decode` gains `--limit NAME=VALUE` and SBE decoding.
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

