import 'database_column.dart';
import 'database_table_sql_queries_ext.dart';

abstract class DatabaseTableSqlX<T> extends DatabaseTableSqlQueriesX<T> {
  const DatabaseTableSqlX();

  /// Maximum datas insert with one command
  int get sqlInsertChunkSize => 0x7f00 ~/ (columnsCount + 1);

  /// Create SQLite tables
  void sqlCreate() => sql.execute(sqlQueryCreateAllTables());

  /// Drop SQLite tables
  void sqlDrop() => sql.execute(sqlQueryDropAllTables());

  /// Insert `dart` [T] objects to SQLite table
  void sqlInsert(Iterable<T> data) => sqlInsertRaw(data.map(dartDecode));

  /// Insert `raw` values to SQLite table
  void sqlInsertRaw(Iterable<List> data) {
    if (data.isEmpty) return;

    if (data.length > sqlInsertChunkSize) {
      sqlInsertRaw(data.take(sqlInsertChunkSize));
      sqlInsertRaw(data.skip(sqlInsertChunkSize));
    } else {
      sql.execute(
        sqlQueryInsert(data.length),
        data.expand(rowEncodeRaw).toList(),
      );
    }
  }

  /// Select count of rows in SQLite table
  int sqlSelectCount([
    String condition = '',
    List<Object?> parameters = const [],
  ]) =>
      sql
          .select(
            sqlQuerySelectLength(condition),
            parameters,
          )
          .first
          .columnAt(0);

  /// Select count of rows in SQLite fts table
  int sqlSelectCountFts([
    String condition = '',
    List<Object?> parameters = const [],
  ]) =>
      sql
          .select(
            sqlQuerySelectLengthFts(condition),
            parameters,
          )
          .first
          .columnAt(0);

  /// Select `dart` column data of column
  Iterable<C> sqlSelectColumnData<C, R>(
    DatabaseColumn<C, R> c, [
    String condition = '',
    List<Object?> parameters = const [],
  ]) =>
      sqlSelectColumnDataRaw(
        c,
        condition,
        parameters,
      ).map(c.dartEncode);

  /// Select `raw` data of column
  Iterable<R> sqlSelectColumnDataRaw<C, R>(
    DatabaseColumn<C, R> c, [
    String condition = '',
    List<Object?> parameters = const [],
  ]) =>
      sql
          .select(
            sqlQuerySelectColumn(c, condition),
            parameters,
          )
          .map((e) => c.databaseLoadMutator(e.columnAt(0)));

  /// Select `dart` [T] objects from SQLite table
  Iterable<T> sqlSelect([
    String condition = '',
    List<Object?> parameters = const [],
  ]) =>
      sqlSelectRaw(
        condition,
        parameters,
      ).map(dartEncodeRaw);

  /// Select `raw` values from SQLite table
  Iterable<List> sqlSelectRaw([
    String condition = '',
    List<Object?> parameters = const [],
  ]) =>
      sql
          .select(
            sqlQuerySelect(condition),
            parameters,
          )
          .map(rowDecodeRaw);

  /// Select `dart` [T] objects from SQLite fts table
  Iterable<T> sqlSelectFts([
    String condition = '',
    List<Object?> parameters = const [],
  ]) =>
      sqlSelectFtsRaw(
        condition,
        parameters,
      ).map(dartEncodeRaw);

  /// Select `raw` values from SQLite fts table
  Iterable<List> sqlSelectFtsRaw([
    String condition = '',
    List<Object?> parameters = const [],
  ]) =>
      sql
          .select(
            sqlQuerySelectFts(condition),
            parameters,
          )
          .map(rowDecodeRaw);

  /// Select highlighted `dart` [T] objects from SQLite fts table
  Iterable<T> sqlSelectFtsHl([
    String condition = '',
    List<Object?> parameters = const [],
  ]) =>
      sqlSelectFtsHlRaw(
        condition,
        parameters,
      ).map(dartEncodeRaw);

  /// Select `raw` values highlighted from SQLite fts table
  Iterable<List> sqlSelectFtsHlRaw([
    String condition = '',
    List<Object?> parameters = const [],
  ]) =>
      sql
          .select(
            sqlQuerySelectFtsHL(condition),
            parameters,
          )
          .map(rowDecodeRaw);

  /// Select `dart` [T] objects from theys ids
  Iterable<T> sqlSelectByIds(List<int> ids) =>
      sqlSelectByIdsRaw(ids).map(dartEncodeRaw);

  /// Select `raw` values from theys ids
  Iterable<List> sqlSelectByIdsRaw(List<int> ids) => sqlSelectRaw(
        'WHERE ${columnId.name} IN (${ids.map((e) => '?').join(', ')})',
        ids,
      );

