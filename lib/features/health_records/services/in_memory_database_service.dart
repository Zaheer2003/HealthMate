
import 'package:health_mate/features/health_records/models/health_record.dart';
import 'i_database_service.dart';

class InMemoryDatabaseService implements IDatabaseService {
  final Map<int, HealthRecord> _records = {};
  int _nextId = 1;

  @override
  Future<void> init() async {
    // No initialization needed for in-memory database
  }

  @override
  Future<int> addHealthRecord(HealthRecord record) async {
    final id = _nextId++;
    _records[id] = record.copyWith(id: id);
    return id;
  }

  @override
  Future<List<HealthRecord>> getHealthRecords() async {
    return _records.values.toList();
  }

  @override
  Future<int> updateHealthRecord(HealthRecord record) async {
    if (_records.containsKey(record.id)) {
      _records[record.id!] = record;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteHealthRecord(int id) async {
    if (_records.containsKey(id)) {
      _records.remove(id);
      return 1;
    }
    return 0;
  }

  @override
  Future<int> getHealthRecordsCount() async {
    return _records.length;
  }
}
