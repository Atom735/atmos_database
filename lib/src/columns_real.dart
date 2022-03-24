import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import 'database_column.dart';

/// Declaring column who contain blob value, must to be const
@immutable
abstract class DatabaseColumnRealBase<T> extends DatabaseColumn<T, double> {
  @literal
  const DatabaseColumnRealBase(
    String name, {
    String constraints = 'NOT NULL',
    bool unique = false,
    bool indexed = false,
  }) : super(
          name,
          'REAL',
          constraints: constraints,
          unique: unique,
          indexed: indexed,
        );

  @override
  double binRead(BinaryReader reader) => reader.readFloat64();

  @override
  void binWrite(double value, BinaryWriter writer) =>
      writer.writeFloat64(value);

  @override
  double jsonDecode(Object? value) => (value as num).toDouble();

  @override
  Object? jsonEncode(double value) => value;

  @override
  double? databaseSaveMutator(double value) => value;

  @override
  double databaseLoadMutator(double? value) => value ?? 0;
}

/// Declaring column who contain [double] directly from dart value,
/// must to be const
@immutable
class DatabaseColumnReal extends DatabaseColumnRealBase<double> {
  @literal
  const DatabaseColumnReal(
    String name, {
    bool unique = false,
    bool indexed = false,
  }) : super(
          name,
          unique: unique,
          indexed: indexed,
        );

  @override
  double dartDecode(double value) => value;

  @override
  double dartEncode(double value) => value;
}
