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

  /// Snapshot of all proto-name dotted paths the decoder marked as
  /// present (set or null). Used by the `(pxf.required)` /
  /// `(pxf.default)` post-decode pass — the only consumer that needs to
  /// distinguish "decoder saw this field" from "decoder marked it null".
  Set<String> get presentFields => _presentFields;
}
