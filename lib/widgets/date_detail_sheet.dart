import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/calendar_provider.dart';
import '../providers/workout_provider.dart';

class DateDetailSheet extends StatelessWidget {
  final DateTime date;

  const DateDetailSheet({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: const BoxDecoration(
        color: Color(0xFF2a2a2a),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF666666),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Date header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d').format(date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAddWorkoutDialog(context),
                    icon: const Icon(
                      Icons.add,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Consumer2<CalendarProvider, WorkoutProvider>(
                builder: (context, calendarProvider, workoutProvider, child) {
                  final plans = calendarProvider.getPlansForDate(date);
                  final sessions = calendarProvider.getSessionsForDate(date);
                  
                  if (plans.isEmpty && sessions.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 40,
                            color: Color(0xFF666666),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No workouts scheduled',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF666666),
                            ),
                          ),
                          Text(
                            'Tap + to add a workout',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Planned workouts
                      ...plans.map((plan) {
                        final template = plan.templateId != null
                            ? workoutProvider.getTemplateById(plan.templateId!)
                            : null;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3a3a3a),
                            borderRadius: BorderRadius.circular(8),
                            border: plan.isCompleted
                                ? Border.all(color: const Color(0xFF4CAF50), width: 1)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                plan.isCompleted 
                                    ? Icons.check_circle 
                                    : Icons.schedule,
                                color: plan.isCompleted 
                                    ? const Color(0xFF4CAF50) 
                                    : const Color(0xFF666666),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      template?.name ?? 'Custom Workout',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFFFFFFFF),
                                        decoration: plan.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      plan.isCompleted ? 'Completed' : 'Planned',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      
                      // Completed sessions (that aren't linked to plans)
                      ...sessions
                          .where((session) => !plans.any((plan) => plan.sessionId == session.id))
                          .map((session) {
                        final template = session.templateId != null
                            ? workoutProvider.getTemplateById(session.templateId!)
                            : null;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3a3a3a),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.fitness_center,
                                color: Color(0xFF4CAF50),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      template?.name ?? 'Custom Workout',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                    Text(
                                      'Completed at ${DateFormat.Hm().format(session.startedAt)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWorkoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text(
          'Add Workout',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.schedule,
                color: Color(0xFFFFFFFF),
              ),
              title: const Text(
                'Plan Workout',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
              subtitle: const Text(
                'Schedule a workout for this date',
                style: TextStyle(color: Color(0xFF666666)),
              ),
              onTap: () {
                Navigator.pop(context);
                _planWorkout(context);
              },
            ),
            const Divider(color: Color(0xFF666666)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.fitness_center,
                color: Color(0xFFFFFFFF),
              ),
              title: const Text(
                'Start Workout',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
              subtitle: const Text(
                'Begin a workout session now',
                style: TextStyle(color: Color(0xFF666666)),
              ),
              onTap: () {
                Navigator.pop(context);
                _startWorkout(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ),
        ],
      ),
    );
  }

  void _planWorkout(BuildContext context) {
    // TODO: Show template selection and plan workout
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plan workout functionality coming soon'),
        backgroundColor: Color(0xFF3a3a3a),
      ),
    );
  }

  void _startWorkout(BuildContext context) {
    // TODO: Show template selection and start workout session
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Start workout functionality coming soon'),
        backgroundColor: Color(0xFF3a3a3a),
      ),
    );
  }
}