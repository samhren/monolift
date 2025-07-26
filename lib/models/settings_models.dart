import 'package:flutter/foundation.dart';

enum WeightUnit { lbs, kg }

@immutable
class AppSettings {
  final WeightUnit weightUnit;
  final bool hapticFeedbackEnabled;
  final bool notificationsEnabled;
  final int defaultRestTimer; // in seconds
  final Map<String, int> customRestTimers; // custom named rest timers

  const AppSettings({
    this.weightUnit = WeightUnit.lbs,
    this.hapticFeedbackEnabled = true,
    this.notificationsEnabled = true,
    this.defaultRestTimer = 120, // 2 minutes default
    this.customRestTimers = const {},
  });

  AppSettings copyWith({
    WeightUnit? weightUnit,
    bool? hapticFeedbackEnabled,
    bool? notificationsEnabled,
    int? defaultRestTimer,
    Map<String, int>? customRestTimers,
  }) {
    return AppSettings(
      weightUnit: weightUnit ?? this.weightUnit,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultRestTimer: defaultRestTimer ?? this.defaultRestTimer,
      customRestTimers: customRestTimers ?? this.customRestTimers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weightUnit': weightUnit.toString(),
      'hapticFeedbackEnabled': hapticFeedbackEnabled,
      'notificationsEnabled': notificationsEnabled,
      'defaultRestTimer': defaultRestTimer,
      'customRestTimers': customRestTimers,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      weightUnit: WeightUnit.values.firstWhere(
        (e) => e.toString() == json['weightUnit'],
        orElse: () => WeightUnit.lbs,
      ),
      hapticFeedbackEnabled: json['hapticFeedbackEnabled'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      defaultRestTimer: json['defaultRestTimer'] ?? 120,
      customRestTimers: Map<String, int>.from(json['customRestTimers'] ?? {}),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          weightUnit == other.weightUnit &&
          hapticFeedbackEnabled == other.hapticFeedbackEnabled &&
          notificationsEnabled == other.notificationsEnabled &&
          defaultRestTimer == other.defaultRestTimer &&
          mapEquals(customRestTimers, other.customRestTimers);

  @override
  int get hashCode =>
      weightUnit.hashCode ^
      hapticFeedbackEnabled.hashCode ^
      notificationsEnabled.hashCode ^
      defaultRestTimer.hashCode ^
      customRestTimers.hashCode;
}

extension WeightUnitExtension on WeightUnit {
  String get displayName {
    switch (this) {
      case WeightUnit.lbs:
        return 'Pounds (lbs)';
      case WeightUnit.kg:
        return 'Kilograms (kg)';
    }
  }

  String get abbreviation {
    switch (this) {
      case WeightUnit.lbs:
        return 'lbs';
      case WeightUnit.kg:
        return 'kg';
    }
  }

  double convert(double weight, WeightUnit to) {
    if (this == to) return weight;
    
    switch (this) {
      case WeightUnit.lbs:
        return weight * 0.453592; // lbs to kg
      case WeightUnit.kg:
        return weight * 2.20462; // kg to lbs
    }
  }
}