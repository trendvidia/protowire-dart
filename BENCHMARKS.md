# Benchmarks

Benchmarks were run on Dart 3.11.5 using `package:benchmark_harness`.

## Results

| Benchmark | Runtime (us) | Description |
|-----------|--------------|-------------|
| PXF Unmarshal | 50.66 | Parsing PXF text into `GeneratedMessage` |
| PXF Marshal | 21.40 | Marshaling `GeneratedMessage` to PXF text |
| SBE Marshal | 4.38 | Marshaling `GeneratedMessage` to SBE binary |
| SBE Unmarshal | 18.12 | Unmarshaling SBE binary into `GeneratedMessage` |
| SBE View Read | 8.64 | Zero-allocation style read of all fields via `View` |
| Proto Marshal | 8.31 | Standard Protobuf `writeToBuffer()` |
| Proto Unmarshal | 10.41 | Standard Protobuf `mergeFromBuffer()` |

## Analysis

*   **SBE Marshal** is ~2x faster than standard Protobuf marshaling.
*   **SBE View Read** provides a fast way to access data without full decoding, performing similarly to standard Protobuf unmarshaling but without object allocation overhead.
*   **SBE Unmarshal** is currently slower than standard Protobuf unmarshaling. This is likely due to the overhead of multiple `setField` calls in Dart compared to the optimized C++/VM-backed binary decoder in `package:protobuf`.
*   **PXF** is the slowest as expected, being a human-friendly text format, but still performs within a reasonable range for configuration use cases.
