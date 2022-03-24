import 'package:meta/meta.dart';

@immutable
class DataString implements Comparable<DataString> {
  const DataString(this.id, this.value);
  const DataString.v(this.value) : id = 0;

  /// Айди записи
  final int id;

  /// Значение записи
  final String value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DataString && other.id == id && other.value == value;
  }

  @override
  int get hashCode => id.hashCode ^ value.hashCode;

  @override
  int compareTo(DataString other) => value.compareTo(other.value);

  @override
  String toString() => 'DataString(id: $id, value: $value)';
}
