import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../models/workout_models.dart';
import '../utils/neon_colors.dart';

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3a3a3a),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: NeonColors.getTemplateColor(template),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: NeonColors.getTemplateColor(template).withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and group
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (template.groupName != null && template.groupName!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: NeonColors.getTemplateColor(template).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: NeonColors.getTemplateColor(template).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      template.groupName!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: NeonColors.getTemplateColor(template),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            
            const Spacer(),
            
            // Stats at bottom
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Days per week with icon
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: NeonColors.getTemplateColor(template),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${template.daysPerWeek} days/week',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                
                // Exercise count with icon
                Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 14,
                      color: NeonColors.getTemplateColor(template),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      template.exercises != null && template.exercises!.isNotEmpty
                          ? '${template.exercises!.length} exercises'
                          : 'No exercises yet',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                
                // Created date
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: NeonColors.getTemplateColor(template),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(template.createdAt),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  void _triggerHapticFeedback() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }

}