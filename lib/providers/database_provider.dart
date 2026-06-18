import 'package:riverpod/riverpod.dart';
import '../database/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
