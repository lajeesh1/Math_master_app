import 'package:flutter_test/flutter_test.dart';
import 'package:math_master_app/models/score_record.dart';
import 'package:math_master_app/services/score_storage_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite_common_ffi for desktop/unit test environments
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('ScoreStorageService Tests', () {
    late Database testDb;
    late ScoreStorageService storageService;

    setUp(() async {
      // Create fresh in-memory database for each test
      testDb = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE ${ScoreStorageService.tableName} (
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
          },
        ),
      );

      storageService = ScoreStorageService(customDb: testDb);
    });

    tearDown(() async {
      await storageService.close();
    });

    test('Insert score record and retrieve ordered newest first', () async {
      final record1 = ScoreRecord.create(
        operation: 'Multiplication (×)',
        score: 12,
        timestamp: DateTime(2026, 10, 26, 9, 0),
      );
      final record2 = ScoreRecord.create(
        operation: 'Addition (+)',
        score: 8,
        timestamp: DateTime(2026, 10, 26, 10, 0),
      );

      final id1 = await storageService.insertScore(record1);
      final id2 = await storageService.insertScore(record2);

      expect(id1, greaterThan(0));
      expect(id2, greaterThan(id1));

      final allRecords = await storageService.getAllScores();
      expect(allRecords.length, equals(2));

      // Newest (record2 at 10:00) should be first
      expect(allRecords[0].operation, equals('Addition (+)'));
      expect(allRecords[0].score, equals(8));
      expect(allRecords[0].resultStatus, equals('TRY AGAIN!'));

      // Older (record1 at 9:00) should be second
      expect(allRecords[1].operation, equals('Multiplication (×)'));
      expect(allRecords[1].score, equals(12));
      expect(allRecords[1].resultStatus, equals('PASSED!'));
    });

    test('Delete score record removes only selected record', () async {
      final r1 = ScoreRecord.create(
        operation: 'Multiplication (×)',
        score: 14,
        timestamp: DateTime(2026, 10, 26, 8, 0),
      );
      final r2 = ScoreRecord.create(
        operation: 'Division (÷)',
        score: 11,
        timestamp: DateTime(2026, 10, 26, 8, 30),
      );

      final id1 = await storageService.insertScore(r1);
      final id2 = await storageService.insertScore(r2);

      var list = await storageService.getAllScores();
      expect(list.length, equals(2));

      // Delete r1
      final deletedCount = await storageService.deleteScore(id1);
      expect(deletedCount, equals(1));

      list = await storageService.getAllScores();
      expect(list.length, equals(1));
      expect(list.first.id, equals(id2));
      expect(list.first.operation, equals('Division (÷)'));
    });

    test('Clear all scores empties the database', () async {
      await storageService.insertScore(
        ScoreRecord.create(operation: 'Addition (+)', score: 10),
      );
      await storageService.insertScore(
        ScoreRecord.create(operation: 'Subtraction (−)', score: 15),
      );

      var list = await storageService.getAllScores();
      expect(list.length, equals(2));

      await storageService.clearAllScores();

      list = await storageService.getAllScores();
      expect(list.isEmpty, isTrue);
    });
  });
}
