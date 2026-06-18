import 'package:drift/drift.dart';
import 'patients.dart';

class LabOrders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderId => text()();
  IntColumn get patientId => integer().references(Patients, #id)();
  IntColumn get orderDate => integer()();
  TextColumn get status => text()();
  RealColumn get totalAmount => real()();
  TextColumn get paymentStatus => text()();
  IntColumn get createdAt => integer()();
}
