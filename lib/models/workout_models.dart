import 'package:hive/hive.dart';

part 'workout_models.g.dart';

@HiveType(typeId: 0)
class WorkoutTemplate extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int daysPerWeek;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  late DateTime updatedAt;

  @HiveField(5)
  List<TemplateExercise>? exercises;

  @HiveField(6)
  late int colorValue; // Store Color as int value

  @HiveField(7)
  late int displayOrder; // For drag-to-reorder functionality

  @HiveField(8)
  String? groupName; // Optional group name

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.daysPerWeek,
    required this.createdAt,
    required this.updatedAt,
    this.exercises,
    required this.colorValue,
    required this.displayOrder,
    this.groupName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'daysPerWeek': daysPerWeek,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'exercises': exercises?.map((e) => e.toJson()).toList(),
      'colorValue': colorValue,
      'displayOrder': displayOrder,
      'groupName': groupName,
    };
  }

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      id: json['id'],
      name: json['name'],
      daysPerWeek: json['daysPerWeek'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      exercises: json['exercises'] != null
          ? (json['exercises'] as List)
              .map((e) => TemplateExercise.fromJson(e))
              .toList()
          : null,
      colorValue: json['colorValue'] ?? 0xFF00FFFF, // Default to cyan if not set
      displayOrder: json['displayOrder'] ?? 0, // Default to 0 if not set
      groupName: json['groupName'],
    );
  }
}

@HiveType(typeId: 1)
class TemplateExercise extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String exerciseId;

  @HiveField(2)
  late int displayOrder;

  @HiveField(3)
  late int targetSets;

  @HiveField(4)
  late int targetReps;

  TemplateExercise({
    required this.id,
    required this.exerciseId,
    required this.displayOrder,
    required this.targetSets,
    required this.targetReps,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'displayOrder': displayOrder,
      'targetSets': targetSets,
      'targetReps': targetReps,
    };
  }

  factory TemplateExercise.fromJson(Map<String, dynamic> json) {
    return TemplateExercise(
      id: json['id'],
      exerciseId: json['exerciseId'],
      displayOrder: json['displayOrder'],
      targetSets: json['targetSets'],
      targetReps: json['targetReps'],
    );
  }
}

@HiveType(typeId: 2)
class Exercise extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String category;

  @HiveField(3)
  String? variantOf;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    this.variantOf,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'variantOf': variantOf,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      variantOf: json['variantOf'],
    );
  }
}

@HiveType(typeId: 3)
class WorkoutSession extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  String? templateId;

  @HiveField(2)
  late DateTime startedAt;

  @HiveField(3)
  DateTime? finishedAt;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late DateTime updatedAt;

  WorkoutSession({
    required this.id,
    this.templateId,
    required this.startedAt,
    this.finishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'startedAt': startedAt.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      templateId: json['templateId'],
      startedAt: DateTime.parse(json['startedAt']),
      finishedAt: json['finishedAt'] != null 
          ? DateTime.parse(json['finishedAt']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

@HiveType(typeId: 4)
class WorkoutPlan extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  String? templateId;

  @HiveField(2)
  late DateTime plannedDate;

  @HiveField(3)
  late bool isCompleted;

  @HiveField(4)
  String? sessionId;

  @HiveField(5)
  late DateTime createdAt;

  @HiveField(6)
  late DateTime updatedAt;

  WorkoutPlan({
    required this.id,
    this.templateId,
    required this.plannedDate,
    required this.isCompleted,
    this.sessionId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'plannedDate': plannedDate.toIso8601String(),
      'isCompleted': isCompleted,
      'sessionId': sessionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'],
      templateId: json['templateId'],
      plannedDate: DateTime.parse(json['plannedDate']),
      isCompleted: json['isCompleted'],
      sessionId: json['sessionId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

@HiveType(typeId: 5)
class ExerciseSet extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String sessionId;

  @HiveField(2)
  late String exerciseId;

  @HiveField(3)
  late int setIndex;

  @HiveField(4)
  late int reps;

  @HiveField(5)
  late double load;

  @HiveField(6)
  late bool isPartial;

  @HiveField(7)
  int? dropsetOfIndex;

  ExerciseSet({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setIndex,
    required this.reps,
    required this.load,
    required this.isPartial,
    this.dropsetOfIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'exerciseId': exerciseId,
      'setIndex': setIndex,
      'reps': reps,
      'load': load,
      'isPartial': isPartial,
      'dropsetOfIndex': dropsetOfIndex,
    };
  }

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      id: json['id'],
      sessionId: json['sessionId'],
      exerciseId: json['exerciseId'],
      setIndex: json['setIndex'],
      reps: json['reps'],
      load: json['load'].toDouble(),
      isPartial: json['isPartial'],
      dropsetOfIndex: json['dropsetOfIndex'],
    );
  }
}

@HiveType(typeId: 6)
class RestLog extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String sessionId;

  @HiveField(2)
  late int setIndex;

  @HiveField(3)
  late int seconds;

  RestLog({
    required this.id,
    required this.sessionId,
    required this.setIndex,
    required this.seconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'setIndex': setIndex,
      'seconds': seconds,
    };
  }

  factory RestLog.fromJson(Map<String, dynamic> json) {
    return RestLog(
      id: json['id'],
      sessionId: json['sessionId'],
      setIndex: json['setIndex'],
      seconds: json['seconds'],
    );
  }
}