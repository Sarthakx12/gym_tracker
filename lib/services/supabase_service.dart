import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout_session.dart';
import '../models/exercise_log.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // ── Auth ────────────────────────────────────────────────────

  static User? get currentUser => client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  static String? get userId => currentUser?.id;
  static String? get userEmail => currentUser?.email;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  static Future<AuthResponse> signUp(String email, String password) =>
      client.auth.signUp(email: email, password: password);

  static Future<AuthResponse> signIn(String email, String password) =>
      client.auth.signInWithPassword(email: email, password: password);

  static Future<void> signOut() => client.auth.signOut();

  // ── Sync: push a completed session to Supabase ──────────────

  static Future<String?> pushSession(
    WorkoutSession session,
    List<ExerciseLog> logs,
  ) async {
    if (!isLoggedIn) return null;
    try {
      final sessionRow = await client.from('workout_sessions').insert({
        'user_id': userId,
        'local_id': session.id,
        'name': session.name,
        'start_time': session.startTime.toIso8601String(),
        'end_time': session.endTime?.toIso8601String(),
        'notes': session.notes,
        'heart_rate': session.heartRate,
        'calories': session.calories,
      }).select('id').single();

      final remoteSessionId = sessionRow['id'] as String;

      for (final log in logs) {
        final logRow = await client.from('exercise_logs').insert({
          'session_id': remoteSessionId,
          'exercise_name': log.exerciseName,
          'order_index': log.orderIndex,
        }).select('id').single();

        final remoteLogId = logRow['id'] as String;

        if (log.sets.isNotEmpty) {
          await client.from('workout_sets').insert(
            log.sets
                .map((s) => {
                      'log_id': remoteLogId,
                      'set_number': s.setNumber,
                      'weight': s.weight,
                      'reps': s.reps,
                      'rest_seconds': s.restSeconds,
                    })
                .toList(),
          );
        }
      }
      return remoteSessionId;
    } catch (_) {
      return null;
    }
  }

  // ── Pull all sessions from Supabase ─────────────────────────

  static Future<List<Map<String, dynamic>>> fetchAllSessions() async {
    if (!isLoggedIn) return [];
    try {
      final data = await client
          .from('workout_sessions')
          .select('''
            id, local_id, name, start_time, end_time,
            notes, heart_rate, calories,
            exercise_logs (
              id, exercise_name, order_index,
              workout_sets (
                id, set_number, weight, reps, rest_seconds
              )
            )
          ''')
          .eq('user_id', userId!)
          .order('start_time', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  // ── Delete a session from Supabase by local_id ──────────────

  static Future<void> deleteSession(int localId) async {
    if (!isLoggedIn) return;
    try {
      await client
          .from('workout_sessions')
          .delete()
          .eq('user_id', userId!)
          .eq('local_id', localId);
    } catch (_) {}
  }

  // ── Sync exercises (custom ones) ────────────────────────────

  static Future<void> pushExercise(
      String name, String muscleGroup, String equipment) async {
    if (!isLoggedIn) return;
    try {
      await client.from('exercises').insert({
        'user_id': userId,
        'name': name,
        'muscle_group': muscleGroup,
        'equipment': equipment,
        'is_default': false,
      });
    } catch (_) {}
  }
}
