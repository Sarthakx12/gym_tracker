import '../models/workout_plan.dart';

// ─── Curated Workout Plans ────────────────────────────────────────────────────

final curatedPlans = <WorkoutPlan>[
  _muscleBuildingPlan,
  _vtaperPlan,
  _powerliftingPlan,
];

// ── Muscle Building: 4-day Upper/Lower + Push/Pull ───────────────────────────

const _muscleBuildingPlan = WorkoutPlan(
  id: 'muscle_building_4day',
  name: 'Muscle Building',
  description:
      'A 4-day Push/Pull/Legs split optimised for hypertrophy. Progressive overload on compound lifts with accessory volume to maximise muscle growth.',
  goal: PlanGoal.muscle,
  difficulty: PlanDifficulty.intermediate,
  daysPerWeek: 4,
  days: [
    WorkoutPlanDay(
      dayName: 'Day 1 — Push',
      focus: ['Chest', 'Shoulders', 'Triceps'],
      exercises: [
        PlanExercise(name: 'Bench Press', sets: 4, repsRange: '8–10', restSeconds: 120, notes: 'Drive feet into floor, keep shoulder blades retracted'),
        PlanExercise(name: 'Incline Dumbbell Press', sets: 3, repsRange: '10–12', restSeconds: 90),
        PlanExercise(name: 'Overhead Press', sets: 3, repsRange: '8–10', restSeconds: 90),
        PlanExercise(name: 'Lateral Raise', sets: 4, repsRange: '12–15', restSeconds: 60, notes: 'Control the negative, slight bend in elbows'),
        PlanExercise(name: 'Tricep Pushdown', sets: 3, repsRange: '12–15', restSeconds: 60),
        PlanExercise(name: 'Tricep Dip', sets: 3, repsRange: '10–12', restSeconds: 60),
      ],
    ),
    WorkoutPlanDay(
      dayName: 'Day 2 — Pull',
      focus: ['Back', 'Biceps'],
      exercises: [
        PlanExercise(name: 'Deadlift', sets: 4, repsRange: '5–6', restSeconds: 180, notes: 'Brace core before each rep, hinge at hips'),
        PlanExercise(name: 'Pull Up', sets: 4, repsRange: '6–10', restSeconds: 90),
        PlanExercise(name: 'Barbell Row', sets: 3, repsRange: '8–10', restSeconds: 90, notes: 'Row to lower chest, squeeze lats at top'),
        PlanExercise(name: 'Lat Pulldown', sets: 3, repsRange: '10–12', restSeconds: 75),
        PlanExercise(name: 'Bicep Curl', sets: 3, repsRange: '10–12', restSeconds: 60),
      ],
    ),
    WorkoutPlanDay(
      dayName: 'Day 3 — Legs',
      focus: ['Quads', 'Hamstrings', 'Glutes'],
      exercises: [
        PlanExercise(name: 'Squat', sets: 4, repsRange: '8–10', restSeconds: 150, notes: 'Break parallel, brace throughout'),
        PlanExercise(name: 'Romanian Deadlift', sets: 3, repsRange: '10–12', restSeconds: 90, notes: 'Feel the hamstring stretch at the bottom'),
        PlanExercise(name: 'Leg Press', sets: 3, repsRange: '12–15', restSeconds: 90),
        PlanExercise(name: 'Plank', sets: 3, repsRange: '30–60s', restSeconds: 60),
      ],
    ),
    WorkoutPlanDay.rest('Day 4 — Rest'),
    WorkoutPlanDay(
      dayName: 'Day 5 — Upper',
      focus: ['Chest', 'Back', 'Shoulders', 'Arms'],
      exercises: [
        PlanExercise(name: 'Bench Press', sets: 3, repsRange: '6–8', restSeconds: 120),
        PlanExercise(name: 'Barbell Row', sets: 3, repsRange: '6–8', restSeconds: 120),
        PlanExercise(name: 'Overhead Press', sets: 3, repsRange: '8–10', restSeconds: 90),
        PlanExercise(name: 'Pull Up', sets: 3, repsRange: '8–10', restSeconds: 90),
        PlanExercise(name: 'Bicep Curl', sets: 3, repsRange: '12', restSeconds: 60),
        PlanExercise(name: 'Tricep Pushdown', sets: 3, repsRange: '12', restSeconds: 60),
      ],
    ),
    WorkoutPlanDay(
      dayName: 'Day 6 — Lower',
      focus: ['Quads', 'Hamstrings', 'Core'],
      exercises: [
        PlanExercise(name: 'Squat', sets: 3, repsRange: '10–12', restSeconds: 120),
        PlanExercise(name: 'Romanian Deadlift', sets: 3, repsRange: '10–12', restSeconds: 90),
        PlanExercise(name: 'Leg Press', sets: 3, repsRange: '15', restSeconds: 75),
        PlanExercise(name: 'Crunches', sets: 3, repsRange: '20–25', restSeconds: 45),
        PlanExercise(name: 'Plank', sets: 3, repsRange: '45–60s', restSeconds: 60),
      ],
    ),
    WorkoutPlanDay.rest('Day 7 — Rest'),
  ],
);

