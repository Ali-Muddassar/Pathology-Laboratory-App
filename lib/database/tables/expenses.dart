import 'package:drift/drift.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  IntColumn get date => integer()();
  TextColumn get category => text().nullable()();
}
