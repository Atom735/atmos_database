import 'package:meta/meta.dart';

@immutable
class DataRef implements Comparable<DataRef> {
  const DataRef(this.id, this.idA, this.idB);
  const DataRef.v(this.idA, this.idB) : id = 0;

  /// Айди записи
  final int id;

  /// Айди первой таблицы
  final int idA;

  /// Айди второй таблицы
  final int idB;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DataRef &&
        other.id == id &&
        other.idA == idA &&
        other.idB == idB;
  }

  @override
  int get hashCode => id.hashCode ^ idA.hashCode ^ idB.hashCode;

  @override
  int compareTo(DataRef other) {
    final i = idA.compareTo(other.idA);
    if (i != 0) return i;
    return idB.compareTo(idB);
  }

  @override
  String toString() => 'DataRef(id: $id, idA: $idA, idB: $idB)';
}
