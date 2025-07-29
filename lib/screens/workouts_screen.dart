import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../providers/workout_provider.dart';
import '../widgets/workout_template_card.dart';
import '../models/workout_models.dart';
import 'create_template_screen.dart';
import 'workout_template_detail_screen.dart';

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

                  return ReorderableGridView.builder(
                    dragStartDelay: Duration.zero,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0, // Make squares
                        ),
                    itemCount: workoutProvider.templates.length,
                    onReorder: (oldIndex, newIndex) {
                      workoutProvider.reorderTemplates(oldIndex, newIndex);
                    },
                    dragWidgetBuilder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Material(elevation: 8, child: child),
                      );
                    },
                    itemBuilder: (context, index) {
                      final template = workoutProvider.templates[index];

                      return WorkoutTemplateCard(
                        key: ValueKey(template.id), // Important for reordering
                        template: template,
                        onTap: () => _navigateToTemplateDetail(context, template.id),
                        onSettingsTap: () => _showTemplateSettingsModal(context, template),
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
      builder: (context) => const CreateTemplateScreen(),
    );
  }

  void _navigateToTemplateDetail(BuildContext context, String templateId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkoutTemplateDetailScreen(templateId: templateId),
    );
  }

  void _showTemplateSettingsModal(BuildContext context, WorkoutTemplate template) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _TemplateSettingsModal(template: template),
    );
  }
}

class _TemplateSettingsModal extends StatelessWidget {
  final WorkoutTemplate template;

