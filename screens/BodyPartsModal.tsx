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
import { DaysSelectionModal } from './DaysSelectionModal';

interface BodyPartsModalProps {
  visible: boolean;
  onClose: () => void;
}

const muscleGroups = [
  'Chest', 'Back', 'Shoulders', 'Arms', 'Legs',
  'Glutes', 'Core', 'Calves', 'Forearms'
];

export const BodyPartsModal: React.FC<BodyPartsModalProps> = ({
  visible,
  onClose,
}) => {
  const [selectedGroups, setSelectedGroups] = useState<string[]>([]);
  const [showDays, setShowDays] = useState(false);

  const toggleGroup = (group: string) => {
    setSelectedGroups(prev => 
      prev.includes(group) 
        ? prev.filter(g => g !== group)
        : [...prev, group]
    );
  };

  const combinedWorkoutName = selectedGroups.length === 0 
    ? 'Body Parts'
    : selectedGroups.length === 1 
      ? selectedGroups[0]
      : selectedGroups.join(' + ');

  const handleNext = () => {
    if (selectedGroups.length > 0) {
      setShowDays(true);
    }
  };

  const handleCloseAll = () => {
    setShowDays(false);
    setSelectedGroups([]);
    onClose();
  };

  return (
    <>
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
            <Text style={styles.title}>Body Parts</Text>
            <TouchableOpacity 
              onPress={handleNext}
              style={[styles.nextButton, selectedGroups.length === 0 && styles.disabledButton]}
              disabled={selectedGroups.length === 0}
            >
              <Text style={[styles.nextText, selectedGroups.length === 0 && styles.disabledText]}>
                Next
              </Text>
            </TouchableOpacity>
          </View>

          <ScrollView style={styles.content}>
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>Selected</Text>
              <ScrollView 
                horizontal 
                showsHorizontalScrollIndicator={false}
                style={styles.selectedContainer}
                contentContainerStyle={styles.selectedContent}
              >
                {selectedGroups.length === 0 ? (
                  <View style={styles.placeholderPill}>
                    <Text style={styles.placeholderText}>Tap muscle groups below</Text>
                  </View>
                ) : (
                  selectedGroups.map((group) => (
                    <TouchableOpacity
                      key={group}
                      style={styles.selectedPill}
                      onPress={() => toggleGroup(group)}
                    >
                      <Text style={styles.selectedPillText}>{group}</Text>
                    </TouchableOpacity>
                  ))
                )}
              </ScrollView>
            </View>

            <View style={styles.section}>
              <Text style={styles.sectionTitle}>Available</Text>
              <View style={styles.muscleGrid}>
                {muscleGroups
                  .filter(group => !selectedGroups.includes(group))
                  .map((group) => (
                    <TouchableOpacity
                      key={group}
                      style={styles.muscleButton}
                      onPress={() => toggleGroup(group)}
                    >
                      <Text style={styles.muscleButtonText}>{group}</Text>
                    </TouchableOpacity>
                  ))}
              </View>
            </View>
          </ScrollView>
        </SafeAreaView>
      </Modal>

      <DaysSelectionModal
        visible={showDays}
        workoutName={combinedWorkoutName}
        onClose={handleCloseAll}
      />
    </>
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
  nextButton: {
    padding: 4,
  },
  nextText: {
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
    padding: 24,
  },
  section: {
    marginBottom: 32,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#FFFFFF',
    marginBottom: 12,
  },
  selectedContainer: {
    backgroundColor: '#1a1a1a',
    borderRadius: 12,
    height: 50,
  },
  selectedContent: {
    paddingHorizontal: 12,
    alignItems: 'center',
    minWidth: '100%',
    justifyContent: 'center',
  },
  placeholderPill: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: '#3a3a3a',
    borderStyle: 'dashed',
  },
  placeholderText: {
    fontSize: 14,
    color: '#3a3a3a',
  },
  selectedPill: {
    backgroundColor: '#FFFFFF',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 16,
    marginRight: 8,
  },
  selectedPillText: {
    fontSize: 14,
    fontWeight: '500',
    color: '#000000',
  },
  muscleGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  muscleButton: {
    backgroundColor: '#3a3a3a',
    paddingHorizontal: 12,
    paddingVertical: 12,
    borderRadius: 16,
    minWidth: '30%',
    alignItems: 'center',
    marginBottom: 8,
  },
  muscleButtonText: {
    fontSize: 14,
    fontWeight: '500',
    color: '#FFFFFF',
  },
});