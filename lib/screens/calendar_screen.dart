import 'package:flutter/material.dart';
import '../widgets/date_detail_sheet.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/today_button.dart';

class CalendarScreen extends StatefulWidget {
  final Function(VoidCallback)? onScrollCallbackReady;
  
  const CalendarScreen({super.key, this.onScrollCallbackReady});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with AutomaticKeepAliveClientMixin {
  DateTime? _selectedDate;
  int _currentYear = DateTime.now().year;
  bool _showTodayButton = false;
  String _todayButtonDirection = 'down';
  final CalendarGridController _calendarController = CalendarGridController();
  bool _hasInitiallyScrolled = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Register the scroll callback with the parent after the CalendarGrid is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reduced delay to minimize flash effect
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          widget.onScrollCallbackReady?.call(scrollToToday);
        }
      });
    });
  }


  void scrollToToday() {
    _calendarController.scrollToToday();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Calendar',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      Text(
                        _currentYear.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3a3a3a),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Calendar Grid
                Expanded(
                  child: CalendarGrid(
                    controller: _calendarController,
                    onDatePress: _handleDatePress,
                    onYearChange: _handleYearChange,
                    onTodayVisibility: _handleTodayVisibility,
                    selectedDate: _selectedDate,
                    isBottomSheetOpen: _selectedDate != null,
                  ),
                ),
              ],
            ),
            
            // Today button
            if (_showTodayButton)
              Positioned(
                bottom: 20,
                right: 16,
                child: TodayButton(
                  direction: _todayButtonDirection,
                  visible: _showTodayButton,
                  onPress: _goToToday,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleDatePress(DateTime date) {
    setState(() {
      if (_selectedDate != null && 
          _selectedDate!.millisecondsSinceEpoch == date.millisecondsSinceEpoch) {
        // Same date clicked - close sheet
        _selectedDate = null;
      } else {
        // New date selected
        _selectedDate = date;
        _showDateDetails(date);
      }
    });
  }

  void _handleYearChange(int year) {
    setState(() {
      _currentYear = year;
    });
  }

  void _handleTodayVisibility({required bool visible, required String direction}) {
    setState(() {
      _showTodayButton = visible;
      _todayButtonDirection = direction;
    });
  }

  void _showDateDetails(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateDetailSheet(date: date),
    ).then((_) {
      // Clear selection when sheet is closed
      setState(() {
        _selectedDate = null;
      });
    });
  }

  void _goToToday() {
    // Use the calendar controller to scroll to today
    _calendarController.scrollToToday();
    
    // Hide the today button since we're now at today
    setState(() {
      _showTodayButton = false;
    });
  }
}