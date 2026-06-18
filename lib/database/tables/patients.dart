import 'package:drift/drift.dart';

class Patients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get gender => text()();
  IntColumn get age => integer().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get referredBy => text().nullable()();
  IntColumn get createdAt => integer()();
}
