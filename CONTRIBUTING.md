# Contributing to protowire-dart

Welcome — this is the Dart port of [protowire](https://protowire.org), a
language-neutral wire-format toolkit. It tracks the canonical specification
in [`trendvidia/protowire`](https://github.com/trendvidia/protowire) and is
one of nine sibling ports (Go, C++, Rust, Java, TypeScript, Python, C#,
Swift, Dart). The port is pure Dart and uses
[`protobuf`](https://pub.dev/packages/protobuf) as its only runtime
dependency.

> **Steward integration is rolling out.** The governance described in
> [GOVERNANCE.md](GOVERNANCE.md) is the steady-state model. While Steward
> is being finalised, pull requests are reviewed by human maintainers in
> the conventional way — open a PR, expect review, iterate.

## Where bugs go

| Symptom | File against |
|---|---|
| Dart port-only crash, wrong API ergonomics, performance regression in this port only | `trendvidia/protowire-dart` |
| The same input produces different output here vs another port | upstream [`trendvidia/protowire`](https://github.com/trendvidia/protowire) (cross-port wire-equivalence regression) |
| Spec / grammar / proto annotation question | upstream [`trendvidia/protowire`](https://github.com/trendvidia/protowire) |
| Decoder crash / hang / OOM on adversarial input | **email security@trendvidia.com**, do not file public issue (see [SECURITY.md](SECURITY.md)) |

## Toolchain

Dart SDK ≥ 3.0. Tested in CI on:

- `stable` × {Linux, macOS, Windows}
- `beta` × Linux (early-warning for breaking changes)

Plus `dart format --output=none --set-exit-if-changed .` and
`dart analyze --fatal-infos --fatal-warnings` as separate gating jobs.

## Local development

```sh
dart pub get

# Tests
dart test

# Static checks
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos --fatal-warnings

# Benchmarks
dart run benchmark/main.dart

# HARDENING corpus (assumes the spec repo is checked out as a sibling)
dart run bin/check_decode.dart \
  --format pxf --schema adversarial.v1.Tree \
  --proto ../protowire/testdata/adversarial/adversarial.proto \
  --input ../protowire/testdata/adversarial/pxf/deep-nesting-100.pxf
```

### Regenerating proto bindings

The `proto/` tree mirrors the upstream wire contract. Bindings are
generated through `buf` (see `buf.yaml` / `buf.gen.yaml`), not directly
through `protoc`. Run `buf generate` when proto annotations change.

## Sending changes

1. Open a draft PR early.
2. **For changes that touch parser/encoder behaviour**: comment with
   which fixtures from `test/testdata/` you exercised. Cross-port
   wire-equivalence means a wrong move here can break six other ports'
   contracts.
3. **For changes that touch the wire format itself** — annotation field
   numbers in `proto/`, the PXF grammar, the SBE schema-id semantics —
   open the upstream PR in
   [`trendvidia/protowire`](https://github.com/trendvidia/protowire)
   first. This port shouldn't lead spec changes; it implements them.
4. **Anything that adds a new public symbol** must be exported from
   `lib/protowire.dart` (the umbrella library), not just live in a
   sub-library.

## Code style

- `dart format` is enforced in CI; your editor should be configured to
  format on save.
- `dart analyze` runs in CI with `--fatal-infos --fatal-warnings`.
  Suppress with `// ignore: rule_name` and a one-line comment.
- Match the existing zero-allocation patterns in `lib/src/sbe/view.dart` —
  the `View` API is the "zero allocation" reference point.
- New public APIs must have at least one dartdoc example exercising
  them.

## What we don't accept

- Changes that break wire-equivalence with another sibling port.
- New top-level dependencies without a one-line justification in the
  PR description. We currently depend only on `protobuf`, `fixnum`,
  `xml`, and `benchmark_harness`.
- Static analysis suppressions on a whole file or whole library. Keep
  them line-scoped.

## Releases

This port releases in lockstep with the rest of the `protowire-*` stack.
The version line is `0.70.x` for the first coordinated public release;
ports that share a `0.70.x` minor implement the same wire contract.

Cutting a release:

1. Bump `version` in `pubspec.yaml`.
2. Add a `## [X.Y.Z]` section to `CHANGELOG.md`.
3. Tag `vX.Y.Z` on `main`.
4. The `.github/workflows/publish.yml` workflow runs `dart pub publish`
   through pub.dev's OIDC trusted publishing flow.
