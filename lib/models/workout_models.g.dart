// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutTemplateAdapter extends TypeAdapter<WorkoutTemplate> {
  @override
  final int typeId = 0;

  @override
  WorkoutTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutTemplate(
      id: fields[0] as String,
      name: fields[1] as String,
      daysPerWeek: fields[2] as int,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      exercises: (fields[5] as List?)?.cast<TemplateExercise>(),
      colorValue: fields[6] as int,
      displayOrder: fields[7] as int,
      groupName: fields[8] as String?,
      weekdays: (fields[9] as List?)?.cast<int>(),
      isActive: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutTemplate obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.daysPerWeek)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.exercises)
      ..writeByte(6)
      ..write(obj.colorValue)
      ..writeByte(7)
      ..write(obj.displayOrder)
      ..writeByte(8)
      ..write(obj.groupName)
      ..writeByte(9)
      ..write(obj.weekdays)
      ..writeByte(10)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TemplateExerciseAdapter extends TypeAdapter<TemplateExercise> {
  @override
  final int typeId = 1;

  @override
  TemplateExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TemplateExercise(
      id: fields[0] as String,
      exerciseId: fields[1] as String,
      displayOrder: fields[2] as int,
      targetSets: fields[3] as int,
      targetReps: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TemplateExercise obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exerciseId)
      ..writeByte(2)
      ..write(obj.displayOrder)
      ..writeByte(3)
      ..write(obj.targetSets)
      ..writeByte(4)
      ..write(obj.targetReps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 2;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      variantOf: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.variantOf);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutSessionAdapter extends TypeAdapter<WorkoutSession> {
  @override
  final int typeId = 3;

  @override
  WorkoutSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSession(
      id: fields[0] as String,
      templateId: fields[1] as String?,
      startedAt: fields[2] as DateTime,
      finishedAt: fields[3] as DateTime?,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSession obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.templateId)
      ..writeByte(2)
      ..write(obj.startedAt)
      ..writeByte(3)
      ..write(obj.finishedAt)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutPlanAdapter extends TypeAdapter<WorkoutPlan> {
  @override
  final int typeId = 4;

  @override
  WorkoutPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutPlan(
      id: fields[0] as String,
      templateId: fields[1] as String?,
      plannedDate: fields[2] as DateTime,
      isCompleted: fields[3] as bool,
      sessionId: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutPlan obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.templateId)
      ..writeByte(2)
      ..write(obj.plannedDate)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.sessionId)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseSetAdapter extends TypeAdapter<ExerciseSet> {
  @override
  final int typeId = 5;

  @override
  ExerciseSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseSet(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      exerciseId: fields[2] as String,
      setIndex: fields[3] as int,
      reps: fields[4] as int,
      load: fields[5] as double,
      isPartial: fields[6] as bool,
      dropsetOfIndex: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseSet obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.exerciseId)
      ..writeByte(3)
      ..write(obj.setIndex)
      ..writeByte(4)
      ..write(obj.reps)
      ..writeByte(5)
      ..write(obj.load)
      ..writeByte(6)
      ..write(obj.isPartial)
      ..writeByte(7)
      ..write(obj.dropsetOfIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RestLogAdapter extends TypeAdapter<RestLog> {
  @override
  final int typeId = 6;

  @override
  RestLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RestLog(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      setIndex: fields[2] as int,
      seconds: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RestLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.setIndex)
      ..writeByte(3)
      ..write(obj.seconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
