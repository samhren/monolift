import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/settings_models.dart';
import '../services/data_service.dart';
import '../services/export_service.dart';
import 'rest_timers_screen.dart';
import 'haptic_feedback_screen.dart';
import 'notifications_screen.dart';
import 'weight_unit_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Function(VoidCallback)? onScrollCallbackReady;
  
  const SettingsScreen({super.key, this.onScrollCallbackReady});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Provide scroll-to-top callback to parent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onScrollCallbackReady?.call(_scrollToTop);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ],
              ),
            ),
            
            // Settings list
            Expanded(
              child: Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                  const SizedBox(height: 16),
                  
                  // Cloud Sync section
                  _buildSectionHeader('Cloud Sync'),
                  const SizedBox(height: 8),
                  _buildSettingsTile(
                    context,
                    icon: Icons.cloud,
                    title: 'iCloud Sync',
                    subtitle: 'Sync data across your devices',
                    onTap: () => _showCloudSyncInfo(context),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Workout Settings section
                  _buildSectionHeader('Workout Settings'),
                  const SizedBox(height: 8),
                  _buildSettingsTile(
                    context,
                    icon: Icons.schedule,
                    title: 'Rest Timers',
                    subtitle: settingsProvider.settings.customRestTimers.isNotEmpty 
                        ? 'Default: ${_formatDuration(settingsProvider.settings.defaultRestTimer)} • ${settingsProvider.settings.customRestTimers.length} custom'
                        : 'Default: ${_formatDuration(settingsProvider.settings.defaultRestTimer)}',
                    onTap: () => _navigateToRestTimers(context),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.vibration,
                    title: 'Haptic Feedback',
                    subtitle: settingsProvider.settings.hapticFeedbackEnabled ? 'Enabled' : 'Disabled',
                    onTap: () => _navigateToHapticFeedback(context),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: settingsProvider.settings.notificationsEnabled ? 'Enabled' : 'Disabled',
                    onTap: () => _navigateToNotifications(context),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Units section
                  _buildSectionHeader('Units'),
                  const SizedBox(height: 8),
                  _buildSettingsTile(
                    context,
                    icon: Icons.straighten,
                    title: 'Weight Unit',
                    subtitle: settingsProvider.settings.weightUnit.displayName,
                    onTap: () => _navigateToWeightUnit(context),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Data section
                  _buildSectionHeader('Data'),
                  const SizedBox(height: 8),
                  _buildSettingsTile(
                    context,
                    icon: Icons.file_download,
                    title: 'Export Data',
                    subtitle: 'Download your workout data',
                    onTap: () => _showExportDialog(context),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.delete_sweep,
                    title: 'Clear All Data',
                    subtitle: 'Remove all workout data',
                    onTap: () => _showClearDataConfirmation(context),
                    textColor: const Color(0xFFFF4444),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // About section
                  _buildSectionHeader('About'),
                  const SizedBox(height: 8),
                  _buildSettingsTile(
                    context,
                    icon: Icons.info,
                    title: 'App Version',
                    subtitle: '1.0.0',
                    onTap: null,
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.privacy_tip,
                    title: 'Privacy',
                    subtitle: 'Your data stays on your device',
                    onTap: () => _showPrivacyInfo(context),
                  ),
                  
                  const SizedBox(height: 32),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF666666),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: textColor ?? const Color(0xFFFFFFFF),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor ?? const Color(0xFFFFFFFF),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        trailing: onTap != null
            ? const Icon(
                Icons.chevron_right,
                color: Color(0xFF666666),
              )
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showCloudSyncInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text(
          'iCloud Sync',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        content: const Text(
          'Your workout data automatically syncs to iCloud and across all your devices. Data is encrypted and private to your iCloud account.',
          style: TextStyle(color: Color(0xFF999999)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFFFFFFFF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text(
          'Privacy',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        content: const Text(
          'Monolift is completely privacy-focused:\n\n• No data is sent to external servers\n• All data stays in your iCloud\n• No analytics or tracking\n• No ads or data collection\n\nYour workout data is yours alone.',
          style: TextStyle(color: Color(0xFF999999)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFFFFFFFF)),
            ),
          ),
        ],
      ),
    );
  }


  void _showClearDataConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text(
          'Clear All Data',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        content: const Text(
          'This will permanently delete all your workout data including templates, sessions, and progress. This action cannot be undone.\n\nAre you sure you want to continue?',
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
              _clearAllData(context);
            },
            child: const Text(
              'Clear Data',
              style: TextStyle(color: Color(0xFFFF4444)),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllData(BuildContext context) async {
    try {
      await DataService.clearAllData();
      
      // Clear settings provider data
      if (context.mounted) {
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        await settingsProvider.clearAllData();
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared successfully'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear data: $e'),
            backgroundColor: const Color(0xFFFF4444),
          ),
        );
      }
    }
  }

  // Navigation methods
  void _navigateToRestTimers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RestTimersScreen()),
    );
  }

  void _navigateToHapticFeedback(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HapticFeedbackScreen()),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  void _navigateToWeightUnit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WeightUnitScreen()),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text(
          'Export Data',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose export format:',
              style: TextStyle(color: Color(0xFF999999)),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.code, color: Color(0xFFFFFFFF)),
              title: const Text(
                'JSON Format',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
              subtitle: const Text(
                'Complete data with full structure',
                style: TextStyle(color: Color(0xFF666666)),
              ),
              onTap: () {
                Navigator.pop(context);
                _exportData(context, 'json');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.table_chart, color: Color(0xFFFFFFFF)),
              title: const Text(
                'CSV Format',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
              subtitle: const Text(
                'Spreadsheet-compatible format',
                style: TextStyle(color: Color(0xFF666666)),
              ),
              onTap: () {
                Navigator.pop(context);
                _exportData(context, 'csv');
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

  void _exportData(BuildContext context, String format) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          backgroundColor: Color(0xFF2a2a2a),
          content: Row(
            children: [
              CircularProgressIndicator(color: Color(0xFFFFFFFF)),
              SizedBox(width: 16),
              Text(
                'Exporting data...',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
            ],
          ),
        ),
      );

      // TODO: Get actual data from providers
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      
      await ExportService.exportAllData(
        workoutTemplates: [], // TODO: Get from workout provider
        workoutSessions: [], // TODO: Get from workout provider  
        exercises: [], // TODO: Get from exercise provider
        settings: settingsProvider.settings,
        format: format,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: const Color(0xFFFF4444),
          ),
        );
      }
    }
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