import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout_models.dart';

class StorageManager {
  static const String _templatesBoxName = 'templates';
  static const String _sessionsBoxName = 'sessions';
  static const String _exercisesBoxName = 'exercises';
  static const String _setsBoxName = 'sets';
  static const String _restLogsBoxName = 'rest_logs';
  static const String _plansBoxName = 'plans';

  static late Box<WorkoutTemplate> _templatesBox;
  static late Box<WorkoutSession> _sessionsBox;
  static late Box<Exercise> _exercisesBox;
  static late Box<ExerciseSet> _setsBox;
  static late Box<RestLog> _restLogsBox;
  static late Box<WorkoutPlan> _plansBox;

  /// Initialize Hive and open boxes
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(WorkoutTemplateAdapter());
    Hive.registerAdapter(TemplateExerciseAdapter());
    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(WorkoutSessionAdapter());
    Hive.registerAdapter(WorkoutPlanAdapter());
    Hive.registerAdapter(ExerciseSetAdapter());
    Hive.registerAdapter(RestLogAdapter());

    // Open boxes
    _templatesBox = await Hive.openBox<WorkoutTemplate>(_templatesBoxName);
    _sessionsBox = await Hive.openBox<WorkoutSession>(_sessionsBoxName);
    _exercisesBox = await Hive.openBox<Exercise>(_exercisesBoxName);
    _setsBox = await Hive.openBox<ExerciseSet>(_setsBoxName);
    _restLogsBox = await Hive.openBox<RestLog>(_restLogsBoxName);
    _plansBox = await Hive.openBox<WorkoutPlan>(_plansBoxName);

    // Initial sync from iCloud
    await _syncFromCloud();
  }

  /// Check if iCloud is available
  static Future<bool> isCloudAvailable() async {
    // TODO: Implement iCloud availability check when container is configured
    // For now, return false to use local storage only
    return false;
  }

  /// Sync data from iCloud to local storage
  static Future<void> _syncFromCloud() async {
    // TODO: Implement iCloud sync when container is properly configured
    // For now, we'll work with local storage only
  }

  /// Sync data to iCloud
  static Future<void> _syncToCloud() async {
    // TODO: Implement iCloud sync when container is properly configured
    // For now, we'll work with local storage only
  }

  // Template operations
  static Future<List<WorkoutTemplate>> getTemplates() async {
    await _syncFromCloud(); // Try to get latest from cloud
    return _templatesBox.values.toList();
  }

  static Future<void> saveTemplate(WorkoutTemplate template) async {
    template.updatedAt = DateTime.now();
    await _templatesBox.put(template.id, template);
    await _syncToCloud();
  }

  static Future<void> deleteTemplate(String id) async {
    await _templatesBox.delete(id);
    await _syncToCloud();
  }

  // Session operations
  static Future<List<WorkoutSession>> getSessions() async {
    await _syncFromCloud();
    return _sessionsBox.values.toList();
  }

  static Future<void> saveSession(WorkoutSession session) async {
    session.updatedAt = DateTime.now();  
    await _sessionsBox.put(session.id, session);
    await _syncToCloud();
  }

  // Exercise operations
  static Future<List<Exercise>> getExercises() async {
    await _syncFromCloud();
    return _exercisesBox.values.toList();
  }

  static Future<void> saveExercise(Exercise exercise) async {
    await _exercisesBox.put(exercise.id, exercise);
    await _syncToCloud();
  }

  // Set operations
  static Future<List<ExerciseSet>> getSets({String? sessionId}) async {
    await _syncFromCloud();
    final allSets = _setsBox.values.toList();
    if (sessionId != null) {
      return allSets.where((set) => set.sessionId == sessionId).toList();
    }
    return allSets;
  }

  static Future<void> saveSet(ExerciseSet set) async {
    await _setsBox.put(set.id, set);
    await _syncToCloud();
  }

  // Rest log operations
  static Future<List<RestLog>> getRestLogs({String? sessionId}) async {
    await _syncFromCloud();
    final allLogs = _restLogsBox.values.toList();
    if (sessionId != null) {
      return allLogs.where((log) => log.sessionId == sessionId).toList();
    }
    return allLogs;
  }

  static Future<void> saveRestLog(RestLog restLog) async {
    await _restLogsBox.put(restLog.id, restLog);
    await _syncToCloud();
  }

  // Workout plan operations
  static Future<List<WorkoutPlan>> getPlans() async {
    await _syncFromCloud();
    return _plansBox.values.toList();
  }

  static Future<void> savePlan(WorkoutPlan plan) async {
    plan.updatedAt = DateTime.now();
    await _plansBox.put(plan.id, plan);
    await _syncToCloud();
  }

  // TODO: Implement cloud sync helper methods when iCloud container is configured
}