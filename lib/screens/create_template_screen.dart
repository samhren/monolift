import 'dart:math';
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
  final ScrollController _nameScrollController = ScrollController();
  int _currentStep = 0;
  bool _isInitializing = true;
  bool _isNavigatingBack = false;
  bool _isManuallyScrolling = false;

  // Template data
  String _templateName = '';
  String _customTemplateName = '';
  String _groupName = '';
  String _customGroupName = '';
  Set<int> _selectedDays = <int>{}; // 0 = Monday, 6 = Sunday
  bool _isCustomTemplate = false;
  bool _isCustomGroup = false;
  bool _isTypingCustomGroupName = false;

  // Selection tracking
  int _selectedTemplateIndex = -1;
  int _selectedGroupIndex = -1;
  int _selectedCustomGroupIndex = -1;
  final ScrollController _groupScrollController = ScrollController();
  final ScrollController _customGroupScrollController = ScrollController();

  final List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> _dayAbbreviations = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize with first item (Push) selected and centered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedTemplateIndex = 0;
          _templateName = 'Push'; // Set template name to first option
        });
        _scrollToIndex(0);

        // Enable scroll listener after initial scroll completes
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isInitializing = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameScrollController.dispose();
    _groupScrollController.dispose();
    _customGroupScrollController.dispose();
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

                // When returning to template name page, re-center on selected item
                if (index == 0 && _selectedTemplateIndex >= 0) {
                  setState(() {
                    _isNavigatingBack = true;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _scrollToIndex(_selectedTemplateIndex);
                      // Re-enable scroll listener after scroll completes
                      Future.delayed(const Duration(milliseconds: 400), () {
                        if (mounted) {
                          setState(() {
                            _isNavigatingBack = false;
                          });
                        }
                      });
                    }
                  });
                }

                // When returning to group page, re-center on selected item
                if (index == (_isCustomTemplate ? 2 : 1) &&
                    _selectedGroupIndex >= 0) {
                  setState(() {
                    _isNavigatingBack = true;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _scrollToGroupIndex(_selectedGroupIndex);
                      // Re-enable scroll listener after scroll completes
                      Future.delayed(const Duration(milliseconds: 400), () {
                        if (mounted) {
                          setState(() {
                            _isNavigatingBack = false;
                          });
                        }
                      });
                    }
                  });
                }

                // When returning to custom group page, re-center on selected item
                final customGroupStepIndex = (_isCustomTemplate ? 3 : 2);
                if (index == customGroupStepIndex &&
                    _selectedCustomGroupIndex >= 0 &&
                    _isCustomGroup) {
                  setState(() {
                    _isNavigatingBack = true;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _scrollToCustomGroupIndex(_selectedCustomGroupIndex);
                      // Re-enable scroll listener after scroll completes
                      Future.delayed(const Duration(milliseconds: 400), () {
                        if (mounted) {
                          setState(() {
                            _isNavigatingBack = false;
                          });
                        }
                      });
                    }
                  });
                }
              },
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildNameSelectionStep(),
                if (_isCustomTemplate) _buildCustomNameStep(),
                _buildGroupStep(),
                if (_isCustomGroup) _buildCustomGroupStep(),
                if (_isTypingCustomGroupName) _buildTypeCustomGroupStep(),
                _buildDaysStep(),
              ],
            ),
          ),
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
            onPressed: () {
              if (_currentStep > 0) {
                _goToPreviousStep();
              } else {
                Navigator.pop(context);
              }
            },
            icon: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              tween: Tween<double>(
                begin: 0,
                end: _currentStep > 0
                    ? 0.25
                    : 0, // 0.25 = 90 degrees (quarter turn right to face left)
              ),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 2 * 3.14159, // Convert to radians
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFFFFFFFF),
                    size: 28,
                  ),
                );
              },
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
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFFFFF),
                  ),
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
    if (_isTypingCustomGroupName) steps++; // Type custom group name
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

          // Options list with center-based selection
          Expanded(
            child: Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    _updateSelectedIndexBasedOnScroll(templateOptions.length);
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
                        controller: _nameScrollController,
                        physics: const ClampingScrollPhysics(),
                        itemCount:
                            templateOptions.length + (2 * paddingItemCount),
                        itemBuilder: (context, index) {
                          // Add padding items at start and end
                          if (index < paddingItemCount ||
                              index >=
                                  templateOptions.length + paddingItemCount) {
                            return const SizedBox(height: 46.0);
                          }

                          final optionIndex = index - paddingItemCount;
                          final option = templateOptions[optionIndex];
                          final isSelected =
                              optionIndex == _selectedTemplateIndex;

                          return Container(
                            height:
                                44, // Even smaller height for tighter spacing
                            margin: const EdgeInsets.only(
                              bottom: 2,
                            ), // Minimal margin
                            child: InkWell(
                              onTap: () {
                                _selectTemplateAtIndex(optionIndex, option);
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
                                          height:
                                              1.2, // Add line height to prevent cutoff
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    if (isSelected)
                                      GestureDetector(
                                        onTap: () {
                                          if (_canProceed()) {
                                            _handleNextAction();
                                          }
                                        },
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
    );
  }

  void _updateSelectedIndexBasedOnScroll(int itemCount) {
    if (!_nameScrollController.hasClients ||
        _isInitializing ||
        _isNavigatingBack ||
        _isManuallyScrolling) {
      return;
    }

    final scrollOffset = _nameScrollController.offset;
    const itemHeight = 46.0; // 44 height + 2 margin
    final viewportHeight = _nameScrollController.position.viewportDimension;
    final centerOffset = scrollOffset + (viewportHeight / 2);

    // Account for padding items - use same calculation as UI
    final paddingItemCount = (viewportHeight / itemHeight / 2).round().clamp(
      3,
      8,
    );
    final adjustedCenterOffset = centerOffset - (paddingItemCount * itemHeight);

    final newSelectedIndex = (adjustedCenterOffset / itemHeight).round().clamp(
      0,
      itemCount - 1,
    );

    if (newSelectedIndex != _selectedTemplateIndex) {
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
        'Custom',
      ];

      final option = templateOptions[newSelectedIndex];

      setState(() {
        _selectedTemplateIndex = newSelectedIndex;
        // Update the logical state based on the new selection
        if (option == 'Custom') {
          _isCustomTemplate = true;
          _templateName = '';
        } else {
          _isCustomTemplate = false;
          _templateName = option;
        }
      });
    }
  }

  void _selectTemplateAtIndex(int index, String option) {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    settingsProvider.triggerHapticFeedback();

    setState(() {
      _selectedTemplateIndex = index;
      _isManuallyScrolling =
          true; // Disable scroll listener during manual scroll
      if (option == 'Custom') {
        _isCustomTemplate = true;
        _templateName = '';
      } else {
        _isCustomTemplate = false;
        _templateName = option;
      }
    });

    // Scroll to center the selected item
    _scrollToIndex(index);

    // Re-enable scroll listener after animation completes
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _isManuallyScrolling = false;
        });
      }
    });
  }

  void _updateGroupSelectedIndexBasedOnScroll(int itemCount) {
    if (!_groupScrollController.hasClients ||
        _isInitializing ||
        _isNavigatingBack ||
        _isManuallyScrolling) {
      return;
    }

    final scrollOffset = _groupScrollController.offset;
    const itemHeight = 46.0; // 44 height + 2 margin
    final viewportHeight = _groupScrollController.position.viewportDimension;
    final centerOffset = scrollOffset + (viewportHeight / 2);

    // Account for padding items - use same calculation as UI
    final paddingItemCount = (viewportHeight / itemHeight / 2).round().clamp(
      3,
      8,
    );
    final adjustedCenterOffset = centerOffset - (paddingItemCount * itemHeight);

    final newSelectedIndex = (adjustedCenterOffset / itemHeight).round().clamp(
      0,
      itemCount - 1,
    );

    if (newSelectedIndex != _selectedGroupIndex) {
      // Get the group options (same as in _buildGroupStep)
      final existingGroups = <String>[]; // This would come from data source
      final groupOptions = [
        ...existingGroups,
        if (existingGroups.isEmpty) 'None',
        'Create New Group',
      ];

      final option = groupOptions[newSelectedIndex];

      setState(() {
        _selectedGroupIndex = newSelectedIndex;
        // Update the logical state based on the new selection
        if (option == 'Create New Group') {
          _isCustomGroup = true;
          _groupName = '';
        } else if (option == 'None') {
          _isCustomGroup = false;
          _groupName = '';
        } else {
          _isCustomGroup = false;
          _groupName = option;
        }
      });
    }
  }

  void _selectGroupAtIndex(int index, String option) {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    settingsProvider.triggerHapticFeedback();

    setState(() {
      _selectedGroupIndex = index;
      _isManuallyScrolling =
          true; // Disable scroll listener during manual scroll
      if (option == 'Create New Group') {
        _isCustomGroup = true;
        _groupName = '';
      } else if (option == 'None') {
        _isCustomGroup = false;
        _groupName = '';
      } else {
        _isCustomGroup = false;
        _groupName = option;
      }
    });

    // Scroll to center the selected item
    _scrollToGroupIndex(index);

    // Re-enable scroll listener after animation completes
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _isManuallyScrolling = false;
        });
      }
    });
  }

  void _scrollToGroupIndex(int index) {
    if (!_groupScrollController.hasClients) return;

    const itemHeight = 46.0; // 44 height + 2 margin
    final viewportHeight = _groupScrollController.position.viewportDimension;

    // Use exact same calculation as UI to ensure consistency
    final paddingItemCount = (viewportHeight / itemHeight / 2).round().clamp(
      3,
      8,
    );

    // Calculate target offset to center the item precisely
    final targetItemPosition = (index + paddingItemCount) * itemHeight;
    final targetOffset =
        targetItemPosition - (viewportHeight / 2) + (itemHeight / 2);

    _groupScrollController.animateTo(
      targetOffset.clamp(0.0, _groupScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _updateCustomGroupSelectedIndexBasedOnScroll(int itemCount) {
    if (!_customGroupScrollController.hasClients ||
        _isInitializing ||
        _isNavigatingBack ||
        _isManuallyScrolling) {
      return;
    }

    final scrollOffset = _customGroupScrollController.offset;
    const itemHeight = 46.0; // 44 height + 2 margin
    final viewportHeight =
        _customGroupScrollController.position.viewportDimension;
    final centerOffset = scrollOffset + (viewportHeight / 2);

    // Account for padding items - use same calculation as UI
    final paddingItemCount = (viewportHeight / itemHeight / 2).round().clamp(
      3,
      8,
    );
    final adjustedCenterOffset = centerOffset - (paddingItemCount * itemHeight);

    final newSelectedIndex = (adjustedCenterOffset / itemHeight).round().clamp(
      0,
      itemCount - 1,
    );

    if (newSelectedIndex != _selectedCustomGroupIndex) {
      // Get the custom group options (same as in _buildCustomGroupStep)
      final customGroupOptions = ['PPL', 'UL', 'UL/PPL', 'Arnold', 'Custom'];

      final option = customGroupOptions[newSelectedIndex];

      setState(() {
        _selectedCustomGroupIndex = newSelectedIndex;
        // Update the logical state based on the new selection
        if (option == 'Custom') {
          _isTypingCustomGroupName = true;
          _customGroupName = '';
        } else {
          _isTypingCustomGroupName = false;
          _customGroupName = option;
        }
      });
    }
  }

  void _selectCustomGroupAtIndex(int index, String option) {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    settingsProvider.triggerHapticFeedback();

    setState(() {
      _selectedCustomGroupIndex = index;
      _isManuallyScrolling =
          true; // Disable scroll listener during manual scroll
      if (option == 'Custom') {
        _isTypingCustomGroupName = true;
        _customGroupName = '';
      } else {
        _isTypingCustomGroupName = false;
        _customGroupName = option;
      }
    });

    // Scroll to center the selected item
    _scrollToCustomGroupIndex(index);

    // Re-enable scroll listener after animation completes
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _isManuallyScrolling = false;
        });
      }
    });
  }

  void _scrollToCustomGroupIndex(int index) {
    if (!_customGroupScrollController.hasClients) return;

    const itemHeight = 46.0; // 44 height + 2 margin
    final viewportHeight =
        _customGroupScrollController.position.viewportDimension;

    // Use exact same calculation as UI to ensure consistency
    final paddingItemCount = (viewportHeight / itemHeight / 2).round().clamp(
      3,
      8,
    );

    // Calculate target offset to center the item precisely
    final targetItemPosition = (index + paddingItemCount) * itemHeight;
    final targetOffset =
        targetItemPosition - (viewportHeight / 2) + (itemHeight / 2);

    _customGroupScrollController.animateTo(
      targetOffset.clamp(
        0.0,
        _customGroupScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToIndex(int index) {
    if (!_nameScrollController.hasClients) return;

    const itemHeight = 46.0; // 44 height + 2 margin
    final viewportHeight = _nameScrollController.position.viewportDimension;

    // Use exact same calculation as UI to ensure consistency
    final paddingItemCount = (viewportHeight / itemHeight / 2).round().clamp(
      3,
      8,
    );

    // Calculate target offset to center the item precisely
    final targetItemPosition = (index + paddingItemCount) * itemHeight;
    final targetOffset =
        targetItemPosition - (viewportHeight / 2) + (itemHeight / 2);

    _nameScrollController.animateTo(
      targetOffset.clamp(0.0, _nameScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
            style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 18),
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

          const Spacer(),

          // Continue button
          if (_customTemplateName.trim().isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_canProceed()) {
                    _handleNextAction();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
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

  Widget _buildGroupStep() {
    final workoutProvider = Provider.of<WorkoutProvider>(
      context,
      listen: false,
    );
    final existingGroups = workoutProvider.getExistingGroupNames();

    // Build group options - show existing groups + none + create new option
    final groupOptions = [...existingGroups, 'None', 'Create New Group'];

    // Initialize group selection if not set
    if (_selectedGroupIndex == -1 && groupOptions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedGroupIndex = 0;
            final firstOption = groupOptions[0];
            if (firstOption == 'Create New Group') {
              _isCustomGroup = true;
              _groupName = '';
            } else if (firstOption == 'None') {
              _isCustomGroup = false;
              _groupName = '';
            } else {
              _isCustomGroup = false;
              _groupName = firstOption;
            }
          });
          _scrollToGroupIndex(0);
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Workout Group',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),

          const SizedBox(height: 24),

          // Options list with center-based selection
          Expanded(
            child: Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    _updateGroupSelectedIndexBasedOnScroll(groupOptions.length);
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
                        controller: _groupScrollController,
                        physics: const ClampingScrollPhysics(),
                        itemCount: groupOptions.length + (2 * paddingItemCount),
                        itemBuilder: (context, index) {
                          // Add padding items at start and end
                          if (index < paddingItemCount ||
                              index >= groupOptions.length + paddingItemCount) {
                            return const SizedBox(height: 46.0);
                          }

                          final optionIndex = index - paddingItemCount;
                          final option = groupOptions[optionIndex];
                          final isSelected = optionIndex == _selectedGroupIndex;

                          return Container(
                            height:
                                44, // Even smaller height for tighter spacing
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
                                          height:
                                              1.2, // Add line height to prevent cutoff
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    if (isSelected)
                                      GestureDetector(
                                        onTap: () {
                                          if (_canProceed()) {
                                            _handleNextAction();
                                          }
                                        },
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
    );
  }

  Widget _buildCustomGroupStep() {
    // Common workout split options
    final customGroupOptions = ['PPL', 'UL', 'UL/PPL', 'Arnold', 'Custom'];

    // Initialize custom group selection if not set
    if (_selectedCustomGroupIndex == -1 && customGroupOptions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedCustomGroupIndex = 0;
            _customGroupName = customGroupOptions[0];
          });
          _scrollToCustomGroupIndex(0);
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Group Name',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),

          const SizedBox(height: 24),

          // Options list with center-based selection
          Expanded(
            child: Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    _updateCustomGroupSelectedIndexBasedOnScroll(
                      customGroupOptions.length,
                    );
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
                        controller: _customGroupScrollController,
                        physics: const ClampingScrollPhysics(),
                        itemCount:
                            customGroupOptions.length + (2 * paddingItemCount),
                        itemBuilder: (context, index) {
                          // Add padding items at start and end
                          if (index < paddingItemCount ||
                              index >=
                                  customGroupOptions.length +
                                      paddingItemCount) {
                            return const SizedBox(height: 46.0);
                          }

                          final optionIndex = index - paddingItemCount;
                          final option = customGroupOptions[optionIndex];
                          final isSelected =
                              optionIndex == _selectedCustomGroupIndex;

                          return Container(
                            height:
                                44, // Even smaller height for tighter spacing
                            margin: const EdgeInsets.only(
                              bottom: 2,
                            ), // Minimal margin
                            child: InkWell(
                              onTap: () {
                                _selectCustomGroupAtIndex(optionIndex, option);
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
                                          height:
                                              1.2, // Add line height to prevent cutoff
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    if (isSelected)
                                      GestureDetector(
                                        onTap: () {
                                          if (_canProceed()) {
                                            _handleNextAction();
                                          }
                                        },
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
    );
  }

  Widget _buildTypeCustomGroupStep() {
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
            'Enter a custom name for your workout group.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF999999),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 32),

          // Group name input
          TextField(
            style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 18),
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

          const Spacer(),

          // Continue button
          if (_customGroupName.trim().isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_canProceed()) {
                    _handleNextAction();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
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

  Widget _buildDaysStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Training Days',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          const Text(
            'Choose which days you plan to follow this template.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF999999),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 32),

          // Days selection - Circular grid layout
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Week visualization in a circular pattern
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      children: List.generate(7, (index) {
                        final isSelected = _selectedDays.contains(index);

                        // Calculate position in circle
                        final angle =
                            (index * 2 * 3.14159) / 7 -
                            3.14159 / 2; // Start from top
                        final radius = 100.0;
                        final x =
                            140 +
                            radius * cos(angle) -
                            35; // Center and adjust for button size
                        final y = 140 + radius * sin(angle) - 35;

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

                              // Haptic feedback
                              final settingsProvider =
                                  Provider.of<SettingsProvider>(
                                    context,
                                    listen: false,
                                  );
                              settingsProvider.triggerHapticFeedback();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 0),
                              width: 70,
                              height: 70,
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
                                          color: const Color(
                                            0xFFFFFFFF,
                                          ).withValues(alpha: 0.3),
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
                                    fontSize: 16,
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

                  const SizedBox(height: 40),

                  // Selection summary
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
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

                  const SizedBox(height: 32),

                  // Create button - always visible, greyed out when no days selected
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedDays.isNotEmpty
                          ? () {
                              if (_canProceed()) {
                                _handleNextAction();
                              }
                            }
                          : null, // Disabled when no days selected
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _selectedDays.isNotEmpty
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF333333),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Create Template',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _selectedDays.isNotEmpty
                              ? const Color(0xFF000000)
                              : const Color(0xFF666666),
                        ),
                      ),
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

  bool _canProceed() {
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
      return _selectedGroupIndex >=
          0; // Any selection is valid (including "None")
    }
    stepIndex++;

    // Step 3: Custom group name (if needed)
    if (_isCustomGroup && _currentStep == stepIndex) {
      return _selectedCustomGroupIndex >= 0;
    }
    if (_isCustomGroup) stepIndex++;

    // Step 4: Type custom group name (if needed)
    if (_isTypingCustomGroupName && _currentStep == stepIndex) {
      return _customGroupName.trim().isNotEmpty;
    }
    if (_isTypingCustomGroupName) stepIndex++;

    // Step 5: Days selection
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
      final workoutProvider = Provider.of<WorkoutProvider>(
        context,
        listen: false,
      );
      final settingsProvider = Provider.of<SettingsProvider>(
        context,
        listen: false,
      );

      // Get final template name
      final finalTemplateName = _isCustomTemplate
          ? _customTemplateName.trim()
          : _templateName.trim();

      // Get final group name
      String? finalGroupName;
      if (_isCustomGroup && _isTypingCustomGroupName) {
        finalGroupName = _customGroupName.trim().isNotEmpty
            ? _customGroupName.trim()
            : null;
      } else if (_isCustomGroup && !_isTypingCustomGroupName) {
        finalGroupName = _customGroupName.trim().isNotEmpty
            ? _customGroupName.trim()
            : null;
      } else if (!_isCustomGroup &&
          _groupName.trim().isNotEmpty &&
          _groupName.trim() != 'None') {
        finalGroupName = _groupName.trim();
      }

      // Create template with group functionality
      await workoutProvider.addTemplate(
        name: finalTemplateName,
        daysPerWeek: _selectedDays.length,
        exercises: [], // Start with no exercises - will be added later
        groupName: finalGroupName,
      );

      settingsProvider.triggerHapticSuccess();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final settingsProvider = Provider.of<SettingsProvider>(
          context,
          listen: false,
        );
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
