import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_models.dart';
import '../services/storage_manager.dart';

class WorkoutProvider extends ChangeNotifier {
  List<WorkoutTemplate> _templates = [];
  bool _loading = false;

  List<WorkoutTemplate> get templates => _templates;
  bool get loading => _loading;

  /// Load templates from storage
  Future<void> refreshTemplates() async {
    try {
      _loading = true;
      notifyListeners();
      
      final loadedTemplates = await StorageManager.getTemplates();
      _templates = loadedTemplates;
    } catch (error) {
      print('Failed to load templates: $error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Add a new template
  Future<void> addTemplate({
    required String name,
    required int daysPerWeek,
    List<TemplateExercise>? exercises,
  }) async {
    final now = DateTime.now();
    final template = WorkoutTemplate(
      id: const Uuid().v4(),
      name: name,
      daysPerWeek: daysPerWeek,
      createdAt: now,
      updatedAt: now,
      exercises: exercises,
    );

    await StorageManager.saveTemplate(template);
    await refreshTemplates();
  }

  /// Delete a template
  Future<void> deleteTemplate(String id) async {
    await StorageManager.deleteTemplate(id);
    await refreshTemplates();
  }

  /// Update an existing template
  Future<void> updateTemplate(WorkoutTemplate template) async {
    template.updatedAt = DateTime.now();
    await StorageManager.saveTemplate(template);
    await refreshTemplates();
  }

  /// Get template by ID
  WorkoutTemplate? getTemplateById(String id) {
    try {
      return _templates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }
}