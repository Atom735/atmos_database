import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/sqlite3.dart';

import 'columns_integer.dart';
import 'columns_text.dart';
import 'database_column.dart';
import 'database_table.dart';
import 'database_table_sql_queries_ext.dart';

export 'database_table_sql_ext.dart';

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
abstract class DatabaseTable<T> extends DatabaseTableSqlX<T> {
  const DatabaseTable(this.sql, this.name, this.columns);
  @override
  final Database sql;

  /// Name of this table
  @override
  final String name;

  /// Table columns definitions
  @override
  final List<DatabaseColumn> columns;
}