  const _TemplateSettingsModal({required this.template});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a1a),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3a3a3a),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    template.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ],
              ),
            ),

            // Options
            Column(
              children: [
                _buildOption(
                  context,
                  icon: Icons.edit,
                  text: 'Edit Name',
                  onTap: () => _editTemplateName(context),
                ),
                _buildOption(
                  context,
                  icon: Icons.calendar_today,
                  text: 'Change Days',
                  onTap: () => _changeDays(context),
                ),
                _buildOption(
                  context,
                  icon: template.isActive ? Icons.visibility_off : Icons.visibility,
                  text: template.isActive ? 'Deactivate' : 'Activate',
                  onTap: () => _toggleTemplateActive(context),
                ),
                _buildOption(
                  context,
                  icon: Icons.delete_outline,
                  text: 'Delete Template',
                  onTap: () => _deleteTemplate(context),
                  isDestructive: true,
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDestructive ? const Color(0xFFFF4444) : const Color(0xFFFFFFFF),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive ? const Color(0xFFFF4444) : const Color(0xFFFFFFFF),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Color(0xFF666666),
            ),
          ],
        ),
      ),
    );
  }

  void _editTemplateName(BuildContext context) {
    Navigator.pop(context);
    
    final TextEditingController controller = TextEditingController(text: template.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text(
          'Edit Template Name',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Color(0xFFFFFFFF)),
          decoration: InputDecoration(
            labelText: 'Template Name',
            labelStyle: const TextStyle(color: Color(0xFF666666)),
            filled: true,
            fillColor: const Color(0xFF2a2a2a),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFFFFFF)),
            ),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
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
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != template.name) {
                Navigator.pop(context);
                
                final workoutProvider = Provider.of<WorkoutProvider>(
                  context,
                  listen: false,
                );
                
                template.name = newName;
                template.updatedAt = DateTime.now();
                await workoutProvider.updateTemplate(template);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Template renamed to "$newName"'),
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  );
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFFFFFFFF)),
            ),
          ),
        ],
      ),
    );
  }

  void _changeDays(BuildContext context) {
    Navigator.pop(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChangeDaysModal(template: template),
    );
  }

  void _changeGroup(BuildContext context) {
    Navigator.pop(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChangeGroupModal(template: template),
    );
  }

  void _createNewGroup(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text(
          'Create New Group',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Color(0xFFFFFFFF)),
          decoration: InputDecoration(
            labelText: 'Group Name',
            labelStyle: const TextStyle(color: Color(0xFF666666)),
            filled: true,
            fillColor: const Color(0xFF2a2a2a),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFFFFFF)),
            ),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
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
            onPressed: () async {
              final newGroupName = controller.text.trim();
              if (newGroupName.isNotEmpty) {
                Navigator.pop(context);
                
                final workoutProvider = Provider.of<WorkoutProvider>(
                  context,
                  listen: false,
                );
                
                template.groupName = newGroupName;
                template.updatedAt = DateTime.now();
                await workoutProvider.updateTemplate(template);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Created group "$newGroupName"'),
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  );
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Create',
              style: TextStyle(color: Color(0xFFFFFFFF)),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTemplateActive(BuildContext context) {
    Navigator.pop(context);
    
    final action = template.isActive ? 'deactivate' : 'activate';
    final actionTitle = template.isActive ? 'Deactivate' : 'Activate';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: Text(
          '$actionTitle Template',
          style: const TextStyle(color: Color(0xFFFFFFFF)),
        ),
        content: Text(
          template.isActive 
            ? 'Are you sure you want to deactivate "${template.name}"? It will be hidden from your workout list but can be reactivated later.'
            : 'Are you sure you want to activate "${template.name}"? It will be shown in your workout list.',
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
            onPressed: () async {
              Navigator.pop(context);
              
              final workoutProvider = Provider.of<WorkoutProvider>(
                context,
                listen: false,
              );
              
              template.isActive = !template.isActive;
              template.updatedAt = DateTime.now();
              await workoutProvider.updateTemplate(template);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${template.name} ${action}d'),
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                );
              }
            },
            child: Text(
              actionTitle,
              style: const TextStyle(color: Color(0xFFFFFFFF)),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteTemplate(BuildContext context) {
    Navigator.pop(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
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
            onPressed: () async {
              Navigator.pop(context);
              final workoutProvider = Provider.of<WorkoutProvider>(
                context,
                listen: false,
              );
              await workoutProvider.deleteTemplate(template.id);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${template.name} deleted'),
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                );
              }
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
}

class _ChangeDaysModal extends StatefulWidget {
  final WorkoutTemplate template;

  const _ChangeDaysModal({required this.template});

  @override
  State<_ChangeDaysModal> createState() => _ChangeDaysModalState();
}

class _ChangeDaysModalState extends State<_ChangeDaysModal> {
  late Set<int> _selectedDays;
  
  final List<String> _dayAbbreviations = [
    'Mon', // 0 in UI = Monday = 1 in model
    'Tue', // 1 in UI = Tuesday = 2 in model
    'Wed', // 2 in UI = Wednesday = 3 in model
    'Thu', // 3 in UI = Thursday = 4 in model
    'Fri', // 4 in UI = Friday = 5 in model
    'Sat', // 5 in UI = Saturday = 6 in model
    'Sun', // 6 in UI = Sunday = 0 in model
  ];

  @override
  void initState() {
    super.initState();
    _selectedDays = <int>{};
    
    // Convert from model format (0=Sunday) to UI format (0=Monday)
    if (widget.template.weekdays != null) {
      for (int modelDay in widget.template.weekdays!) {
        // modelDay: 0=Sunday, 1=Monday, ..., 6=Saturday
        // uiDay: 0=Monday, 1=Tuesday, ..., 6=Sunday
        final uiDay = modelDay == 0 ? 6 : modelDay - 1;
        _selectedDays.add(uiDay);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a1a),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3a3a3a),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Change Training Days',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select which days you plan to follow this template.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF999999),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Week visualization in a circular pattern
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: Stack(
                          children: List.generate(7, (index) {
                            final isSelected = _selectedDays.contains(index);

                            // Calculate position in circle
                            final angle = (index * 2 * 3.14159) / 7 - 3.14159 / 2; // Start from top
                            const radius = 85.0;
                            final x = 125 + radius * cos(angle) - 30; // Center and adjust for button size
                            final y = 125 + radius * sin(angle) - 30;

                            return Positioned(
                              left: x,
                              top: y,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedDays.remove(index);
                                    } else {
                                      _selectedDays.add(index);
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 0),
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFFFFFF)
                                        : const Color(0xFF2a2a2a),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFFFFFFF)
                                          : const Color(0xFF444444),
                                      width: 2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFFFFFFF).withValues(alpha: 0.3),
                                              blurRadius: 12,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _dayAbbreviations[index],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? const Color(0xFF000000)
                                            : const Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Selection summary
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedDays.isEmpty
                              ? const Color(0xFF333333)
                              : const Color(0xFF2a2a2a),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedDays.isEmpty
                                ? const Color(0xFF444444)
                                : const Color(0xFF666666),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _selectedDays.isEmpty
                              ? 'Select training days'
                              : _selectedDays.length == 1
                              ? '1 day per week'
                              : '${_selectedDays.length} days per week',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _selectedDays.isEmpty
                                ? const Color(0xFF666666)
                                : const Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed button at bottom
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedDays.isNotEmpty ? _saveDays : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedDays.isNotEmpty
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF333333),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDays.isNotEmpty
                          ? const Color(0xFF000000)
                          : const Color(0xFF666666),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveDays() async {
    Navigator.pop(context);
    
    // Convert from UI format (0=Monday) to model format (0=Sunday)
    final convertedWeekdays = _selectedDays.map((uiDay) {
      // uiDay: 0=Monday, 1=Tuesday, ..., 6=Sunday
      // modelDay: 0=Sunday, 1=Monday, ..., 6=Saturday
      return uiDay == 6 ? 0 : uiDay + 1;
    }).toList()..sort();

    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    
    widget.template.weekdays = convertedWeekdays;
    widget.template.daysPerWeek = convertedWeekdays.length;
    widget.template.updatedAt = DateTime.now();
    
    await workoutProvider.updateTemplate(widget.template);
    
    if (context.mounted) {
      final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      final selectedDayNames = convertedWeekdays.map((day) => dayNames[day]).join(', ');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Training days updated to: $selectedDayNames'),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    }
  }
}

class _ChangeGroupModal extends StatefulWidget {
  final WorkoutTemplate template;

  const _ChangeGroupModal({required this.template});

  @override
  State<_ChangeGroupModal> createState() => _ChangeGroupModalState();
}

class _ChangeGroupModalState extends State<_ChangeGroupModal> {
  late List<String> _groupOptions;
  late int _selectedGroupIndex;
  final ScrollController _scrollController = ScrollController();
  bool _isManuallyScrolling = false;

  @override
  void initState() {
    super.initState();
    
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    final existingGroups = workoutProvider.getExistingGroupNames();
    _groupOptions = [...existingGroups, 'None', 'Create New Group'];
    
    // Find current selection
    _selectedGroupIndex = 0;
    final currentGroup = widget.template.groupName ?? 'None';
    final foundIndex = _groupOptions.indexOf(currentGroup);
    if (foundIndex != -1) {
      _selectedGroupIndex = foundIndex;
    }

    // Center the selected item after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToIndex(_selectedGroupIndex);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a1a),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header with down arrow and progress bar
          Container(
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
                const Expanded(
                  child: Text(
                    'Change Group',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Options list with center-based selection
                  Expanded(
                    child: Stack(
                      children: [
                        NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            if (!_isManuallyScrolling) {
                              _updateSelectedIndexBasedOnScroll();
                            }
                            return true;
                          },
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Calculate padding needed to center items
                              const itemHeight = 46.0; // 44 height + 2 margin
                              final viewportHeight = constraints.maxHeight;
                              // Use fixed padding for predictable behavior
                              final paddingItemCount = (viewportHeight / itemHeight / 2)
                                  .round()
                                  .clamp(3, 8);

                              return ListView.builder(
                                controller: _scrollController,
                                physics: const ClampingScrollPhysics(),
                                itemCount: _groupOptions.length + (2 * paddingItemCount),
                                itemBuilder: (context, index) {
                                  // Add padding items at start and end
                                  if (index < paddingItemCount ||
                                      index >= _groupOptions.length + paddingItemCount) {
                                    return const SizedBox(height: 46.0);
                                  }

                                  final optionIndex = index - paddingItemCount;
                                  final option = _groupOptions[optionIndex];
                                  final isSelected = optionIndex == _selectedGroupIndex;

                                  return Container(
                                    height: 44, // Even smaller height for tighter spacing
                                    margin: const EdgeInsets.only(
                                      bottom: 2,
                                    ), // Minimal margin
                                    child: InkWell(
                                      onTap: () {
                                        _selectGroupAtIndex(optionIndex, option);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ), // Reduced vertical padding
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                option,
                                                style: TextStyle(
                                                  fontSize: isSelected ? 24 : 20,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                                  color: isSelected
                                                      ? const Color(0xFFFFFFFF)
                                                      : const Color(0xFF666666),
                                                  height: 1.2, // Add line height to prevent cutoff
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            if (isSelected)
                                              GestureDetector(
                                                onTap: () => _confirmSelection(),
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFFFFFFFF),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.arrow_forward,
                                                      color: Color(0xFF000000),
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateSelectedIndexBasedOnScroll() {
    if (!_scrollController.hasClients) return;

    final scrollOffset = _scrollController.offset;
    const itemHeight = 46.0;
    final viewportHeight = _scrollController.position.viewportDimension;
    final centerOffset = scrollOffset + (viewportHeight / 2);

    final paddingItemCount = (viewportHeight / itemHeight / 2).round().clamp(3, 8);
    final adjustedCenterOffset = centerOffset - (paddingItemCount * itemHeight);

    final newSelectedIndex = (adjustedCenterOffset / itemHeight).round().clamp(
      0,
      _groupOptions.length - 1,
    );

    if (newSelectedIndex != _selectedGroupIndex) {
      setState(() {
        _selectedGroupIndex = newSelectedIndex;
      });
    }
  }

  void _selectGroupAtIndex(int index, String option) {
    setState(() {
      _selectedGroupIndex = index;
      _isManuallyScrolling = true;
    });

    _scrollToIndex(index);

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _isManuallyScrolling = false;
        });
      }
    });
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;

    const itemHeight = 46.0;
    final viewportHeight = _scrollController.position.viewportDimension;
    final paddingItemCount = (viewportHeight / itemHeight / 2).round().clamp(3, 8);

    final targetItemPosition = (index + paddingItemCount) * itemHeight;
    final targetOffset = targetItemPosition - (viewportHeight / 2) + (itemHeight / 2);

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _confirmSelection() async {
    Navigator.pop(context);

    final selectedOption = _groupOptions[_selectedGroupIndex];
    
    if (selectedOption == 'Create New Group') {
      _showCreateNewGroupDialog(context);
    } else {
      final newGroup = selectedOption == 'None' ? null : selectedOption;
      if (newGroup != widget.template.groupName) {
        final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
        
        widget.template.groupName = newGroup;
        widget.template.updatedAt = DateTime.now();
        await workoutProvider.updateTemplate(widget.template);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Group changed to: ${newGroup ?? "None"}'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      }
    }
  }

  void _showCreateNewGroupDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text(
          'Create New Group',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Color(0xFFFFFFFF)),
          decoration: InputDecoration(
            labelText: 'Group Name',
            labelStyle: const TextStyle(color: Color(0xFF666666)),
            filled: true,
            fillColor: const Color(0xFF2a2a2a),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFFFFFF)),
            ),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
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
            onPressed: () async {
              final newGroupName = controller.text.trim();
              if (newGroupName.isNotEmpty) {
                Navigator.pop(context);
                
                final workoutProvider = Provider.of<WorkoutProvider>(
                  context,
                  listen: false,
                );
                
                widget.template.groupName = newGroupName;
                widget.template.updatedAt = DateTime.now();
                await workoutProvider.updateTemplate(widget.template);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Created group "$newGroupName"'),
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  );
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Create',
              style: TextStyle(color: Color(0xFFFFFFFF)),
            ),
          ),
        ],
      ),
    );
  }
}
