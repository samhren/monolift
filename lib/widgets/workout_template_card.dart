import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../models/workout_models.dart';
import '../utils/neon_colors.dart';

class WorkoutTemplateCard extends StatelessWidget {
  final WorkoutTemplate template;
  final VoidCallback onTap;
  final VoidCallback? onSettingsTap;

  const WorkoutTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    this.onSettingsTap,
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
            ),
            child: Stack(
              children: [
                // Main content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Header with title and group
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: const TextStyle(
                      fontSize: 18,
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
                        color: const Color(0xFF555555),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        template.groupName!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFFFFFF),
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
                        _formatWeekdays(template),
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
                ],
              ),
            ],
          ),
                
                // Settings icon aligned with template name
                if (onSettingsTap != null)
                  Positioned(
                    top: -1,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        _triggerHapticFeedback();
                        onSettingsTap!();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.settings,
                          size: 18,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ),
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

  String _formatWeekdays(WorkoutTemplate template) {
    if (template.weekdays == null || template.weekdays!.isEmpty) {
      return '${template.daysPerWeek} days/week';
    }
    
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final sortedDays = List<int>.from(template.weekdays!)..sort();
    final dayLabels = sortedDays.map((day) => dayNames[day]).toList();
    
    return dayLabels.join(', ');
  }


}