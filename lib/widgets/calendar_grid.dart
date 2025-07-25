import 'package:flutter/material.dart';
import '../models/calendar_models.dart';
import '../utils/calendar_utils.dart';
import 'day_cell.dart';

class CalendarGrid extends StatefulWidget {
  final Function(DateTime) onDatePress;
  final Function(int) onYearChange;
  final Function({required bool visible, required String direction}) onTodayVisibility;
  final DateTime? selectedDate;
  final bool isBottomSheetOpen;
  final CalendarGridController? controller;

  const CalendarGrid({
    super.key,
    required this.onDatePress,
    required this.onYearChange,
    required this.onTodayVisibility,
    this.selectedDate,
    this.isBottomSheetOpen = false,
    this.controller,
  });

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}

class CalendarGridController {
  _CalendarGridState? _state;
  
  void _attach(_CalendarGridState state) {
    _state = state;
  }
  
  void _detach() {
    _state = null;
  }
  
  void scrollToToday() {
    _state?._centerOnToday();
  }
}

class _CalendarGridState extends State<CalendarGrid> {
  final ScrollController _scrollController = ScrollController();
  List<MonthData> _monthsData = [];
  bool _isInitialized = false;
  int _todayRowIndex = -1;
  int _currentYear = DateTime.now().year;
  bool _showTodayButton = false;

  static const double _rowHeight = 63.0;
  static const double _rowMargin = 8.0;
  static const double _totalRowHeight = _rowHeight + _rowMargin;
  static const List<String> _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _initializeCalendar();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeCalendar() {
    // Generate calendar data for 1.5 years (6 months back, 12 months forward)
    _monthsData = generateMonthsData(startOffset: -6, endOffset: 12);
    _findTodayRowIndex();
    _isInitialized = true;
    
    // Center on today after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerOnToday();
    });
    
    setState(() {});
  }

  void _findTodayRowIndex() {
    if (_monthsData.isEmpty || _monthsData[0].monthGroups == null) return;
    
    final monthGroups = _monthsData[0].monthGroups!;
    int rowCounter = 0;
    
    for (int m = 0; m < monthGroups.length && _todayRowIndex == -1; m++) {
      final rows = monthGroups[m];
      
      for (int i = 0; i < rows.length; i++) {
        final todayInRow = rows[i].days.any((day) => day?.isToday == true);
        if (todayInRow) {
          _todayRowIndex = rowCounter + i;
          break;
        }
      }
      rowCounter += rows.length;
    }
  }

  void _centerOnToday() {
    if (_todayRowIndex == -1 || !_scrollController.hasClients) return;
    
    // Get the actual viewport height from the scroll controller
    final viewportHeight = _scrollController.position.viewportDimension;
    
    // Calculate offset to center today's row in the viewport
    // Position today's row so it appears in the middle of the visible area
    final todayPixelPosition = _todayRowIndex * _totalRowHeight;
    final targetOffset = todayPixelPosition - (viewportHeight / 2) + (_totalRowHeight / 2);
    
    final clampedOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);
    
    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _handleScroll() {
    if (!_isInitialized || _monthsData.isEmpty || _monthsData[0].monthGroups == null) return;
    
    final scrollOffset = _scrollController.offset;
    final viewportHeight = _scrollController.position.viewportDimension;
    
    final firstVisibleRow = (scrollOffset / _totalRowHeight).floor();
    final lastVisibleRow = ((scrollOffset + viewportHeight) / _totalRowHeight).ceil();
    
    // Find the current year based on visible month
    _updateCurrentYear(firstVisibleRow, lastVisibleRow);
    
    // Update today button visibility
    _updateTodayButtonVisibility(firstVisibleRow, lastVisibleRow);
  }

  void _updateCurrentYear(int firstVisibleRow, int lastVisibleRow) {
    final monthGroups = _monthsData[0].monthGroups!;
    int rowCounter = 0;
    
    for (int m = 0; m < monthGroups.length; m++) {
      final rows = monthGroups[m];
      final nextRowCounter = rowCounter + rows.length;
      
      if (firstVisibleRow < nextRowCounter && lastVisibleRow >= rowCounter) {
        // Calculate year for this month
        final today = DateTime.now();
        final baseYear = today.year;
        final baseMonth = today.month - 6; // -6 is our start offset
        final targetMonth = baseMonth + m;
        final currentYearFound = baseYear + (targetMonth ~/ 12);
        
        if (currentYearFound != _currentYear) {
          _currentYear = currentYearFound;
          widget.onYearChange(_currentYear);
        }
        break;
      }
      
      rowCounter = nextRowCounter;
      if (rowCounter > lastVisibleRow) break;
    }
  }

  void _updateTodayButtonVisibility(int firstVisibleRow, int lastVisibleRow) {
    if (_todayRowIndex == -1) return;
    
    final visible = _todayRowIndex < firstVisibleRow || _todayRowIndex > lastVisibleRow;
    
    if (visible != _showTodayButton) {
      _showTodayButton = visible;
      widget.onTodayVisibility(
        visible: visible,
        direction: _todayRowIndex < firstVisibleRow ? 'up' : 'down',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildLoadingState();
    }

    return Column(
      children: [
        _buildWeekHeader(),
        _buildSeparator(),
        Expanded(
          child: _buildCalendarBody(),
        ),
      ],
    );
  }

  Widget _buildWeekHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: _weekdays.map((weekday) => Expanded(
          child: Center(
            child: Text(
              weekday,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3a3a3a),
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFF333333),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        _buildWeekHeader(),
        _buildSeparator(),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: List.generate(8, (i) => 
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: List.generate(7, (j) => 
                      Expanded(
                        child: Container(
                          height: 55,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1a1a1a),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarBody() {
    final monthGroups = _monthsData[0].monthGroups!;
    final today = DateTime.now();
    final startMonth = DateTime(today.year, today.month - 6, 1);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _getTotalRows(monthGroups),
      itemBuilder: (context, globalRowIndex) {
        final rowData = _getRowData(monthGroups, globalRowIndex, startMonth);
        if (rowData == null) return const SizedBox.shrink();

        return Container(
          height: _rowHeight,
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: rowData.days.map((day) {
              if (day == null) {
                return const Expanded(child: SizedBox());
              }

              // Determine if we should show month label
              final showMonthLabel = day.date.day == 1;
              final monthAbbrev = showMonthLabel ? getMonthAbbreviation(day.date) : null;

              return Expanded(
                child: DayCell(
                  day: day,
                  onPress: widget.onDatePress,
                  monthAbbrev: monthAbbrev,
                  selectedDate: widget.selectedDate,
                  isBottomSheetOpen: widget.isBottomSheetOpen,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  int _getTotalRows(List<List<CalendarWeek>> monthGroups) {
    return monthGroups.fold(0, (sum, month) => sum + month.length);
  }

  CalendarWeek? _getRowData(List<List<CalendarWeek>> monthGroups, int globalRowIndex, DateTime startMonth) {
    int rowCounter = 0;
    
    for (final monthRows in monthGroups) {
      if (globalRowIndex < rowCounter + monthRows.length) {
        return monthRows[globalRowIndex - rowCounter];
      }
      rowCounter += monthRows.length;
    }
    
    return null;
  }
}