// ── V-Taper: 5-day Aesthetic ──────────────────────────────────────────────────

const _vtaperPlan = WorkoutPlan(
  id: 'vtaper_5day',
  name: 'V-Taper Body',
  description:
      'Sculpt the V-taper aesthetic with extra shoulder width, a wide back, and a lean midsection. High shoulder and lat volume with minimal leg bulk.',
  goal: PlanGoal.vtaper,
  difficulty: PlanDifficulty.intermediate,
  daysPerWeek: 5,
  days: [
    WorkoutPlanDay(
      dayName: 'Day 1 — Lat Width',
      focus: ['Lats', 'Back Width'],
      exercises: [
        PlanExercise(name: 'Pull Up', sets: 5, repsRange: '6–10', restSeconds: 90, notes: 'Full hang at bottom, lead with elbows'),
        PlanExercise(name: 'Lat Pulldown', sets: 4, repsRange: '10–12', restSeconds: 75, notes: 'Wide grip, lean back slightly'),
        PlanExercise(name: 'Barbell Row', sets: 3, repsRange: '8–10', restSeconds: 90),
        PlanExercise(name: 'Bicep Curl', sets: 3, repsRange: '12–15', restSeconds: 60),
      ],
    ),
    WorkoutPlanDay(
      dayName: 'Day 2 — Shoulder Width',
      focus: ['Shoulders', 'Traps'],
      exercises: [
        PlanExercise(name: 'Overhead Press', sets: 4, repsRange: '8–10', restSeconds: 90),
        PlanExercise(name: 'Lateral Raise', sets: 5, repsRange: '15–20', restSeconds: 45, notes: 'Light weight, chase the burn'),
        PlanExercise(name: 'Pull Up', sets: 3, repsRange: '8–10', restSeconds: 75),
        PlanExercise(name: 'Lat Pulldown', sets: 3, repsRange: '12', restSeconds: 60),
      ],
    ),
    WorkoutPlanDay(
      dayName: 'Day 3 — Chest',
      focus: ['Chest', 'Triceps'],
      exercises: [
        PlanExercise(name: 'Bench Press', sets: 4, repsRange: '8–10', restSeconds: 120),
        PlanExercise(name: 'Incline Dumbbell Press', sets: 4, repsRange: '10–12', restSeconds: 90),
        PlanExercise(name: 'Push Up', sets: 3, repsRange: '15–20', restSeconds: 60),
        PlanExercise(name: 'Tricep Dip', sets: 3, repsRange: '10–12', restSeconds: 75),
        PlanExercise(name: 'Tricep Pushdown', sets: 3, repsRange: '12–15', restSeconds: 60),
      ],
    ),
    WorkoutPlanDay.rest('Day 4 — Rest'),
    WorkoutPlanDay(
      dayName: 'Day 5 — Arms & Core',
      focus: ['Biceps', 'Triceps', 'Core'],
      exercises: [
        PlanExercise(name: 'Bicep Curl', sets: 4, repsRange: '10–12', restSeconds: 60),
        PlanExercise(name: 'Tricep Pushdown', sets: 4, repsRange: '12–15', restSeconds: 60),
        PlanExercise(name: 'Tricep Dip', sets: 3, repsRange: '10–12', restSeconds: 60),
        PlanExercise(name: 'Plank', sets: 4, repsRange: '45–60s', restSeconds: 45),
        PlanExercise(name: 'Crunches', sets: 3, repsRange: '20–25', restSeconds: 45),
      ],
    ),
    WorkoutPlanDay(
      dayName: 'Day 6 — Back Thickness',
      focus: ['Back', 'Posterior Chain'],
      exercises: [
        PlanExercise(name: 'Deadlift', sets: 3, repsRange: '4–5', restSeconds: 180, notes: 'Heavy — prioritise form over weight'),
        PlanExercise(name: 'Barbell Row', sets: 4, repsRange: '8–10', restSeconds: 90),
        PlanExercise(name: 'Lat Pulldown', sets: 3, repsRange: '10–12', restSeconds: 75),
        PlanExercise(name: 'Pull Up', sets: 3, repsRange: '8', restSeconds: 90),
      ],
    ),
    WorkoutPlanDay.rest('Day 7 — Rest'),
  ],
);

