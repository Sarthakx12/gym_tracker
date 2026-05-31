enum PlanGoal { muscle, vtaper, powerlifting, fatLoss, general }
enum PlanDifficulty { beginner, intermediate, advanced }

class PlanExercise {
  final String name;
  final int sets;
  final String repsRange;
  final int restSeconds;
  final String? notes;

  const PlanExercise({
    required this.name,
    required this.sets,
    required this.repsRange,
    this.restSeconds = 90,
    this.notes,
  });

  factory PlanExercise.fromJson(Map<String, dynamic> j) => PlanExercise(
        name: j['name'] as String,
        sets: (j['sets'] as num).toInt(),
        repsRange: j['repsRange'] as String,
        restSeconds: (j['restSeconds'] as num?)?.toInt() ?? 90,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'sets': sets,
        'repsRange': repsRange,
        'restSeconds': restSeconds,
        if (notes != null) 'notes': notes,
      };
}

class WorkoutPlanDay {
  final String dayName;
  final List<String> focus;
  final List<PlanExercise> exercises;
  final bool isRest;

  const WorkoutPlanDay({
    required this.dayName,
    required this.focus,
    required this.exercises,
    this.isRest = false,
  });

  const WorkoutPlanDay.rest(this.dayName)
      : focus = const [],
        exercises = const [],
        isRest = true;

  factory WorkoutPlanDay.fromJson(Map<String, dynamic> j) => WorkoutPlanDay(
        dayName: j['dayName'] as String,
        focus: (j['focus'] as List).cast<String>(),
        exercises: (j['exercises'] as List)
            .map((e) => PlanExercise.fromJson(e as Map<String, dynamic>))
            .toList(),
        isRest: j['isRest'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'dayName': dayName,
        'focus': focus,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'isRest': isRest,
      };
}

class WorkoutPlan {
  final String id;
  final String name;
  final String description;
  final PlanGoal goal;
  final PlanDifficulty difficulty;
  final int daysPerWeek;
  final List<WorkoutPlanDay> days;
  final bool isAiGenerated;

  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.goal,
    required this.difficulty,
    required this.daysPerWeek,
    required this.days,
    this.isAiGenerated = false,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> j, {bool isAi = false}) =>
      WorkoutPlan(
        id: j['id'] as String? ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: j['name'] as String,
        description: j['description'] as String,
        goal: PlanGoal.values.firstWhere(
          (g) => g.name == j['goal'],
          orElse: () => PlanGoal.general,
        ),
        difficulty: PlanDifficulty.values.firstWhere(
          (d) => d.name == j['difficulty'],
          orElse: () => PlanDifficulty.intermediate,
        ),
        daysPerWeek: (j['daysPerWeek'] as num).toInt(),
        days: (j['days'] as List)
            .map((d) => WorkoutPlanDay.fromJson(d as Map<String, dynamic>))
            .toList(),
        isAiGenerated: isAi,
      );
}

// ─── Cardio ──────────────────────────────────────────────────────────────────

enum CardioType { running, cycling, rowing, jumpRope, hiit, walking }
enum CardioIntensity { low, medium, high }

class CardioWorkout {
  final String id;
  final String name;
  final CardioType type;
  final int durationMin;
  final CardioIntensity intensity;
  final String description;
  final List<String> structure;
  final int caloriesPerKg;

  const CardioWorkout({
    required this.id,
    required this.name,
    required this.type,
    required this.durationMin,
    required this.intensity,
    required this.description,
    required this.structure,
    required this.caloriesPerKg,
  });
}
