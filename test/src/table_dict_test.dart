import 'package:atmos_database/atmos_database.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  test('table dict ...', () async {
    final sql = sqlite3.openInMemory();
    final table = DatabaseTableDict(sql, 'testDict')
      ..sqlCreate()
      ..addValues(['Hello', 'World'])
      ..addValues(['Hello', 'World', 'Dear', 'Friend'])
      ..addValues(['Hello World', 'Dear Friend', 'Hello Friend', 'Hello Dear']);
    print(table.getValuesContained(['Hello', 'Friend']).toList());
    print(table.getValuesContained(['Friend', 'Hello Dear']).toList());
    print(table.getValuesSearch().toList());
    print(table
        .getValuesSearch(order: DatabaseTableDictOrderType.value)
        .toList());
    print(table
        .getValuesSearch(
            searchPattern: 'Hello', order: DatabaseTableDictOrderType.bm25)
        .toList());

    table.sql.dispose();
  });
}
