
import 'package:health_mate/features/health_records/services/i_database_service.dart';
import 'package:health_mate/features/health_records/services/sqflite_database_service.dart';

IDatabaseService getDatabaseService() {
  return SqfliteDatabaseService();
}
