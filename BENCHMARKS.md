# Benchmarks

Run with `package:benchmark_harness` against the canonical 11-field
`Order` (with a 3-entry `Fill` group) defined in `benchmark/bench.dart`.
Hardware: Apple M-series, Dart 3.11.5. Each cell is the median of three
runs.

## Steady-state JIT (`dart run benchmark/bench.dart`)

| Benchmark | Runtime (us) | Description |
|-----------|--------------|-------------|
| PXF Unmarshal | 50.85 | Parsing PXF text into `GeneratedMessage` |
| PXF Marshal | 22.40 | Marshaling `GeneratedMessage` to PXF text |
| SBE Marshal | 4.23 | Marshaling `GeneratedMessage` to SBE binary |
| SBE Unmarshal | 16.15 | Unmarshaling SBE binary into `GeneratedMessage` |
| SBE View Read | 8.75 | Zero-allocation read of all fields via `View` |
| Proto Marshal | 8.12 | Standard Protobuf `writeToBuffer()` |
| Proto Unmarshal | 8.97 | Standard Protobuf `mergeFromBuffer()` |

## AOT (`dart compile exe benchmark/bench.dart`)

| Benchmark | Runtime (us) |
|-----------|--------------|
| PXF Unmarshal | 57.15 |
| PXF Marshal | 36.77 |
| SBE Marshal | 5.30 |
| SBE Unmarshal | 19.28 |
| SBE View Read | 11.03 |
| Proto Marshal | 10.46 |
| Proto Unmarshal | 9.84 |

JIT numbers are typically what you see in `dart test` and during
development; AOT numbers are what ship in `dart compile exe` /
`flutter build` binaries. The two are listed separately because the
relative gap between them isn't uniform across formats.

## Analysis

*   **SBE Marshal** is ~2× faster than standard Protobuf marshaling.
*   **SBE View Read** provides a fast way to access data without
    full decoding, performing similarly to standard Protobuf
    unmarshaling but without object allocation overhead.
*   **SBE Unmarshal** is currently slower than standard Protobuf
    unmarshaling. This is likely due to the overhead of multiple
    `setField` calls in Dart compared to the optimized C++/VM-backed
    binary decoder in `package:protobuf`.
*   **PXF** is the slowest as expected, being a human-friendly text
    format, but still performs within a reasonable range for
    configuration use cases.

## Cross-port harness

`bin/bench_pxf.dart` and `bin/bench_sbe.dart` mirror Go's
`scripts/bench_pxf` / `scripts/bench_sbe` for numerically-stable
comparisons between language ports. They emit one JSON line per op:

```bash
$ dart run bin/bench_pxf.dart --seconds=3
{"port":"dart","op":"unmarshal","ns_per_op":12961,"mib_per_sec":47.97,"iterations":38592,"bytes":652}
{"port":"dart","op":"marshal","ns_per_op":11025,"iterations":45376}

$ dart run bin/bench_sbe.dart --seconds=3
{"port":"dart","op":"sbe-marshal","ns_per_op":554,"iterations":541504,"bytes":94}
{"port":"dart","op":"sbe-unmarshal","ns_per_op":1144,"mib_per_sec":78.32,"iterations":262144,"bytes":94}
```

The fixture is intentionally smaller than the JIT bench above (matching
the canonical cross-port `bench.v1.Config` / `bench.v1.Order`), so the
absolute numbers don't line up — the harnesses exist to compare ports,
not formats.
