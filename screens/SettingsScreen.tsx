import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
  Switch,
  Alert,
  Linking,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { CloudStorage, useIsCloudAvailable } from 'react-native-cloud-storage';
import { useWorkout } from '../contexts/WorkoutContext';

interface SettingsItem {
  id: string;
  title: string;
  subtitle?: string;
  type: 'toggle' | 'action' | 'info';
  value?: boolean;
  onPress?: () => void;
  onToggle?: (value: boolean) => void;
  icon?: keyof typeof Ionicons.glyphMap;
}

export const SettingsScreen: React.FC = () => {
  const { templates, refreshTemplates } = useWorkout();
  const isCloudAvailable = useIsCloudAvailable();
  const [settings, setSettings] = useState({
    cloudSync: true,
    darkMode: true,
    notifications: true,
    hapticFeedback: true,
  });

  const updateSetting = (key: keyof typeof settings, value: boolean) => {
    setSettings(prev => ({ ...prev, [key]: value }));
    // TODO: Persist settings to storage
  };

  const exportData = async () => {
    try {
      const data = {
        templates,
        exportDate: new Date().toISOString(),
        version: '1.0.0',
      };
      
      Alert.alert(
        'Export Data',
        'Data export functionality will be implemented here. This would generate a JSON file with all your workout data.',
        [{ text: 'OK' }]
      );
    } catch (error) {
      Alert.alert('Error', 'Failed to export data');
    }
  };

  const clearAllData = () => {
    Alert.alert(
      'Clear All Data',
      'This will permanently delete all your workout templates and data. This action cannot be undone.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete All',
          style: 'destructive',
          onPress: async () => {
            try {
              // TODO: Implement data clearing
              Alert.alert('Success', 'All data has been cleared');
            } catch (error) {
              Alert.alert('Error', 'Failed to clear data');
            }
          },
        },
      ]
    );
  };

  const openGitHub = () => {
    Linking.openURL('https://github.com/your-username/monolift-rn');
  };

  const openSupport = () => {
    Linking.openURL('mailto:support@monolift.app?subject=Monolift Support');
  };

  const settingsData: SettingsItem[] = [
    // Cloud & Sync
    {
      id: 'cloud-status',
      title: 'iCloud Status',
      subtitle: isCloudAvailable ? 'Connected and syncing' : 'Not available',
      type: 'info',
      icon: 'cloud',
    },
    {
      id: 'cloud-sync',
      title: 'Cloud Sync',
      subtitle: 'Automatically sync data to iCloud',
      type: 'toggle',
      value: settings.cloudSync,
      onToggle: (value) => updateSetting('cloudSync', value),
      icon: 'sync',
    },

    // App Preferences
    {
      id: 'notifications',
      title: 'Notifications',
      subtitle: 'Rest timer and workout reminders',
      type: 'toggle',
      value: settings.notifications,
      onToggle: (value) => updateSetting('notifications', value),
      icon: 'notifications',
    },
    {
      id: 'haptic',
      title: 'Haptic Feedback',
      subtitle: 'Vibrations for button presses',
      type: 'toggle',
      value: settings.hapticFeedback,
      onToggle: (value) => updateSetting('hapticFeedback', value),
      icon: 'phone-portrait',
    },

    // Data Management
    {
      id: 'export',
      title: 'Export Data',
      subtitle: 'Create a backup of your workout data',
      type: 'action',
      onPress: exportData,
      icon: 'download',
    },
    {
      id: 'refresh',
      title: 'Refresh Data',
      subtitle: 'Reload data from cloud storage',
      type: 'action',
      onPress: refreshTemplates,
      icon: 'refresh',
    },
    {
      id: 'clear',
      title: 'Clear All Data',
      subtitle: 'Permanently delete all workout data',
      type: 'action',
      onPress: clearAllData,
      icon: 'trash',
    },

    // About
    {
      id: 'templates-count',
      title: 'Workout Templates',
      subtitle: `${templates.length} templates created`,
      type: 'info',
      icon: 'barbell',
    },
    {
      id: 'version',
      title: 'Version',
      subtitle: '1.0.0',
      type: 'info',
      icon: 'information-circle',
    },
    {
      id: 'github',
      title: 'Source Code',
      subtitle: 'View on GitHub',
      type: 'action',
      onPress: openGitHub,
      icon: 'logo-github',
    },
    {
      id: 'support',
      title: 'Support',
      subtitle: 'Get help or report issues',
      type: 'action',
      onPress: openSupport,
      icon: 'help-circle',
    },
  ];

  const renderSettingItem = (item: SettingsItem) => {
    return (
      <View key={item.id} style={styles.settingItem}>
        <TouchableOpacity
          style={styles.settingButton}
          onPress={item.onPress}
          disabled={item.type !== 'action'}
        >
          <View style={styles.settingLeft}>
            {item.icon && (
              <Ionicons
                name={item.icon}
                size={20}
                color="#FFFFFF"
                style={styles.settingIcon}
              />
            )}
            <View style={styles.settingText}>
              <Text style={styles.settingTitle}>{item.title}</Text>
              {item.subtitle && (
                <Text style={styles.settingSubtitle}>{item.subtitle}</Text>
              )}
            </View>
          </View>

          {item.type === 'toggle' && (
            <Switch
              value={item.value}
              onValueChange={item.onToggle}
              trackColor={{ false: '#3a3a3a', true: '#FFFFFF' }}
              thumbColor={item.value ? '#000000' : '#FFFFFF'}
            />
          )}

          {item.type === 'action' && (
            <Ionicons name="chevron-forward" size={16} color="#666666" />
          )}
        </TouchableOpacity>
      </View>
    );
  };

  const groupedSettings = [
    {
      title: 'Cloud & Sync',
      items: settingsData.slice(0, 2),
    },
    {
      title: 'Preferences',
      items: settingsData.slice(2, 4),
    },
    {
      title: 'Data',
      items: settingsData.slice(4, 7),
    },
    {
      title: 'About',
      items: settingsData.slice(7),
    },
  ];

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Settings</Text>
      </View>

      <ScrollView style={styles.content}>
        {groupedSettings.map((group, index) => (
          <View key={index} style={styles.settingGroup}>
            <Text style={styles.groupTitle}>{group.title}</Text>
            <View style={styles.groupContainer}>
              {group.items.map(renderSettingItem)}
            </View>
          </View>
        ))}

        <View style={styles.footer}>
          <Text style={styles.footerText}>
            Monolift - Minimalist Strength Training Tracker
          </Text>
          <Text style={styles.footerSubtext}>
            Privacy-focused • Offline-first • iCloud sync
          </Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000000',
  },
  header: {
    paddingHorizontal: 24,
    paddingVertical: 8,
    backgroundColor: '#000000',
  },
  title: {
    fontSize: 34,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  content: {
    flex: 1,
  },
  settingGroup: {
    marginBottom: 32,
  },
  groupTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#FFFFFF',
    paddingHorizontal: 24,
    marginBottom: 12,
  },
  groupContainer: {
    backgroundColor: '#1a1a1a',
    marginHorizontal: 16,
    borderRadius: 12,
  },
  settingItem: {
    borderBottomWidth: 1,
    borderBottomColor: '#3a3a3a',
  },
  settingButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 16,
  },
  settingLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  settingIcon: {
    marginRight: 12,
    width: 20,
  },
  settingText: {
    flex: 1,
  },
  settingTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: '#FFFFFF',
    marginBottom: 2,
  },
  settingSubtitle: {
    fontSize: 14,
    color: '#666666',
  },
  footer: {
    paddingHorizontal: 24,
    paddingVertical: 32,
    alignItems: 'center',
  },
  footerText: {
    fontSize: 16,
    fontWeight: '500',
    color: '#FFFFFF',
    textAlign: 'center',
    marginBottom: 8,
  },
  footerSubtext: {
    fontSize: 14,
    color: '#666666',
    textAlign: 'center',
  },
});