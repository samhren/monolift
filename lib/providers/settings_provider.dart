import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings_models.dart';

class SettingsProvider with ChangeNotifier {
  static const String _settingsKey = 'app_settings';
  late Box<String> _settingsBox;
  
  AppSettings _settings = const AppSettings();
  AppSettings get settings => _settings;

  Future<void> initialize() async {
    _settingsBox = await Hive.openBox<String>('settings');
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsJson = _settingsBox.get(_settingsKey);
      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        _settings = AppSettings.fromJson(settingsMap);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final settingsJson = jsonEncode(_settings.toJson());
      await _settingsBox.put(_settingsKey, settingsJson);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> updateWeightUnit(WeightUnit unit) async {
    _settings = _settings.copyWith(weightUnit: unit);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateHapticFeedback(bool enabled) async {
    _settings = _settings.copyWith(hapticFeedbackEnabled: enabled);
    await _saveSettings();
    notifyListeners();
    
    if (enabled) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> updateNotifications(bool enabled) async {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateDefaultRestTimer(int seconds) async {
    _settings = _settings.copyWith(defaultRestTimer: seconds);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateCustomRestTimer(String timerName, int seconds) async {
    final updatedTimers = Map<String, int>.from(_settings.customRestTimers);
    updatedTimers[timerName] = seconds;
    _settings = _settings.copyWith(customRestTimers: updatedTimers);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> removeCustomRestTimer(String timerName) async {
    final updatedTimers = Map<String, int>.from(_settings.customRestTimers);
    updatedTimers.remove(timerName);
    _settings = _settings.copyWith(customRestTimers: updatedTimers);
    await _saveSettings();
    notifyListeners();
  }

  void triggerHapticFeedback() {
    if (_settings.hapticFeedbackEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void triggerHapticSuccess() {
    if (_settings.hapticFeedbackEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  void triggerHapticError() {
    if (_settings.hapticFeedbackEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  double convertWeight(double weight, WeightUnit from, WeightUnit to) {
    return from.convert(weight, to);
  }

  String formatWeight(double weight) {
    final unit = _settings.weightUnit;
    if (weight == weight.round()) {
      return '${weight.round()} ${unit.abbreviation}';
    }
    return '${weight.toStringAsFixed(1)} ${unit.abbreviation}';
  }

  int getCustomRestTimer(String timerName) {
    return _settings.customRestTimers[timerName] ?? _settings.defaultRestTimer;
  }

  Future<void> clearAllData() async {
    await _settingsBox.clear();
    _settings = const AppSettings();
    notifyListeners();
  }
}