import 'package:flutter/foundation.dart';
import '../db/database_helper.dart';
import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../models/exercise_log.dart';
import '../models/workout_set.dart';
import '../models/body_weight.dart';
import '../services/supabase_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  List<WorkoutSession> sessions = [];
  List<Exercise> exercises = [];
  List<BodyWeight> bodyWeights = [];
  WorkoutSession? activeSession;
  List<ExerciseLog> activeLogs = [];

  double weekVolumeKg = 0;
  bool isSyncing = false;
  DateTime? lastSyncTime;
  int get unsyncedCount =>
      sessions.where((s) => s.endTime != null && !s.isSynced).length;

  BodyWeight? get latestBodyWeight =>
      bodyWeights.isNotEmpty ? bodyWeights.first : null;

  Future<void> loadSessions() async {
    sessions = await _db.getSessions();
    weekVolumeKg = await _db.getWeekVolume();
    notifyListeners();
  }

  Future<void> loadExercises() async {
    exercises = await _db.getExercises();
    notifyListeners();
  }

  Future<void> loadBodyWeights() async {
    bodyWeights = await _db.getBodyWeights();
    notifyListeners();
  }

  Future<void> addBodyWeight(double kg) async {
    final bw = BodyWeight(weight: kg, loggedAt: DateTime.now());
    await _db.insertBodyWeight(bw);
    await loadBodyWeights();
  }

  Future<Map<String, dynamic>?> getLastBestForExercise(
          String exerciseName) =>
      _db.getLastBestForExercise(exerciseName);

  Future<void> startSession(String name) async {
    final session = WorkoutSession(name: name, startTime: DateTime.now());
    final id = await _db.insertSession(session);
    activeSession =
        WorkoutSession(id: id, name: name, startTime: session.startTime);
    activeLogs = [];
    notifyListeners();
  }

  Future<void> finishSession(
      {String? notes, int? heartRate, int? calories}) async {
    if (activeSession == null) return;
    final finished = WorkoutSession(
      id: activeSession!.id,
      name: activeSession!.name,
      startTime: activeSession!.startTime,
      endTime: DateTime.now(),
      notes: notes,
      heartRate: heartRate,
      calories: calories,
    );
    await _db.updateSession(finished);

    final logsToSync = List<ExerciseLog>.from(activeLogs);
    final sessionToSync = finished;

    activeSession = null;
    activeLogs = [];
    await loadSessions();

    _syncSessionInBackground(sessionToSync, logsToSync);
  }

  void _syncSessionInBackground(
      WorkoutSession session, List<ExerciseLog> logs) async {
    if (!SupabaseService.isLoggedIn) return;
    final remoteId = await SupabaseService.pushSession(session, logs);
    if (remoteId != null && session.id != null) {
      await _db.markSessionSynced(session.id!, remoteId);
      await loadSessions();
    }
  }

  Future<void> syncPending() async {
    if (!SupabaseService.isLoggedIn) return;
    isSyncing = true;
    notifyListeners();

    final unsynced = await _db.getUnsyncedSessions();
    for (final session in unsynced) {
      final logs = await _db.getLogsForSession(session.id!);
      final remoteId = await SupabaseService.pushSession(session, logs);
      if (remoteId != null) {
        await _db.markSessionSynced(session.id!, remoteId);
      }
    }

    isSyncing = false;
    lastSyncTime = DateTime.now();
    await loadSessions();
  }

  Future<void> onLogin() async {
    await syncPending();
    await loadSessions();
    await loadExercises();
  }

  Future<void> addExerciseToSession(Exercise exercise) async {
    if (activeSession == null) return;
    final log = ExerciseLog(
      sessionId: activeSession!.id!,
      exerciseId: exercise.id!,
      exerciseName: exercise.name,
      orderIndex: activeLogs.length,
    );
    final id = await _db.insertExerciseLog(log);
    activeLogs.add(ExerciseLog(
      id: id,
      sessionId: log.sessionId,
      exerciseId: log.exerciseId,
      exerciseName: log.exerciseName,
      orderIndex: log.orderIndex,
      sets: [],
    ));
    notifyListeners();
  }

  Future<void> removeExerciseLog(int logId) async {
    await _db.deleteExerciseLog(logId);
    activeLogs.removeWhere((l) => l.id == logId);
    notifyListeners();
  }

  Future<void> addSet(int logId, double weight, int reps) async {
    final log = activeLogs.firstWhere((l) => l.id == logId);
    final set = WorkoutSet(
      logId: logId,
      setNumber: log.sets.length + 1,
      weight: weight,
      reps: reps,
    );
    final id = await _db.insertSet(set);
    log.sets.add(WorkoutSet(
      id: id,
      logId: logId,
      setNumber: set.setNumber,
      weight: weight,
      reps: reps,
    ));
    notifyListeners();
  }

  Future<void> removeSet(int logId, int setId) async {
    await _db.deleteSet(setId);
    final log = activeLogs.firstWhere((l) => l.id == logId);
    log.sets.removeWhere((s) => s.id == setId);
    notifyListeners();
  }

  Future<List<ExerciseLog>> getSessionLogs(int sessionId) async {
    return _db.getLogsForSession(sessionId);
  }

  Future<void> deleteSession(int id) async {
    SupabaseService.deleteSession(id);
    await _db.deleteSession(id);
    await loadSessions();
  }

  Future<void> addCustomExercise(
      String name, String muscleGroup, String equipment) async {
    final exercise = Exercise(
        name: name, muscleGroup: muscleGroup, equipment: equipment);
    await _db.insertExercise(exercise);
    await loadExercises();
    SupabaseService.pushExercise(name, muscleGroup, equipment);
  }

  Future<List<Map<String, dynamic>>> getProgressData(String exerciseName) =>
      _db.getProgressForExercise(exerciseName);

  Future<List<Map<String, dynamic>>> getVolumeData() =>
      _db.getVolumePerSession();

  // Workout streak: consecutive days ending today with at least one session
  int get currentStreak {
    if (sessions.isEmpty) return 0;
    final completed =
        sessions.where((s) => s.endTime != null).toList();
    if (completed.isEmpty) return 0;

    final days = completed
        .map((s) => DateTime(
            s.startTime.year, s.startTime.month, s.startTime.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final yesterdayNorm = todayNorm.subtract(const Duration(days: 1));

    if (days.first != todayNorm && days.first != yesterdayNorm) return 0;

    int streak = 1;
    for (int i = 1; i < days.length; i++) {
      final expected = days[i - 1].subtract(const Duration(days: 1));
      if (days[i] == expected) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
