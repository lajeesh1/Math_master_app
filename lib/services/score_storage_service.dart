import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/score_record.dart';

/// Service responsible for managing local SQLite storage for quiz score records.
class ScoreStorageService {
  static final ScoreStorageService instance = ScoreStorageService._internal();

  Database? _db;

  ScoreStorageService._internal();

  ScoreStorageService({Database? customDb}) : _db = customDb;

  static const String tableName = 'score_history';
  static const String dbName = 'math_master_quiz.db';
  static const int dbVersion = 1;

  /// Returns the existing database instance or initializes it.
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, dbName);

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        score INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        correct_answers INTEGER NOT NULL,
        incorrect_answers INTEGER NOT NULL,
        percentage REAL NOT NULL,
        result_status TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  /// Inserts a new score record into the database. Returns the generated record ID.
  Future<int> insertScore(ScoreRecord record) async {
    try {
      final db = await database;
      return await db.insert(
        tableName,
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // Re-throw or handle accordingly
      throw Exception('Failed to save score record: $e');
    }
  }

  /// Retrieves all score records ordered by timestamp descending (newest first).
  Future<List<ScoreRecord>> getAllScores() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: 'timestamp DESC, id DESC',
      );
      return maps.map((map) => ScoreRecord.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch score records: $e');
    }
  }

  /// Deletes a single score record by its ID.
  Future<int> deleteScore(int id) async {
    try {
      final db = await database;
      return await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete score record with id $id: $e');
    }
  }

  /// Clears all score history from the database.
  Future<int> clearAllScores() async {
    try {
      final db = await database;
      return await db.delete(tableName);
    } catch (e) {
      throw Exception('Failed to clear score history: $e');
    }
  }

  /// Closes database connection (useful for testing and cleanup).
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
