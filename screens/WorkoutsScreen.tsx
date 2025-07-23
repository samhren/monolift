import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useWorkout } from '../contexts/WorkoutContext';
import { WorkoutTemplateCard } from '../components/WorkoutTemplateCard';
import { AddTemplateModal } from './AddTemplateModal';

export const WorkoutsScreen: React.FC = () => {
  const { templates, loading } = useWorkout();
  const [showAddTemplate, setShowAddTemplate] = useState(false);

  const handleStartWorkout = (templateId: string) => {
    // TODO: Navigate to workout session
    console.log('Starting workout:', templateId);
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Workouts</Text>
        <TouchableOpacity
          style={styles.addButton}
          onPress={() => setShowAddTemplate(true)}
        >
          <Ionicons name="add" size={18} color="#FFFFFF" />
        </TouchableOpacity>
      </View>

      <ScrollView style={styles.content} contentContainerStyle={styles.contentContainer}>
        {templates.length === 0 ? (
          <View style={styles.emptyState}>
            <Ionicons name="barbell" size={60} color="#3a3a3a" />
            <Text style={styles.emptyTitle}>No Workout Templates</Text>
            <Text style={styles.emptySubtitle}>
              Create your first workout template to get started
            </Text>
          </View>
        ) : (
          templates.map((template) => (
            <WorkoutTemplateCard
              key={template.id}
              template={template}
              onPress={() => handleStartWorkout(template.id)}
            />
          ))
        )}
      </ScrollView>

      <AddTemplateModal
        visible={showAddTemplate}
        onClose={() => setShowAddTemplate(false)}
      />
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
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingVertical: 8,
    backgroundColor: '#000000',
  },
  title: {
    fontSize: 34,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  addButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: '#3a3a3a',
    justifyContent: 'center',
    alignItems: 'center',
  },
  content: {
    flex: 1,
  },
  contentContainer: {
    padding: 16,
    flexGrow: 1,
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 32,
  },
  emptyTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#FFFFFF',
    marginTop: 20,
    marginBottom: 8,
  },
  emptySubtitle: {
    fontSize: 16,
    color: '#3a3a3a',
    textAlign: 'center',
    lineHeight: 22,
  },
});