/// A high-performance serialization and messaging toolkit for Dart.
///
/// Protowire provides:
/// - **PXF**: Human-friendly text serialization for Protobuf.
/// - **SBE**: Ultra-low-latency binary encoding.
/// - **Envelope**: Standardized API response structure.
library;

export 'src/encoding/pxf/decode.dart';
export 'src/encoding/pxf/encode.dart';
export 'src/encoding/pxf/options.dart';
export 'src/encoding/pxf/errors.dart';
export 'src/encoding/pxf/wellknown.dart';
export 'src/encoding/sbe/sbe.dart';
export 'src/encoding/sbe/view.dart';
export 'src/encoding/sbe/xmltoproto.dart';
export 'src/encoding/sbe/prototoxml.dart';
// `src/encoding/pb/native.dart` is deliberately NOT re-exported. It uses
// `dart:mirrors`, which is unsupported on Flutter and AOT-compiled Dart;
// importing it would crash any production build. Users who need it must
// import the path explicitly and accept the JIT-only constraint.
export 'src/envelope/envelope.dart';

// Proto descriptor holders. Each .pb.dart file emits an `Annotations`
// holder class; we hide them here to avoid an `ambiguous_export` clash
// between pxf/annotations.pb.dart and sbe/annotations.pb.dart. Users
// who need the descriptors can import the relevant .pb.dart directly.
export 'src/generated/proto/pxf/annotations.pb.dart' hide Annotations;
export 'src/generated/proto/sbe/annotations.pb.dart' hide Annotations;
// The bignum proto declares `BigInt`/`Decimal`/`BigFloat` types that
// would shadow Dart core `BigInt` (and other arithmetic types) in any
// file that imports `package:protowire/protowire.dart`. Hide them
// from the umbrella; users that want them can do
// `import 'package:protowire/src/generated/proto/pxf/bignum.pb.dart' as pxf;`
// (the `pxf.BigInt` form already used in tests).
export 'src/generated/proto/pxf/bignum.pb.dart' hide BigInt, Decimal, BigFloat;
// The proto-generated `Envelope` from envelope/v1/envelope.pb.dart and the
// hand-written `Envelope` (with builder ergonomics: ok / err / transportErr
// / withField / withMeta) collide on the names Envelope, AppError, and
// FieldError. The hand-written version is the canonical user-facing API;
// the proto descriptor stays available via direct import for byte-level
// cross-port work (dump_envelope, future PB harness).
