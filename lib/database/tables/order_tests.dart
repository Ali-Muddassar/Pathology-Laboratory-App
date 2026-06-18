import 'package:drift/drift.dart';
import 'lab_orders.dart';
import 'tests.dart';

class OrderTests extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(LabOrders, #id)();
  IntColumn get testId => integer().references(Tests, #id)();
  TextColumn get resultValue => text().nullable()();
  BoolColumn get isAbnormal => boolean().nullable()();
  TextColumn get technicianNotes => text().nullable()();
  IntColumn get completedAt => integer().nullable()();
}
