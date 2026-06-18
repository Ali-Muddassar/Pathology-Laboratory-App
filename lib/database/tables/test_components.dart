import 'package:drift/drift.dart';
import 'tests.dart';

class TestComponents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get parentTestId => integer().references(Tests, #id)();
  TextColumn get name => text()();
  TextColumn get unit => text().nullable()();
  RealColumn get minRange => real().nullable()();
  RealColumn get maxRange => real().nullable()();
  BoolColumn get isQualitative => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