// ── Powerlifting: 3-day Strength ─────────────────────────────────────────────

const _powerliftingPlan = WorkoutPlan(
  id: 'powerlifting_3day',
  name: 'Powerlifting',
  description:
      'A classic 3-day strength programme built around the squat, bench, and deadlift. Linear progression on the big three with accessory work to address weak points.',
  goal: PlanGoal.powerlifting,
  difficulty: PlanDifficulty.advanced,
  daysPerWeek: 3,
  days: [
    WorkoutPlanDay(
      dayName: 'Day 1 — Squat Focus',
      focus: ['Squat', 'Legs', 'Core'],
      exercises: [
        PlanExercise(name: 'Squat', sets: 5, repsRange: '5', restSeconds: 180, notes: 'Add 2.5 kg each session while form is solid'),
        PlanExercise(name: 'Bench Press', sets: 3, repsRange: '5', restSeconds: 120),
        PlanExercise(name: 'Barbell Row', sets: 3, repsRange: '5', restSeconds: 90),
        PlanExercise(name: 'Plank', sets: 3, repsRange: '30–45s', restSeconds: 60),
      ],
    ),
    WorkoutPlanDay.rest('Day 2 — Rest'),
    WorkoutPlanDay(
      dayName: 'Day 3 — Bench Focus',
      focus: ['Bench Press', 'Chest', 'Upper Body'],
      exercises: [
        PlanExercise(name: 'Bench Press', sets: 5, repsRange: '5', restSeconds: 180, notes: 'Add 2.5 kg each session'),
        PlanExercise(name: 'Overhead Press', sets: 3, repsRange: '5', restSeconds: 120),
        PlanExercise(name: 'Pull Up', sets: 3, repsRange: '5', restSeconds: 90),
        PlanExercise(name: 'Tricep Dip', sets: 3, repsRange: '8–10', restSeconds: 60),
      ],
    ),
    WorkoutPlanDay.rest('Day 4 — Rest'),
    WorkoutPlanDay(
      dayName: 'Day 5 — Deadlift Focus',
      focus: ['Deadlift', 'Back', 'Posterior Chain'],
      exercises: [
        PlanExercise(name: 'Deadlift', sets: 1, repsRange: '5', restSeconds: 300, notes: 'One all-out work set — add 5 kg each session'),
        PlanExercise(name: 'Squat', sets: 3, repsRange: '3', restSeconds: 150, notes: '80% of Monday weight'),
        PlanExercise(name: 'Barbell Row', sets: 3, repsRange: '5', restSeconds: 90),
        PlanExercise(name: 'Romanian Deadlift', sets: 3, repsRange: '8', restSeconds: 90, notes: 'Accessory — lighter weight, feel the stretch'),
      ],
    ),
    WorkoutPlanDay.rest('Day 6 — Rest'),
    WorkoutPlanDay.rest('Day 7 — Rest'),
  ],
);

// ─── Cardio Workouts ──────────────────────────────────────────────────────────

