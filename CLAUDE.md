# CLAUDE.md

Notes for future Claude sessions working on this Dart port.

## What this is

Standalone Dart port of `github.com/trendvidia/protowire`. The Go module
at `../protowire-go/` is the canonical reference — when behavior is
ambiguous, that's the source of truth. Annotation field numbers, the
envelope shape, and the `_null` FieldMask convention are cross-port wire
contracts and must not drift.

## Layout

Standard Dart package. Library code under `lib/`, tests under `test/`,
generated proto code under `lib/src/generated/proto/`:

- `lib/protowire.dart` — umbrella library, exports the public API.
- `lib/src/encoding/pxf/` — PXF text format (lexer, parser, AST,
  decoder, encoder, options, result, errors, wellknown, duration).
- `lib/src/encoding/sbe/` — SBE binary format (sbe, codec/template,
  marshal, unmarshal, view, plus xmlschema/xmltoproto/prototoxml for
  the SBE XML schema interop).
- `lib/src/encoding/pb/native.dart` — `dart:mirrors`-driven dynamic
  Protobuf codec for arbitrary Dart classes annotated with `@ProtoTag`.
  **JIT/development only.** Not re-exported from the umbrella; users
  must import the explicit path. Will not work in Flutter or any
  AOT-compiled binary (`dart compile exe`).
- `lib/src/envelope/envelope.dart` — hand-written user-facing
  Envelope/AppError/FieldError with builder ergonomics. The
  proto-generated counterpart at
  `lib/src/generated/proto/envelope/v1/envelope.pb.dart` stays available
  via direct import for byte-level cross-port work.

## Build & test

```bash
dart pub get          # install dependencies
dart analyze          # warning-clean (warnings/errors are CI-failing)
dart test             # 17+ tests
buf generate          # regen lib/src/generated/proto/ from proto/*.proto
```

## Cross-port wire contracts (don't re-derive)

- `pb`: signed-int fields default to proto3 `int32`/`int64` (plain
  varint). Canonical envelope: 129 bytes (258 hex chars) starting
  `08 92 03 1a 04 de ad be ef 22 76 …`.
- `pxf` annotations: `(pxf.required)` = 50000, `(pxf.default)` = 50001
  (definitions in `proto/pxf/annotations.proto`).
- `_null` field of type `google.protobuf.FieldMask` carries
  null-survival across protobuf binary.
- `sbe` annotations: `sbe.schema_id` = 50100, `version` = 50101,
  `template_id` = 50200, `length` = 50300, `encoding` = 50301.
- `sbe` wire: 8-byte LE message header + 4-byte LE group header.

## Design calls (settled)

1. **Umbrella export hides clashing names.** `package:protowire/protowire.dart`
   re-exports both PXF and SBE annotation descriptor files; both .pb.dart
   files declare a class called `Annotations`, so the umbrella hides them
   from re-export. `bignum.pb.dart` declares classes named `BigInt`,
   `Decimal`, and `BigFloat` that would shadow Dart's core `BigInt`; the
   umbrella hides them too. Users who need those types import the explicit
   path: `import 'package:protowire/src/generated/proto/pxf/bignum.pb.dart' as pxf;`
   then use `pxf.BigInt`, `pxf.Decimal`, `pxf.BigFloat`.
2. **Two `Envelope` types are NOT both exported.** The hand-written
   `Envelope` (with `ok`/`err`/`transportErr`/`withField`/`withMeta`
   builders) is the user-facing canonical type. The proto-generated
   `Envelope_V1_Envelope` (and the `Envelope` re-export it carried) was
   removed from the umbrella to avoid the name clash; stay available via
   direct import for the dump_envelope cross-port harness.
3. **`PxfError implements Exception`, not `extends Error`.** Format /
   parse failures are runtime conditions a caller is expected to handle.
   Dart's `Error` is for programmer-fault conditions and shouldn't be
   used for input-driven failures.

## What this repo does NOT contain (yet)

These gaps are tracked in the protowire-dart code-review PR series:

- **Public `unmarshalFull`** returning a presence `Result`. The
  `DirectDecoder` plumbs a `Result?` field internally but no public API
  exposes it (PR4).
- **`(pxf.required)` / `(pxf.default)` enforcement.** The annotation
  extension fields are loaded into the proto descriptors but never
  read by the encoder/decoder (PR4).
- **`_null` FieldMask round-trip**. The decoder writes paths into the
  FieldMask field, but the encoder doesn't read them back (PR4).
- **Map decoder is a stub** (`decode.dart` `_decodeMap`): it parses the
  surface syntax but doesn't insert into the target map. Map fields
  silently drop on decode (PR2).
- **Enum-by-name decoding** throws "not yet implemented in Dart port"
  (PR2).
- **Encoder `Any` marshaling missing** while decoding works — round-trip
  with Any breaks (PR2).
- **Cross-port harness binaries (bin/) absent.** No `dump_envelope`,
  `bench_pxf`, `bench_sbe`. The Dart port isn't wired into
  `protowire/scripts/cross_*_bench.sh` or `cross_envelope_check.sh` (PR3).

## Working conventions

- After any change touching `lib/src/encoding/pb/` or
  `lib/src/envelope/`, run the cross-port envelope check to confirm
  byte-equivalence with the Go reference: from the spec repo,
  `bash scripts/cross_envelope_check.sh` (with appropriate skip flags
  for missing toolchains).
- Don't add `Annotations` / `Envelope` / `BigInt` etc. back to the
  umbrella export — the hide clauses in `lib/protowire.dart` are
  load-bearing.
- The proto-generated `*.pb.dart` files under `lib/src/generated/` are
  buf output. Don't edit by hand. Regenerate via `buf generate` against
  the `proto/` tree.
