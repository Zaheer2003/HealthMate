
import 'package:hive/hive.dart';

part 'health_record.g.dart';

@HiveType(typeId: 1)
class HealthRecord {
  @HiveField(0)
  int? id;
  @HiveField(1)
  DateTime date;
  @HiveField(2)
  int steps;
  @HiveField(3)
  int calories;
  @HiveField(4)
  int water; // in ml
  @HiveField(5)
  int? goalSteps; // Optional daily steps goal
  @HiveField(6)
  int? goalCalories; // Optional daily calories goal
  @HiveField(7)
  int? goalWater; // Optional daily water goal

  HealthRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
    this.goalSteps,
    this.goalCalories,
    this.goalWater,
  });
}
