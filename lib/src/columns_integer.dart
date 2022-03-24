import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import 'database_column.dart';

final _sw = Stopwatch()..start();
final _swBegins = DateTime.now().toUtc().microsecondsSinceEpoch;

/// Gets unique timestamp for now (microsecondsSinceEpoch)
int getTimestamp() => _swBegins + _sw.elapsedMicroseconds;

/// Offset of timestamp for store data, contains micro
/// Declaring column who contain integer value, must to be const
@immutable
abstract class DatabaseColumnIntegerBase<T> extends DatabaseColumn<T, int> {
  @literal
  const DatabaseColumnIntegerBase(
    String name, {
    String constraints = 'NOT NULL',
    bool unique = false,
    bool indexed = false,
  }) : super(
          name,
          'INTEGER',
          constraints: constraints,
          unique: unique,
          indexed: indexed,
        );

  @override
  int binRead(BinaryReader reader) => reader.readPackedInt();

  @override
  void binWrite(int value, BinaryWriter writer) => writer.writePackedInt(value);

  @override
  int jsonDecode(Object? value) => value as int;

  @override
  Object? jsonEncode(int value) => value;

  @override
  int? databaseSaveMutator(int value) => value;

  @override
  int databaseLoadMutator(int? value) => value ?? 0;
}

/// Declaring column who contain unsigned integer value, must to be const
@immutable
abstract class DatabaseColumnUnsignedBase<T>
    extends DatabaseColumnIntegerBase<T> {
  @literal
  const DatabaseColumnUnsignedBase(
    String name, {
    String? constraints,
    bool unique = false,
    bool indexed = false,
  }) : super(
          name,
          constraints: constraints ?? 'NOT NULL CHECK($name >= 0)',
          unique: unique,
          indexed: indexed,
        );

  @override
  int binRead(BinaryReader reader) => reader.readSize();

  @override
  void binWrite(int value, BinaryWriter writer) => writer.writeSize(value);

  @override
  int jsonDecode(Object? value) => value as int;

  @override
  Object? jsonEncode(int value) => value;
}

/// Declaring column who contain [int] value directly from dart,
/// must to be const
@immutable
class DatabaseColumnInteger extends DatabaseColumnIntegerBase<int> {
  @literal
  const DatabaseColumnInteger(
    String name, {
    bool unique = false,
    bool indexed = false,
  }) : super(
          name,
          unique: unique,
          indexed: indexed,
        );

  @override
  int dartDecode(int value) => value;

  @override
  int dartEncode(int value) => value;
}

/// Declaring column who contain [int] value directly from dart,
/// must to be const
@immutable
class DatabaseColumnUnsigned extends DatabaseColumnUnsignedBase<int> {
  @literal
  const DatabaseColumnUnsigned(
    String name, {
    bool unique = false,
    bool indexed = false,
  }) : super(
          name,
          unique: unique,
          indexed: indexed,
        );

  @override
  int dartDecode(int value) => value;

  @override
  int dartEncode(int value) => value;
}

/// Declaring column who contain [DateTime] value directly from dart,
/// must to be const
@immutable
class DatabaseColumnDateTimeInt extends DatabaseColumnIntegerBase<DateTime> {
  @literal
  const DatabaseColumnDateTimeInt(
    String name, {
    bool unique = false,
    bool indexed = false,
    this.microseconds = false,
  }) : super(
          name,
          unique: unique,
          indexed: indexed,
        );

  /// is save data microseconds like
  final bool microseconds;

  @override
  int dartDecode(DateTime value) => microseconds
      ? value.toUtc().microsecondsSinceEpoch
      : value.toUtc().millisecondsSinceEpoch;

  @override
  DateTime dartEncode(int value) => microseconds
      ? DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
      : DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
}

/// Declaring column who contain [DateTime] timestamp value directly from dart,
/// must be unique value in column,
/// `indexed`,
/// must to be const
///
/// if paste 0 from Unix epoch, they generate new value when convert to table
@immutable
class DatabaseColumnTimestampDateTime
    extends DatabaseColumnUnsignedBase<DateTime> {
  @literal
  const DatabaseColumnTimestampDateTime(
    String name, {
    bool indexed = true,
  }) : super(
          name,
          unique: true,
          indexed: indexed,
        );

  @override
  int dartDecode(DateTime value) => value.toUtc().microsecondsSinceEpoch;

  @override
  DateTime dartEncode(int value) =>
      DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);

  @override
  int? databaseSaveMutator(int value) => value == 0 ? getTimestamp() : value;
}

/// Declaring column who contain [int] timestamp microseconds with offset,
/// must be unique value in column,
/// `indexed`,
/// must to be const
///
/// if paste 0 from Unix epoch, they generate new value when convert to table
@immutable
class DatabaseColumnTimestamp extends DatabaseColumnUnsigned {
  @literal
  const DatabaseColumnTimestamp(
    String name, {
    bool indexed = true,
  }) : super(
          name,
          unique: true,
          indexed: indexed,
        );

  @override
  int? databaseSaveMutator(int value) => value == 0 ? getTimestamp() : value;
}

/// Declaring column who contain [int] primary key,
/// must be unique value in column,
/// must to be const
///
/// if paste 0, they insert new row
@immutable
class DatabaseColumnId extends DatabaseColumnUnsignedBase<int> {
  @literal
  const DatabaseColumnId(String name)
      : super(
          name,
          constraints: 'PRIMARY KEY ASC',
          unique: false,
          indexed: false,
        );

  @override
  int dartDecode(int value) => value;

  @override
  int dartEncode(int value) => value;

  @override
  int? databaseSaveMutator(int value) => value == 0 ? null : value;

  @override
  int databaseLoadMutator(int? value) => value ?? 0;
}

/// Declaring column who contain [int] reference to other table id column,
/// must to be const
///
/// if paste 0, they insert null
@immutable
class DatabaseColumnRef extends DatabaseColumnUnsignedBase<int> {
  @literal
  const DatabaseColumnRef(
    String name,
    String refTableName, {
    String refColumnName = 'ROWID',
    bool unique = true,
  }) : super(
          name,
          constraints: 'REFERENCES $refTableName($refColumnName)',
          unique: unique,
          indexed: true,
        );

  @override
  int dartDecode(int value) => value;

  @override
  int dartEncode(int value) => value;

  @override
  int? databaseSaveMutator(int value) => value == 0 ? null : value;

  @override
  int databaseLoadMutator(int? value) => value ?? 0;
}
