import 'package:atmos_database/atmos_database.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  test('table refs ...', () async {
    final sql = sqlite3.openInMemory()..execute('PRAGMA foreign_keys = ON;');
    final tableA = DatabaseTableDict(sql, 'testDict')
      ..sqlCreate()
      ..addValues(['Hello', 'World'])
      ..addValues(['Hello', 'World', 'Dear', 'Friend']);
    final tableRefs = DatabaseTableRefs(
      sql,
      'testRefs',
      columnA: DatabaseColumnRef('idA', tableA.name),
      columnB: DatabaseColumnRef('idB', tableA.name),
    )
      ..sqlCreate()
      ..addValues([DataRef.v(1, 1), DataRef.v(1, 2), DataRef.v(1, 3)]);

    print(tableRefs.getByA([1]).toList());
    tableRefs.addValues([DataRef.v(0, 0), DataRef.v(1, 2), DataRef.v(1, 1)]);
    print(tableRefs.getByA([0, 1]).toList());
    print(tableRefs.sqlSelectCount());

    tableRefs.sql.dispose();
    tableA.sql.dispose();
  });
}
