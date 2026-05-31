import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout_plan.dart';
import '../config/app_config.dart';

class AiPlanParams {
  final double bodyWeightKg;
  final int heightCm;
  final int age;
  final PlanGoal goal;
  final int daysPerWeek;
  final PlanDifficulty experience;
  final String equipment;

  const AiPlanParams({
    required this.bodyWeightKg,
    required this.heightCm,
    required this.age,
    required this.goal,
    required this.daysPerWeek,
    required this.experience,
    required this.equipment,
  });
}

class AiPlanService {
  static const _endpoint = 'https://api.anthropic.com/v1/messages';

  static const _exerciseList = [
    'Bench Press', 'Incline Dumbbell Press', 'Push Up',
    'Pull Up', 'Deadlift', 'Barbell Row', 'Lat Pulldown',
    'Overhead Press', 'Lateral Raise',
    'Squat', 'Leg Press', 'Romanian Deadlift',
    'Bicep Curl', 'Tricep Dip', 'Tricep Pushdown',
    'Plank', 'Crunches',
  ];

  static Future<WorkoutPlan> generatePlan(AiPlanParams p) async {
    if (AppConfig.anthropicApiKey.isEmpty) {
      throw Exception('no_api_key');
    }

    final goalLabel = _goalLabel(p.goal);
    final diffLabel = p.experience.name;
    final bmi = (p.bodyWeightKg / ((p.heightCm / 100) * (p.heightCm / 100))).toStringAsFixed(1);

    final prompt = '''
You are an expert certified personal trainer. Create a personalised 7-day workout plan.

USER PROFILE
- Body weight: ${p.bodyWeightKg} kg
- Height: ${p.heightCm} cm (BMI ≈ $bmi)
- Age: ${p.age}
- Goal: $goalLabel
- Training days per week: ${p.daysPerWeek}
- Experience level: $diffLabel
- Available equipment: ${p.equipment}

RULES
1. Return ONLY a single JSON object — no markdown, no explanation.
2. The plan must have exactly 7 day entries (fill non-training days with isRest: true).
3. Use ONLY exercises from this list: ${_exerciseList.join(', ')}.
4. Tailor sets, reps, and rest to the goal and experience level.
5. Add brief coaching notes where helpful.

JSON FORMAT
{
  "name": "Plan name (short)",
  "description": "2–3 sentence description tailored to goal",
  "goal": "${p.goal.name}",
  "difficulty": "${p.experience.name}",
  "daysPerWeek": ${p.daysPerWeek},
  "days": [
    {
      "dayName": "Day 1 — Push",
      "focus": ["Chest", "Shoulders", "Triceps"],
      "exercises": [
        { "name": "Bench Press", "sets": 4, "repsRange": "8–10", "restSeconds": 120, "notes": "optional" }
      ],
      "isRest": false
    },
    {
      "dayName": "Day 2 — Rest",
      "focus": [],
      "exercises": [],
      "isRest": true
    }
  ]
}
''';

    final response = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': AppConfig.anthropicApiKey,
            'anthropic-version': '2023-06-01',
          },
          body: jsonEncode({
            'model': 'claude-haiku-4-5-20251001',
            'max_tokens': 2048,
            'messages': [
              {'role': 'user', 'content': prompt},
            ],
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('api_error_${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (data['content'] as List).first['text'] as String;

    // Extract the JSON block (model may wrap in markdown fences)
    final jsonStr = _extractJson(content);
    final planJson = jsonDecode(jsonStr) as Map<String, dynamic>;
    return WorkoutPlan.fromJson(planJson, isAi: true);
  }

  static String _extractJson(String text) {
    // Strip ```json ... ``` fences if present
    final fenced = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
    final fenceMatch = fenced.firstMatch(text);
    if (fenceMatch != null) return fenceMatch.group(1)!.trim();

    // Otherwise grab the outermost { ... }
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    throw Exception('No JSON found in AI response');
  }

  static String _goalLabel(PlanGoal g) => switch (g) {
        PlanGoal.muscle => 'Muscle Building (hypertrophy)',
        PlanGoal.vtaper => 'V-Taper Aesthetic (wide back, broad shoulders, lean waist)',
        PlanGoal.powerlifting => 'Powerlifting (maximal strength on squat/bench/deadlift)',
        PlanGoal.fatLoss => 'Fat Loss (preserve muscle, high metabolic demand)',
        PlanGoal.general => 'General Fitness',
      };
}
