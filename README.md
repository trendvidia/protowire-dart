# Protowire Dart

A high-performance serialization and messaging toolkit for Dart, ported from the original Go implementation. Protowire provides human-friendly text serialization (PXF), ultra-low-latency binary encoding (SBE), and a standardized API response envelope.

**PXF** (Proto eXpressive Format) is a human-friendly text serialization format backed by protobuf schemas.

Proto defines the schema. Protobuf binary is the wire format. PXF is the text representation for humans. The `encoding/sbe` package provides FIX SBE (Simple Binary Encoding) for ultra-low-latency use cases, driven by the same `.proto` schemas with SBE annotations.

```
@type infra.v1.ServerConfig

hostname = "web-01.prod.example.com"
port     = 8443
enabled  = true
status   = STATUS_SERVING

# Well-known type literals
created_at = 2024-01-15T10:30:00Z
timeout    = 30s

# Nested messages use block syntax
tls {
  cert_file = "/etc/ssl/cert.pem"
  key_file  = "/etc/ssl/key.pem"
  verify    = true
}

# Repeated fields use list syntax
tags = ["production", "us-east", "frontend"]

# Maps use : for key-value pairs
labels = {
  env: "production"
  team: "platform"
  "hello world": "quoted keys supported"
}

# Repeated messages
endpoints = [
  {
    path = "/api/v1/users"
    method = "GET"
  }
  {
    path = "/health"
    method = "GET"
  }
]

# Wrapper type sugar
nullable_name = "present"
```

## Why PXF?

| Format | Problem |
|--------|---------|
| JSON | Loosely typed, no comments, verbose, ambiguous without schema |
| YAML | Indentation-fragile, type coercion surprises (`no` -> `false`), complex spec |
| Protobuf textproto | No list/map literals, repeated fields are ugly, `:` separators feel archaic |
| HCL | Own type system, designed for config not serialization, expression evaluation adds complexity |

PXF uses your existing `.proto` files as the schema. No new schema language. No ambiguity — the parser always knows every field's type.

## Syntax

### Operators

| Context | Operator | Meaning |
|---------|----------|---------|
| `key = value` | `=` | Field assignment (message context) |
| `name { }` | (none) | Nested message block |
| `key: value` | `:` | Map entry (map context) |

### Comments

```
# hash comment
// double-slash comment
/* block comment */
```

### Scalars

```
name    = "string"           # always quoted
port    = 8080               # integer
weight  = 0.85               # float
enabled = true               # bool (true or false)
status  = STATUS_SERVING     # enum (by name)
raw     = b"SGVsbG8="        # bytes (base64)
```

### Well-known type literals

```
created_at = 2024-01-15T10:30:00Z   # google.protobuf.Timestamp (RFC 3339)
timeout    = 1h30m45s                # google.protobuf.Duration (Go-style)
```

### Null

Any field can be explicitly set to null:

```
email = null       # explicitly null — different from absent
```

Null is not allowed inside repeated fields or map values.

## SBE binary encoding (`encoding/sbe`)

