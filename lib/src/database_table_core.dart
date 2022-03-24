import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/sqlite3.dart';

import 'columns_integer.dart';
import 'columns_text.dart';
import 'database_column.dart';

bool _columnsFilterIndexed(DatabaseColumn c) => c.indexed;
bool _columnsFilterFts(DatabaseColumn c) =>
    c is DatabaseColumnTextBase && c.fts;

/// Definition of database table
/// - [T] - type of contains data
///
/// #### data levels:
/// - `json` - Json representation of [T] value
/// - `bin` - bytes representation of [T] value
/// - `dart` - [T] object repesentation of value
/// - `dartraw` - List of [DatabaseColumn.T]
/// - `raw` - List of [DatabaseColumn.R]
/// - `db` - List of [DatabaseColumn.R]? used like paramters in queries
@immutable
abstract class DatabaseTableCore<T> {
  const DatabaseTableCore();
  Database get sql;

  /// Name of this table
  String get name;

  /// Name of Fts table
  String get nameFts => '_fts_$name';

  /// Table columns definitions
  List<DatabaseColumn> get columns;

  /// Count of columns
  int get columnsCount => columns.length;

  /// Table columns who need to create indexes
  Iterable<DatabaseColumn> get columnsIndexed =>
      columns.where(_columnsFilterIndexed);

  /// Table columns who need to create fts tables
  Iterable<DatabaseColumn> get columnsFts => columns.where(_columnsFilterFts);

  /// Column who haw primary key
  DatabaseColumnId get columnId => columns.whereType<DatabaseColumnId>().first;

  /// Converting `dart` [T] object to `dartraw` database columns dart represents
  List dartDecode(T value);

  /// Converting `dartraw` database columns dart represents to `dart` [T] object
  T dartEncode(List value);

  /// Converting `dart` [T] object to `raw`
  List dartDecodeRaw(T value) => _rawDecode(dartDecode(value));

  /// Converting `raw` to `dart` [T] object
  T dartEncodeRaw(List value) => dartEncode(_rawEncode(value).toList());

  /// Converting `dartraw` to `raw`
  List _rawDecode(List value) {
    final out = [];
    for (var i = 0; i < columnsCount; i++) {
      final c = columns[i];
      out.add(c.dartDecode(value[i]));
    }
    return out;
  }

  /// Converting `raw` to `dartraw`
  List _rawEncode(List value) {
    final out = [];
    for (var i = 0; i < columnsCount; i++) {
      final c = columns[i];
      out.add(c.dartEncode(value[i]));
    }
    return out;
  }

  /// Converting `db` values to `raw` values
  List rowDecodeRaw(Row value) {
    final out = [];
    for (var i = 0; i < columnsCount; i++) {
      final c = columns[i];
      out.add(c.databaseLoadMutator(value.columnAt(i)));
    }
    return out;
  }

  /// Converting `raw` values to `db` values
  List rowEncodeRaw(List value) {
    final out = [];
    for (var i = 0; i < columnsCount; i++) {
      final c = columns[i];
      out.add(c.databaseSaveMutator(value[i]));
    }
    return out;
  }

  /// Read `raw` values from `bin` [reader]
  List binReadRaw(BinaryReader reader) {
    final out = [];
    for (var i = 0; i < columnsCount; i++) {
      out.add(columns[i].binRead(reader));
    }
    return out;
  }

  /// Wrtie `raw` values to `bin` [writer]
  void binWriteRaw(List value, BinaryWriter writer) {
    for (var i = 0; i < columnsCount; i++) {
      columns[i].binWrite(value[i], writer);
    }
  }

  /// Read `dart` [T] object from `bin` [reader]
  T binRead(BinaryReader reader) => dartEncodeRaw(binReadRaw(reader).toList());

  /// Wrtie `dart` [T] object to `bin` [writer]
  void binWrite(T value, BinaryWriter writer) =>
      binWriteRaw(dartDecodeRaw(value).toList(), writer);

  /// Converting `json` to `raw`
  List jsonDecodeRaw(Object? value) {
    if (value is! Map) {
      throw ArgumentError('Table can decode only Json Map Objects');
    }
    final out = [];
    for (var i = 0; i < columnsCount; i++) {
      final c = columns[i];
      out.add(c.jsonDecode(value[c.name]));
    }
    return out;
  }

  /// Converting `raw`  to `json`
  Map<String, dynamic> jsonEncodeRaw(List value) {
    final out = <String, dynamic>{};
    for (var i = 0; i < columnsCount; i++) {
      final c = columns[i];
      out[c.name] = c.jsonEncode(value[i]);
    }
    return out;
  }

  /// Converting `json` to `dart` [T] object
  T jsonDecode(Object? value) => dartEncodeRaw(jsonDecodeRaw(value).toList());

  /// Converting `dart` [T] object to `json`
  Map<String, dynamic> jsonEncode(T value) =>
      jsonEncodeRaw(dartDecodeRaw(value).toList());

  @override
  String toString() => '$name(${columns.join(', ')})';
}
