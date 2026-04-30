/// A high-performance serialization and messaging toolkit for Dart.
///
/// Protowire provides:
/// - **PXF**: Human-friendly text serialization for Protobuf.
/// - **SBE**: Ultra-low-latency binary encoding.
/// - **Envelope**: Standardized API response structure.
library protowire;

export 'src/encoding/pxf/decode.dart';
export 'src/encoding/pxf/encode.dart';
export 'src/encoding/pxf/options.dart';
export 'src/encoding/pxf/errors.dart';
export 'src/encoding/pxf/wellknown.dart';
export 'src/encoding/sbe/sbe.dart';
export 'src/encoding/sbe/view.dart';
export 'src/encoding/sbe/xmltoproto.dart';
export 'src/encoding/sbe/prototoxml.dart';
export 'src/encoding/pb/native.dart';
export 'src/envelope/envelope.dart';

// Generated types
export 'src/generated/proto/pxf/bignum.pb.dart';
export 'src/generated/proto/pxf/annotations.pb.dart';
export 'src/generated/proto/sbe/annotations.pb.dart';
export 'src/generated/proto/envelope/v1/envelope.pb.dart';
