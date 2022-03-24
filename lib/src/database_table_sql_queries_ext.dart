import 'columns_text.dart';
import 'database_column.dart';
import 'database_table_core.dart';

String _columnsMapDefs(DatabaseColumn c) => c.columnDefinition;
String _columnsMapNames(DatabaseColumn c) => c.name;
String _columnsMapNamesBinds(DatabaseColumn c) => '${c.name} = ?';
Iterable<String> _columnsNamesWithPrefix(
    Iterable<DatabaseColumn> cs, String prefix) sync* {
  for (final c in cs) {
    yield '$prefix.${c.name}';
  }
}

Iterable<String> _columnsNamesWithHighlight(
    Iterable<DatabaseColumn> cs, String name, String nameFts) sync* {
  var i = 0;
  for (final c in cs) {
    if (c is DatabaseColumnTextBase && c.fts) {
      yield '''highlight($nameFts, $i, '$kHighlightTextBegin', '$kHighlightTextEnd')''';
      i++;
    } else {
      yield '$name.${c.name}';
    }
  }
}

abstract class DatabaseTableSqlQueriesX<T> extends DatabaseTableCore<T> {
  const DatabaseTableSqlQueriesX();
  String get _nameI => '_i_${name}_';
  String get _nameTemp => '_tmp_$name';
  String get _nameFtsI => '_ftsI_$name';
  String get _nameFtsD => '_ftsD_$name';
  String get _nameFtsU => '_ftsU_$name';

  String sqlQueryCreateIndex(DatabaseColumn c) => '''
    CREATE ${c.unique ? 'UNIQUE ' : ''}
    INDEX IF NOT EXISTS $_nameI${c.name}
      ON $name(${c.name});
  ''';
  String sqlQueryDropIndex(DatabaseColumn c) => '''
    DROP INDEX EXISTS $_nameI${c.name};
  ''';

  String get _sqlQueryCreateFtsD => '''
    INSERT INTO $nameFts(
      $nameFts, ROWID,
      ${columnsFts.map(_columnsMapNames).join(', ')}
    ) VALUES (
      'delete', old.ROWID,
      ${_columnsNamesWithPrefix(columnsFts, 'old').join(', ')}
    );
  ''';

  String get _sqlQueryCreateFtsI => '''
    INSERT INTO $nameFts(
      ROWID,
      ${columnsFts.map(_columnsMapNames).join(', ')}
    ) VALUES (
      new.ROWID,
      ${_columnsNamesWithPrefix(columnsFts, 'new').join(', ')}
    );
  ''';

  String sqlQueryCreateFts() => columnsFts.isEmpty
      ? ''
      : '''
    CREATE VIRTUAL TABLE IF NOT EXISTS $nameFts USING fts5(
      ${columnsFts.map(_columnsMapNames).join(', ')},
      content='$name', content_rowid='ROWID'
    );
    CREATE TRIGGER IF NOT EXISTS $_nameFtsI
      AFTER INSERT ON $name BEGIN
      $_sqlQueryCreateFtsI
    END;
    CREATE TRIGGER IF NOT EXISTS $_nameFtsD
      AFTER DELETE ON $name BEGIN
      $_sqlQueryCreateFtsD
    END;
    CREATE TRIGGER IF NOT EXISTS $_nameFtsU
      AFTER UPDATE ON $name BEGIN
      $_sqlQueryCreateFtsD
      $_sqlQueryCreateFtsI
    END;
  ''';

  String sqlQueryDropFts() => columnsFts.isEmpty
      ? ''
      : '''
    DROP TRIGGER IF EXISTS $_nameFtsU;
    DROP TRIGGER IF EXISTS $_nameFtsD;
    DROP TRIGGER IF EXISTS $_nameFtsI;
    DROP TABLE IF EXISTS $nameFts;
  ''';

  String sqlQueryCreateMainTable() => '''
    CREATE TABLE IF NOT EXISTS $name(
      ${columns.map(_columnsMapDefs).join(', ')}
    );
  ''';

  String sqlQueryDropMainTable() => '''
    DROP TABLE IF EXISTS $name;
  ''';

  String sqlQueryCreateAllTables() => '''
    ${sqlQueryCreateMainTable()}
    ${columnsIndexed.map(sqlQueryCreateIndex).join('\n')}
    ${sqlQueryCreateFts()}
  ''';

  /// SQL Query string for drop tables
  String sqlQueryDropAllTables() => '''
    ${columnsIndexed.map(sqlQueryDropIndex).join('\n')}
    ${sqlQueryDropFts()}
    ${sqlQueryDropMainTable()}
  ''';

  String sqlQuerySelectLength([String condition = '']) => '''
    SELECT COUNT(*) FROM $name $condition
  ''';

  String sqlQuerySelectLengthFts([String condition = '']) => '''
    SELECT COUNT(*) FROM $nameFts $condition
  ''';

  /// Generate string like `?, ?, ?`, with some [length]
  String sqlQueryRowBindings(int length) => '''
    ${Iterable.generate(length, (i) => '?').join(', ')}
  ''';

  String _sqlQueryValues(int length) => '''
    VALUES ${Iterable.generate(length, (i) => '(${sqlQueryRowBindings(columnsCount)})').join(', ')}
  ''';

  String sqlQueryInsert(int length) => '''
    INSERT INTO $name ${_sqlQueryValues(length)}
  ''';

  String sqlQuerySelect([String condition = '']) => '''
    SELECT ${columns.map(_columnsMapNames).join(', ')}
    FROM $name $condition
  ''';

  String sqlQuerySelectColumn(DatabaseColumn c, [String condition = '']) => '''
    SELECT ${c.name} FROM $name $condition
  ''';

  String sqlQuerySelectFts([String condition = '']) => '''
    SELECT ${_columnsNamesWithPrefix(columns, name).join(', ')}
    FROM $nameFts LEFT JOIN $name ON $nameFts.ROWID = $name.ROWID
    $condition
  ''';

  String sqlQuerySelectFtsHL([String condition = '']) => '''
    SELECT ${_columnsNamesWithHighlight(columns, name, nameFts).join(', ')}
    FROM $nameFts LEFT JOIN $name ON $nameFts.ROWID = $name.ROWID
    $condition
  ''';

  String sqlQueryDelete([String condition = '']) => '''
    DELETE FROM $name $condition
  ''';

  String sqlQueryUpdate1() => '''
    UPDATE $name SET
    ${columns.map(_columnsMapNamesBinds).join(', ')}
    WHERE ${columnId.name} = ?;
  ''';

  String sqlQueryUpdateM(int length, [String condition = '']) => '''
    WITH $_nameTemp(
      ${columns.map(_columnsMapNames).join(', ')}
    ) AS (${_sqlQueryValues(length)})
    UPDATE $name SET
    ${columns.map((e) => '''
          ${e.name} = (
            SELECT ${e.name} FROM $_nameTemp
            WHERE $name.${columnId.name} = $_nameTemp.${columnId.name}
          )
        ''').join(', ')}
     WHERE ${columnId.name} IN (SELECT ${columnId.name} FROM $name.${columnId.name});
  ''';
}
