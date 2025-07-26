import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../providers/settings_provider.dart';

class CreateTemplateScreen extends StatefulWidget {
  const CreateTemplateScreen({super.key});

  @override
  State<CreateTemplateScreen> createState() => _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends State<CreateTemplateScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Template data
  String _templateName = '';
  String _customTemplateName = '';
  String _groupName = '';
  String _customGroupName = '';
  Set<int> _selectedDays = <int>{}; // 0 = Monday, 6 = Sunday
  bool _isCustomTemplate = false;
  bool _isCustomGroup = false;
  
  final List<String> _dayNames = [
    'Monday',
    'Tuesday', 
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void dispose() {
    _pageController.dispose();
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
          _buildHeader(),
          
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildNameSelectionStep(),
                if (_isCustomTemplate) _buildCustomNameStep(),
                _buildGroupStep(),
                if (_isCustomGroup) _buildCustomGroupStep(),
                _buildDaysStep(),
              ],
            ),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final totalSteps = _getTotalSteps();
    final currentProgress = _currentStep;
    
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
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              tween: Tween<double>(
                begin: 0,
                end: totalSteps > 0 ? (currentProgress + 1) / totalSteps : 0,
              ),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: const Color(0xFF333333),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFFFFF)),
                );
              },
            ),
          ),
          const SizedBox(width: 20), // Right padding for symmetry
        ],
      ),
    );
  }


  int _getTotalSteps() {
    int steps = 1; // Name selection
    if (_isCustomTemplate) steps++; // Custom name
    steps++; // Group selection
    if (_isCustomGroup) steps++; // Custom group
    steps++; // Days selection
    return steps;
  }


  Widget _buildNameSelectionStep() {
    final templateOptions = [
      'Push',
      'Pull', 
      'Legs',
      'Upper',
      'Lower',
      'Full Body',
      'Arms',
      'Chest',
      'Back',
      'Shoulders',
      'Cardio',
      'Custom',
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Template Name',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Options list
          Expanded(
            child: ListView.builder(
              itemCount: templateOptions.length,
              itemBuilder: (context, index) {
                final option = templateOptions[index];
                final isSelected = _isCustomTemplate 
                    ? option == 'Custom'
                    : _templateName == option;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
                        settingsProvider.triggerHapticFeedback();
                        
                        setState(() {
                          if (option == 'Custom') {
                            _isCustomTemplate = true;
                            _templateName = '';
                          } else {
                            _isCustomTemplate = false;
                            _templateName = option;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFF2a2a2a),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF333333),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              option == 'Custom' ? Icons.edit : Icons.fitness_center,
                              color: isSelected 
                                  ? const Color(0xFF000000)
                                  : const Color(0xFF666666),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected 
                                    ? const Color(0xFF000000)
                                    : const Color(0xFFFFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomNameStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          
          // Title
          const Text(
            'Custom Template Name',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          const Text(
            'Enter a custom name for your workout template.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF999999),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Name input
          TextField(
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 18,
            ),
            decoration: InputDecoration(
              labelText: 'Template Name',
              hintText: 'e.g., "Heavy Bench Day", "Accessory Work"',
              labelStyle: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 16,
              ),
              hintStyle: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 16,
              ),
              filled: true,
              fillColor: const Color(0xFF2a2a2a),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFFFFFF),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
            onChanged: (value) {
              setState(() {
                _customTemplateName = value;
              });
            },
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupStep() {
    final groupOptions = [
      'Push Pull Legs',
      'Upper Lower', 
      'Full Body',
      'Strength Training',
      'Bodybuilding',
      'Powerlifting',
      'Athletic Performance',
      'Custom',
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // Title
          const Text(
            'Workout Group',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          const Text(
            'Choose a workout group to organize your templates.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF999999),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Group options
          Expanded(
            child: ListView.builder(
              itemCount: groupOptions.length,
              itemBuilder: (context, index) {
                final option = groupOptions[index];
                final isSelected = _isCustomGroup 
                    ? option == 'Custom'
                    : _groupName == option;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
                        settingsProvider.triggerHapticFeedback();
                        
                        setState(() {
                          if (option == 'Custom') {
                            _isCustomGroup = true;
                            _groupName = '';
                          } else {
                            _isCustomGroup = false;
                            _groupName = option;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFF2a2a2a),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF333333),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              option == 'Custom' ? Icons.edit : Icons.folder,
                              color: isSelected 
                                  ? const Color(0xFF000000)
                                  : const Color(0xFF666666),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected 
                                    ? const Color(0xFF000000)
                                    : const Color(0xFFFFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomGroupStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          
          // Title
          const Text(
            'Custom Group Name',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          const Text(
            'Create a custom group to organize your workout templates.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF999999),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Group name input
          TextField(
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 18,
            ),
            decoration: InputDecoration(
              labelText: 'Group Name',
              hintText: 'e.g., "My Program", "Contest Prep"',
              labelStyle: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 16,
              ),
              hintStyle: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 16,
              ),
              filled: true,
              fillColor: const Color(0xFF2a2a2a),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFFFFFF),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
            onChanged: (value) {
              setState(() {
                _customGroupName = value;
              });
            },
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
        ],
      ),
    );
  }



  Widget _buildDaysStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          
          // Title
          const Text(
            'Select Training Days',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          const Text(
            'Choose which days of the week you plan to follow this template.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF999999),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Days selection
          Column(
            children: List.generate(7, (index) {
              final isSelected = _selectedDays.contains(index);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedDays.remove(index);
                        } else {
                          _selectedDays.add(index);
                        }
                      });
                      
                      // Haptic feedback
                      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
                      settingsProvider.triggerHapticFeedback();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF2a2a2a),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFF333333),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isSelected 
                                ? const Color(0xFF000000)
                                : const Color(0xFF666666),
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            _dayNames[index],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: isSelected 
                                  ? const Color(0xFF000000)
                                  : const Color(0xFFFFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 24),
          
          // Summary
          if (_selectedDays.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF999999),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Template will be active on ${_selectedDays.length} day${_selectedDays.length == 1 ? '' : 's'} per week',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF333333), width: 1),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: TextButton(
                onPressed: _goToPreviousStep,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF333333),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 12),
          
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _handleNextAction : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFFFFFFF),
                disabledBackgroundColor: const Color(0xFF333333),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentStep < _getTotalSteps() - 1 ? 'Next' : 'Create Template',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _canProceed() 
                      ? const Color(0xFF000000)
                      : const Color(0xFF666666),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    final totalSteps = _getTotalSteps();
    int stepIndex = 0;
    
    // Step 0: Template name selection
    if (_currentStep == stepIndex) {
      return _templateName.isNotEmpty || _isCustomTemplate;
    }
    stepIndex++;
    
    // Step 1: Custom template name (if needed)
    if (_isCustomTemplate && _currentStep == stepIndex) {
      return _customTemplateName.trim().isNotEmpty;
    }
    if (_isCustomTemplate) stepIndex++;
    
    // Step 2: Group selection
    if (_currentStep == stepIndex) {
      return _groupName.isNotEmpty || _isCustomGroup;
    }
    stepIndex++;
    
    // Step 3: Custom group name (if needed)
    if (_isCustomGroup && _currentStep == stepIndex) {
      return _customGroupName.trim().isNotEmpty;
    }
    if (_isCustomGroup) stepIndex++;
    
    // Step 4: Days selection
    if (_currentStep == stepIndex) {
      return _selectedDays.isNotEmpty;
    }
    
    return false;
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleNextAction() {
    final totalSteps = _getTotalSteps();
    
    if (_currentStep < totalSteps - 1) {
      // Go to next step
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Create template
      _createTemplate();
    }
  }

  void _createTemplate() async {
    try {
      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      
      // Get final template name
      final finalTemplateName = _isCustomTemplate 
          ? _customTemplateName.trim()
          : _templateName.trim();
      
      // Get final group name  
      final finalGroupName = _isCustomGroup
          ? _customGroupName.trim()
          : _groupName.trim();
      
      // Create template with current model structure
      // Note: Group functionality would need to be added to the WorkoutTemplate model
      await workoutProvider.addTemplate(
        name: finalTemplateName,
        daysPerWeek: _selectedDays.length,
        exercises: [], // Start with no exercises - will be added later
      );
      
      settingsProvider.triggerHapticSuccess();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Template "$finalTemplateName" created successfully'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        settingsProvider.triggerHapticError();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create template: $e'),
            backgroundColor: const Color(0xFFFF4444),
          ),
        );
      }
    }
  }
}