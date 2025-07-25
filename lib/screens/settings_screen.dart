import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              child: ListView(
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
                    subtitle: 'Configure default rest periods',
                    onTap: () => _showComingSoon(context, 'Rest timer settings'),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.vibration,
                    title: 'Haptic Feedback',
                    subtitle: 'Enable vibration for interactions',
                    onTap: () => _showComingSoon(context, 'Haptic feedback settings'),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Workout reminders and alerts',
                    onTap: () => _showComingSoon(context, 'Notification settings'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Units section
                  _buildSectionHeader('Units'),
                  const SizedBox(height: 8),
                  _buildSettingsTile(
                    context,
                    icon: Icons.straighten,
                    title: 'Weight Unit',
                    subtitle: 'Pounds (lbs)',
                    onTap: () => _showComingSoon(context, 'Weight unit selection'),
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
                    onTap: () => _showComingSoon(context, 'Data export'),
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
      margin: const EdgeInsets.only(bottom: 1),
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
        tileColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon'),
        backgroundColor: const Color(0xFF3a3a3a),
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
      // TODO: Implement clear all data functionality
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clear data functionality coming soon'),
          backgroundColor: Color(0xFF3a3a3a),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to clear data'),
          backgroundColor: Color(0xFFFF4444),
        ),
      );
    }
  }
}