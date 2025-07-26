import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class HapticFeedbackScreen extends StatelessWidget {
  const HapticFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        title: const Text(
          'Haptic Feedback',
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
                'Configure haptic feedback (vibration) for app interactions. This provides tactile feedback when you tap buttons, complete sets, and navigate the app.',
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
                title: 'Enable Haptic Feedback',
                subtitle: settingsProvider.settings.hapticFeedbackEnabled 
                    ? 'Vibration enabled for interactions'
                    : 'No vibration feedback',
                value: settingsProvider.settings.hapticFeedbackEnabled,
                onChanged: (value) => settingsProvider.updateHapticFeedback(value),
              ),
              
              const SizedBox(height: 32),
              
              // Test Section
              _buildSectionHeader('Test Haptic Feedback'),
              const SizedBox(height: 12),
              _buildTestSection(context, settingsProvider),
              
              const SizedBox(height: 32),
              
              // Information Section
              _buildSectionHeader('About Haptic Feedback'),
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

  Widget _buildTestSection(BuildContext context, SettingsProvider settingsProvider) {
    return Column(
      children: [
        _buildTestButton(
          context,
          title: 'Light Impact',
          subtitle: 'Button taps, navigation',
          icon: Icons.touch_app,
          onTap: () => settingsProvider.triggerHapticFeedback(),
          enabled: settingsProvider.settings.hapticFeedbackEnabled,
        ),
        const SizedBox(height: 8),
        _buildTestButton(
          context,
          title: 'Success Feedback',
          subtitle: 'Completing sets, saving data',
          icon: Icons.check_circle,
          onTap: () => settingsProvider.triggerHapticSuccess(),
          enabled: settingsProvider.settings.hapticFeedbackEnabled,
        ),
        const SizedBox(height: 8),
        _buildTestButton(
          context,
          title: 'Error Feedback',
          subtitle: 'Failed actions, warnings',
          icon: Icons.error,
          onTap: () => settingsProvider.triggerHapticError(),
          enabled: settingsProvider.settings.hapticFeedbackEnabled,
        ),
      ],
    );
  }

  Widget _buildTestButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
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
        trailing: enabled 
            ? const Icon(
                Icons.play_arrow,
                color: Color(0xFF666666),
              )
            : null,
        onTap: enabled ? onTap : null,
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
                'How Haptic Feedback Works',
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
            '• Light Impact: Subtle vibration for general interactions\n\n'
            '• Success Feedback: Gentle confirmation for completed actions\n\n'
            '• Error Feedback: Stronger vibration for warnings or errors\n\n'
            'Haptic feedback enhances the user experience by providing tactile confirmation of your actions, making the app feel more responsive and intuitive.',
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
}