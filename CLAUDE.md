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

## PXF wire-name policy

PXF emits and parses **proto-canonical (snake_case) field names**, not
Dart codegen's camelCase. The decoder looks up via `fi.protoName` first
and falls back to `fi.name` so hand-rolled `BuilderInfo` declarations
in tests still resolve. The encoder always emits `fi.protoName`. The
`_null` FieldMask paths are also proto-name dotted paths (e.g.
`tls.cert_file`, never `tls.certFile`).

## (pxf.required) / (pxf.default) enforcement

`lib/src/encoding/pxf/annotations.dart` provides opt-in enforcement.
The Dart `protobuf` runtime does NOT expose `FieldOptions` extensions
on `BuilderInfo` (unlike Go's protoreflect), so the registry parses
the per-message `xxxDescriptor` Uint8List from `*.pbjson.dart` to
extract field option extensions 50000 / 50001. Usage:

```dart
final ann = PxfAnnotations()
  ..register(Config.getDefault().info_, configDescriptor)
  ..register(Endpoint.getDefault().info_, endpointDescriptor);
unmarshal(input, msg, options: UnmarshalOptions(annotations: ann));
```

Sub-messages must be registered explicitly; unregistered types are
skipped silently — same stance Go takes for descriptors without
`(pxf.*)` extensions. Defaults supported: scalars, bytes (base64),
enums (by name or number), and the well-known message types
Timestamp, Duration, and StringValue/wrappers.

## Cross-port bench harnesses

`bin/bench_pxf.dart` and `bin/bench_sbe.dart` mirror Go's
`scripts/bench_pxf` / `scripts/bench_sbe` byte-for-byte (canonical
`bench.v1.Config` PXF input, 94-byte canonical `Order` SBE payload,
identical JSON output shape with `port=dart`). The proto schemas live
at `proto/bench/v1/bench.proto` (Config) and
`proto/bench/v1/order.proto` (Order). The PXF input fixture
`testdata/bench-test.pxf` is vendored from the spec repo.

## Working conventions

- After any change touching the proto-generated envelope or
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
