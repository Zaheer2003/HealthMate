
import 'package:health_mate/features/health_records/models/health_record.dart'; // Updated import

abstract class IDatabaseService {
  Future<void> init();
  Future<int> addHealthRecord(HealthRecord record);
  Future<List<HealthRecord>> getHealthRecords();
  Future<int> updateHealthRecord(HealthRecord record);
  Future<int> deleteHealthRecord(int id);
  Future<int> getHealthRecordsCount();
}
