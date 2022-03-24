import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import 'database_column.dart';

const kHighlightTextBegin = '\u{1}';
const kHighlightTextEnd = '\u{2}';

/// Returns separated strings where every odd indexed was higlights
List<String> highlightSeparateText(String text) {
  final l = <String>[];
  var i0 = 0;
  while (true) {
    final i1 = text.indexOf(kHighlightTextBegin, i0);
    if (i1 == -1) break;
    final i2 = text.indexOf(kHighlightTextEnd, i1);
    if (i2 == -1) break;
    l
      ..add(text.substring(i0, i1))
      ..add(text.substring(i1 + kHighlightTextBegin.length, i2));
    i0 = i2 + kHighlightTextEnd.length;
  }
  l.add(text.substring(i0));
  return l;
}

/// Declaring column who contain text value, must to be const
@immutable
abstract class DatabaseColumnTextBase<T> extends DatabaseColumn<T, String> {
  @literal
  const DatabaseColumnTextBase(
    String name, {
    String constraints = 'NOT NULL',
    bool unique = false,
    bool indexed = false,
    this.fts = false,
  }) : super(
          name,
          'TEXT',
          constraints: constraints,
          unique: unique,
          indexed: indexed,
        );

  /// Needs to create Fts table for this column
  final bool fts;

  @override
  String binRead(BinaryReader reader) => reader.readString();

  @override
  void binWrite(String value, BinaryWriter writer) => writer.writeString(value);

  @override
  String jsonDecode(Object? value) => value as String;

  @override
  Object? jsonEncode(String value) => value;

  @override
  String? databaseSaveMutator(String value) => value;

  @override
  String databaseLoadMutator(String? value) => value ?? '';
}

@immutable
class DatabaseColumnText extends DatabaseColumnTextBase<String> {
  @literal
  const DatabaseColumnText(
    String name, {
    bool unique = false,
    bool indexed = false,
    bool fts = false,
  }) : super(
          name,
          unique: unique,
          indexed: indexed,
          fts: fts,
        );

  @override
  String dartDecode(String value) => value;

  @override
  String dartEncode(String value) => value;
}

@immutable
class DatabaseColumnDateTimeTxt extends DatabaseColumnTextBase<DateTime> {
  @literal
  const DatabaseColumnDateTimeTxt(
    String name, {
    bool unique = false,
    bool indexed = false,
    bool fts = false,
  }) : super(
          name,
          unique: unique,
          indexed: indexed,
          fts: fts,
        );

  @override
  String dartDecode(DateTime value) => value.toIso8601String();

  @override
  DateTime dartEncode(String value) => DateTime.parse(value);
}
