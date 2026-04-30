# Protowire Dart

A high-performance serialization and messaging toolkit for Dart, ported from the original Go implementation. Protowire provides human-friendly text serialization (PXF), ultra-low-latency binary encoding (SBE), and a standardized API response envelope.

## Features

*   **PXF (Proto eXpressive Format):** A human-friendly text serialization format backed by protobuf schemas. Ideal for configuration files and readable data exchange.
*   **SBE (Simple Binary Encoding):** Implementation of the FIX SBE standard for ultra-low-latency use cases. Provides fixed-offset field access and zero-allocation reading via the `View` API.
*   **Envelope System:** A uniform API response structure that separates transport-level errors from application-level errors, supporting machine-readable codes and client-side localization.
*   **Protobuf Interop:** Fully compatible with standard Protobuf binary format and `package:protobuf`.

## Getting started

Add `protowire` to your `pubspec.yaml`:

```yaml
dependencies:
  protowire:
    git: https://github.com/trendvidia/protowire-dart.git
```

## Usage

### PXF (Proto eXpressive Format)

PXF allows you to represent Protobuf messages in a readable text format.

```dart
import 'package:protowire/protowire.dart';

// Unmarshal PXF text into a GeneratedMessage
final pxfText = '''
hostname = "web-01.prod.example.com"
port = 8443
enabled = true
''';

final config = Config();
unmarshal(pxfText, config);

// Marshal a GeneratedMessage to PXF text
final output = marshal(config);
print(output);
```

### SBE (Simple Binary Encoding)

SBE is designed for maximum performance. It requires annotations in your `.proto` files to define fixed-length fields and offsets.

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

// Fast, zero-allocation reading via View
final v = codec.view(data);
print(v.getUint('orderId'));
print(v.getString('symbol'));
```

### Envelope System

Standardize your API responses across different systems.

```dart
import 'package:protowire/protowire.dart';

// Create a successful response
final ok = Envelope.ok(200, Uint8List.fromList([1, 2, 3]));

// Create an error response
final err = Envelope.err(400, "INVALID_INPUT", "The provided ID is invalid")
  ..error!.withField("id", "REQUIRED", "ID is mandatory");

if (err.isAppError) {
  print('Error code: ${err.errorCode}');
  print('Field errors: ${err.fieldErrors}');
}
```

## Performance

Protowire-dart is optimized for performance, especially the SBE component.

*   **SBE Marshal** is ~2x faster than standard Protobuf `writeToBuffer()`.
*   **SBE View** allows reading fields directly from a buffer with minimal overhead.

See [BENCHMARKS.md](BENCHMARKS.md) for detailed results.

## Additional information

This project is a Dart port of [trendvidia/protowire](https://github.com/trendvidia/protowire). It maintains binary compatibility with the Go implementation.
