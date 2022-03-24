import 'package:sqlite3/sqlite3.dart' show Database;

import 'columns_integer.dart';
import 'columns_text.dart';
import 'data_string.dart';
import 'database_table.dart';

class DatabaseTableDict extends DatabaseTable<DataString> {
  DatabaseTableDict(
    Database sql,
    String name, {
    this.columnValue = const DatabaseColumnText('value',
        unique: true, indexed: true, fts: true),
    this.columnId = const DatabaseColumnId('rowid'),
  }) : super(sql, name, [columnId, columnValue]);

  @override
  final DatabaseColumnId columnId;

  final DatabaseColumnText columnValue;

  @override
  List dartDecode(DataString value) => [value.id, value.value];

  @override
  DataString dartEncode(List value) => DataString(value[0], value[1]);

  /// Add new values to table
  void addValues(List<String> values) {
    sqlInsertNewsUnqiueValues(values.map(DataString.v).toList(), [columnValue]);
  }

  /// Get values
  Iterable<DataString> getValuesContainde(List<String> values) =>
      sqlSelectByColumns({columnValue: values});

  /// Search values
  Iterable<DataString> getValuesSearch({
    String searchPattern = '',
    int limit = 0,
    int offset = 0,
    DatabaseTableDictOrderType order = DatabaseTableDictOrderType.unorderer,
    bool orderAsc = true,
    bool highlights = false,
  }) {
    final sb = StringBuffer();
    final binds = [];
    if (searchPattern.isNotEmpty) {
      sb.write(' $nameFts = ?');
      binds.add(searchPattern);
      if (order != DatabaseTableDictOrderType.unorderer) {
        sb.write(' ORDER BY ');
        switch (order) {
          case DatabaseTableDictOrderType.unorderer:
            break;
          case DatabaseTableDictOrderType.id:
            sb.write('$nameFts.ROWID');
            break;
          case DatabaseTableDictOrderType.value:
            sb.write('$nameFts.${columnValue.name}');
            break;
          case DatabaseTableDictOrderType.bm25:
            sb.write('bm25($nameFts)');
            break;
        }
        if (orderAsc) {
          sb.write(' ASC');
        } else {
          sb.write(' DESC');
        }
      }
    } else {
      if (order != DatabaseTableDictOrderType.unorderer &&
          order != DatabaseTableDictOrderType.bm25) {
        sb.write(' ORDER BY ');
        switch (order) {
          case DatabaseTableDictOrderType.id:
            sb.write('ROWID');
            break;
          case DatabaseTableDictOrderType.value:
            sb.write(columnValue.name);
            break;
          case DatabaseTableDictOrderType.unorderer:
          case DatabaseTableDictOrderType.bm25:
            break;
        }
        if (orderAsc) {
          sb.write(' ASC');
        } else {
          sb.write(' DESC');
        }
      }
    }
    if (limit > 0) {
      sb.write(' LIMIT ?, ?');
      binds
        ..add(limit)
        ..add(offset);
    }
    if (searchPattern.isNotEmpty) {
      if (highlights) {
        return sqlSelectFtsHl(sb.toString());
      }
      return sqlSelectFts(sb.toString());
    }
    return sqlSelect(sb.toString());
  }
}

enum DatabaseTableDictOrderType {
  unorderer,
  id,
  value,
  bm25,
}
