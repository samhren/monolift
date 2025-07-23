import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
  Switch,
  Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';

interface Props {
  currentSettings: {
    cloudSync: boolean;
  };
  isCloudAvailable: boolean;
  onSettingsChange: (key: string, value: boolean) => void;
  onBack: () => void;
}

export const CloudSyncScreen: React.FC<Props> = ({ 
  currentSettings, 
  isCloudAvailable,
  onSettingsChange, 
  onBack 
}) => {
  const [settings, setSettings] = useState({
    cloudSync: currentSettings.cloudSync,
    autoSync: true,
    syncWorkouts: true,
    syncTemplates: true,
    syncSettings: true,
  });

  const [lastSyncTime] = useState(new Date());

  const updateSetting = (key: keyof typeof settings, value: boolean) => {
    setSettings(prev => ({ ...prev, [key]: value }));
    if (key === 'cloudSync') {
      onSettingsChange('cloudSync', value);
    }
  };

  const forceSync = async () => {
    Alert.alert(
      'Sync Data',
      'Force syncing your data with iCloud. This may take a moment.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Sync Now',
          onPress: async () => {
            // TODO: Implement actual sync logic
            Alert.alert('Sync Complete', 'Your data has been synced with iCloud.');
          },
        },
      ]
    );
  };

  const cloudOptions = [
    {
      id: 'cloudSync',
      title: 'Enable Cloud Sync',
      subtitle: isCloudAvailable ? 'Sync data with your iCloud account' : 'iCloud not available',
      value: settings.cloudSync && isCloudAvailable,
      icon: 'cloud' as const,
      disabled: !isCloudAvailable,
    },
    {
      id: 'autoSync',
      title: 'Automatic Sync',
      subtitle: 'Sync changes automatically in the background',
      value: settings.autoSync,
      icon: 'sync' as const,
      disabled: !settings.cloudSync || !isCloudAvailable,
    },
    {
      id: 'syncWorkouts',
      title: 'Sync Workout Sessions',
      subtitle: 'Include completed workouts and exercise data',
      value: settings.syncWorkouts,
      icon: 'fitness' as const,
      disabled: !settings.cloudSync || !isCloudAvailable,
    },
    {
      id: 'syncTemplates',
      title: 'Sync Workout Templates',
      subtitle: 'Include your custom workout templates',
      value: settings.syncTemplates,
      icon: 'document-text' as const,
      disabled: !settings.cloudSync || !isCloudAvailable,
    },
    {
      id: 'syncSettings',
      title: 'Sync App Settings',
      subtitle: 'Include preferences and configuration',
      value: settings.syncSettings,
      icon: 'settings' as const,
      disabled: !settings.cloudSync || !isCloudAvailable,
    },
  ];

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Ionicons name="arrow-back" size={24} color="#FFFFFF" />
        </TouchableOpacity>
        <Text style={styles.title}>Cloud Sync</Text>
        <View style={styles.headerSpacer} />
      </View>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {/* Status Card */}
        <View style={styles.statusSection}>
          <View style={[
            styles.statusCard,
            isCloudAvailable ? styles.statusCardAvailable : styles.statusCardUnavailable
          ]}>
            <View style={styles.statusIcon}>
              <Ionicons 
                name={isCloudAvailable ? "cloud-done" : "cloud-offline"} 
                size={32} 
                color={isCloudAvailable ? "#FFFFFF" : "#FF6B6B"} 
              />
            </View>
            <View style={styles.statusText}>
              <Text style={styles.statusTitle}>
                {isCloudAvailable ? 'iCloud Available' : 'iCloud Unavailable'}
              </Text>
              <Text style={styles.statusSubtitle}>
                {isCloudAvailable 
                  ? 'Connected and ready to sync your data'
                  : 'Check your iCloud settings and connection'
                }
              </Text>
              {isCloudAvailable && settings.cloudSync && (
                <Text style={styles.lastSync}>
                  Last sync: {lastSyncTime.toLocaleString()}
                </Text>
              )}
            </View>
          </View>
          
          {isCloudAvailable && settings.cloudSync && (
            <TouchableOpacity style={styles.syncButton} onPress={forceSync}>
              <Ionicons name="refresh" size={16} color="#000000" />
              <Text style={styles.syncButtonText}>Force Sync Now</Text>
            </TouchableOpacity>
          )}
        </View>

        {/* Settings */}
        <View style={styles.settingGroup}>
          <View style={styles.groupContainer}>
            {cloudOptions.map((option, index) => (
              <View 
                key={option.id} 
                style={[
                  styles.settingItem,
                  index === cloudOptions.length - 1 && styles.settingItemLast,
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

        {/* Info Section */}
        <View style={styles.infoSection}>
          <View style={styles.infoCard}>
            <Ionicons name="information-circle" size={20} color="#FFFFFF" />
            <Text style={styles.infoText}>
              Cloud sync uses your iCloud account to backup and synchronize your workout data 
              across all your devices. Your data remains private and is never shared with third parties.
            </Text>
          </View>
          
          {!isCloudAvailable && (
            <View style={styles.troubleshootCard}>
              <Ionicons name="warning" size={20} color="#FF6B6B" />
              <View style={styles.troubleshootText}>
                <Text style={styles.troubleshootTitle}>Troubleshooting</Text>
                <Text style={styles.troubleshootSubtitle}>
                  • Check that you're signed into iCloud in Settings{'\n'}
                  • Ensure iCloud Drive is enabled{'\n'}
                  • Verify you have an internet connection
                </Text>
              </View>
            </View>
          )}
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
  statusSection: {
    paddingHorizontal: 16,
    marginBottom: 32,
  },
  statusCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#1a1a1a',
    padding: 20,
    borderRadius: 12,
    marginBottom: 16,
  },
  statusCardAvailable: {
    borderLeftWidth: 3,
    borderLeftColor: '#FFFFFF',
  },
  statusCardUnavailable: {
    borderLeftWidth: 3,
    borderLeftColor: '#FF6B6B',
  },
  statusIcon: {
    marginRight: 16,
  },
  statusText: {
    flex: 1,
  },
  statusTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#FFFFFF',
    marginBottom: 4,
  },
  statusSubtitle: {
    fontSize: 14,
    color: '#999999',
    lineHeight: 18,
    marginBottom: 8,
  },
  lastSync: {
    fontSize: 12,
    color: '#666666',
    fontStyle: 'italic',
  },
  syncButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#FFFFFF',
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 8,
  },
  syncButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#000000',
    marginLeft: 8,
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
    marginBottom: 16,
  },
  infoText: {
    flex: 1,
    fontSize: 14,
    color: '#CCCCCC',
    lineHeight: 20,
    marginLeft: 12,
  },
  troubleshootCard: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    backgroundColor: '#1a1a1a',
    padding: 16,
    borderRadius: 12,
    borderLeftWidth: 3,
    borderLeftColor: '#FF6B6B',
  },
  troubleshootText: {
    flex: 1,
    marginLeft: 12,
  },
  troubleshootTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFFFFF',
    marginBottom: 8,
  },
  troubleshootSubtitle: {
    fontSize: 14,
    color: '#CCCCCC',
    lineHeight: 20,
  },
});