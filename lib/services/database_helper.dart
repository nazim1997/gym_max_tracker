import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/exercise.dart';
import '../models/workout_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  
  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fitness_tracker.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE workout_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id)
      )
    ''');
  }

  Future<List<Exercise>> getAllExercises() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('exercises');

    return List.generate(maps.length, (i) {
      return Exercise(
        id: maps[i]['id'],
        name: maps[i]['name'],
        category: maps[i]['category'],
      );
    });
  }

  Future<int> insertExercise(Exercise exercise) async {
    final db = await database;
    return await db.insert('exercises', {
      'name': exercise.name,
      'category': exercise.category,
    });
  }

  Future<int> insertWorkoutEntry(WorkoutEntry entry) async {
    final db = await database;
    return await db.insert('workout_entries', {
      'exercise_id': entry.exerciseId,
      'weight': entry.weight,
      'reps': entry.reps,
      'date': entry.date.toIso8601String(),
    });
  }

  Future<double?> getMaxWeight(int exerciseId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(weight) as max_weight FROM workout_entries WHERE exercise_id = ?',
      [exerciseId]
    );
    
    if (result.isNotEmpty && result.first['max_weight'] != null) {
      return result.first['max_weight'] as double;
    }
    return null;
  }

  Future<List<WorkoutEntry>> getWorkoutEntries(int exerciseId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_entries',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return WorkoutEntry(
        id: maps[i]['id'],
        exerciseId: maps[i]['exercise_id'],
        weight: maps[i]['weight'],
        reps: maps[i]['reps'],
        date: DateTime.parse(maps[i]['date']),
      );
    });
  }
}