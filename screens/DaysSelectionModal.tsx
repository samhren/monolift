import React, { useState } from 'react';
import {
  View,
  Text,
  Modal,
  StyleSheet,
  SafeAreaView,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useWorkout } from '../contexts/WorkoutContext';

interface DaysSelectionModalProps {
  visible: boolean;
  workoutName: string;
  onClose: () => void;
}

const weekdays = [
  { index: 1, name: 'Monday' },
  { index: 2, name: 'Tuesday' },
  { index: 3, name: 'Wednesday' },
  { index: 4, name: 'Thursday' },
  { index: 5, name: 'Friday' },
  { index: 6, name: 'Saturday' },
  { index: 0, name: 'Sunday' },
];

export const DaysSelectionModal: React.FC<DaysSelectionModalProps> = ({
  visible,
  workoutName,
  onClose,
}) => {
  const [selectedDays, setSelectedDays] = useState<Set<number>>(new Set());
  const [focusedIndex, setFocusedIndex] = useState(0);
  const { addTemplate } = useWorkout();

  const toggleDay = (dayIndex: number, arrayIndex: number) => {
    const newSelectedDays = new Set(selectedDays);
    if (newSelectedDays.has(dayIndex)) {
      newSelectedDays.delete(dayIndex);
    } else {
      newSelectedDays.add(dayIndex);
    }
    setSelectedDays(newSelectedDays);
    setFocusedIndex(arrayIndex);
  };

  const handleSave = async () => {
    try {
      await addTemplate({
        name: workoutName,
        daysPerWeek: selectedDays.size,
      });
      onClose();
    } catch (error) {
      console.error('Failed to save template:', error);
    }
  };

  return (
    <Modal
      visible={visible}
      animationType="slide"
      presentationStyle="pageSheet"
    >
      <SafeAreaView style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity onPress={onClose} style={styles.cancelButton}>
            <Text style={styles.cancelText}>Cancel</Text>
          </TouchableOpacity>
          <Text style={styles.title}>Days</Text>
          <TouchableOpacity 
            onPress={handleSave}
            style={[styles.saveButton, selectedDays.size === 0 && styles.disabledButton]}
            disabled={selectedDays.size === 0}
          >
            <Text style={[styles.saveText, selectedDays.size === 0 && styles.disabledText]}>
              Save
            </Text>
          </TouchableOpacity>
        </View>

        <ScrollView style={styles.content}>
          <View style={styles.daysContainer}>
            {weekdays.map((day, index) => {
              const distance = Math.abs(index - focusedIndex);
              const scale = Math.max(0.6, 1.0 - distance * 0.15);
              const opacity = Math.max(0.3, 1.0 - distance * 0.25);
              const isSelected = selectedDays.has(day.index);

              return (
                <TouchableOpacity
                  key={day.index}
                  style={[
                    styles.dayButton,
                    index === focusedIndex && styles.focusedDay,
                    { transform: [{ scale }], opacity },
                  ]}
                  onPress={() => toggleDay(day.index, index)}
                >
                  <View style={styles.dayContent}>
                    <Text
                      style={[
                        styles.dayText,
                        index === focusedIndex && styles.focusedDayText,
                      ]}
                    >
                      {day.name}
                    </Text>
                    {isSelected && (
                      <Ionicons
                        name="checkmark-circle"
                        size={16}
                        color="#FFFFFF"
                        style={{ opacity }}
                      />
                    )}
                  </View>
                </TouchableOpacity>
              );
            })}
          </View>
        </ScrollView>
      </SafeAreaView>
    </Modal>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000000',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 0.5,
    borderBottomColor: '#3a3a3a',
  },
  cancelButton: {
    padding: 4,
  },
  cancelText: {
    fontSize: 17,
    color: '#FFFFFF',
  },
  title: {
    fontSize: 17,
    fontWeight: '600',
    color: '#FFFFFF',
  },
  saveButton: {
    padding: 4,
  },
  saveText: {
    fontSize: 17,
    color: '#FFFFFF',
    fontWeight: '600',
  },
  disabledButton: {
    opacity: 0.5,
  },
  disabledText: {
    color: '#666666',
  },
  content: {
    flex: 1,
  },
  daysContainer: {
    flex: 1,
    justifyContent: 'center',
    paddingVertical: 100,
  },
  dayButton: {
    paddingVertical: 8,
    marginBottom: 16,
  },
  focusedDay: {
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 8,
    marginHorizontal: 20,
  },
  dayContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 24,
    paddingVertical: 8,
  },
  dayText: {
    fontSize: 20,
    color: '#FFFFFF',
  },
  focusedDayText: {
    fontWeight: '500',
  },
});