// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
import 'ast.dart';

class Result {
  final Set<String> _nullFields = {};
  final Set<String> _presentFields = {};
  final List<Directive> _directives = [];
  final List<DatasetDirective> _datasets = [];
  final List<ProtoDirective> _protos = [];

  void markNull(String path) {
    _nullFields.add(path);
    _presentFields.add(path);
  }

  void markPresent(String path) {
    _presentFields.add(path);
  }

  bool isNull(String path) => _nullFields.contains(path);

  bool isAbsent(String path) => !_presentFields.contains(path);

  bool isSet(String path) =>
      _presentFields.contains(path) && !_nullFields.contains(path);

  List<String> get nullFields => _nullFields.toList();

  /// Generic `@<name> *(prefix) [{ ... }]` directives the decoder saw
  /// at document root, in source order (draft §3.4.2).
  List<Directive> get directives => List.unmodifiable(_directives);

  /// `@dataset` directives in source order (draft §3.4.4). A document
  /// with any `@dataset` has no body entries — the rows are the
  /// document's payload.
  List<DatasetDirective> get datasets => List.unmodifiable(_datasets);

  /// `@proto` directives in source order (draft §3.4.5).
  List<ProtoDirective> get protos => List.unmodifiable(_protos);

  void addDirective(Directive d) => _directives.add(d);
  void addDataset(DatasetDirective d) => _datasets.add(d);
  void addProto(ProtoDirective p) => _protos.add(p);
}
