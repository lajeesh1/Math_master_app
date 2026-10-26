import 'package:flutter_test/flutter_test.dart';
import 'package:math_master_app/models/score_record.dart';

void main() {
  group('ScoreRecord Tests', () {
    test('Pass/fail threshold rule: score > 10 is PASSED!, score <= 10 is TRY AGAIN!', () {
      // Score 0: TRY AGAIN!
      final r0 = ScoreRecord.create(
        operation: 'Multiplication (×)',
        score: 0,
        totalQuestions: 15,
      );
      expect(r0.resultStatus, equals('TRY AGAIN!'));
      expect(r0.isPassed, isFalse);
      expect(r0.correctAnswers, equals(0));
      expect(r0.incorrectAnswers, equals(15));
      expect(r0.percentage, equals(0.0));

      // Score 7: TRY AGAIN!
      final r7 = ScoreRecord.create(
        operation: 'Addition (+)',
        score: 7,
        totalQuestions: 15,
      );
      expect(r7.resultStatus, equals('TRY AGAIN!'));
      expect(r7.isPassed, isFalse);
      expect(r7.correctAnswers, equals(7));
      expect(r7.incorrectAnswers, equals(8));

      // Score 10: strictly TRY AGAIN! (boundary test)
      final r10 = ScoreRecord.create(
        operation: 'Subtraction (−)',
        score: 10,
        totalQuestions: 15,
      );
      expect(r10.resultStatus, equals('TRY AGAIN!'));
      expect(r10.isPassed, isFalse);
      expect(r10.correctAnswers, equals(10));
      expect(r10.incorrectAnswers, equals(5));

      // Score 11: strictly PASSED! (boundary test)
      final r11 = ScoreRecord.create(
        operation: 'Multiplication (×)',
        score: 11,
        totalQuestions: 15,
      );
      expect(r11.resultStatus, equals('PASSED!'));
      expect(r11.isPassed, isTrue);
      expect(r11.correctAnswers, equals(11));
      expect(r11.incorrectAnswers, equals(4));

      // Score 15: PASSED! (perfect score)
      final r15 = ScoreRecord.create(
        operation: 'Division (÷)',
        score: 15,
        totalQuestions: 15,
      );
      expect(r15.resultStatus, equals('PASSED!'));
      expect(r15.isPassed, isTrue);
      expect(r15.correctAnswers, equals(15));
      expect(r15.incorrectAnswers, equals(0));
      expect(r15.percentage, equals(100.0));
    });

    test('SQLite serialization toMap and fromMap', () {
      final now = DateTime(2026, 10, 26, 10, 30);
      final original = ScoreRecord.create(
        id: 1,
        operation: 'Multiplication (×)',
        score: 12,
        totalQuestions: 15,
        timestamp: now,
      );

      final map = original.toMap();
      final restored = ScoreRecord.fromMap(map);

      expect(restored.id, equals(1));
      expect(restored.operation, equals('Multiplication (×)'));
      expect(restored.score, equals(12));
      expect(restored.totalQuestions, equals(15));
      expect(restored.correctAnswers, equals(12));
      expect(restored.incorrectAnswers, equals(3));
      expect(restored.resultStatus, equals('PASSED!'));
      expect(restored.timestamp, equals(now));
      expect(restored.formattedDate, equals('26 Oct 2026'));
      expect(restored.formattedTime, equals('10:30 AM'));
    });
  });
}
