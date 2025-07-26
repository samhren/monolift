import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/settings_models.dart';

class ExportService {
  static Future<void> exportAllData({
    required List<Map<String, dynamic>> workoutTemplates,
    required List<Map<String, dynamic>> workoutSessions,
    required List<Map<String, dynamic>> exercises,
    required AppSettings settings,
    String format = 'json',
  }) async {
    try {
      final exportData = {
        'export_info': {
          'app': 'Monolift',
          'version': '1.0.0',
          'exported_at': DateTime.now().toIso8601String(),
          'format': format,
        },
        'settings': settings.toJson(),
        'data': {
          'workout_templates': workoutTemplates,
          'workout_sessions': workoutSessions,
          'exercises': exercises,
        },
        'statistics': {
          'total_templates': workoutTemplates.length,
          'total_sessions': workoutSessions.length,
          'total_exercises': exercises.length,
        },
      };

      if (format.toLowerCase() == 'csv') {
        await _exportAsCSV(exportData);
      } else {
        await _exportAsJSON(exportData);
      }
    } catch (e) {
      debugPrint('Error exporting data: $e');
      rethrow;
    }
  }

  static Future<void> _exportAsJSON(Map<String, dynamic> data) async {
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    await _saveAndShareFile(
      content: jsonString,
      filename: 'monolift_data_${_getTimestamp()}.json',
      mimeType: 'application/json',
    );
  }

  static Future<void> _exportAsCSV(Map<String, dynamic> data) async {
    final csvContent = _convertToCSV(data);
    await _saveAndShareFile(
      content: csvContent,
      filename: 'monolift_data_${_getTimestamp()}.csv',
      mimeType: 'text/csv',
    );
  }

  static String _convertToCSV(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    
    // Add header information
    buffer.writeln('Monolift Data Export');
    buffer.writeln('Exported: ${data['export_info']['exported_at']}');
    buffer.writeln('');
    
    // Workout Sessions CSV
    buffer.writeln('WORKOUT SESSIONS');
    buffer.writeln('Session ID,Template ID,Started At,Finished At,Duration (minutes)');
    
    final sessions = data['data']['workout_sessions'] as List;
    for (final session in sessions) {
      final startedAt = session['startedAt'] ?? '';
      final finishedAt = session['finishedAt'] ?? '';
      final duration = _calculateDuration(startedAt, finishedAt);
      
      buffer.writeln([
        session['id'] ?? '',
        session['templateId'] ?? '',
        startedAt,
        finishedAt,
        duration,
      ].map(_escapeCsvField).join(','));
    }
    
    buffer.writeln('');
    
    // Workout Templates CSV
    buffer.writeln('WORKOUT TEMPLATES');
    buffer.writeln('Template ID,Name,Days Per Week,Created At');
    
    final templates = data['data']['workout_templates'] as List;
    for (final template in templates) {
      buffer.writeln([
        template['id'] ?? '',
        template['name'] ?? '',
        template['daysPerWeek'] ?? '',
        template['createdAt'] ?? '',
      ].map(_escapeCsvField).join(','));
    }
    
    buffer.writeln('');
    
    // Exercises CSV
    buffer.writeln('EXERCISES');
    buffer.writeln('Exercise ID,Name,Category,Variant Of');
    
    final exercises = data['data']['exercises'] as List;
    for (final exercise in exercises) {
      buffer.writeln([
        exercise['id'] ?? '',
        exercise['name'] ?? '',
        exercise['category'] ?? '',
        exercise['variantOf'] ?? '',
      ].map(_escapeCsvField).join(','));
    }
    
    return buffer.toString();
  }

  static String _escapeCsvField(dynamic field) {
    final str = field.toString();
    if (str.contains(',') || str.contains('"') || str.contains('\n')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  static String _calculateDuration(String? startedAt, String? finishedAt) {
    if (startedAt == null || finishedAt == null) return '';
    
    try {
      final start = DateTime.parse(startedAt);
      final end = DateTime.parse(finishedAt);
      final duration = end.difference(start);
      return duration.inMinutes.toString();
    } catch (e) {
      return '';
    }
  }

  static Future<void> _saveAndShareFile({
    required String content,
    required String filename,
    required String mimeType,
  }) async {
    try {
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename');
      
      // Write content to file
      await file.writeAsString(content);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path, mimeType: mimeType)],
        subject: 'Monolift Data Export',
        text: 'Your Monolift workout data export',
      );
    } catch (e) {
      debugPrint('Error saving and sharing file: $e');
      rethrow;
    }
  }

  static String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
           '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  static Future<String> getExportPreview({
    required int templatesCount,
    required int sessionsCount,
    required int exercisesCount,
    required AppSettings settings,
  }) async {
    final buffer = StringBuffer();
    
    buffer.writeln('Export Preview');
    buffer.writeln('═' * 40);
    buffer.writeln('');
    
    buffer.writeln('📊 Data Summary:');
    buffer.writeln('• Workout Templates: $templatesCount');
    buffer.writeln('• Workout Sessions: $sessionsCount');
    buffer.writeln('• Exercises: $exercisesCount');
    buffer.writeln('');
    
    buffer.writeln('⚙️ Settings:');
    buffer.writeln('• Weight Unit: ${settings.weightUnit.displayName}');
    buffer.writeln('• Haptic Feedback: ${settings.hapticFeedbackEnabled ? "Enabled" : "Disabled"}');
    buffer.writeln('• Notifications: ${settings.notificationsEnabled ? "Enabled" : "Disabled"}');
    buffer.writeln('• Default Rest Timer: ${_formatDuration(settings.defaultRestTimer)}');
    
    if (settings.customRestTimers.isNotEmpty) {
      buffer.writeln('• Custom Rest Timers: ${settings.customRestTimers.length}');
    }
    
    buffer.writeln('');
    buffer.writeln('📁 Export will include:');
    buffer.writeln('• All workout data and progress');
    buffer.writeln('• App settings and preferences');
    buffer.writeln('• Exercise definitions and variants');
    buffer.writeln('• Session history and statistics');
    
    return buffer.toString();
  }

  static String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    }
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) {
      return '${minutes}m';
    }
    return '${minutes}m ${remainingSeconds}s';
  }
}