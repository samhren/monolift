import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_models.dart';
import '../services/storage_manager.dart';

class CalendarProvider extends ChangeNotifier {
  List<WorkoutPlan> _plans = [];
  List<WorkoutSession> _sessions = [];
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  bool _loading = false;

  List<WorkoutPlan> get plans => _plans;
  List<WorkoutSession> get sessions => _sessions;
  DateTime get selectedDate => _selectedDate;
  DateTime get focusedDate => _focusedDate;
  bool get loading => _loading;

  /// Load plans and sessions from storage
  Future<void> refreshData() async {
    try {
      _loading = true;
      notifyListeners();
      
      final loadedPlans = await StorageManager.getPlans();
      final loadedSessions = await StorageManager.getSessions();
      
      _plans = loadedPlans;
      _sessions = loadedSessions;
    } catch (error) {
      print('Failed to load calendar data: $error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Set focused date
  void setFocusedDate(DateTime date) {
    _focusedDate = date;
    notifyListeners();
  }

  /// Get plans for a specific date
  List<WorkoutPlan> getPlansForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return _plans.where((plan) {
      final planDateOnly = DateTime(
        plan.plannedDate.year,
        plan.plannedDate.month,
        plan.plannedDate.day,
      );
      return planDateOnly.isAtSameMomentAs(dateOnly);
    }).toList();
  }

  /// Get sessions for a specific date
  List<WorkoutSession> getSessionsForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return _sessions.where((session) {
      final sessionDateOnly = DateTime(
        session.startedAt.year,
        session.startedAt.month,
        session.startedAt.day,
      );
      return sessionDateOnly.isAtSameMomentAs(dateOnly);
    }).toList();
  }

  /// Check if a date has any workouts
  bool hasWorkoutsOnDate(DateTime date) {
    return getPlansForDate(date).isNotEmpty || getSessionsForDate(date).isNotEmpty;
  }

  /// Add a workout plan
  Future<void> addPlan({
    required DateTime plannedDate,
    String? templateId,
  }) async {
    final now = DateTime.now();
    final plan = WorkoutPlan(
      id: const Uuid().v4(),
      templateId: templateId,
      plannedDate: plannedDate,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    await StorageManager.savePlan(plan);
    await refreshData();
  }

  /// Complete a workout plan (link it to a session)
  Future<void> completePlan(String planId, String sessionId) async {
    final plan = _plans.firstWhere((p) => p.id == planId);
    plan.isCompleted = true;
    plan.sessionId = sessionId;
    plan.updatedAt = DateTime.now();

    await StorageManager.savePlan(plan);
    await refreshData();
  }

  /// Delete a workout plan
  Future<void> deletePlan(String planId) async {
    // Note: This would need to be implemented in StorageManager
    // For now, we'll filter it out locally
    _plans.removeWhere((plan) => plan.id == planId);
    notifyListeners();
  }
}