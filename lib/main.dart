import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/storage_manager.dart';
import 'providers/workout_provider.dart';
import 'providers/calendar_provider.dart';
import 'screens/workouts_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await StorageManager.initialize();

  runApp(const MonoliftApp());
}

class MonoliftApp extends StatelessWidget {
  const MonoliftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
      ],
      child: MaterialApp(
        title: 'Monolift',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF000000),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF000000),
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF000000),
            selectedItemColor: Color(0xFFFFFFFF),
            unselectedItemColor: Color(0xFF666666),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF3a3a3a),
            elevation: 0,
          ),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFFFFF),
            secondary: Color(0xFF3a3a3a),
            surface: Color(0xFF000000),
            onPrimary: Color(0xFF000000),
            onSecondary: Color(0xFFFFFFFF),
            onSurface: Color(0xFFFFFFFF),
          ),
        ),
        home: const MainNavigator(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  VoidCallback? _calendarScrollToToday;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    
    _screens = [
      const WorkoutsScreen(),
      CalendarScreen(onScrollCallbackReady: (callback) {
        _calendarScrollToToday = callback;
      }),
      const ProgressScreen(),
      const SettingsScreen(),
    ];
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().refreshTemplates();
      context.read<CalendarProvider>().refreshData();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF333333), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            
            // If calendar tab is selected, scroll to today
            if (index == 1) {
              // Add a small delay to ensure the tab switch animation completes
              Future.delayed(const Duration(milliseconds: 100), () {
                _calendarScrollToToday?.call();
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF000000),
          selectedItemColor: const Color(0xFFFFFFFF),
          unselectedItemColor: const Color(0xFF666666),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 26,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Workouts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_outlined),
              activeIcon: Icon(Icons.trending_up),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
