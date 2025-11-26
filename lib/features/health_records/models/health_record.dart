
class HealthRecord {
  int? id;
  DateTime date;
  int steps;
  int calories;
  int water; // in ml
  int? goalSteps; // Optional daily steps goal
  int? goalCalories; // Optional daily calories goal
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'steps': steps,
      'calories': calories,
      'water': water,
      'goalSteps': goalSteps,
      'goalCalories': goalCalories,
      'goalWater': goalWater,
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      date: DateTime.parse(map['date']),
      steps: map['steps'],
      calories: map['calories'],
      water: map['water'],
      goalSteps: map['goalSteps'],
      goalCalories: map['goalCalories'],
      goalWater: map['goalWater'],
    );
  }
}
