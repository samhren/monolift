export interface WorkoutTemplate {
  id: string;
  name: string;
  daysPerWeek: number;
  createdAt: string;
  updatedAt: string;
  exercises?: TemplateExercise[];
}

export interface TemplateExercise {
  id: string;
  exerciseId: string;
  displayOrder: number;
  targetSets: number;
  targetReps: number;
}

export interface Exercise {
  id: string;
  name: string;
  category: string;
  variantOf?: string;
}

export interface WorkoutSession {
  id: string;
  templateId?: string;
  startedAt: string;
  finishedAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface ExerciseSet {
  id: string;
  sessionId: string;
  exerciseId: string;
  setIndex: number;
  reps: number;
  load: number;
  isPartial: boolean;
  dropsetOfIndex?: number;
}

export interface RestLog {
  id: string;
  sessionId: string;
  setIndex: number;
  seconds: number;
}