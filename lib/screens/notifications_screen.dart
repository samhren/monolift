import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        title: const Text(
          'Notifications',
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
                'Configure notifications for rest timers, workout reminders, and other alerts to help you stay on track with your training.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Main Toggle
              _buildSectionHeader('General'),
              const SizedBox(height: 12),
              _buildToggleTile(
                context,
                title: 'Enable Notifications',
                subtitle: settingsProvider.settings.notificationsEnabled 
                    ? 'App can send notifications'
                    : 'Notifications disabled',
                value: settingsProvider.settings.notificationsEnabled,
                onChanged: (value) => settingsProvider.updateNotifications(value),
              ),
              
              const SizedBox(height: 32),
              
              // Notification Types
              _buildSectionHeader('Notification Types'),
              const SizedBox(height: 12),
              _buildNotificationTypeSection(settingsProvider),
              
              const SizedBox(height: 32),
              
              // Permission Status
              _buildSectionHeader('Permissions'),
              const SizedBox(height: 12),
              _buildPermissionSection(context),
              
              const SizedBox(height: 32),
              
              // Information Section
              _buildSectionHeader('About Notifications'),
              const SizedBox(height: 12),
              _buildInfoSection(),
              
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

  Widget _buildToggleTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
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
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFFFFFFF),
        activeTrackColor: const Color(0xFF666666),
        inactiveThumbColor: const Color(0xFF666666),
        inactiveTrackColor: const Color(0xFF3a3a3a),
      ),
    );
  }

  Widget _buildNotificationTypeSection(SettingsProvider settingsProvider) {
    final enabled = settingsProvider.settings.notificationsEnabled;
    
    return Column(
      children: [
        _buildNotificationTypeTile(
          title: 'Rest Timer',
          subtitle: 'Alert when rest period is complete',
          icon: Icons.timer,
          enabled: enabled,
          // TODO: Add individual notification type settings
          value: enabled,
          onChanged: null, // Will be implemented when individual settings are added
        ),
        const SizedBox(height: 8),
        _buildNotificationTypeTile(
          title: 'Workout Reminders',
          subtitle: 'Daily reminders to work out',
          icon: Icons.event,
          enabled: enabled,
          value: enabled,
          onChanged: null,
        ),
        const SizedBox(height: 8),
        _buildNotificationTypeTile(
          title: 'Achievement Alerts',
          subtitle: 'New personal records and milestones',
          icon: Icons.emoji_events,
          enabled: enabled,
          value: enabled,
          onChanged: null,
        ),
      ],
    );
  }

  Widget _buildNotificationTypeTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool enabled,
    required bool value,
    required Function(bool)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: enabled ? const Color(0xFFFFFFFF) : const Color(0xFF666666),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: enabled ? const Color(0xFFFFFFFF) : const Color(0xFF666666),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        trailing: onChanged != null
            ? Switch(
                value: value && enabled,
                onChanged: enabled ? onChanged : null,
                activeColor: const Color(0xFFFFFFFF),
                activeTrackColor: const Color(0xFF666666),
                inactiveThumbColor: const Color(0xFF666666),
                inactiveTrackColor: const Color(0xFF3a3a3a),
              )
            : Icon(
                Icons.check_circle,
                color: enabled && value ? const Color(0xFF4CAF50) : const Color(0xFF666666),
                size: 20,
              ),
      ),
    );
  }

  Widget _buildPermissionSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.notifications,
              color: Color(0xFFFFFFFF),
              size: 22,
            ),
            title: const Text(
              'Notification Permission',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFFFFFF),
              ),
            ),
            subtitle: const Text(
              'Allow Monolift to send notifications',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            trailing: const Icon(
              Icons.settings,
              color: Color(0xFF666666),
            ),
            onTap: () => _showPermissionDialog(context),
          ),
          const Divider(color: Color(0xFF333333), height: 1),
          ListTile(
            leading: const Icon(
              Icons.phone_android,
              color: Color(0xFFFFFFFF),
              size: 22,
            ),
            title: const Text(
              'System Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFFFFFF),
              ),
            ),
            subtitle: const Text(
              'Open device notification settings',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            trailing: const Icon(
              Icons.open_in_new,
              color: Color(0xFF666666),
            ),
            onTap: () => _openSystemSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF666666),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Notification Types',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '• Rest Timer: Alerts when your rest period between sets is complete\n\n'
            '• Workout Reminders: Daily notifications to help maintain your routine\n\n'
            '• Achievement Alerts: Celebrate new personal records and milestones\n\n'
            'All notifications respect your device\'s Do Not Disturb settings and can be customized in your system settings.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text(
          'Notification Permission',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        content: const Text(
          'To receive rest timer alerts and workout reminders, please allow notifications for Monolift in your device settings.\n\nYou can manage notification preferences at any time in your system settings.',
          style: TextStyle(color: Color(0xFF999999)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Maybe Later',
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _requestNotificationPermission(context);
            },
            child: const Text(
              'Allow',
              style: TextStyle(color: Color(0xFFFFFFFF)),
            ),
          ),
        ],
      ),
    );
  }

  void _requestNotificationPermission(BuildContext context) {
    // TODO: Implement notification permission request
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification permission request will be implemented'),
        backgroundColor: Color(0xFF3a3a3a),
      ),
    );
  }

  void _openSystemSettings(BuildContext context) {
    // TODO: Implement opening system notification settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening system settings will be implemented'),
        backgroundColor: Color(0xFF3a3a3a),
      ),
    );
  }
}