  /// Select `dart` [T] objects from some columns values,
  /// where [MapEntry.key] is column, and [MapEntry.value] is
  /// [List] of `dart` column value
  Iterable<T> sqlSelectByColumns(Map<DatabaseColumn, List> m,
          {bool and = true}) =>
      sqlSelectByColumnsRaw(
        m.map((key, value) => MapEntry(key, key.dartDecode(value))),
        and: and,
      ).map(dartEncodeRaw);

  /// Select `raw` values from some columns values,
  /// where [MapEntry.key] is column, and [MapEntry.value] is
  /// [List] of `raw` column value
  Iterable<List> sqlSelectByColumnsRaw(Map<DatabaseColumn, List> m,
      {bool and = true}) {
    final sb = StringBuffer('WHERE ');
    final e = m.entries.first;
    sb.write('${e.key.name} IN (${sqlQueryRowBindings(e.value.length)})');
    for (final e in m.entries.skip(1)) {
      if (and) {
        sb.write(' AND ');
      } else {
        sb.write(' OR ');
      }
      sb.write('${e.key.name} IN (${sqlQueryRowBindings(e.value.length)})');
    }
    return sqlSelectRaw(
      sb.toString(),
      m.entries.expand((c) => c.value.map(c.key.databaseSaveMutator)).toList(),
    );
  }

  /// insert `dart` [T] objects, which not founded in table
  /// return in [MapEntry.key] - count of added rows
  ///
  ///- [selectors] - columns where need to search haved data
  ///- [returnAdded] - if this `true` returns all copies of [data] added to
  /// table after insert, else return only added rows of [data]
  ///- [returnFulls] - if this `true` returns all copies of [data] contained in
  /// table after insert, else return only added rows of [data]
  /// return in [MapEntry.key] - count of added rows
  MapEntry<int, List<T>> sqlInsertNewsUnqiueValues(
    List<T> data,
    List<DatabaseColumn> selectors, {
    bool returnAdded = false,
    bool returnFulls = false,
  }) {
    final m = sqlInsertNewsUnqiueValuesRaw(
      data.map(dartDecodeRaw).toList(),
      selectors,
      returnAdded: returnAdded,
      returnFulls: returnFulls,
    );
    return MapEntry(m.key, m.value.map(dartEncodeRaw).toList());
  }

  /// insert `raw` values, which not founded in table,
  /// return in [MapEntry.key] - count of added rows
  ///
  ///- [selectors] - columns where need to search haved data
  ///- [returnAdded] - if this `true` returns all copies of [data] added to
  /// table after insert, else return only added rows of [data]
  ///- [returnFulls] - if this `true` returns all copies of [data] contained in
  /// table after insert, else return only added rows of [data]
  MapEntry<int, List<List>> sqlInsertNewsUnqiueValuesRaw(
    List<List> data,
    List<DatabaseColumn> selectors, {
    bool returnAdded = false,
    bool returnFulls = false,
  }) {
    final sb = StringBuffer('WHERE ');
    final l = data.length;
    final e = selectors.first;
    final binds = 'IN (${sqlQueryRowBindings(l)})';
    sb.write('${e.name} $binds');
    for (final e in selectors.skip(1)) {
      sb.write(' AND ${e.name} $binds');
    }
    final str = sb.toString();
    final bindsVals = [];
    final datas = data.map(rowEncodeRaw).toList();
    for (final i in selectors) {
      final c = columns.indexOf(i);
      bindsVals.addAll(datas.map((e) => e[c]));
    }
    final contains = sqlSelectRaw(str, bindsVals);
    final added = data.toList()
      ..removeWhere(
        (d) => selectors.every(
          (i) {
            final k = columns.indexOf(i);
            return contains.any(
              (c) => d[k] == c[k],
            );
          },
        ),
      );
    sqlInsertRaw(added);
    if (returnFulls) {
      return MapEntry(
        added.length,
        sqlSelectRaw(str, bindsVals).toList(),
      );
    }
    if (returnAdded) {
      final sb = StringBuffer('WHERE ');
      final l = added.length;
      final e = selectors.first;
      final binds = 'IN (${sqlQueryRowBindings(l)})';
      sb.write('${e.name} $binds');
      for (final e in selectors.skip(1)) {
        sb.write(' AND ${e.name} $binds');
      }
      final str = sb.toString();
      final bindsVals = [];
      final datas = added.map(rowEncodeRaw).toList();
      for (final i in selectors) {
        final c = columns.indexOf(i);
        bindsVals.addAll(datas.map((e) => e[c]));
      }
      final contains = sqlSelectRaw(str, bindsVals);
      return MapEntry(l, contains.toList());
    }
    return MapEntry(added.length, []);
  }
}