final cardioWorkouts = <CardioWorkout>[
  // 15 min
  const CardioWorkout(
    id: 'jump_rope_15_high',
    name: 'Jump Rope Tabata',
    type: CardioType.jumpRope,
    durationMin: 15,
    intensity: CardioIntensity.high,
    description: 'Explosive Tabata intervals on the jump rope. Burns fat fast.',
    structure: [
      '2 min — steady warm-up',
      '8 rounds: 20 sec max effort / 10 sec rest',
      '3 min — cool-down jog',
    ],
    caloriesPerKg: 10,
  ),
  const CardioWorkout(
    id: 'walk_15_low',
    name: 'Brisk Walk',
    type: CardioType.walking,
    durationMin: 15,
    intensity: CardioIntensity.low,
    description: 'Low-impact active recovery. Promotes blood flow without taxing the CNS.',
    structure: [
      '15 min — brisk walk at 5–6 km/h',
    ],
    caloriesPerKg: 3,
  ),
  const CardioWorkout(
    id: 'hiit_15_medium',
    name: 'Sprint Intervals',
    type: CardioType.running,
    durationMin: 15,
    intensity: CardioIntensity.medium,
    description: 'Short sprint intervals to spike heart rate and boost metabolism.',
    structure: [
      '3 min — jog warm-up',
      '6 rounds: 30 sec sprint / 60 sec walk',
      '3 min — walk cool-down',
    ],
    caloriesPerKg: 7,
  ),

  // 30 min
  const CardioWorkout(
    id: 'steady_run_30_medium',
    name: 'Steady-State Run',
    type: CardioType.running,
    durationMin: 30,
    intensity: CardioIntensity.medium,
    description: 'Aerobic base run at a conversational pace. Builds cardiovascular endurance.',
    structure: [
      '5 min — easy jog warm-up',
      '20 min — steady run at 65–75% max HR',
      '5 min — walk cool-down',
    ],
    caloriesPerKg: 8,
  ),
  const CardioWorkout(
    id: 'hiit_circuit_30_high',
    name: 'HIIT Circuit',
    type: CardioType.hiit,
    durationMin: 30,
    intensity: CardioIntensity.high,
    description: 'Full-body high-intensity circuit. Elevates EPOC for hours post-workout.',
    structure: [
      '5 min — dynamic warm-up',
      '4 rounds: Burpees 45s / Mountain Climbers 45s / Jump Squats 45s / Rest 30s',
      '5 min — cool-down stretch',
    ],
    caloriesPerKg: 12,
  ),
  const CardioWorkout(
    id: 'bike_30_low',
    name: 'Easy Bike Ride',
    type: CardioType.cycling,
    durationMin: 30,
    intensity: CardioIntensity.low,
    description: 'Low-intensity cycling for active recovery. Easy on joints, great after leg day.',
    structure: [
      '30 min — steady cycle at 60% max HR',
    ],
    caloriesPerKg: 4,
  ),

  // 45 min
  const CardioWorkout(
    id: 'run_45_medium',
    name: 'Aerobic Run',
    type: CardioType.running,
    durationMin: 45,
    intensity: CardioIntensity.medium,
    description: 'Sustained aerobic run to build a strong cardio base and improve fat oxidation.',
    structure: [
      '5 min — easy jog',
      '35 min — run at 65–70% max HR',
      '5 min — walk cool-down',
    ],
    caloriesPerKg: 10,
  ),
  const CardioWorkout(
    id: 'rowing_45_high',
    name: 'Rowing Intervals',
    type: CardioType.rowing,
    durationMin: 45,
    intensity: CardioIntensity.high,
    description: 'Full-body rowing intervals. Excellent for back development alongside cardio.',
    structure: [
      '5 min — easy row warm-up',
      '5 rounds: 3 min hard row / 2 min easy row',
      '10 min — steady cool-down',
    ],
    caloriesPerKg: 11,
  ),
  const CardioWorkout(
    id: 'walk_hike_45_low',
    name: 'Power Walk / Hike',
    type: CardioType.walking,
    durationMin: 45,
    intensity: CardioIntensity.low,
    description: 'Extended power walk. Ideal for fat loss while preserving muscle.',
    structure: [
      '45 min — brisk walk at 5.5–6.5 km/h',
    ],
    caloriesPerKg: 4,
  ),

  // 60 min
  const CardioWorkout(
    id: 'long_run_60_medium',
    name: 'Long Run',
    type: CardioType.running,
    durationMin: 60,
    intensity: CardioIntensity.medium,
    description: 'The weekly long run. Builds aerobic capacity and mental toughness.',
    structure: [
      '5 min — walk warm-up',
      '50 min — run at 60–70% max HR',
      '5 min — walk cool-down',
    ],
    caloriesPerKg: 13,
  ),
  const CardioWorkout(
    id: 'endurance_hiit_60_high',
    name: 'Endurance HIIT',
    type: CardioType.hiit,
    durationMin: 60,
    intensity: CardioIntensity.high,
    description: 'Longer HIIT session with lactate threshold intervals and sprint finishers.',
    structure: [
      '10 min — warm-up jog',
      '6 rounds: 5 min at threshold pace / 2 min walk',
      '4 × 200 m sprints with 90 sec rest',
      '5 min — cool-down walk',
    ],
    caloriesPerKg: 16,
  ),
  const CardioWorkout(
    id: 'cycle_60_low',
    name: 'Long Easy Cycle',
    type: CardioType.cycling,
    durationMin: 60,
    intensity: CardioIntensity.low,
    description: 'Low-intensity aerobic cycling session. Zero joint impact, high calorie burn.',
    structure: [
      '60 min — steady cycling at 55–65% max HR',
    ],
    caloriesPerKg: 6,
  ),
];
