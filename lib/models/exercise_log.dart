import 'workout_set.dart';

class ExerciseLog {
  final int? id;
  final int sessionId;
  final int exerciseId;
  final String exerciseName;
  final int orderIndex;
  List<WorkoutSet> sets;

  ExerciseLog({
    this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.exerciseName,
    required this.orderIndex,
    this.sets = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'session_id': sessionId,
        'exercise_id': exerciseId,
        'exercise_name': exerciseName,
        'order_index': orderIndex,
      };

  factory ExerciseLog.fromMap(Map<String, dynamic> m) => ExerciseLog(
        id: m['id'],
        sessionId: m['session_id'],
        exerciseId: m['exercise_id'],
        exerciseName: m['exercise_name'],
        orderIndex: m['order_index'],
      );
}
