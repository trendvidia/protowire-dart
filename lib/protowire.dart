// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
/// A high-performance serialization and messaging toolkit for Dart.
///
/// Protowire provides:
/// - **PXF**: Human-friendly text serialization for Protobuf.
/// - **SBE**: Ultra-low-latency binary encoding.
/// - **Envelope**: Standardized API response structure.
library;

export 'src/limits.dart' show DecodeLimits, defaultMaxMessageSize;
export 'src/encoding/pxf/dataset.dart' show bindDatasetRow;
export 'src/encoding/pxf/decode.dart' hide fieldNamed;
export 'src/encoding/pxf/encode.dart';
export 'src/encoding/pxf/format.dart' show formatPxf;
export 'src/encoding/pxf/options.dart';
export 'src/encoding/pxf/annotations.dart';
export 'src/encoding/pxf/result.dart';
export 'src/encoding/pxf/errors.dart';
export 'src/encoding/pxf/wellknown.dart';
export 'src/encoding/sbe/sbe.dart';
export 'src/encoding/sbe/descriptor.dart';
export 'src/encoding/sbe/view.dart';
export 'src/encoding/sbe/xmltoproto.dart';
export 'src/encoding/sbe/prototoxml.dart';
export 'src/encoding/pb/depth.dart';
export 'src/encoding/pb/proto_tag.dart';
export 'src/encoding/pb/native_stub.dart'
    if (dart.library.mirrors) 'src/encoding/pb/native.dart';
export 'src/envelope/envelope.dart';

// Note: the protoc-generated bindings under src/generated/proto/ are
// implementation details and intentionally not re-exported here.
// Re-exporting them caused name collisions:
//   - `Annotations` is defined twice (pxf/annotations.pb.dart vs
//     sbe/annotations.pb.dart);
//   - `BigInt` from pxf/bignum.pb.dart shadows `dart:core.BigInt`,
//     which broke any test code calling `BigInt.parse()`;
//   - `Envelope` / `AppError` / `FieldError` collide with the
//     hand-written envelope library above.
// Callers that need a generated binding directly can import the
// specific file: `import 'package:protowire/src/generated/...';`.
