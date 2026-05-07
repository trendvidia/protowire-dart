// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
class Result {
  final Set<String> _nullFields = {};
  final Set<String> _presentFields = {};

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
}
