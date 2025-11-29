
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:health_mate/features/health_records/services/i_database_service.dart';
import 'package:health_mate/features/health_records/services/sqflite_database_service.dart';
import 'package:health_mate/features/health_records/services/in_memory_database_service.dart';

IDatabaseService getDatabaseService() {
  if (kIsWeb) {
    return InMemoryDatabaseService();
  } else {
    return SqfliteDatabaseService();
  }
}

