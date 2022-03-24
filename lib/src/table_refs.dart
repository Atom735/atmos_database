import 'package:sqlite3/sqlite3.dart';

import 'columns_integer.dart';
import 'data_ref.dart';
import 'database_table.dart';

class DatabaseTableRefs extends DatabaseTable<DataRef> {
  DatabaseTableRefs(
    Database sql,
    String name, {
    required this.columnA,
    required this.columnB,
    this.columnId = const DatabaseColumnId('rowid'),
  }) : super(sql, name, [columnId, columnA, columnB]);

  @override
  final DatabaseColumnId columnId;

  final DatabaseColumnRef columnA;

  final DatabaseColumnRef columnB;

  @override
  List dartDecode(DataRef value) => [value.id, value.idA, value.idB];

  @override
  DataRef dartEncode(List value) => DataRef(value[0], value[1], value[2]);
}
