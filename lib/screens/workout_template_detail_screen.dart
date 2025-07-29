import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../models/workout_models.dart';
import '../providers/workout_provider.dart';

class WorkoutTemplateDetailScreen extends StatelessWidget {
  final String templateId;

  const WorkoutTemplateDetailScreen({super.key, required this.templateId});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final template = workoutProvider.templates.firstWhere(
          (t) => t.id == templateId,
          orElse: () => throw Exception('Template not found'),
        );

        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Color(0xFF1a1a1a),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header with down arrow and template name
              _buildHeader(context, template),

              // Template info header
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a1a),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (template.groupName != null &&
                        template.groupName!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3a3a3a),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          template.groupName!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3a3a3a),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${template.daysPerWeek} days per week',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3a3a3a),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            size: 16,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          template.exercises != null &&
                                  template.exercises!.isNotEmpty
                              ? '${template.exercises!.length} exercises'
                              : 'No exercises yet',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Exercises list
              Expanded(
                child: template.exercises == null || template.exercises!.isEmpty
                    ? _buildEmptyState(context, template)
                    : _buildExercisesList(context, template),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, WorkoutTemplate template) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFFFFFFFF),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              template.name,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Start workout button
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => _startWorkout(context, template),
              icon: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Color(0xFF000000),
                  size: 20,
                ),
              ),
            ),
          ),
          // More options menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFFFFFFFF)),
            color: const Color(0xFF3a3a3a),
            onSelected: (value) => _handleMenuOption(context, value, template),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Color(0xFFFFFFFF), size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Edit Template',
                      style: TextStyle(color: Color(0xFFFFFFFF)),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'deactivate',
                child: Row(
                  children: [
                    Icon(
                      Icons.pause_circle,
                      color: Color(0xFFFFAA00),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Deactivate',
                      style: TextStyle(color: Color(0xFFFFAA00)),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Color(0xFFFF4444), size: 20),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Color(0xFFFF4444))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WorkoutTemplate template) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.fitness_center,
              size: 40,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Exercises Added',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFFFFF),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Add exercises to this workout template to get started',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF999999),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () => _addExercise(context, template),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Add Exercise',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(BuildContext context, WorkoutTemplate template) {
    final exercises = template.exercises!
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Column(
      children: [
        // Add exercise button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => _addExercise(context, template),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF1a1a1a),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF3a3a3a), width: 1),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Color(0xFFFFFFFF), size: 20),
                SizedBox(width: 8),
                Text(
                  'Add Exercise',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Exercises list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final templateExercise = exercises[index];
              return _buildExerciseCard(
                context,
                template,
                templateExercise,
                index,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    WorkoutTemplate template,
    TemplateExercise templateExercise,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Exercise info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exercise ${templateExercise.exerciseId}', // TODO: Get actual exercise name
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3a3a3a),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${templateExercise.targetSets} sets',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3a3a3a),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${templateExercise.targetReps} reps',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () =>
                    _editExercise(context, template, templateExercise),
                icon: const Icon(
                  Icons.edit,
                  color: Color(0xFF999999),
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF3a3a3a),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(36, 36),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () =>
                    _deleteExercise(context, template, templateExercise),
                icon: const Icon(
                  Icons.delete,
                  color: Color(0xFFFF4444),
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF3a3a3a),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(36, 36),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startWorkout(BuildContext context, WorkoutTemplate template) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
    // TODO: Navigate to workout session screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting workout: ${template.name}'),
        backgroundColor: const Color(0xFF3a3a3a),
      ),
    );
  }

  void _handleMenuOption(
    BuildContext context,
    String option,
    WorkoutTemplate template,
  ) {
    switch (option) {
      case 'edit':
        _editTemplate(context, template);
        break;
      case 'deactivate':
        _deactivateTemplate(context, template);
        break;
      case 'delete':
        _deleteTemplate(context, template);
        break;
    }
  }

  void _editTemplate(BuildContext context, WorkoutTemplate template) {
    // TODO: Navigate to edit template screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit template functionality coming soon'),
        backgroundColor: Color(0xFF3a3a3a),
      ),
    );
  }

  void _deactivateTemplate(BuildContext context, WorkoutTemplate template) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3a3a3a),
          title: const Text(
            'Deactivate Template',
            style: TextStyle(color: Color(0xFFFFFFFF)),
          ),
          content: Text(
            'Are you sure you want to deactivate "${template.name}"? You can reactivate it later.',
            style: const TextStyle(color: Color(0xFF999999)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF999999)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement deactivate functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Template deactivated'),
                    backgroundColor: Color(0xFF3a3a3a),
                  ),
                );
              },
              child: const Text(
                'Deactivate',
                style: TextStyle(color: Color(0xFFFFAA00)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteTemplate(BuildContext context, WorkoutTemplate template) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3a3a3a),
          title: const Text(
            'Delete Template',
            style: TextStyle(color: Color(0xFFFFFFFF)),
          ),
          content: Text(
            'Are you sure you want to delete "${template.name}"? This action cannot be undone.',
            style: const TextStyle(color: Color(0xFF999999)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF999999)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Provider.of<WorkoutProvider>(
                  context,
                  listen: false,
                ).deleteTemplate(template.id);
                Navigator.pop(context); // Close modal
                Navigator.pop(context); // Go back to workouts screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Template deleted'),
                    backgroundColor: Color(0xFF3a3a3a),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFFF4444)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addExercise(BuildContext context, WorkoutTemplate template) {
    // TODO: Navigate to exercise selection screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add exercise functionality coming soon'),
        backgroundColor: Color(0xFF3a3a3a),
      ),
    );
  }

  void _editExercise(
    BuildContext context,
    WorkoutTemplate template,
    TemplateExercise exercise,
  ) {
    // TODO: Navigate to exercise edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit exercise functionality coming soon'),
        backgroundColor: Color(0xFF3a3a3a),
      ),
    );
  }

  void _deleteExercise(
    BuildContext context,
    WorkoutTemplate template,
    TemplateExercise exercise,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3a3a3a),
          title: const Text(
            'Remove Exercise',
            style: TextStyle(color: Color(0xFFFFFFFF)),
          ),
          content: const Text(
            'Are you sure you want to remove this exercise from the template?',
            style: TextStyle(color: Color(0xFF999999)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF999999)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement remove exercise from template
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exercise removed'),
                    backgroundColor: Color(0xFF3a3a3a),
                  ),
                );
              },
              child: const Text(
                'Remove',
                style: TextStyle(color: Color(0xFFFF4444)),
              ),
            ),
          ],
        );
      },
    );
  }
}
