<!--
For changes that touch wire-format behaviour: please open the upstream
PR in trendvidia/protowire FIRST. This port implements the spec; it
shouldn't lead spec changes. See CONTRIBUTING.md.
-->

## Summary

What this PR changes, in 1–3 sentences.

## Why

Link to the issue or upstream spec change that motivated this.

## Scope

- [ ] Wire-impacting source (`lib/src/{pb,pxf,sbe,envelope}/`)
- [ ] Vendored proto annotations (`proto/`)
- [ ] Test fixtures / benches / harnesses (`test/`, `benchmark/`, `bin/`)
- [ ] Build / CI / repo plumbing (`pubspec.yaml`, `.github/`)
- [ ] Documentation only

## Test plan

- [ ] `dart pub get`
- [ ] `dart format --output=none --set-exit-if-changed .`
- [ ] `dart analyze --fatal-infos --fatal-warnings`
- [ ] `dart test`
- [ ] If parser/encoder change: HARDENING corpus run via
      `dart run bin/check_decode.dart` against the upstream adversarial
      fixtures
- [ ] If wire-impacting: matching upstream spec PR linked above
- [ ] If new public symbol: re-exported from `lib/protowire.dart`
