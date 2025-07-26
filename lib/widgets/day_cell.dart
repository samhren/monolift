import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../models/calendar_models.dart';

class DayCell extends StatefulWidget {
  final CalendarDay? day;
  final Function(DateTime) onPress;
  final String? monthAbbrev;
  final DateTime? selectedDate;
  final bool isBottomSheetOpen;

  const DayCell({
    super.key,
    required this.day,
    required this.onPress,
    this.monthAbbrev,
    this.selectedDate,
    this.isBottomSheetOpen = false,
  });

  @override
  State<DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<DayCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _borderOpacity;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _borderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DayCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateBorderAnimation();
  }

  void _updateBorderAnimation() {
    final isSelected = widget.day != null &&
        widget.selectedDate != null &&
        widget.day!.date.millisecondsSinceEpoch == widget.selectedDate!.millisecondsSinceEpoch &&
        widget.isBottomSheetOpen;

    if (isSelected) {
      _animationController.forward();
    } else {
      if (!widget.isBottomSheetOpen) {
        // Instant disappear when popup closes
        _animationController.reset();
      } else {
        // Smooth fade when transitioning between dates
        _animationController.reverse();
      }
    }
  }

  void _triggerHapticFeedback() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.day == null) {
      return const SizedBox(
        height: 55,
      );
    }

    final day = widget.day!;
    final isFirstOfMonth = day.date.day == 1;

    return GestureDetector(
      onTap: () {
        _triggerHapticFeedback();
        widget.onPress(day.date);
      },
      child: Container(
        height: isFirstOfMonth && widget.monthAbbrev != null ? 70 : 55,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Month label (shown above the date on first of month)
            if (isFirstOfMonth && widget.monthAbbrev != null)
              Positioned(
                top: 5,
                child: Text(
                  widget.monthAbbrev!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            
            // Day container
            Positioned(
              bottom: 0,
              child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _getDayBackgroundColor(day),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Selection border animation
                  AnimatedBuilder(
                    animation: _borderOpacity,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _borderOpacity.value,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFFFFFFF),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Day number
                  Center(
                    child: Text(
                      '${day.date.day}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: _getDayTextColor(day),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDayBackgroundColor(CalendarDay day) {
    if (day.hasWorkout) {
      return const Color(0xFF3a3a3a);
    } else if (day.isToday) {
      return const Color(0xFF3a3a3a).withValues(alpha: 0.5);
    }
    return Colors.transparent;
  }

  Color _getDayTextColor(CalendarDay day) {
    if (day.hasWorkout || day.isToday) {
      return const Color(0xFFFFFFFF);
    } else {
      return const Color(0xFF919191);
    }
  }
}