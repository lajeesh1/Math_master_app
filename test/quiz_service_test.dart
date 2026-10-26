import 'package:flutter_test/flutter_test.dart';
import 'package:math_master_app/services/quiz_service.dart';

void main() {
  group('QuizService Tests', () {
    late QuizService quizService;

    setUp(() {
      quizService = QuizService();
    });

    test('Generates exactly 15 questions per quiz', () {
      for (final op in QuizOperation.values) {
        final questions = quizService.generateQuestions(op);
        expect(questions.length, equals(15),
            reason: '${op.displayName} should generate exactly 15 questions');
      }
    });

    test('Multiplication questions conform to 4th Standard rules (1..10)', () {
      final questions = quizService.generateQuestions(QuizOperation.multiplication);
      expect(questions.length, equals(15));

      for (final q in questions) {
        expect(q.operation, equals('×'));
        expect(q.operand1, inInclusiveRange(1, 10),
            reason: 'Operand 1 must be between 1 and 10');
        expect(q.operand2, inInclusiveRange(1, 10),
            reason: 'Operand 2 must be between 1 and 10');
        expect(q.correctAnswer, equals(q.operand1 * q.operand2));
        expect(q.isCorrect(q.operand1 * q.operand2), isTrue);
        expect(q.isCorrect(q.operand1 * q.operand2 + 1), isFalse);
      }
    });

    test('Addition questions conform to 4th Standard rules (1..999)', () {
      final questions = quizService.generateQuestions(QuizOperation.addition);
      expect(questions.length, equals(15));

      for (final q in questions) {
        expect(q.operation, equals('+'));
        expect(q.operand1, inInclusiveRange(1, 999));
        expect(q.operand2, inInclusiveRange(1, 999));
        expect(q.correctAnswer, equals(q.operand1 + q.operand2));
        expect(q.correctAnswer, greaterThan(0));
      }
    });

    test('Subtraction questions never produce negative answers (operand1 >= operand2)', () {
      final questions = quizService.generateQuestions(QuizOperation.subtraction);
      expect(questions.length, equals(15));

      for (final q in questions) {
        expect(q.operation, equals('−'));
        expect(q.operand1, inInclusiveRange(1, 999));
        expect(q.operand2, inInclusiveRange(1, 999));
        expect(q.operand1, greaterThanOrEqualTo(q.operand2),
            reason: 'Operand 1 must be >= Operand 2 so result is never negative');
        expect(q.correctAnswer, equals(q.operand1 - q.operand2));
        expect(q.correctAnswer, greaterThanOrEqualTo(0),
            reason: 'Subtraction result must never be negative');
      }
    });

    test('Division questions produce positive whole numbers with no remainder and no division by zero', () {
      final questions = quizService.generateQuestions(QuizOperation.division);
      expect(questions.length, equals(15));

      for (final q in questions) {
        expect(q.operation, equals('÷'));
        expect(q.operand2, greaterThan(0), reason: 'Divisor must not be zero');
        expect(q.operand1 % q.operand2, equals(0),
            reason: 'Division must have no remainder');
        expect(q.correctAnswer, equals(q.operand1 ~/ q.operand2));
        expect(q.correctAnswer, greaterThan(0));
      }
    });

    test('No duplicate questions within the same quiz', () {
      for (final op in QuizOperation.values) {
        final questions = quizService.generateQuestions(op);
        final signatures = questions.map((q) => '${q.operand1}_${q.operation}_${q.operand2}').toSet();
        expect(signatures.length, equals(15),
            reason: '${op.displayName} questions should be distinct');
      }
    });
  });
}
