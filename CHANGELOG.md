## 1.0.0

- Initial port from Go `protowire`.
- Implementation of **PXF (Proto eXpressive Format)**:
    - Lexer and Parser for human-friendly text representation.
    - Decoder for `GeneratedMessage`.
    - Encoder for `GeneratedMessage`.
- Implementation of **SBE (Simple Binary Encoding)**:
    - Template builder from `BuilderInfo`.
    - Marshaler and Unmarshaler.
    - Zero-allocation `View` API for fast binary reads.
- Implementation of **Envelope system**:
    - `Envelope`, `AppError`, and `FieldError` for standardized API responses.
- Added comprehensive unit tests and Go-interop verification tests.
- Added performance benchmarks.
