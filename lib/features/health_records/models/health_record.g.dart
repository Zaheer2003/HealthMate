// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthRecordAdapter extends TypeAdapter<HealthRecord> {
  @override
  final int typeId = 1;

  @override
  HealthRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthRecord(
      id: fields[0] as int?,
      date: fields[1] as DateTime,
      steps: fields[2] as int,
      calories: fields[3] as int,
      water: fields[4] as int,
      goalSteps: fields[5] as int?,
      goalCalories: fields[6] as int?,
      goalWater: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, HealthRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.steps)
      ..writeByte(3)
      ..write(obj.calories)
      ..writeByte(4)
      ..write(obj.water)
      ..writeByte(5)
      ..write(obj.goalSteps)
      ..writeByte(6)
      ..write(obj.goalCalories)
      ..writeByte(7)
      ..write(obj.goalWater);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
