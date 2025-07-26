import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class RestTimersScreen extends StatelessWidget {
  const RestTimersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        title: const Text(
          'Rest Timers',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF)),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),
              
              // Description
              const Text(
                'Set default rest times between sets. You can also customize rest times for specific exercises.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Default Rest Timer
              _buildSectionHeader('Default Rest Timer'),
              const SizedBox(height: 12),
              _buildTimerTile(
                context,
                title: 'Default Rest Time',
                subtitle: _formatDuration(settingsProvider.settings.defaultRestTimer),
                currentSeconds: settingsProvider.settings.defaultRestTimer,
                onChanged: (seconds) => settingsProvider.updateDefaultRestTimer(seconds),
              ),
              
              const SizedBox(height: 32),
              
              // Quick Presets
              _buildSectionHeader('Quick Presets'),
              const SizedBox(height: 12),
              _buildPresetRow(context, settingsProvider),
              
              const SizedBox(height: 32),
              
              // Custom Timers
              _buildSectionHeader('Custom Timers'),
              const SizedBox(height: 12),
              if (settingsProvider.settings.customRestTimers.isEmpty)
                _buildEmptyCustomTimers()
              else
                ...settingsProvider.settings.customRestTimers.entries.map(
                  (entry) => _buildCustomTimerTile(
                    context,
                    settingsProvider,
                    entry.key,
                    entry.value,
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Add Custom Timer Button
              _buildAddCustomTimerButton(context, settingsProvider),
              
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF666666),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTimerTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int currentSeconds,
    required Function(int) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFFFFFF),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF666666),
        ),
        onTap: () => _showTimerPicker(context, currentSeconds, onChanged),
      ),
    );
  }

  Widget _buildPresetRow(BuildContext context, SettingsProvider settingsProvider) {
    final presets = [30, 60, 90, 120, 180, 300]; // seconds
    
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: presets.length,
        itemBuilder: (context, index) {
          final seconds = presets[index];
          final isSelected = settingsProvider.settings.defaultRestTimer == seconds;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: Material(
              color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF3a3a3a),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => settingsProvider.updateDefaultRestTimer(seconds),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    _formatDuration(seconds),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyCustomTimers() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.timer,
            size: 32,
            color: Color(0xFF666666),
          ),
          SizedBox(height: 12),
          Text(
            'No custom timers',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Add custom named rest timers for different scenarios',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTimerTile(
    BuildContext context,
    SettingsProvider settingsProvider,
    String timerName,
    int seconds,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          timerName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFFFFFF),
          ),
        ),
        subtitle: Text(
          _formatDuration(seconds),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF666666), size: 20),
              onPressed: () => _showTimerPicker(
                context,
                seconds,
                (newSeconds) => settingsProvider.updateCustomRestTimer(timerName, newSeconds),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFFFF4444), size: 20),
              onPressed: () => settingsProvider.removeCustomRestTimer(timerName),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCustomTimerButton(BuildContext context, SettingsProvider settingsProvider) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.add,
          color: Color(0xFFFFFFFF),
        ),
        title: const Text(
          'Add Custom Timer',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFFFFFF),
          ),
        ),
        subtitle: const Text(
          'Create a custom named rest timer',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        onTap: () => _showAddCustomTimerDialog(context, settingsProvider),
      ),
    );
  }

  void _showTimerPicker(
    BuildContext context,
    int currentSeconds,
    Function(int) onChanged,
  ) {
    int minutes = currentSeconds ~/ 60;
    int seconds = currentSeconds % 60;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text(
          'Set Rest Timer',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Minutes
                    Column(
                      children: [
                        const Text(
                          'Minutes',
                          style: TextStyle(color: Color(0xFF999999), fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 80,
                          height: 120,
                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 40,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() => minutes = index);
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                if (index < 0 || index > 10) return null;
                                return Center(
                                  child: Text(
                                    '$index',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: index == minutes 
                                          ? const Color(0xFFFFFFFF) 
                                          : const Color(0xFF666666),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Seconds
                    Column(
                      children: [
                        const Text(
                          'Seconds',
                          style: TextStyle(color: Color(0xFF999999), fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 80,
                          height: 120,
                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 40,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() => seconds = index * 15);
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                final value = index * 15;
                                if (value < 0 || value > 59) return null;
                                return Center(
                                  child: Text(
                                    '$value',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: value == seconds 
                                          ? const Color(0xFFFFFFFF) 
                                          : const Color(0xFF666666),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ),
          TextButton(
            onPressed: () {
              onChanged(minutes * 60 + seconds);
              Navigator.pop(context);
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

  void _showAddCustomTimerDialog(BuildContext context, SettingsProvider settingsProvider) {
    String timerName = '';
    int restSeconds = 120;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text(
          'Add Custom Timer',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: Color(0xFFFFFFFF)),
              decoration: const InputDecoration(
                labelText: 'Timer Name',
                hintText: 'e.g., "Heavy Squats", "Light Sets"',
                labelStyle: TextStyle(color: Color(0xFF666666)),
                hintStyle: TextStyle(color: Color(0xFF666666)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF666666)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFFFFF)),
                ),
              ),
              onChanged: (value) => timerName = value,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Rest Time',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
              subtitle: Text(
                _formatDuration(restSeconds),
                style: const TextStyle(color: Color(0xFF666666)),
              ),
              trailing: const Icon(Icons.timer, color: Color(0xFF666666)),
              onTap: () => _showTimerPicker(
                context,
                restSeconds,
                (seconds) => restSeconds = seconds,
              ),
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
          TextButton(
            onPressed: () {
              if (timerName.isNotEmpty) {
                settingsProvider.updateCustomRestTimer(timerName, restSeconds);
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(color: Color(0xFFFFFFFF)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    }
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) {
      return '${minutes}m';
    }
    return '${minutes}m ${remainingSeconds}s';
  }
}