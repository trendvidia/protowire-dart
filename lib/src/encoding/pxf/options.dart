import 'package:protobuf/protobuf.dart';

class UnmarshalOptions {
  final TypeRegistry typeRegistry;
  final bool discardUnknown;

  UnmarshalOptions({
    this.typeRegistry = const TypeRegistry.empty(),
    this.discardUnknown = false,
  });
}
