import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Animated,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { WorkoutTemplate } from '../types/workout';

interface WorkoutTemplateCardProps {
  template: WorkoutTemplate;
  onPress: () => void;
}

export const WorkoutTemplateCard: React.FC<WorkoutTemplateCardProps> = ({
  template,
  onPress,
}) => {
  const [scaleAnim] = useState(new Animated.Value(1));

  const handlePressIn = () => {
    Animated.spring(scaleAnim, {
      toValue: 0.98,
      useNativeDriver: true,
    }).start();
  };

  const handlePressOut = () => {
    Animated.spring(scaleAnim, {
      toValue: 1,
      useNativeDriver: true,
    }).start();
  };

  return (
    <Animated.View style={[styles.container, { transform: [{ scale: scaleAnim }] }]}>
      <TouchableOpacity
        style={styles.button}
        onPress={onPress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        activeOpacity={1}
      >
        <View style={styles.content}>
          <View style={styles.leftContent}>
            <Text style={styles.title}>{template.name}</Text>
            <Text style={styles.subtitle}>
              {template.exercises?.length || 0} exercises
            </Text>
            {template.daysPerWeek > 0 && (
              <Text style={styles.days}>
                {template.daysPerWeek} days per week
              </Text>
            )}
          </View>
          
          <View style={styles.rightContent}>
            <Ionicons name="play" size={24} color="#FFFFFF" />
          </View>
        </View>
      </TouchableOpacity>
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: 16,
  },
  button: {
    backgroundColor: '#3a3a3a',
    borderRadius: 12,
    padding: 16,
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  leftContent: {
    flex: 1,
  },
  rightContent: {
    marginLeft: 16,
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    color: '#FFFFFF',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 14,
    color: '#3a3a3a',
  },
  days: {
    fontSize: 12,
    color: '#3a3a3a',
    marginTop: 4,
  },
});