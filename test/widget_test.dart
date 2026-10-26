import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_master_app/main.dart';
import 'package:math_master_app/models/quiz_question.dart';
import 'package:math_master_app/models/score_record.dart';
import 'package:math_master_app/screens/about_screen.dart';
import 'package:math_master_app/screens/quiz_screen.dart';
import 'package:math_master_app/screens/result_screen.dart';
import 'package:math_master_app/screens/score_history_screen.dart';
import 'package:math_master_app/services/quiz_service.dart';
import 'package:math_master_app/services/score_storage_service.dart';

/// In-memory mock storage for deterministic widget testing
class MockScoreStorageService extends ScoreStorageService {
  final List<ScoreRecord> _storage = [];
  int _nextId = 1;

  MockScoreStorageService() : super();

  @override
  Future<int> insertScore(ScoreRecord record) async {
    final id = record.id ?? _nextId++;
    final stored = ScoreRecord(
      id: id,
      operation: record.operation,
      score: record.score,
      totalQuestions: record.totalQuestions,
      correctAnswers: record.correctAnswers,
      incorrectAnswers: record.incorrectAnswers,
      percentage: record.percentage,
      resultStatus: record.resultStatus,
      timestamp: record.timestamp,
    );
    _storage.insert(0, stored);
    return id;
  }

  @override
  Future<List<ScoreRecord>> getAllScores() async {
    return List.from(_storage);
  }

  @override
  Future<int> deleteScore(int id) async {
    _storage.removeWhere((r) => r.id == id);
    return 1;
  }

  @override
  Future<int> clearAllScores() async {
    final count = _storage.length;
    _storage.clear();
    return count;
  }

  @override
  Future<void> close() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockScoreStorageService testStorageService;

  setUp(() {
    testStorageService = MockScoreStorageService();
  });

  void setPhoneScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('Widget Tests', () {
    testWidgets('Home Screen displays title, dropdown, and Start Quiz button', (tester) async {
      setPhoneScreenSize(tester);
      await tester.pumpWidget(const MathMasterApp());
      await tester.pumpAndSettle();

      expect(find.text('Math Master Quiz'), findsOneWidget);
      expect(find.text('Choose Question Type'), findsOneWidget);
      expect(find.text('Start Quiz'), findsOneWidget);
      expect(find.text('View Past Scores'), findsOneWidget);
    });

    testWidgets('Tapping Start Quiz without selecting operation shows warning SnackBar', (tester) async {
      setPhoneScreenSize(tester);
      await tester.pumpWidget(const MathMasterApp());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Start Quiz'));
      await tester.tap(find.text('Start Quiz'));
      await tester.pump();

      expect(find.text('Please select a question type to start the quiz!'), findsOneWidget);
    });

    testWidgets('About Screen displays correct app and developer details', (tester) async {
      setPhoneScreenSize(tester);
      await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Math Master Quiz'), findsOneWidget);
      expect(find.text('Lajeesh'), findsOneWidget);
      expect(find.text('Version 1.0.0'), findsOneWidget);
      expect(find.textContaining('4th Standard students'), findsOneWidget);
    });

    testWidgets('Quiz Screen validates empty input and progresses on answer submission', (tester) async {
      setPhoneScreenSize(tester);
      final sampleQuestions = [
        const QuizQuestion(
          operand1: 4,
          operand2: 5,
          operation: '×',
          correctAnswer: 20,
        ),
        const QuizQuestion(
          operand1: 6,
          operand2: 7,
          operation: '×',
          correctAnswer: 42,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreen(
            operation: QuizOperation.multiplication,
            questions: sampleQuestions,
            storageService: testStorageService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check initial question display
      expect(find.text('Question 1 of 2'), findsNWidgets(2));
      expect(find.text('Score: 0'), findsOneWidget);
      expect(find.text('4  ×  5 = ?'), findsOneWidget);

      // Submit with empty field -> error shown
      await tester.tap(find.text('Submit Answer'));
      await tester.pump();
      expect(find.text('Please enter your answer.'), findsOneWidget);

      // Enter correct answer "20"
      await tester.enterText(find.byType(TextField), '20');
      await tester.pump();
      await tester.tap(find.text('Submit Answer'));
      await tester.pumpAndSettle();

      // Should now advance to Question 2 of 2 with Score: 1
      expect(find.text('Question 2 of 2'), findsNWidgets(2));
      expect(find.text('Score: 1'), findsOneWidget);
      expect(find.text('6  ×  7 = ?'), findsOneWidget);
      expect(find.text('Finish Quiz'), findsOneWidget);

      // Submit final answer "42"
      await tester.enterText(find.byType(TextField), '42');
      await tester.pump();
      await tester.tap(find.text('Finish Quiz'));
      await tester.pumpAndSettle();

      // Result screen should now be shown
      expect(find.text('Quiz Completed!'), findsOneWidget);
      expect(find.text('2/2'), findsOneWidget);

      // Verify that the record was automatically saved to test storage
      final savedScores = await testStorageService.getAllScores();
      expect(savedScores.length, equals(1));
      expect(savedScores.first.score, equals(2));
    });

    testWidgets('Result Screen displays PASSED! for score > 10 and provides navigation buttons', (tester) async {
      setPhoneScreenSize(tester);
      final passedRecord = ScoreRecord.create(
        operation: 'Multiplication (×)',
        score: 13,
        totalQuestions: 15,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ResultScreen(
            record: passedRecord,
            operation: QuizOperation.multiplication,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PASSED!'), findsOneWidget);
      expect(find.text('13/15'), findsOneWidget);
      expect(find.text('Play Again'), findsOneWidget);
      expect(find.text('View Score History'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Result Screen displays TRY AGAIN! for score <= 10', (tester) async {
      setPhoneScreenSize(tester);
      final tryAgainRecord = ScoreRecord.create(
        operation: 'Multiplication (×)',
        score: 10,
        totalQuestions: 15,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ResultScreen(
            record: tryAgainRecord,
            operation: QuizOperation.multiplication,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TRY AGAIN!'), findsOneWidget);
      expect(find.text('10/15'), findsOneWidget);
    });

    testWidgets('Score History Screen shows empty state when no records exist', (tester) async {
      setPhoneScreenSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: ScoreHistoryScreen(storageService: testStorageService),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('No quiz records yet. Complete your first quiz!'), findsOneWidget);
    });

    testWidgets('Score History Screen shows records and handles deletion', (tester) async {
      setPhoneScreenSize(tester);
      final record = ScoreRecord.create(
        operation: 'Addition (+)',
        score: 12,
        totalQuestions: 15,
        timestamp: DateTime(2026, 10, 26, 10, 0),
      );
      await testStorageService.insertScore(record);

      await tester.pumpWidget(
        MaterialApp(
          home: ScoreHistoryScreen(storageService: testStorageService),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Addition (+)'), findsOneWidget);
      expect(find.text('PASSED!'), findsOneWidget);

      // Tap delete button on record
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      // Check confirmation dialog
      expect(find.text('Are you sure you want to delete this score record?'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify list is empty now
      expect(find.text('No quiz records yet. Complete your first quiz!'), findsOneWidget);
    });
  });
}
