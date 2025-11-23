
import 'package:flutter/foundation.dart';
import 'package:student_records_app/features/health_records/services/i_database_service.dart'; // Updated import
import 'package:student_records_app/features/health_records/services/hive_database_service.dart'; // Updated import
import 'package:student_records_app/features/health_records/services/sqflite_database_service.dart'; // Updated import

IDatabaseService getDatabaseService() {
  if (kIsWeb) {
    return HiveDatabaseService();
  } else {
    return SqfliteDatabaseService();
  }
}
