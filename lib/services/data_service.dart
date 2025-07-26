import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DataService {
  static const List<String> _boxNames = [
    'settings',
    'workout_templates',
    'workout_sessions',
    'exercises',
    'exercise_sets',
    'rest_logs',
    'calendar_plans',
  ];

  static Future<void> clearAllData() async {
    try {
      // Close all boxes first
      for (final boxName in _boxNames) {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).close();
        }
      }

      // Delete all box files
      for (final boxName in _boxNames) {
        try {
          await Hive.deleteBoxFromDisk(boxName);
          debugPrint('Deleted box: $boxName');
        } catch (e) {
          debugPrint('Error deleting box $boxName: $e');
        }
      }

      // Reopen essential boxes
      await _reopenEssentialBoxes();
      
      debugPrint('All data cleared successfully');
    } catch (e) {
      debugPrint('Error clearing data: $e');
      rethrow;
    }
  }

  static Future<void> _reopenEssentialBoxes() async {
    try {
      // Reopen settings box
      await Hive.openBox<String>('settings');
      debugPrint('Reopened settings box');
      
      // Add other essential boxes as needed
      // await Hive.openBox('workout_templates');
      // await Hive.openBox('exercises');
    } catch (e) {
      debugPrint('Error reopening boxes: $e');
    }
  }

  static Future<Map<String, int>> getDataStatistics() async {
    final stats = <String, int>{};
    
    try {
      for (final boxName in _boxNames) {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          stats[boxName] = box.length;
        } else {
          stats[boxName] = 0;
        }
      }
    } catch (e) {
      debugPrint('Error getting data statistics: $e');
    }
    
    return stats;
  }

  static Future<bool> hasAnyData() async {
    try {
      final stats = await getDataStatistics();
      return stats.values.any((count) => count > 0);
    } catch (e) {
      debugPrint('Error checking for data: $e');
      return false;
    }
  }

  static Future<String> getDataSummary() async {
    try {
      final stats = await getDataStatistics();
      final buffer = StringBuffer();
      
      buffer.writeln('Data Summary');
      buffer.writeln('═' * 30);
      
      final displayNames = {
        'settings': 'Settings',
        'workout_templates': 'Workout Templates',
        'workout_sessions': 'Workout Sessions',
        'exercises': 'Exercises',
        'exercise_sets': 'Exercise Sets',
        'rest_logs': 'Rest Logs',
        'calendar_plans': 'Calendar Plans',
      };
      
      for (final entry in stats.entries) {
        final displayName = displayNames[entry.key] ?? entry.key;
        buffer.writeln('• $displayName: ${entry.value}');
      }
      
      final totalItems = stats.values.fold(0, (sum, count) => sum + count);
      buffer.writeln('');
      buffer.writeln('Total items: $totalItems');
      
      return buffer.toString();
    } catch (e) {
      debugPrint('Error generating data summary: $e');
      return 'Error generating summary';
    }
  }

  static Future<void> exportBackup() async {
    // TODO: Implement backup export functionality
    // This would create a backup file before clearing data
    debugPrint('Backup export functionality to be implemented');
  }
}