import 'dart:math';
import '../models/quiz_question.dart';

/// Available operations in the Math Master Quiz.
enum QuizOperation {
  multiplication(
    displayName: 'Multiplication (×)',
    shortName: 'Multiplication',
    symbol: '×',
  ),
  addition(
    displayName: 'Addition (+)',
    shortName: 'Addition',
    symbol: '+',
  ),
  subtraction(
    displayName: 'Subtraction (−)',
    shortName: 'Subtraction',
    symbol: '−',
  ),
  division(
    displayName: 'Division (÷)',
    shortName: 'Division',
    symbol: '÷',
  );

  final String displayName;
  final String shortName;
  final String symbol;

  const QuizOperation({
    required this.displayName,
    required this.shortName,
    required this.symbol,
  });

  /// Match from dropdown display name
  static QuizOperation? fromDisplayName(String? name) {
    if (name == null) return null;
    for (final op in QuizOperation.values) {
      if (op.displayName == name || op.shortName == name) {
        return op;
      }
    }
    return null;
  }
}

/// Service to generate quiz questions according to 4th Standard curriculum guidelines.
class QuizService {
  final Random _random;

  QuizService({Random? random}) : _random = random ?? Random();

  /// Total questions per quiz
  static const int questionsCount = 15;

  /// Generates exactly [questionsCount] unique questions for the chosen [operation].
  List<QuizQuestion> generateQuestions(QuizOperation operation) {
    final List<QuizQuestion> questions = [];
    final Set<String> seenSignatures = {};

    // Keep generating until we reach exactly 15 unique questions
    // Max attempts prevent infinite loop in extreme edge cases
    int attempts = 0;
    const int maxAttempts = 1000;

    while (questions.length < questionsCount && attempts < maxAttempts) {
      attempts++;
      final question = _generateSingleQuestion(operation);
      final signature = '${question.operand1}_${question.operation}_${question.operand2}';

      if (!seenSignatures.contains(signature)) {
        seenSignatures.add(signature);
        questions.add(question);
      }
    }

    // Fallback if max attempts exceeded (should never happen with the large state space)
    while (questions.length < questionsCount) {
      questions.add(_generateSingleQuestion(operation));
    }

    return questions;
  }

  /// Generates a single question conforming to rules for 4th Standard:
  /// 1. Multiplication: operands from 1 to 10
  /// 2. Addition: numbers from 1 to 999
  /// 3. Subtraction: operands from 1 to 999, result is NEVER negative (op1 >= op2)
  /// 4. Division: whole-number answers, no remainder, no division by zero
  QuizQuestion _generateSingleQuestion(QuizOperation operation) {
    switch (operation) {
      case QuizOperation.multiplication:
        // Operands from 1 to 10
        final op1 = _random.nextInt(10) + 1; // 1..10
        final op2 = _random.nextInt(10) + 1; // 1..10
        return QuizQuestion(
          operand1: op1,
          operand2: op2,
          operation: operation.symbol,
          correctAnswer: op1 * op2,
        );

      case QuizOperation.addition:
        // Numbers from 1 to 999
        final op1 = _random.nextInt(999) + 1; // 1..999
        final op2 = _random.nextInt(999) + 1; // 1..999
        return QuizQuestion(
          operand1: op1,
          operand2: op2,
          operation: operation.symbol,
          correctAnswer: op1 + op2,
        );

      case QuizOperation.subtraction:
        // Numbers from 1 to 999, ensuring op1 >= op2 so result is never negative
        int num1 = _random.nextInt(999) + 1; // 1..999
        int num2 = _random.nextInt(999) + 1; // 1..999
        final op1 = max(num1, num2);
        final op2 = min(num1, num2);
        return QuizQuestion(
          operand1: op1,
          operand2: op2,
          operation: operation.symbol,
          correctAnswer: op1 - op2,
        );

      case QuizOperation.division:
        // Division: whole-number answer, no remainder, no division by zero
        // Divisor b in 1..12 (mostly 2..12 for engaging 4th grade division)
        final divisor = _random.nextInt(12) + 1; // 1..12
        // Quotient q in 1..20
        final quotient = _random.nextInt(20) + 1; // 1..20
        // Dividend = divisor * quotient (positive whole number)
        final dividend = divisor * quotient;
        return QuizQuestion(
          operand1: dividend,
          operand2: divisor,
          operation: operation.symbol,
          correctAnswer: quotient,
        );
    }
  }
}
