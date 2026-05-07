# Governance

`protowire-dart` is governed under the same constitution as the rest of
the `protowire-*` stack. The machine-readable source of truth lives in
the upstream spec repo at
[`governance.pxf`](https://github.com/trendvidia/protowire/blob/main/governance.pxf);
the human-readable preamble is at
[`GOVERNANCE.md`](https://github.com/trendvidia/protowire/blob/main/GOVERNANCE.md).

This file is a short pointer-doc. If anything below disagrees with the
upstream constitution, the upstream wins.

## Domain ownership

This repo's only domain vector is
[`protowire-dart`](https://github.com/trendvidia/protowire/blob/main/governance.pxf)
under the upstream `port-libraries` umbrella. Approval requirements:

| Path | Reviewer authority |
|---|---|
| `lib/src/pb/`, `lib/src/pxf/`, `lib/src/sbe/`, `lib/src/envelope/` | port maintainers (`@trendvidia/maintainers`) |
| `proto/` | upstream spec maintainers — these mirror `trendvidia/protowire/proto/` and may not diverge |
| `bin/`, `test/`, `benchmark/` | port maintainers |
| `pubspec.yaml`, `analysis_options.yaml`, `buf.yaml`, `buf.gen.yaml` | port maintainers |
| `.github/workflows/publish.yml` | maintainers only — controls pub.dev release surface |
| `.github/` (other) | port maintainers |

## What's enforced today vs (roadmap)

The Steward agent that enforces the constitution programmatically is
**rolling out**. Until it is live:

- Pull requests are reviewed by human maintainers.
- The `0.70.x` release line implements the wire contract documented in
  [`docs/grammar.ebnf`](https://github.com/trendvidia/protowire/blob/main/docs/grammar.ebnf)
  + [`docs/HARDENING.md`](https://github.com/trendvidia/protowire/blob/main/docs/HARDENING.md);
  the `bin/check_decode.dart` adversarial corpus run is the local
  enforcement of the hardening invariants.
- Reputation-weighted voting, automatic escrow for risky changes, and
  the `manifesto.blocked_module_globs` restriction are all `(roadmap)`
  per the upstream `governance.pxf`.

## Stable surfaces

Everything in these public libraries is part of the SemVer contract:

- `package:protowire/protowire.dart` (umbrella, re-exports the four
  sub-libraries below)
- `package:protowire/pb.dart`
- `package:protowire/pxf.dart`
- `package:protowire/sbe.dart`
- `package:protowire/envelope.dart`

Anything in a library named `src/` is internal and not stable.

The wire contract — what bytes a given proto message produces — is
governed by the **upstream** spec, not this port. Bumping the wire
contract requires a coordinated PR landing in every sibling port; see
[`STABILITY.md`](https://github.com/trendvidia/protowire/blob/main/STABILITY.md)
upstream.
