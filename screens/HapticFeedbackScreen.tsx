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
import * as Haptics from 'expo-haptics';

interface Props {
  currentSettings: {
    hapticFeedback: boolean;
  };
  onSettingsChange: (key: string, value: boolean) => void;
  onBack: () => void;
}

export const HapticFeedbackScreen: React.FC<Props> = ({ 
  currentSettings, 
  onSettingsChange, 
  onBack 
}) => {
  const [settings, setSettings] = useState({
    hapticFeedback: currentSettings.hapticFeedback,
    buttonTaps: true,
    setCompletion: true,
    timerAlerts: true,
    navigationFeedback: false,
  });

  const updateSetting = (key: keyof typeof settings, value: boolean) => {
    setSettings(prev => ({ ...prev, [key]: value }));
    if (key === 'hapticFeedback') {
      onSettingsChange('hapticFeedback', value);
    }
  };

  const testHaptic = (type: 'light' | 'medium' | 'heavy' | 'selection') => {
    if (!settings.hapticFeedback) return;
    
    switch (type) {
      case 'light':
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
        break;
      case 'medium':
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
        break;
      case 'heavy':
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
        break;
      case 'selection':
        Haptics.selectionAsync();
        break;
    }
  };

  const hapticOptions = [
    {
      id: 'hapticFeedback',
      title: 'Enable Haptic Feedback',
      subtitle: 'Allow the app to provide vibration feedback',
      value: settings.hapticFeedback,
      icon: 'phone-portrait' as const,
    },
    {
      id: 'buttonTaps',
      title: 'Button Interactions',
      subtitle: 'Vibrate when tapping buttons and controls',
      value: settings.buttonTaps,
      icon: 'finger-print' as const,
      disabled: !settings.hapticFeedback,
    },
    {
      id: 'setCompletion',
      title: 'Set Completion',
      subtitle: 'Feedback when completing exercise sets',
      value: settings.setCompletion,
      icon: 'checkmark-circle' as const,
      disabled: !settings.hapticFeedback,
    },
    {
      id: 'timerAlerts',
      title: 'Timer Notifications',
      subtitle: 'Vibrate when rest timers complete',
      value: settings.timerAlerts,
      icon: 'alarm' as const,
      disabled: !settings.hapticFeedback,
    },
    {
      id: 'navigationFeedback',
      title: 'Navigation Feedback',
      subtitle: 'Subtle feedback when switching screens',
      value: settings.navigationFeedback,
      icon: 'navigate' as const,
      disabled: !settings.hapticFeedback,
    },
  ];

  const testButtons = [
    { id: 'light', label: 'Light', type: 'light' as const },
    { id: 'medium', label: 'Medium', type: 'medium' as const },
    { id: 'heavy', label: 'Heavy', type: 'heavy' as const },
    { id: 'selection', label: 'Selection', type: 'selection' as const },
  ];

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Ionicons name="arrow-back" size={24} color="#FFFFFF" />
        </TouchableOpacity>
        <Text style={styles.title}>Haptic Feedback</Text>
        <View style={styles.headerSpacer} />
      </View>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        <View style={styles.settingGroup}>
          <View style={styles.groupContainer}>
            {hapticOptions.map((option, index) => (
              <View 
                key={option.id} 
                style={[
                  styles.settingItem,
                  index === hapticOptions.length - 1 && styles.settingItemLast,
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

        {settings.hapticFeedback && (
          <View style={styles.testSection}>
            <Text style={styles.sectionTitle}>Test Haptic Feedback</Text>
            <View style={styles.testButtons}>
              {testButtons.map((button) => (
                <TouchableOpacity
                  key={button.id}
                  style={styles.testButton}
                  onPress={() => testHaptic(button.type)}
                >
                  <Text style={styles.testButtonText}>{button.label}</Text>
                </TouchableOpacity>
              ))}
            </View>
            <Text style={styles.testDescription}>
              Tap the buttons above to test different haptic feedback intensities
            </Text>
          </View>
        )}

        <View style={styles.infoSection}>
          <View style={styles.infoCard}>
            <Ionicons name="information-circle" size={20} color="#FFFFFF" />
            <Text style={styles.infoText}>
              Haptic feedback enhances your workout experience with tactile responses. 
              Intensity may vary based on your device model and system settings.
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
  testSection: {
    paddingHorizontal: 16,
    marginBottom: 32,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#FFFFFF',
    marginBottom: 16,
    textAlign: 'center',
  },
  testButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  testButton: {
    flex: 1,
    backgroundColor: '#1a1a1a',
    paddingVertical: 12,
    paddingHorizontal: 8,
    borderRadius: 8,
    marginHorizontal: 4,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#3a3a3a',
  },
  testButtonText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#FFFFFF',
  },
  testDescription: {
    fontSize: 14,
    color: '#999999',
    textAlign: 'center',
    lineHeight: 18,
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