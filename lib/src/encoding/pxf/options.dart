// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'package:protobuf/protobuf.dart';

import 'annotations.dart';

class UnmarshalOptions {
  final TypeRegistry typeRegistry;
  final bool discardUnknown;

  /// Schema annotations: an absent `(pxf.required)` field is an error, an
  /// absent `(pxf.default)` field takes its literal, and a `(pxf.key)` field
  /// decodes from its keyed block form. Generated messages carry no field
  /// options, so null means no field has any of these.
  final PxfAnnotations? annotations;

  UnmarshalOptions({
    this.typeRegistry = const TypeRegistry.empty(),
    this.discardUnknown = false,
    this.annotations,
  });
}
