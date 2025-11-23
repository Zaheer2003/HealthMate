
import 'package:hive_flutter/hive_flutter.dart';
import 'package:student_records_app/features/health_records/models/health_record.dart'; // Updated import
import 'i_database_service.dart';

class HiveDatabaseService implements IDatabaseService {
  late Box<HealthRecord> _healthRecordBox;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(HealthRecordAdapter()); // Register the generated adapter for HealthRecord
    _healthRecordBox = await Hive.openBox<HealthRecord>('health_records'); // New box name
  }

  @override
  Future<int> addHealthRecord(HealthRecord record) async {
    final int id = await _healthRecordBox.add(record);
    record.id = id; // Assign the Hive-generated ID back to the health record object
    await _healthRecordBox.put(id, record); // Update the health record with its ID
    return id;
  }

  @override
  Future<List<HealthRecord>> getHealthRecords() async {
    return _healthRecordBox.values.toList();
  }

  @override
  Future<int> updateHealthRecord(HealthRecord record) async {
    if (record.id == null) {
      throw Exception("HealthRecord ID cannot be null for update operation.");
    }
    await _healthRecordBox.put(record.id!, record);
    return 1; // Hive put operation doesn't return affected rows, return 1 for success
  }

  @override
  Future<int> deleteHealthRecord(int id) async {
    await _healthRecordBox.delete(id);
    return 1; // Hive delete operation doesn't return affected rows, return 1 for success
  }

  @override
  Future<int> getHealthRecordsCount() async {
    return _healthRecordBox.length;
  }
}
