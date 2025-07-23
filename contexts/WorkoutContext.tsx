import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { WorkoutTemplate } from '../types/workout';
import { StorageManager } from '../utils/storage';

interface WorkoutContextType {
  templates: WorkoutTemplate[];
  loading: boolean;
  addTemplate: (template: Omit<WorkoutTemplate, 'id' | 'createdAt' | 'updatedAt'>) => Promise<void>;
  deleteTemplate: (id: string) => Promise<void>;
  refreshTemplates: () => Promise<void>;
}

const WorkoutContext = createContext<WorkoutContextType | undefined>(undefined);

export const useWorkout = () => {
  const context = useContext(WorkoutContext);
  if (!context) {
    throw new Error('useWorkout must be used within a WorkoutProvider');
  }
  return context;
};

interface WorkoutProviderProps {
  children: ReactNode;
}

export const WorkoutProvider: React.FC<WorkoutProviderProps> = ({ children }) => {
  const [templates, setTemplates] = useState<WorkoutTemplate[]>([]);
  const [loading, setLoading] = useState(true);

  const refreshTemplates = async () => {
    try {
      setLoading(true);
      const loadedTemplates = await StorageManager.getTemplates();
      setTemplates(loadedTemplates);
    } catch (error) {
      console.error('Failed to load templates:', error);
    } finally {
      setLoading(false);
    }
  };

  const addTemplate = async (templateData: Omit<WorkoutTemplate, 'id' | 'createdAt' | 'updatedAt'>) => {
    const template: WorkoutTemplate = {
      ...templateData,
      id: Date.now().toString() + Math.random().toString(36).substr(2, 9),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    await StorageManager.saveTemplate(template);
    await refreshTemplates();
  };

  const deleteTemplate = async (id: string) => {
    await StorageManager.deleteTemplate(id);
    await refreshTemplates();
  };

  useEffect(() => {
    refreshTemplates();
  }, []);

  const value: WorkoutContextType = {
    templates,
    loading,
    addTemplate,
    deleteTemplate,
    refreshTemplates,
  };

  return <WorkoutContext.Provider value={value}>{children}</WorkoutContext.Provider>;
};