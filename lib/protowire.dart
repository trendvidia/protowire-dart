/// A high-performance serialization and messaging toolkit for Dart.
///
/// Protowire provides:
/// - **PXF**: Human-friendly text serialization for Protobuf.
/// - **SBE**: Ultra-low-latency binary encoding.
/// - **Envelope**: Standardized API response structure.
library protowire;

export 'src/encoding/pxf/decode.dart';
export 'src/encoding/pxf/encode.dart';
export 'src/encoding/sbe/sbe.dart';
export 'src/encoding/sbe/view.dart';
export 'src/envelope/envelope.dart';
