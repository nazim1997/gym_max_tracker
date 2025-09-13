import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/exercise.dart';

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
}