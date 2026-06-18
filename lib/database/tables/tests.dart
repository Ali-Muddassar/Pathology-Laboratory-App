import 'package:drift/drift.dart';

class Tests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get shortName => text().nullable()();
  TextColumn get unit => text().nullable()();
  RealColumn get minRange => real().nullable()();
  RealColumn get maxRange => real().nullable()();
  RealColumn get price => real()();
  BoolColumn get isQualitative => boolean().withDefault(const Constant(false))();
  TextColumn get type => text().withDefault(const Constant('simple'))(); // 'simple', 'panel', 'detailed'
  IntColumn get createdAt => integer()();
}
