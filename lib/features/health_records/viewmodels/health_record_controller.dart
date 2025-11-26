
import 'package:flutter/material.dart'; // Import for ChangeNotifier
import 'package:health_mate/features/health_records/models/health_record.dart'; // Updated import
import 'package:health_mate/features/health_records/services/i_database_service.dart'; // Updated import
import 'package:health_mate/features/health_records/services/database_service_factory.dart'; // Updated import
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class HealthRecordController extends ChangeNotifier {
  static final HealthRecordController _instance = HealthRecordController._internal();
  factory HealthRecordController() => _instance;
  HealthRecordController._internal();

  final IDatabaseService _databaseService = getDatabaseService();
  List<HealthRecord> _healthRecords = [];

  // Default goals
  int _defaultGoalSteps = 10000;
  int _defaultGoalCalories = 500;
  int _defaultGoalWater = 2000; // ml

  List<HealthRecord> get healthRecords => _healthRecords;
  int get defaultGoalSteps => _defaultGoalSteps;
  int get defaultGoalCalories => _defaultGoalCalories;
  int get defaultGoalWater => _defaultGoalWater;

  Future<void> init() async {
    await _databaseService.init();
    await _loadGoals(); // Load goals from SharedPreferences
    await _loadHealthRecords(); // Load initial data

    // Add dummy data if the database is empty
    if (_healthRecords.isEmpty) {
      _addDummyData();
    }
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    _defaultGoalSteps = prefs.getInt('goalSteps') ?? 10000;
    _defaultGoalCalories = prefs.getInt('goalCalories') ?? 500;
    _defaultGoalWater = prefs.getInt('goalWater') ?? 2000;
    notifyListeners();
  }

  Future<void> setGoalSteps(int steps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('goalSteps', steps);
    _defaultGoalSteps = steps;
    notifyListeners();
  }

  Future<void> setGoalCalories(int calories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('goalCalories', calories);
    _defaultGoalCalories = calories;
    notifyListeners();
  }

  Future<void> setGoalWater(int water) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('goalWater', water);
    _defaultGoalWater = water;
    notifyListeners();
  }

  Future<void> _loadHealthRecords() async {
    _healthRecords = await _databaseService.getHealthRecords();
    notifyListeners();
  }

  Future<int> addHealthRecord(HealthRecord record) async {
    // Assign current default goals if not explicitly set in the record
    final recordWithGoals = HealthRecord(
      id: record.id,
      date: record.date,
      steps: record.steps,
      calories: record.calories,
      water: record.water,
      goalSteps: record.goalSteps ?? _defaultGoalSteps,
      goalCalories: record.goalCalories ?? _defaultGoalCalories,
      goalWater: record.goalWater ?? _defaultGoalWater,
    );
    final id = await _databaseService.addHealthRecord(recordWithGoals);
    await _loadHealthRecords(); // Reload and notify
    return id;
  }

  Future<List<HealthRecord>> getHealthRecords() async {
    return _healthRecords; // Return from cached list
  }

  Future<int> updateHealthRecord(HealthRecord record) async {
    // Ensure goal fields are not null when updating
    final recordWithGoals = HealthRecord(
      id: record.id,
      date: record.date,
      steps: record.steps,
      calories: record.calories,
      water: record.water,
      goalSteps: record.goalSteps ?? _defaultGoalSteps, // Use current default if not provided
      goalCalories: record.goalCalories ?? _defaultGoalCalories,
      goalWater: record.goalWater ?? _defaultGoalWater,
    );
    final result = await _databaseService.updateHealthRecord(recordWithGoals);
    await _loadHealthRecords(); // Reload and notify
    return result;
  }

  Future<int> deleteHealthRecord(int id) async {
    final result = await _databaseService.deleteHealthRecord(id);
    await _loadHealthRecords(); // Reload and notify
    return result;
  }

  Future<int> getHealthRecordsCount() async {
    return _healthRecords.length; // Return count from cached list
  }

  Future<void> _addDummyData() async {
    final now = DateTime.now();
    final dummyRecords = [
      HealthRecord(date: now.subtract(Duration(days: 2)), steps: 5000, calories: 300, water: 1500, goalSteps: _defaultGoalSteps, goalCalories: _defaultGoalCalories, goalWater: _defaultGoalWater),
      HealthRecord(date: now.subtract(Duration(days: 1)), steps: 7500, calories: 450, water: 2000, goalSteps: _defaultGoalSteps, goalCalories: _defaultGoalCalories, goalWater: _defaultGoalWater),
      HealthRecord(date: now, steps: 10000, calories: 600, water: 2500, goalSteps: _defaultGoalSteps, goalCalories: _defaultGoalCalories, goalWater: _defaultGoalWater),
    ];

    for (var record in dummyRecords) {
      await _databaseService.addHealthRecord(record);
    }
    await _loadHealthRecords(); // Reload after adding dummy data
  }
}
