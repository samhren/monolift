import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
  TextInput,
  Alert,
  Modal,
} from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { Ionicons } from '@expo/vector-icons';

interface RestTimer {
  id: string;
  name: string;
  seconds: number;
}

interface Props {
  onBack: () => void;
}

export const RestTimersScreen: React.FC<Props> = ({ onBack }) => {
  const [restTimers, setRestTimers] = useState<RestTimer[]>([
    { id: '1', name: 'Short Rest', seconds: 60 },
    { id: '2', name: 'Medium Rest', seconds: 120 },
    { id: '3', name: 'Long Rest', seconds: 180 },
  ]);

  const [showAddModal, setShowAddModal] = useState(false);
  const [newTimerName, setNewTimerName] = useState('');
  const [selectedMinutes, setSelectedMinutes] = useState(1);
  const [selectedSeconds, setSelectedSeconds] = useState(0);

  const formatTime = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const openAddModal = () => {
    setNewTimerName('');
    setSelectedMinutes(1);
    setSelectedSeconds(0);
    setShowAddModal(true);
  };

  const addRestTimer = () => {
    if (!newTimerName.trim()) {
      Alert.alert('Error', 'Please enter a timer name');
      return;
    }

    const totalSeconds = selectedMinutes * 60 + selectedSeconds;
    if (totalSeconds === 0) {
      Alert.alert('Error', 'Timer must be at least 1 second');
      return;
    }

    const newTimer: RestTimer = {
      id: Date.now().toString(),
      name: newTimerName.trim(),
      seconds: totalSeconds,
    };

    setRestTimers(prev => [...prev, newTimer]);
    setShowAddModal(false);
  };

  const deleteRestTimer = (id: string) => {
    Alert.alert(
      'Delete Timer',
      'Are you sure you want to delete this rest timer?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: () => setRestTimers(prev => prev.filter(timer => timer.id !== id)),
        },
      ]
    );
  };

  const renderAddModal = () => {
    return (
      <Modal
        visible={showAddModal}
        transparent
        animationType="slide"
        onRequestClose={() => setShowAddModal(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <TouchableOpacity onPress={() => setShowAddModal(false)}>
                <Text style={styles.modalCancel}>Cancel</Text>
              </TouchableOpacity>
              <Text style={styles.modalTitle}>Add Timer</Text>
              <TouchableOpacity onPress={addRestTimer}>
                <Text style={styles.modalSave}>Save</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.inputSection}>
              <Text style={styles.inputLabel}>Timer Name</Text>
              <TextInput
                style={styles.nameInput}
                placeholder="Enter timer name"
                placeholderTextColor="#666"
                value={newTimerName}
                onChangeText={setNewTimerName}
              />
            </View>

            <View style={styles.timeSection}>
              <Text style={styles.inputLabel}>Duration</Text>
              <View style={styles.pickerContainer}>
                <View style={styles.pickerColumn}>
                  <Text style={styles.pickerLabel}>Minutes</Text>
                  <View style={styles.pickerWrapper}>
                    <Picker
                      selectedValue={selectedMinutes}
                      onValueChange={(value) => setSelectedMinutes(value)}
                      style={styles.picker}
                      itemStyle={styles.pickerItem}
                    >
                      {Array.from({ length: 10 }, (_, i) => (
                        <Picker.Item
                          key={i}
                          label={i.toString()}
                          value={i}
                          color="#FFFFFF"
                        />
                      ))}
                    </Picker>
                  </View>
                </View>
                <Text style={styles.timeSeparator}>:</Text>
                <View style={styles.pickerColumn}>
                  <Text style={styles.pickerLabel}>Seconds</Text>
                  <View style={styles.pickerWrapper}>
                    <Picker
                      selectedValue={selectedSeconds}
                      onValueChange={(value) => setSelectedSeconds(value)}
                      style={styles.picker}
                      itemStyle={styles.pickerItem}
                    >
                      {Array.from({ length: 60 }, (_, i) => (
                        <Picker.Item
                          key={i}
                          label={i.toString().padStart(2, '0')}
                          value={i}
                          color="#FFFFFF"
                        />
                      ))}
                    </Picker>
                  </View>
                </View>
              </View>
            </View>
          </View>
        </View>
      </Modal>
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Ionicons name="arrow-back" size={24} color="#FFFFFF" />
        </TouchableOpacity>
        <Text style={styles.title}>Rest Timers</Text>
        <TouchableOpacity style={styles.addHeaderButton} onPress={openAddModal}>
          <Ionicons name="add" size={24} color="#FFFFFF" />
        </TouchableOpacity>
      </View>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {restTimers.length === 0 ? (
          <View style={styles.emptyState}>
            <Ionicons name="timer-outline" size={64} color="#666" />
            <Text style={styles.emptyTitle}>No Rest Timers</Text>
            <Text style={styles.emptySubtitle}>
              Add your first rest timer to get started
            </Text>
          </View>
        ) : (
          <View style={styles.timersList}>
            {restTimers.map((timer, index) => (
              <View key={timer.id} style={[
                styles.timerCard,
                index === restTimers.length - 1 && styles.timerCardLast
              ]}>
                <View style={styles.timerCardContent}>
                  <View style={styles.timerIconContainer}>
                    <Ionicons name="timer" size={24} color="#FFFFFF" />
                  </View>
                  <View style={styles.timerInfo}>
                    <Text style={styles.timerName}>{timer.name}</Text>
                    <Text style={styles.timerDuration}>{formatTime(timer.seconds)}</Text>
                  </View>
                  <TouchableOpacity
                    style={styles.deleteButton}
                    onPress={() => deleteRestTimer(timer.id)}
                  >
                    <Ionicons name="trash-outline" size={20} color="#FF6B6B" />
                  </TouchableOpacity>
                </View>
              </View>
            ))}
          </View>
        )}

        <TouchableOpacity style={styles.addTimerButton} onPress={openAddModal}>
          <Ionicons name="add-circle" size={24} color="#FFFFFF" />
          <Text style={styles.addTimerText}>Add New Timer</Text>
        </TouchableOpacity>
      </ScrollView>

      {renderAddModal()}
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
    justifyContent: 'space-between',
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
  addHeaderButton: {
    padding: 4,
  },
  content: {
    flex: 1,
    paddingTop: 20,
  },
  emptyState: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 80,
    paddingHorizontal: 40,
  },
  emptyTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#FFFFFF',
    marginTop: 16,
    marginBottom: 8,
  },
  emptySubtitle: {
    fontSize: 16,
    color: '#666666',
    textAlign: 'center',
    lineHeight: 22,
  },
  timersList: {
    paddingHorizontal: 16,
  },
  timerCard: {
    backgroundColor: '#1a1a1a',
    borderRadius: 16,
    marginBottom: 12,
    overflow: 'hidden',
  },
  timerCardLast: {
    marginBottom: 24,
  },
  timerCardContent: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 18,
  },
  timerIconContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: '#3a3a3a',
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 16,
  },
  timerInfo: {
    flex: 1,
  },
  timerName: {
    fontSize: 18,
    fontWeight: '600',
    color: '#FFFFFF',
    marginBottom: 4,
  },
  timerDuration: {
    fontSize: 15,
    color: '#999999',
    fontWeight: '500',
  },
  deleteButton: {
    padding: 12,
    borderRadius: 8,
  },
  addTimerButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#1a1a1a',
    marginHorizontal: 16,
    paddingVertical: 18,
    borderRadius: 16,
    borderWidth: 2,
    borderColor: '#3a3a3a',
    borderStyle: 'dashed',
  },
  addTimerText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFFFFF',
    marginLeft: 8,
  },
  // Modal Styles
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#1a1a1a',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    paddingBottom: 40,
  },
  modalHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 24,
    paddingVertical: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#3a3a3a',
  },
  modalCancel: {
    fontSize: 16,
    color: '#666666',
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  modalSave: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFFFFF',
  },
  inputSection: {
    paddingHorizontal: 24,
    paddingTop: 24,
  },
  inputLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFFFFF',
    marginBottom: 12,
  },
  nameInput: {
    backgroundColor: '#2a2a2a',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
    color: '#FFFFFF',
    fontSize: 16,
  },
  timeSection: {
    paddingHorizontal: 24,
    paddingTop: 32,
  },
  pickerContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#2a2a2a',
    borderRadius: 12,
    paddingVertical: 20,
  },
  pickerColumn: {
    flex: 1,
    alignItems: 'center',
  },
  pickerLabel: {
    fontSize: 14,
    fontWeight: '500',
    color: '#999999',
    marginBottom: 8,
  },
  pickerWrapper: {
    width: '100%',
    height: 200,
  },
  picker: {
    width: '100%',
    height: 200,
    color: '#FFFFFF',
  },
  pickerItem: {
    fontSize: 18,
    color: '#FFFFFF',
  },
  timeSeparator: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#FFFFFF',
    marginHorizontal: 20,
    alignSelf: 'center',
    marginTop: 40,
  },
});