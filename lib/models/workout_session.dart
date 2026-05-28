class WorkoutSession {
  final int? id;
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final String? notes;
  final int? heartRate;
  final int? calories;
  final String? remoteId;

  WorkoutSession({
    this.id,
    required this.name,
    required this.startTime,
    this.endTime,
    this.notes,
    this.heartRate,
    this.calories,
    this.remoteId,
  });

  Duration get duration =>
      (endTime ?? DateTime.now()).difference(startTime);

  bool get isSynced => remoteId != null;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'notes': notes,
        'heart_rate': heartRate,
        'calories': calories,
        'remote_id': remoteId,
      };

  factory WorkoutSession.fromMap(Map<String, dynamic> m) => WorkoutSession(
        id: m['id'],
        name: m['name'],
        startTime: DateTime.parse(m['start_time']),
        endTime: m['end_time'] != null ? DateTime.parse(m['end_time']) : null,
        notes: m['notes'],
        heartRate: m['heart_rate'],
        calories: m['calories'],
        remoteId: m['remote_id'],
      );
}
