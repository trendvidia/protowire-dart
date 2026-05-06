import 'package:protobuf/protobuf.dart';

import 'annotations.dart';

class UnmarshalOptions {
  final TypeRegistry typeRegistry;
  final bool discardUnknown;

  /// Optional registry of `(pxf.required)` / `(pxf.default)` field
  /// annotations, parsed from the per-message `xxxDescriptor` blobs in
  /// `*.pbjson.dart`. When supplied, the decoder runs a post-decode pass
  /// that fails on absent required fields and applies declared defaults.
  /// Messages whose qualified name is not registered are skipped — same
  /// stance the Go reference takes.
  final PxfAnnotations? annotations;

  UnmarshalOptions({
    this.typeRegistry = const TypeRegistry.empty(),
    this.discardUnknown = false,
    this.annotations,
  });
}
