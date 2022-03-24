// ignore_for_file: avoid_print

import 'package:atmos_database/src/data_string.dart';
import 'package:atmos_database/src/table_dict.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  test('database table sql ext 1...', () async {
    final sql = sqlite3.openInMemory();
    final table = DatabaseTableDict(sql, 'testDict')
      ..sqlCreate()
      ..sqlInsert(['Hello', 'World'].map(DataString.v));

    final news = table.sqlInsertNewsUnqiueValues(
      ['Hello', 'World', 'Dear', 'Friend'].map(DataString.v).toList(),
      [table.columnValue],
      returnAdded: true,
    );
    print(news.value.map((e) => '${e.id} = ${e.value}').toList());
    table.sql.dispose();
  });

  test('database table sql ext 2...', () async {
    final sql = sqlite3.openInMemory();
    final table = DatabaseTableDict(sql, 'testDict')
      ..sqlCreate()
      ..sqlInsert(['Hello', 'World'].map(DataString.v));

    final news = table.sqlInsertNewsUnqiueValues(
      ['Hello', 'Dear', 'Friend'].map(DataString.v).toList(),
      [table.columnValue],
      returnFulls: true,
    );
    print(news.value.map((e) => '${e.id} = ${e.value}').toList());
    table.sql.dispose();
  });

  test('database table sql ext 3...', () async {
    final sql = sqlite3.openInMemory();
    final table = DatabaseTableDict(sql, 'testDict')
      ..sqlCreate()
      ..sqlInsert(['abc', 'abd', 'bcd'].map(DataString.v));

    print(table.sqlSelectCountFts('WHERE ${table.nameFts} = ?', ['ab*']));
    table.sql.dispose();
  });
}
