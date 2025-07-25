import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/workout_template_card.dart';
import '../widgets/add_template_modal.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Workouts',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAddTemplateModal(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3a3a3a),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFFFFFFFF),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Consumer<WorkoutProvider>(
                builder: (context, workoutProvider, child) {
                  if (workoutProvider.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFFFFF),
                      ),
                    );
                  }

                  if (workoutProvider.templates.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 60,
                            color: Color(0xFF3a3a3a),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'No Workout Templates',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Create your first workout template to get started',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF3a3a3a),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: workoutProvider.templates.length,
                    itemBuilder: (context, index) {
                      final template = workoutProvider.templates[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: WorkoutTemplateCard(
                          template: template,
                          onTap: () => _handleStartWorkout(context, template.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTemplateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTemplateModal(),
    );
  }

  void _handleStartWorkout(BuildContext context, String templateId) {
    // TODO: Navigate to workout session
    print('Starting workout: $templateId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting workout: $templateId'),
        backgroundColor: const Color(0xFF3a3a3a),
      ),
    );
  }
}