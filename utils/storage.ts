import { CloudStorage } from 'react-native-cloud-storage';
import { WorkoutTemplate } from '../types/workout';

const STORAGE_KEYS = {
  TEMPLATES: '/workout-templates.json',
  SESSIONS: '/workout-sessions.json',
  EXERCISES: '/exercises.json',
  SETS: '/exercise-sets.json',
  REST_LOGS: '/rest-logs.json',
} as const;

export class StorageManager {
  static async readData<T>(key: string): Promise<T[]> {
    try {
      const data = await CloudStorage.readFile(key);
      return data ? JSON.parse(data) : [];
    } catch (error) {
      console.log(`No data found for ${key}, returning empty array`);
      return [];
    }
  }

  static async writeData<T>(key: string, data: T[]): Promise<void> {
    try {
      await CloudStorage.writeFile(key, JSON.stringify(data, null, 2));
      console.log(`Successfully wrote data to ${key}`);
    } catch (error) {
      console.error(`Failed to write data to ${key}:`, error);
      throw error;
    }
  }

  // Template operations
  static async getTemplates(): Promise<WorkoutTemplate[]> {
    return this.readData<WorkoutTemplate>(STORAGE_KEYS.TEMPLATES);
  }

  static async saveTemplate(template: WorkoutTemplate): Promise<void> {
    const templates = await this.getTemplates();
    const existingIndex = templates.findIndex(t => t.id === template.id);
    
    if (existingIndex >= 0) {
      templates[existingIndex] = { ...template, updatedAt: new Date().toISOString() };
    } else {
      templates.push(template);
    }
    
    await this.writeData(STORAGE_KEYS.TEMPLATES, templates);
  }

  static async deleteTemplate(id: string): Promise<void> {
    const templates = await this.getTemplates();
    const filtered = templates.filter(t => t.id !== id);
    await this.writeData(STORAGE_KEYS.TEMPLATES, filtered);
  }

  // Utility to check if cloud storage is available
  static async isCloudAvailable(): Promise<boolean> {
    try {
      await CloudStorage.readFile('/test.txt');
      return true;
    } catch {
      return false;
    }
  }
}