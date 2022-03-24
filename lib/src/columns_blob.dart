import 'dart:convert';
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import 'database_column.dart';

/// Declaring column who contain blob value, must to be const
@immutable
abstract class DatabaseColumnBlobBase<T> extends DatabaseColumn<T, Uint8List> {
  @literal
  const DatabaseColumnBlobBase(
    String name, {
    String constraints = 'NOT NULL',
    bool unique = false,
    bool indexed = false,
  }) : super(
          name,
          'BLOB',
          constraints: constraints,
          unique: unique,
          indexed: indexed,
        );

  @override
  Uint8List binRead(BinaryReader reader) => reader.readListUint8();

  @override
  void binWrite(Uint8List value, BinaryWriter writer) =>
      writer.writeListUint8(value);

  @override
  Uint8List jsonDecode(Object? value) => base64Decode(value as String);

  @override
  Object? jsonEncode(Uint8List value) => base64Encode(value);

  static final _emptyList = Uint8List(0);

  @override
  Uint8List databaseLoadMutator(Uint8List? value) => value ?? _emptyList;
}

/// Declaring column who contain bytes directly from dart value, must to be const
///
/// in Json represent like [base64] string
@immutable
class DatabaseColumnBlob extends DatabaseColumnBlobBase<Uint8List> {
  @literal
  const DatabaseColumnBlob(
    String name, {
    bool unique = false,
    bool indexed = false,
  }) : super(
          name,
          unique: unique,
          indexed: indexed,
        );

  @override
  Uint8List dartDecode(Uint8List value) => value;

  @override
  Uint8List dartEncode(Uint8List value) => value;
}
