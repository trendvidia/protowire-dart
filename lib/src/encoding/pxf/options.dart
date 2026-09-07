// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'package:protobuf/protobuf.dart';

import 'annotations.dart';

class UnmarshalOptions {
  final TypeRegistry typeRegistry;
  final bool discardUnknown;

  /// Schema annotations to apply after decoding: an absent
  /// `(pxf.required)` field is an error, an absent `(pxf.default)` field
  /// takes its literal. Nil leaves decoding exactly as before.
  final PxfAnnotations? annotations;

  UnmarshalOptions({
    this.typeRegistry = const TypeRegistry.empty(),
    this.discardUnknown = false,
    this.annotations,
  });
}
