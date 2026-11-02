// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// The native codec reflects on a class's fields through dart:mirrors, which
// only the Dart VM has. This stands in for it elsewhere, so that the package's
// main import compiles with `dart compile exe` and for the web.
import 'dart:typed_data';

import '../../limits.dart';

Never _unsupported() => throw UnsupportedError(
    'the native pb codec needs dart:mirrors, which this platform does not '
    'have: use generated messages');

Uint8List marshalNative(Object obj) => _unsupported();

void unmarshalNative(Uint8List data, Object obj,
        {DecodeLimits limits = const DecodeLimits()}) =>
    _unsupported();
