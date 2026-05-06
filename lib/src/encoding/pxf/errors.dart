import 'token.dart';

/// Thrown when PXF text fails to lex, parse, or decode.
///
/// Extends `Exception` (not `Error`) because parse failures are runtime
/// conditions a caller is expected to handle — not programmer mistakes.
class PxfError implements Exception {
  final Position pos;
  final String message;

  PxfError(this.pos, this.message);

  @override
  String toString() => '$pos: $message';
}
