import 'token.dart';

class PxfError extends Error {
  final Position pos;
  final String message;

  PxfError(this.pos, this.message);

  @override
  String toString() => '$pos: $message';
}
