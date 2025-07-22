import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const exercises = [
  // Chest
  { name: 'Bench Press', category: 'chest' },
  { name: 'Incline Bench Press', category: 'chest' },
  { name: 'Decline Bench Press', category: 'chest' },
  { name: 'Dumbbell Bench Press', category: 'chest' },
  { name: 'Incline Dumbbell Press', category: 'chest' },
  { name: 'Dumbbell Flyes', category: 'chest' },
  { name: 'Incline Dumbbell Flyes', category: 'chest' },
  { name: 'Cable Flyes', category: 'chest' },
  { name: 'Pec Deck', category: 'chest' },
  { name: 'Dips', category: 'chest' },
  
  // Back
  { name: 'Deadlift', category: 'back' },
  { name: 'Conventional Deadlift', category: 'back' },
  { name: 'Sumo Deadlift', category: 'back' },
  { name: 'Romanian Deadlift', category: 'back' },
  { name: 'Stiff Leg Deadlift', category: 'back' },
  { name: 'Pull-ups', category: 'back' },
  { name: 'Chin-ups', category: 'back' },
  { name: 'Lat Pulldown', category: 'back' },
  { name: 'Wide Grip Lat Pulldown', category: 'back' },
  { name: 'Cable Rows', category: 'back' },
  { name: 'Barbell Rows', category: 'back' },
  { name: 'Dumbbell Rows', category: 'back' },
  { name: 'T-Bar Rows', category: 'back' },
  { name: 'Chest Supported Rows', category: 'back' },
  { name: 'Hyperextensions', category: 'back' },
  
  // Legs
  { name: 'Squat', category: 'legs' },
  { name: 'Back Squat', category: 'legs' },
  { name: 'Front Squat', category: 'legs' },
  { name: 'Goblet Squat', category: 'legs' },
  { name: 'Bulgarian Split Squat', category: 'legs' },
  { name: 'Leg Press', category: 'legs' },
  { name: 'Lunges', category: 'legs' },
  { name: 'Walking Lunges', category: 'legs' },
  { name: 'Leg Curls', category: 'legs' },
  { name: 'Leg Extensions', category: 'legs' },
  { name: 'Calf Raises', category: 'legs' },
  { name: 'Standing Calf Raises', category: 'legs' },
  { name: 'Seated Calf Raises', category: 'legs' },
  
  // Shoulders
  { name: 'Overhead Press', category: 'shoulders' },
  { name: 'Military Press', category: 'shoulders' },
  { name: 'Push Press', category: 'shoulders' },
  { name: 'Dumbbell Shoulder Press', category: 'shoulders' },
  { name: 'Lateral Raises', category: 'shoulders' },
  { name: 'Front Raises', category: 'shoulders' },
  { name: 'Rear Delt Flyes', category: 'shoulders' },
  { name: 'Face Pulls', category: 'shoulders' },
  { name: 'Arnold Press', category: 'shoulders' },
  { name: 'Upright Rows', category: 'shoulders' },
  
  // Arms
  { name: 'Barbell Curls', category: 'arms' },
  { name: 'Dumbbell Curls', category: 'arms' },
  { name: 'Hammer Curls', category: 'arms' },
  { name: 'Preacher Curls', category: 'arms' },
  { name: 'Cable Curls', category: 'arms' },
  { name: 'Close Grip Bench Press', category: 'arms' },
  { name: 'Tricep Dips', category: 'arms' },
  { name: 'Tricep Pushdowns', category: 'arms' },
  { name: 'Overhead Tricep Extension', category: 'arms' },
  { name: 'French Press', category: 'arms' },
  
  // Core
  { name: 'Plank', category: 'core' },
  { name: 'Side Plank', category: 'core' },
  { name: 'Sit-ups', category: 'core' },
  { name: 'Crunches', category: 'core' },
  { name: 'Russian Twists', category: 'core' },
  { name: 'Leg Raises', category: 'core' },
  { name: 'Hanging Leg Raises', category: 'core' },
  { name: 'Mountain Climbers', category: 'core' },
  { name: 'Dead Bug', category: 'core' },
  { name: 'Bird Dog', category: 'core' }
];

async function main() {
  console.log('Starting seed...');
  
  // Clear existing exercises
  await prisma.exercise.deleteMany();
  console.log('Cleared existing exercises');
  
  // Create exercises
  for (const exercise of exercises) {
    await prisma.exercise.create({
      data: exercise,
    });
  }
  
  console.log(`Seeded ${exercises.length} exercises`);
  
  // Create some exercise variants
  const benchPress = await prisma.exercise.findFirst({
    where: { name: 'Bench Press' }
  });
  
  if (benchPress) {
    await prisma.exercise.create({
      data: {
        name: 'Paused Bench Press',
        category: 'chest',
        variantOf: benchPress.id
      }
    });
    
    await prisma.exercise.create({
      data: {
        name: 'Spoto Press',
        category: 'chest',
        variantOf: benchPress.id
      }
    });
  }
  
  const squat = await prisma.exercise.findFirst({
    where: { name: 'Squat' }
  });
  
  if (squat) {
    await prisma.exercise.create({
      data: {
        name: 'Paused Squat',
        category: 'legs',
        variantOf: squat.id
      }
    });
    
    await prisma.exercise.create({
      data: {
        name: 'Box Squat',
        category: 'legs',
        variantOf: squat.id
      }
    });
  }
  
  const deadlift = await prisma.exercise.findFirst({
    where: { name: 'Deadlift' }
  });
  
  if (deadlift) {
    await prisma.exercise.create({
      data: {
        name: 'Deficit Deadlift',
        category: 'back',
        variantOf: deadlift.id
      }
    });
    
    await prisma.exercise.create({
      data: {
        name: 'Block Pull',
        category: 'back',
        variantOf: deadlift.id
      }
    });
  }
  
  console.log('Seeded exercise variants');
  console.log('Seed completed successfully');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });