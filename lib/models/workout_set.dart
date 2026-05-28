class WorkoutSet {
  final int? id;
  final int logId;
  final int setNumber;
  final double weight;
  final int reps;
  final int? restSeconds;

  WorkoutSet({
    this.id,
    required this.logId,
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.restSeconds,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'log_id': logId,
        'set_number': setNumber,
        'weight': weight,
        'reps': reps,
        'rest_seconds': restSeconds,
      };

  factory WorkoutSet.fromMap(Map<String, dynamic> m) => WorkoutSet(
        id: m['id'],
        logId: m['log_id'],
        setNumber: m['set_number'],
        weight: (m['weight'] as num).toDouble(),
        reps: m['reps'],
        restSeconds: m['rest_seconds'],
      );
}