[FIX SBE](https://www.fixtrading.org/standards/sbe/) (Simple Binary Encoding) for latency-sensitive workloads. Same `.proto` schema drives both protobuf and SBE wire formats — add SBE annotations and use the codec at runtime.

### Schema annotations

```proto
import "sbe/annotations.proto";

option (sbe.schema_id) = 1;
option (sbe.version) = 0;

message NewOrderSingle {
  option (sbe.template_id) = 1;

  uint64 order_id = 1;
  string symbol   = 2 [(sbe.length) = 8];     // fixed-size char[8]
  int64  price    = 3;
  uint32 quantity = 4;
  uint32 side     = 5 [(sbe.encoding) = "uint8"]; // narrow to 1 byte

  message Fill {
    int64  fill_price = 1;
    uint32 fill_qty   = 2;
    uint64 fill_id    = 3;
  }
  repeated Fill fills = 6;  // SBE repeating group
}
```

### Codec API (Marshal / Unmarshal)

```dart
import 'package:protowire/protowire.dart';

final codec = Codec()
  ..registerMessage(
    Order.info_,
    1, // templateId
    1, // schemaId
    0, // version
    lengths: {2: 8}, // symbol length = 8
  );

// Marshal to SBE binary
final order = Order()..orderId = Int64(123)..symbol = "AAPL";
final data = codec.marshal(order);

// Unmarshal SBE binary into GeneratedMessage
final decoded = Order();
codec.unmarshal(data, decoded);
```

### View API (zero-allocation reads)

For maximum performance, the `View` API reads fields directly from the SBE buffer at pre-computed offsets with zero allocations:

```dart
final v = codec.view(data);

// Scalars — direct buffer reads, no allocations
final orderID = v.getUint("order_id");
final symbol  = v.getString("symbol");   // zero-copy, backed by buffer
final price   = v.getInt("price");

// Repeating groups
final fills = v.getGroup("fills");
for (int i = 0; i < fills.length; i++) {
    final e = fills.entry(i);
    final fillPrice = e.getInt("fill_price");
}

// Composites (nested messages)
final header = v.getComposite("header");
final timestamp = header.getUint("timestamp");
```

## Proto Compilation

This project uses [Buf](https://buf.build/) for Protobuf management and code generation.

### Prerequisites

1.  Install the `buf` CLI: [Installation Guide](https://docs.buf.build/installation)
2.  Install the Dart protoc plugin:
    ```bash
    dart pub global activate protoc_plugin
    ```

### Generating Code

To generate Dart code from the `.proto` files in the `proto/` directory:

```bash
buf generate
```

The configuration is defined in `buf.yaml` and `buf.gen.yaml`.

## PXF Dart API

### Unmarshal

```dart
import 'package:protowire/protowire.dart';

// Unmarshal PXF text into a GeneratedMessage
final config = Config();
unmarshal(pxfText, config);
```

### Marshal

```dart
import 'package:protowire/protowire.dart';

final output = marshal(config, options: MarshalOptions(
  typeUrl: "infra.v1.ServerConfig",
  indent: "  ",
));
```

## Field presence and nulls

PXF distinguishes three field states:

| State | PXF syntax | Meaning |
|-------|-----------|---------|
| **Set** | `name = "Alice"` | Field has a concrete value |
| **Null** | `name = null` | Field is explicitly null |
| **Absent** | *(field not mentioned)* | Field was not included in the document |

### Null survival across protobuf binary

If you need nulls to survive a protobuf binary round-trip, add a field named `_null` of type `google.protobuf.FieldMask` to your message. Protowire will automatically record null fields into this mask during unmarshal and restore them during marshal.

## Benchmarks

### At a glance

Performance comparison on Apple M1 (Dart 3.11).

| Format | Marshal (us) | Unmarshal (us) |
|--------|--------------|----------------|
| **SBE** | **4.38** | 18.12 |
| Protobuf | 8.31 | 10.41 |
| **SBE View** | -- | **8.64** (Read-only) |
| **PXF** | 21.40 | 50.66 |

*   **SBE Marshal** is ~2x faster than standard Protobuf `writeToBuffer()`.
*   **SBE View** provides zero-allocation reads, bypassing full object decoding.

## Project structure

```
lib/
├── protowire.dart         # Main entry point and exports
└── src/
    ├── encoding/
    │   ├── pxf/           # PXF text format
    │   │   ├── lexer.dart # Tokenizer
    │   │   ├── parser.dart# AST Parser
    │   │   ├── decode.dart# GeneratedMessage decoder
    │   │   └── encode.dart# GeneratedMessage encoder
    │   └── sbe/           # SBE binary format
    │       ├── codec.dart # High-level Codec API
    │       ├── marshal.dart
    │       ├── unmarshal.dart
    │       └── view.dart  # Zero-allocation reader
    └── envelope/          # API response envelope
```

## Additional information

This project is a Dart port of [trendvidia/protowire](https://github.com/trendvidia/protowire). It maintains binary compatibility with the Go implementation.
