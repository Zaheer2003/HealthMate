
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:health_mate/features/health_records/models/health_record.dart'; // Updated import
import 'i_database_service.dart';

class SqfliteDatabaseService implements IDatabaseService {
  static Database? _database;

  @override
  Future<void> init() async {
    if (_database != null) return;
    _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'health_records.db'); // New database name
    return await openDatabase(
      path,
      version: 2, // Increment version for schema change
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Add onUpgrade callback
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE health_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date INTEGER,
        steps INTEGER,
        calories INTEGER,
        water INTEGER,
        goalSteps INTEGER,
        goalCalories INTEGER,
        goalWater INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop existing table and recreate it with new schema
      await db.execute('DROP TABLE IF EXISTS health_records');
      await _onCreate(db, newVersion);
    }
  }

  @override
  Future<int> addHealthRecord(HealthRecord record) async {
    Database db = await _database!;
    return await db.insert('health_records', record.toMap());
  }

  @override
  Future<List<HealthRecord>> getHealthRecords() async {
    Database db = await _database!;
    final List<Map<String, dynamic>> maps = await db.query('health_records');
    return List.generate(maps.length, (i) {
      return HealthRecord.fromMap(maps[i]);
    });
  }

  @override
  Future<int> updateHealthRecord(HealthRecord record) async {
    Database db = await _database!;
    return await db.update('health_records', record.toMap(), where: 'id = ?', whereArgs: [record.id]);
  }

  @override
  Future<int> deleteHealthRecord(int id) async {
    Database db = await _database!;
    return await db.delete('health_records', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> getHealthRecordsCount() async {
    Database db = await _database!;
    final result = await db.rawQuery('SELECT COUNT(*) FROM health_records');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
