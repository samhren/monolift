import 'package:flutter/foundation.dart';

@immutable
class CalendarDay {
  final DateTime date;
  final bool isToday;
  final bool isCurrentMonth;
  final bool hasWorkout;

  const CalendarDay({
    required this.date,
    required this.isToday,
    required this.isCurrentMonth,
    required this.hasWorkout,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDay &&
          runtimeType == other.runtimeType &&
          date.millisecondsSinceEpoch == other.date.millisecondsSinceEpoch &&
          isToday == other.isToday &&
          isCurrentMonth == other.isCurrentMonth &&
          hasWorkout == other.hasWorkout;

  @override
  int get hashCode =>
      date.millisecondsSinceEpoch.hashCode ^
      isToday.hashCode ^
      isCurrentMonth.hashCode ^
      hasWorkout.hashCode;
}

@immutable
class CalendarWeek {
  final List<CalendarDay?> days;
  final bool isLastInMonth;

  const CalendarWeek({
    required this.days,
    required this.isLastInMonth,
  });
}

@immutable
class MonthData {
  final DateTime monthDate;
  final List<CalendarDay> days;
  final List<List<CalendarWeek>>? monthGroups;

  const MonthData({
    required this.monthDate,
    required this.days,
    this.monthGroups,
  });
}