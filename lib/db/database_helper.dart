import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../models/exercise_log.dart';
import '../models/workout_set.dart';
import '../models/body_weight.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;

  DatabaseHelper._();

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'gym_tracker.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE workout_sessions ADD COLUMN remote_id TEXT',
      );
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS body_weights (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          weight REAL NOT NULL,
          logged_at TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        muscle_group TEXT NOT NULL,
        equipment TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE workout_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        notes TEXT,
        heart_rate INTEGER,
        calories INTEGER,
        remote_id TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE exercise_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        exercise_name TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (session_id) REFERENCES workout_sessions(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE workout_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        log_id INTEGER NOT NULL,
        set_number INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        rest_seconds INTEGER,
        FOREIGN KEY (log_id) REFERENCES exercise_logs(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE body_weights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        logged_at TEXT NOT NULL
      )
    ''');
    await _seedExercises(db);
  }

  Future<void> _seedExercises(Database db) async {
    final exercises = [
      ['Bench Press', 'Chest', 'Barbell'],
      ['Incline Dumbbell Press', 'Chest', 'Dumbbell'],
      ['Push Up', 'Chest', 'Bodyweight'],
      ['Pull Up', 'Back', 'Bodyweight'],
      ['Deadlift', 'Back', 'Barbell'],
      ['Barbell Row', 'Back', 'Barbell'],
      ['Lat Pulldown', 'Back', 'Cable'],
      ['Overhead Press', 'Shoulders', 'Barbell'],
      ['Lateral Raise', 'Shoulders', 'Dumbbell'],
      ['Squat', 'Legs', 'Barbell'],
      ['Leg Press', 'Legs', 'Machine'],
      ['Romanian Deadlift', 'Legs', 'Barbell'],
      ['Bicep Curl', 'Arms', 'Dumbbell'],
      ['Tricep Dip', 'Arms', 'Bodyweight'],
      ['Tricep Pushdown', 'Arms', 'Cable'],
      ['Plank', 'Core', 'Bodyweight'],
      ['Crunches', 'Core', 'Bodyweight'],
    ];
    for (final e in exercises) {
      await db.insert('exercises', {
        'name': e[0],
        'muscle_group': e[1],
        'equipment': e[2],
      });
    }
  }

  // Exercises
  Future<List<Exercise>> getExercises() async {
    final db = await database;
    final rows = await db.query('exercises', orderBy: 'muscle_group, name');
    return rows.map(Exercise.fromMap).toList();
  }

  Future<int> insertExercise(Exercise e) async {
    final db = await database;
    return db.insert('exercises', e.toMap());
  }

  // Sessions
  Future<int> insertSession(WorkoutSession s) async {
    final db = await database;
    return db.insert('workout_sessions', s.toMap());
  }

  Future<void> markSessionSynced(int localId, String remoteId) async {
    final db = await database;
    await db.update(
      'workout_sessions',
      {'remote_id': remoteId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  Future<List<WorkoutSession>> getUnsyncedSessions() async {
    final db = await database;
    final rows = await db.query(
      'workout_sessions',
      where: 'remote_id IS NULL AND end_time IS NOT NULL',
      orderBy: 'start_time DESC',
    );
    return rows.map(WorkoutSession.fromMap).toList();
  }

  Future<void> updateSession(WorkoutSession s) async {
    final db = await database;
    await db.update('workout_sessions', s.toMap(),
        where: 'id = ?', whereArgs: [s.id]);
  }

  Future<List<WorkoutSession>> getSessions() async {
    final db = await database;
    final rows = await db.query('workout_sessions', orderBy: 'start_time DESC');
    return rows.map(WorkoutSession.fromMap).toList();
  }

  Future<void> deleteSession(int id) async {
    final db = await database;
    await db.delete('workout_sessions', where: 'id = ?', whereArgs: [id]);
  }

  // Exercise logs
  Future<int> insertExerciseLog(ExerciseLog log) async {
    final db = await database;
    return db.insert('exercise_logs', log.toMap());
  }

  Future<List<ExerciseLog>> getLogsForSession(int sessionId) async {
    final db = await database;
    final rows = await db.query('exercise_logs',
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'order_index');
    final logs = rows.map(ExerciseLog.fromMap).toList();
    for (final log in logs) {
      log.sets = await getSetsForLog(log.id!);
    }
    return logs;
  }

  Future<void> deleteExerciseLog(int id) async {
    final db = await database;
    await db.delete('exercise_logs', where: 'id = ?', whereArgs: [id]);
  }

  // Sets
  Future<int> insertSet(WorkoutSet s) async {
    final db = await database;
    return db.insert('workout_sets', s.toMap());
  }

  Future<void> updateSet(WorkoutSet s) async {
    final db = await database;
    await db.update('workout_sets', s.toMap(),
        where: 'id = ?', whereArgs: [s.id]);
  }

  Future<void> deleteSet(int id) async {
    final db = await database;
    await db.delete('workout_sets', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<WorkoutSet>> getSetsForLog(int logId) async {
    final db = await database;
    final rows = await db.query('workout_sets',
        where: 'log_id = ?', whereArgs: [logId], orderBy: 'set_number');
    return rows.map(WorkoutSet.fromMap).toList();
  }

  // Body weights
  Future<int> insertBodyWeight(BodyWeight bw) async {
    final db = await database;
    return db.insert('body_weights', bw.toMap());
  }

  Future<List<BodyWeight>> getBodyWeights({int limit = 30}) async {
    final db = await database;
    final rows = await db.query('body_weights',
        orderBy: 'logged_at DESC', limit: limit);
    return rows.map(BodyWeight.fromMap).toList();
  }

  // Previous best: most recent max weight for an exercise across completed sessions
  Future<Map<String, dynamic>?> getLastBestForExercise(
      String exerciseName) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT ws.weight, ws.reps
      FROM workout_sessions s
      JOIN exercise_logs el ON el.session_id = s.id
      JOIN workout_sets ws ON ws.log_id = el.id
      WHERE el.exercise_name = ? AND s.end_time IS NOT NULL
      ORDER BY s.start_time DESC, ws.weight DESC
      LIMIT 1
    ''', [exerciseName]);
    return rows.isNotEmpty ? rows.first : null;
  }

  // Progress: max weight per exercise over time
  Future<List<Map<String, dynamic>>> getProgressForExercise(
      String exerciseName) async {
    final db = await database;
    return db.rawQuery('''
      SELECT date(s.start_time) as date, MAX(wset.weight) as max_weight
      FROM workout_sessions s
      JOIN exercise_logs el ON el.session_id = s.id
      JOIN workout_sets wset ON wset.log_id = el.id
      WHERE el.exercise_name = ?
      GROUP BY date(s.start_time)
      ORDER BY date(s.start_time)
    ''', [exerciseName]);
  }

  Future<double> getWeekVolume() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT SUM(ws.weight * ws.reps) as total
      FROM workout_sessions s
      JOIN exercise_logs el ON el.session_id = s.id
      JOIN workout_sets ws ON ws.log_id = el.id
      WHERE s.start_time >= datetime('now', '-7 days')
        AND s.end_time IS NOT NULL
    ''');
    if (rows.isEmpty || rows.first['total'] == null) return 0;
    return (rows.first['total'] as num).toDouble();
  }

  Future<List<Map<String, dynamic>>> getVolumePerSession() async {
    final db = await database;
    return db.rawQuery('''
      SELECT date(s.start_time) as date, SUM(wset.weight * wset.reps) as volume
      FROM workout_sessions s
      JOIN exercise_logs el ON el.session_id = s.id
      JOIN workout_sets wset ON wset.log_id = el.id
      GROUP BY date(s.start_time)
      ORDER BY date(s.start_time)
      LIMIT 30
    ''');
  }
}
