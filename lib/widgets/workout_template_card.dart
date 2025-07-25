import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../models/workout_models.dart';
import '../providers/workout_provider.dart';

class WorkoutTemplateCard extends StatelessWidget {
  final WorkoutTemplate template;
  final VoidCallback onTap;

  const WorkoutTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _triggerHapticFeedback();
        onTap();
      },
      onLongPress: () => _showOptionsMenu(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF3a3a3a),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    template.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showOptionsMenu(context),
                  child: const Icon(
                    Icons.more_horiz,
                    color: Color(0xFF999999),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${template.daysPerWeek} days per week',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
            if (template.exercises != null && template.exercises!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${template.exercises!.length} exercises',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _triggerHapticFeedback() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  void _showOptionsMenu(BuildContext context) {
    _triggerHapticFeedback();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2a2a2a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF666666),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                template.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.edit,
                color: Color(0xFFFFFFFF),
              ),
              title: const Text(
                'Edit Template',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
              onTap: () {
                Navigator.pop(context);
                _editTemplate(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete,
                color: Color(0xFFFF4444),
              ),
              title: const Text(
                'Delete Template',
                style: TextStyle(color: Color(0xFFFF4444)),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _editTemplate(BuildContext context) {
    // TODO: Implement edit template functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit template functionality coming soon'),
        backgroundColor: Color(0xFF3a3a3a),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
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
              _deleteTemplate(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFF4444)),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteTemplate(BuildContext context) async {
    try {
      await context.read<WorkoutProvider>().deleteTemplate(template.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${template.name}"'),
            backgroundColor: const Color(0xFF3a3a3a),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete template'),
            backgroundColor: Color(0xFFFF4444),
          ),
        );
      }
    }
  }
}