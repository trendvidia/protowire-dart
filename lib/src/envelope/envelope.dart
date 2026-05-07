// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'dart:typed_data';

class Envelope {
  int status;
  String? transportError;
  Uint8List? data;
  AppError? error;

  Envelope({
    this.status = 0,
    this.transportError,
    this.data,
    this.error,
  });

  bool get isOk => transportError == null && error == null;
  bool get isTransportError => transportError != null;
  bool get isAppError => error != null;

  String get errorCode => error?.code ?? '';

  Map<String, FieldError> get fieldErrors {
    if (error == null || error!.details.isEmpty) return {};
    return {for (var fe in error!.details) fe.field: fe};
  }

  // Builders
  static Envelope ok(int status, Uint8List data) =>
      Envelope(status: status, data: data);

  static Envelope err(int status, String code, String message,
          [List<String>? args]) =>
      Envelope(
        status: status,
        error: AppError(code: code, message: message, args: args ?? []),
      );

  static Envelope transportErr(String err) => Envelope(transportError: err);
}

class AppError {
  String code;
  String message;
  List<String> args;
  List<FieldError> details;
  Map<String, String> metadata;

  AppError({
    required this.code,
    this.message = '',
    this.args = const [],
    this.details = const [],
    this.metadata = const {},
  });

  AppError withField(String field, String code, String message,
      [List<String>? args]) {
    details = List.from(details)
      ..add(FieldError(
          field: field, code: code, message: message, args: args ?? []));
    return this;
  }

  AppError withMeta(String key, String value) {
    metadata = Map.from(metadata)..[key] = value;
    return this;
  }
}

class FieldError {
  String field;
  String code;
  String message;
  List<String> args;

  FieldError({
    required this.field,
    required this.code,
    this.message = '',
    this.args = const [],
  });
}
