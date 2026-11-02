// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// Built by test/compile_test.dart with `dart compile exe`, where dart:mirrors
// does not exist: a program importing the package's main library.
import 'dart:typed_data';

import 'package:protowire/protowire.dart';
import 'package:protowire/src/generated/proto/envelope/v1/envelope.pb.dart'
    as envpb;

void main() {
  final env = envpb.Envelope()
    ..status = 7
    ..error = (envpb.AppError()..code = 'X');
  final text = marshal(env);
  final back = envpb.Envelope();
  unmarshal(text, back);
  try {
    marshalNative(Object());
    print('native did not refuse');
  } on UnsupportedError {
    print('ok ${back.status} ${back.error.code} ${Uint8List(1).length}');
  }
}
