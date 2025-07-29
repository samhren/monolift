import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_models.dart';
import '../services/storage_manager.dart';
import '../utils/neon_colors.dart';

class WorkoutProvider extends ChangeNotifier {
  List<WorkoutTemplate> _templates = [];
  bool _loading = false;

  List<WorkoutTemplate> get templates {
    // Always return templates sorted by display order
    List<WorkoutTemplate> sortedTemplates = List.from(_templates);
    sortedTemplates.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return sortedTemplates;
  }
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
    String? groupName,
  }) async {
    final now = DateTime.now();
    
    // Select the best neon color for this new template
    final selectedColor = NeonColors.selectBestColor(_templates);
    
    // Set display order to be after all existing templates
    final maxOrder = _templates.isEmpty 
        ? 0 
        : _templates.map((t) => t.displayOrder).reduce((a, b) => a > b ? a : b);
    
    final template = WorkoutTemplate(
      id: const Uuid().v4(),
      name: name,
      daysPerWeek: daysPerWeek,
      createdAt: now,
      updatedAt: now,
      exercises: exercises,
      colorValue: NeonColors.colorToInt(selectedColor),
      displayOrder: maxOrder + 1,
      groupName: groupName,
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

  /// Reorder templates by updating their display order
  Future<void> reorderTemplates(int oldIndex, int newIndex) async {
    // Work with the actual internal list to avoid snap-back
    final List<WorkoutTemplate> workingList = List.from(_templates);
    workingList.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    
    // Move the template in the list
    final template = workingList.removeAt(oldIndex);
    workingList.insert(newIndex, template);
    
    // Update display orders for all templates
    for (int i = 0; i < workingList.length; i++) {
      workingList[i].displayOrder = i;
      workingList[i].updatedAt = DateTime.now();
    }
    
    // Update the internal list immediately to prevent snap-back
    _templates = workingList;
    notifyListeners();
    
    // Save all updated templates in background
    for (final template in workingList) {
      await StorageManager.saveTemplate(template);
    }
  }

  /// Get all unique group names from existing templates
  List<String> getExistingGroupNames() {
    final groupNames = <String>{};
    for (final template in _templates) {
      if (template.groupName != null && template.groupName!.isNotEmpty) {
        groupNames.add(template.groupName!);
      }
    }
    return groupNames.toList()..sort();
  }
}