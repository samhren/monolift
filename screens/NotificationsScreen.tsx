import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
  Switch,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';

interface Props {
  currentSettings: {
    notifications: boolean;
  };
  onSettingsChange: (key: string, value: boolean) => void;
  onBack: () => void;
}

export const NotificationsScreen: React.FC<Props> = ({ 
  currentSettings, 
  onSettingsChange, 
  onBack 
}) => {
  const [settings, setSettings] = useState({
    notifications: currentSettings.notifications,
    restTimerAlerts: true,
    workoutReminders: false,
    achievementNotifications: true,
  });

  const updateSetting = (key: keyof typeof settings, value: boolean) => {
    setSettings(prev => ({ ...prev, [key]: value }));
    if (key === 'notifications') {
      onSettingsChange('notifications', value);
    }
  };

  const notificationOptions = [
    {
      id: 'notifications',
      title: 'Enable Notifications',
      subtitle: 'Allow the app to send notifications',
      value: settings.notifications,
      icon: 'notifications' as const,
    },
    {
      id: 'restTimerAlerts',
      title: 'Rest Timer Alerts',
      subtitle: 'Get notified when rest periods end',
      value: settings.restTimerAlerts,
      icon: 'timer' as const,
      disabled: !settings.notifications,
    },
    {
      id: 'workoutReminders',
      title: 'Workout Reminders',
      subtitle: 'Daily reminders to stay consistent',
      value: settings.workoutReminders,
      icon: 'fitness' as const,
      disabled: !settings.notifications,
    },
    {
      id: 'achievementNotifications',
      title: 'Achievement Alerts',
      subtitle: 'Celebrate personal records and milestones',
      value: settings.achievementNotifications,
      icon: 'trophy' as const,
      disabled: !settings.notifications,
    },
  ];

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Ionicons name="arrow-back" size={24} color="#FFFFFF" />
        </TouchableOpacity>
        <Text style={styles.title}>Notifications</Text>
        <View style={styles.headerSpacer} />
      </View>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        <View style={styles.settingGroup}>
          <View style={styles.groupContainer}>
            {notificationOptions.map((option, index) => (
              <View 
                key={option.id} 
                style={[
                  styles.settingItem,
                  index === notificationOptions.length - 1 && styles.settingItemLast,
                  option.disabled && styles.settingItemDisabled,
                ]}
              >
                <View style={styles.settingLeft}>
                  <View style={[
                    styles.iconContainer,
                    option.disabled && styles.iconContainerDisabled,
                  ]}>
                    <Ionicons
                      name={option.icon}
                      size={20}
                      color={option.disabled ? "#666" : "#FFFFFF"}
                    />
                  </View>
                  <View style={styles.settingText}>
                    <Text style={[
                      styles.settingTitle,
                      option.disabled && styles.settingTitleDisabled,
                    ]}>
                      {option.title}
                    </Text>
                    <Text style={[
                      styles.settingSubtitle,
                      option.disabled && styles.settingSubtitleDisabled,
                    ]}>
                      {option.subtitle}
                    </Text>
                  </View>
                </View>
                <Switch
                  value={option.value}
                  onValueChange={(value) => updateSetting(option.id as keyof typeof settings, value)}
                  trackColor={{ false: '#3a3a3a', true: '#FFFFFF' }}
                  thumbColor={option.value ? '#000000' : '#FFFFFF'}
                  disabled={option.disabled}
                />
              </View>
            ))}
          </View>
        </View>

        <View style={styles.infoSection}>
          <View style={styles.infoCard}>
            <Ionicons name="information-circle" size={20} color="#FFFFFF" />
            <Text style={styles.infoText}>
              Notification permissions are managed by your device settings. 
              If you don't receive notifications, check your system settings.
            </Text>
          </View>
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
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingVertical: 16,
    backgroundColor: '#000000',
  },
  backButton: {
    padding: 4,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#FFFFFF',
    flex: 1,
    textAlign: 'center',
  },
  headerSpacer: {
    width: 32,
  },
  content: {
    flex: 1,
    paddingTop: 20,
  },
  settingGroup: {
    marginBottom: 32,
  },
  groupContainer: {
    backgroundColor: '#1a1a1a',
    marginHorizontal: 16,
    borderRadius: 12,
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#3a3a3a',
  },
  settingItemLast: {
    borderBottomWidth: 0,
  },
  settingItemDisabled: {
    opacity: 0.5,
  },
  settingLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  iconContainer: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: '#3a3a3a',
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  iconContainerDisabled: {
    backgroundColor: '#3a3a3a',
  },
  settingText: {
    flex: 1,
  },
  settingTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFFFFF',
    marginBottom: 2,
  },
  settingTitleDisabled: {
    color: '#666666',
  },
  settingSubtitle: {
    fontSize: 14,
    color: '#999999',
    lineHeight: 18,
  },
  settingSubtitleDisabled: {
    color: '#666666',
  },
  infoSection: {
    paddingHorizontal: 16,
    marginBottom: 32,
  },
  infoCard: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    backgroundColor: '#1a1a1a',
    padding: 16,
    borderRadius: 12,
    borderLeftWidth: 3,
    borderLeftColor: '#FFFFFF',
  },
  infoText: {
    flex: 1,
    fontSize: 14,
    color: '#CCCCCC',
    lineHeight: 20,
    marginLeft: 12,
  },
});