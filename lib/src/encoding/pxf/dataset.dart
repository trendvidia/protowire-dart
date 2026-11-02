// SPDX-License-Identifier: MIT
// Copyright (c) 2026 TrendVidia, LLC.
//
// `@dataset` column paths and row binding (draft -01 §3.4.4). A row binds as
// the body that writes `c = <value>` for each non-empty cell, so a cell means
// exactly what the same value means in a body. Cells that share a path prefix
// land in one block: two blocks for one sub-message bind it twice, which the
// decoder rejects. Mirrors protowire-go's dataset_paths.go and dataset_bind.go.
import 'package:protobuf/protobuf.dart';

import 'ast.dart';
import 'decode.dart';
import 'errors.dart';
import 'format.dart' show formatValue;
import 'options.dart';
import 'wellknown.dart';

/// Checks the header rules that need no schema: no path has an empty segment,
/// no path appears twice, and no column is a prefix of another. Returns the
/// index of the first column that breaks one with the message, or null.
(int, String)? columnPathError(List<String> columns) {
  for (var i = 0; i < columns.length; i++) {
    final c = columns[i];
    if (c.startsWith('.') || c.endsWith('.') || c.contains('..')) {
      return (
        i,
        '@dataset column "$c": a column path has an empty segment (draft §3.4.4)'
      );
    }
    for (final prev in columns.take(i)) {
      if (prev == c) {
        return (i, '@dataset column "$c" appears twice (draft §3.4.4)');
      }
      if (c.startsWith('$prev.') || prev.startsWith('$c.')) {
        return (
          i,
          '@dataset column "$c" overlaps column "$prev": a field and a path '
              'inside it cannot both be columns (draft §3.4.4)'
        );
      }
    }
  }
  return null;
}

/// Checks every column against the row type [info], and returns the message
/// for the first that breaks a rule, or null. Each segment names a field, and
/// each segment but the last names a singular message field whose type is not
/// written as a literal of its own. A `pxf.Secret` has a block form as well as
/// its literal, so a path may go into one.
String? _columnProblem(BuilderInfo info, List<String> columns) {
  final header = columnPathError(columns);
  if (header != null) return header.$2;
  for (final c in columns) {
    var current = info;
    final segments = c.split('.');
    for (var i = 0; i < segments.length; i++) {
      final fi = fieldNamed(current, segments[i]);
      if (fi == null) {
        return '@dataset column "$c": ${current.qualifiedMessageName} has no field "${segments[i]}"';
      }
      if (i == segments.length - 1) break;
      final at = segments.take(i + 1).join('.');
      if (fi.isMapField) {
        return '@dataset column "$c": "$at" is a map field, and a column path cannot go through one; use a value cell for "$at" (draft §3.4.4)';
      }
      if (fi.isRepeated) {
        return '@dataset column "$c": "$at" is a repeated field, and a column path cannot go through one; use a value cell for "$at" (draft §3.4.4)';
      }
      if (!fi.isGroupOrMessage) {
        return '@dataset column "$c": "$at" is not a message field';
      }
      final sub = fi.subBuilder!().info_;
      if (_isLiteralMessage(sub)) {
        return '@dataset column "$c": "$at" is a ${sub.qualifiedMessageName}, which is written as a literal; a column path cannot go into it (draft §3.4.4)';
      }
      current = sub;
    }
  }
  return null;
}

bool _isLiteralMessage(BuilderInfo info) =>
    isTimestamp(info) ||
    isDuration(info) ||
    isWrapperType(info) ||
    isBigInt(info) ||
    isDecimal(info) ||
    isBigFloat(info);

/// One level of a row's body: a cell's value, or a block of children.
class _BodyNode {
  final String name;
  final Value? cell;
  final List<_BodyNode> children = [];

  _BodyNode(this.name, [this.cell]);

  void write(StringBuffer out) {
    for (final child in children) {
      final value = child.cell;
      if (value != null) {
        out.write('${child.name} = ${formatValue(value)}\n');
      } else {
        out.write('${child.name} {\n');
        child.write(out);
        out.write('}\n');
      }
    }
  }
}

/// The document body [row] stands for. Empty cells write no entry, and a block
/// none of whose cells is non-empty is not written.
String _rowBody(List<String> columns, DatasetRow row) {
  final root = _BodyNode('');
  for (var i = 0; i < columns.length; i++) {
    final cell = row.cells[i];
    if (cell == null) continue;
    final segments = columns[i].split('.');
    var node = root;
    for (final segment in segments.take(segments.length - 1)) {
      var next = node.children
          .where((c) => c.cell == null && c.name == segment)
          .firstOrNull;
      if (next == null) {
        next = _BodyNode(segment);
        node.children.add(next);
      }
      node = next;
    }
    node.children.add(_BodyNode(segments.last, cell));
  }
  final out = StringBuffer();
  root.write(out);
  return out.toString();
}

/// Binds [row] to [msg] by column name. A non-empty cell in column `c` means
/// exactly what `c = <value>` means in a body of the row type, and a column
/// may be a dotted path into a sub-message.
///
/// With [UnmarshalOptions.annotations] an empty cell takes the field's
/// default or is rejected as required, and a null cell counts as present.
/// A failure is a [PxfError] at the row.
///
/// ```dart
/// final ds = unmarshalFull(doc, Row()).datasets.single;
/// final row = Row();
/// bindDatasetRow(row, ds.columns, ds.rows.first);
/// ```
void bindDatasetRow(GeneratedMessage msg, List<String> columns, DatasetRow row,
    {UnmarshalOptions? options}) {
  if (columns.length != row.cells.length) {
    throw PxfError(row.pos,
        'bindDatasetRow: ${columns.length} columns vs ${row.cells.length} cells');
  }
  final problem = _columnProblem(msg.info_, columns);
  if (problem != null) throw PxfError(row.pos, problem);
  try {
    unmarshalFull(_rowBody(columns, row), msg, options: options);
  } on PxfError catch (e) {
    throw PxfError(row.pos, '@dataset row: ${e.message}');
  }
}
