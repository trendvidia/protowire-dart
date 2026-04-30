import 'package:protobuf/protobuf.dart';

abstract class TypeResolver {
  num? findMessageByURL(String url); // Wait, Dart's protobuf TypeRegistry might be different
}

class UnmarshalOptions {
  final TypeResolver? typeResolver;
  final bool discardUnknown;

  UnmarshalOptions({this.typeResolver, this.discardUnknown = false});
}
