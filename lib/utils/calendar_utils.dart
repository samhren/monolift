import '../models/calendar_models.dart';

/// Check if two dates are the same day
bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Generate calendar data for a range of months
List<MonthData> generateMonthsData({
  required int startOffset,
  required int endOffset,
}) {
  final today = DateTime.now();
  final todayDateOnly = DateTime(today.year, today.month, today.day);
  final currentMonth = today.month;
  final currentYear = today.year;

  final monthGroups = <List<CalendarWeek>>[];

  // Calculate start month
  final startMonth = DateTime(
    today.year,
    today.month + startOffset,
    1,
  );
  final totalMonths = endOffset - startOffset;

  // Create a continuous list of all days across all months
  final allDays = <CalendarDay>[];
  
  for (int offset = 0; offset < totalMonths; offset++) {
    // Calculate the actual month/year considering overflow
    final monthYear = startMonth.year;
    final monthIndex = startMonth.month - 1 + offset; // Convert to 0-based
    final adjustedYear = monthYear + (monthIndex ~/ 12);
    final adjustedMonth = (monthIndex % 12) + 1; // Convert back to 1-based

    final daysInMonth = DateTime(adjustedYear, adjustedMonth + 1, 0).day;

    // Add actual days of the month
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(adjustedYear, adjustedMonth, d);
      final isToday = isSameDay(date, todayDateOnly);
      
      
      allDays.add(CalendarDay(
        date: date,
        isToday: isToday,
        isCurrentMonth: adjustedMonth == currentMonth && adjustedYear == currentYear,
        hasWorkout: false, // TODO: Add workout data
      ));
    }
  }

  // Create a single continuous calendar grid
  // Start from the first Sunday of the range
  final firstDay = allDays.first.date;
  final startDayOfWeek = firstDay.weekday % 7; // Sunday = 0
  
  // Add padding days from the previous month to start on Sunday
  final paddingDays = <CalendarDay>[];
  for (int i = 0; i < startDayOfWeek; i++) {
    final paddingDate = firstDay.subtract(Duration(days: startDayOfWeek - i));
    paddingDays.add(CalendarDay(
      date: paddingDate,
      isToday: isSameDay(paddingDate, todayDateOnly),
      isCurrentMonth: paddingDate.month == currentMonth && paddingDate.year == currentYear,
      hasWorkout: false,
    ));
  }
  
  // Combine padding days with all days
  final allCalendarDays = [...paddingDays, ...allDays];
  
  // Split into weeks
  final rows = <CalendarWeek>[];
  for (int i = 0; i < allCalendarDays.length; i += 7) {
    final week = allCalendarDays.skip(i).take(7).toList();
    
    // Pad to 7 days if needed (only for incomplete last week)
    while (week.length < 7) {
      final lastDate = week.last.date;
      final nextDate = lastDate.add(const Duration(days: 1));
      week.add(CalendarDay(
        date: nextDate,
        isToday: isSameDay(nextDate, todayDateOnly),
        isCurrentMonth: nextDate.month == currentMonth && nextDate.year == currentYear,
        hasWorkout: false,
      ));
    }

    rows.add(CalendarWeek(
      days: week,
      isLastInMonth: false, // Not used in continuous calendar
    ));
  }
  
  monthGroups.add(rows);

  // Return single MonthData wrapper that holds the master grid
  return [
    MonthData(
      monthDate: today,
      days: const [],
      monthGroups: monthGroups,
    )
  ];
}

/// Get month abbreviation for a date
String getMonthAbbreviation(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[date.month - 1];
}