import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

/// Base class of declaring column, must to be const
/// - [T] - type of data represents in Dart
/// - [R] - type of data represents in database
/// (this must be one of [int], [double], [String], [Uint8List])
///
/// #### data levels:
/// - `json` - Json representation of contains value
/// - `bin` - bytes representation of contains value
/// - `dart` - [T] dart representation of contains value
/// - `raw` - [R] database representation of contains value
/// - `db` - [R]? contained directly in db of this column
@immutable
abstract class DatabaseColumn<T, R> {
  @literal
  const DatabaseColumn(
    this.name,
    this.type, {
    this.constraints = 'NOT NULL',
    this.unique = false,
    this.indexed = false,
  });

  /// Column name
  final String name;

  /// Declared type of column
  /// - https://www.sqlite.org/datatype3.html
  final String type;

  /// Constraints of that column
  /// - https://www.sqlite.org/syntax/column-constraint.html
  final String constraints;

  /// Unique values in column
  final bool unique;

  /// Needs to create index for this column
  final bool indexed;

  /// Converting [T] `dart` object to `raw` database value
  R dartDecode(T value);

  /// Converting `raw` database value to [T] `dart` object
  T dartEncode(R value);

  /// Read `raw` database value from [reader]
  R binRead(BinaryReader reader);

  /// Wrtie `raw` database value to [writer]
  void binWrite(R value, BinaryWriter writer);

  /// Converting `json` to `raw` database value
  R jsonDecode(Object? value);

  /// Converting `raw` database value to `json`
  Object? jsonEncode(R value);

  /// Mutate `raw` value to `db` before insert it to database
  R? databaseSaveMutator(R value) => value;

  /// Mutate `db` value after select to `raw` value
  R databaseLoadMutator(R? value);

  /// Column definition for sqlite3
  /// - https://www.sqlite.org/syntax/column-def.html
  String get columnDefinition =>
      '$name $type $constraints${unique ? ' UNIQUE' : ''}';

  @override
  String toString() => columnDefinition;
}
