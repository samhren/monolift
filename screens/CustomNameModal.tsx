import React, { useState } from 'react';
import {
  View,
  Text,
  Modal,
  StyleSheet,
  SafeAreaView,
  TouchableOpacity,
  TextInput,
} from 'react-native';
import { DaysSelectionModal } from './DaysSelectionModal';

interface CustomNameModalProps {
  visible: boolean;
  onClose: () => void;
}

export const CustomNameModal: React.FC<CustomNameModalProps> = ({
  visible,
  onClose,
}) => {
  const [customName, setCustomName] = useState('');
  const [showDays, setShowDays] = useState(false);

  const handleNext = () => {
    if (customName.trim()) {
      setShowDays(true);
    }
  };

  const handleCloseAll = () => {
    setShowDays(false);
    setCustomName('');
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
            <Text style={styles.title}>Custom Name</Text>
            <TouchableOpacity 
              onPress={handleNext}
              style={[styles.nextButton, !customName.trim() && styles.disabledButton]}
              disabled={!customName.trim()}
            >
              <Text style={[styles.nextText, !customName.trim() && styles.disabledText]}>
                Next
              </Text>
            </TouchableOpacity>
          </View>

          <View style={styles.content}>
            <TextInput
              style={styles.textInput}
              placeholder="Workout name"
              placeholderTextColor="#666666"
              value={customName}
              onChangeText={setCustomName}
              autoFocus
            />
          </View>
        </SafeAreaView>
      </Modal>

      <DaysSelectionModal
        visible={showDays}
        workoutName={customName}
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
  textInput: {
    backgroundColor: '#3a3a3a',
    borderRadius: 8,
    padding: 16,
    fontSize: 16,
    color: '#FFFFFF',
  },
});