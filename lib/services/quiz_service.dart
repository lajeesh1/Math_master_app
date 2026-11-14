import 'dart:math';
import '../models/quiz_question.dart';

/// Question difficulty levels available in Math Master Quiz.
enum QuestionLevel {
  low(displayName: 'Low', description: 'Easy & foundational'),
  medium(displayName: 'Medium', description: 'Standard practice'),
  advanced(displayName: 'Advanced', description: 'Challenging & sharp');

  final String displayName;
  final String description;

  const QuestionLevel({
    required this.displayName,
    required this.description,
  });

  static QuestionLevel fromDisplayName(String? name) {
    if (name == null) return QuestionLevel.medium;
    for (final level in QuestionLevel.values) {
      if (level.displayName.toLowerCase() == name.toLowerCase()) {
        return level;
      }
    }
    return QuestionLevel.medium;
  }
}

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

  /// Match from operation display name
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

/// Service to generate quiz questions according to curriculum and user guidelines.
class QuizService {
  final Random _random;

  QuizService({Random? random}) : _random = random ?? Random();

  /// Total questions per quiz
  static const int questionsCount = 15;

  /// Generates exactly [questionsCount] unique questions for the chosen [operation] and [level].
  List<QuizQuestion> generateQuestions(
    QuizOperation operation, {
    QuestionLevel level = QuestionLevel.medium,
  }) {
    final List<QuizQuestion> questions = [];
    final Set<String> seenSignatures = {};

    int attempts = 0;
    const int maxAttempts = 1000;

    while (questions.length < questionsCount && attempts < maxAttempts) {
      attempts++;
      final question = _generateSingleQuestion(operation, level);
      final signature = '${question.operand1}_${question.operation}_${question.operand2}';

      if (!seenSignatures.contains(signature)) {
        seenSignatures.add(signature);
        questions.add(question);
      }
    }

    // Fallback if max attempts exceeded
    while (questions.length < questionsCount) {
      questions.add(_generateSingleQuestion(operation, level));
    }

    return questions;
  }

  /// Generates a single question conforming to rules:
  /// 1. Multiplication: ALWAYS avoids simple calculations (never multiplies with 1, 2, or 10).
  /// 2. Addition: positive integers tailored to the selected level.
  /// 3. Subtraction: result is NEVER negative (op1 >= op2).
  /// 4. Division: whole-number answers, no remainder, no division by zero.
  QuizQuestion _generateSingleQuestion(QuizOperation operation, QuestionLevel level) {
    switch (operation) {
      case QuizOperation.multiplication:
        return _generateMultiplicationQuestion(level);

      case QuizOperation.addition:
        return _generateAdditionQuestion(level);

      case QuizOperation.subtraction:
        return _generateSubtractionQuestion(level);

      case QuizOperation.division:
        return _generateDivisionQuestion(level);
    }
  }

  /// Generates multiplication question strictly avoiding 1, 2, and 10.
  QuizQuestion _generateMultiplicationQuestion(QuestionLevel level) {
    late final int op1;
    late final int op2;

    switch (level) {
      case QuestionLevel.low:
        // Single-digit multiplication avoiding 1, 2, and 10: 3..9
        final pool = [3, 4, 5, 6, 7, 8, 9];
        op1 = pool[_random.nextInt(pool.length)];
        op2 = pool[_random.nextInt(pool.length)];
        break;

      case QuestionLevel.medium:
        // Operands 3..15, strictly avoiding 1, 2, and 10
        final pool1 = [3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15];
        final pool2 = [3, 4, 5, 6, 7, 8, 9];
        op1 = pool1[_random.nextInt(pool1.length)];
        op2 = pool2[_random.nextInt(pool2.length)];
        break;

      case QuestionLevel.advanced:
        // Operands 11..25 and 3..12, strictly avoiding 1, 2, and 10
        final pool1 = [11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 22, 25];
        final pool2 = [3, 4, 5, 6, 7, 8, 9, 11, 12];
        op1 = pool1[_random.nextInt(pool1.length)];
        op2 = pool2[_random.nextInt(pool2.length)];
        break;
    }

    return QuizQuestion(
      operand1: op1,
      operand2: op2,
      operation: QuizOperation.multiplication.symbol,
      correctAnswer: op1 * op2,
    );
  }

  QuizQuestion _generateAdditionQuestion(QuestionLevel level) {
    late final int op1;
    late final int op2;

    switch (level) {
      case QuestionLevel.low:
        // 2-digit additions: 10..99
        op1 = _random.nextInt(90) + 10;
        op2 = _random.nextInt(90) + 10;
        break;

      case QuestionLevel.medium:
        // 2 to 3-digit additions: 50..999
        op1 = _random.nextInt(950) + 50;
        op2 = _random.nextInt(950) + 50;
        break;

      case QuestionLevel.advanced:
        // 3 to 4-digit additions: 100..4999
        op1 = _random.nextInt(4900) + 100;
        op2 = _random.nextInt(4900) + 100;
        break;
    }

    return QuizQuestion(
      operand1: op1,
      operand2: op2,
      operation: QuizOperation.addition.symbol,
      correctAnswer: op1 + op2,
    );
  }

  QuizQuestion _generateSubtractionQuestion(QuestionLevel level) {
    late final int num1;
    late final int num2;

    switch (level) {
      case QuestionLevel.low:
        num1 = _random.nextInt(90) + 10;
        num2 = _random.nextInt(90) + 10;
        break;

      case QuestionLevel.medium:
        num1 = _random.nextInt(950) + 50;
        num2 = _random.nextInt(950) + 50;
        break;

      case QuestionLevel.advanced:
        num1 = _random.nextInt(4900) + 100;
        num2 = _random.nextInt(4900) + 100;
        break;
    }

    final op1 = max(num1, num2);
    final op2 = min(num1, num2);

    return QuizQuestion(
      operand1: op1,
      operand2: op2,
      operation: QuizOperation.subtraction.symbol,
      correctAnswer: op1 - op2,
    );
  }

  QuizQuestion _generateDivisionQuestion(QuestionLevel level) {
    late final int divisor;
    late final int quotient;

    switch (level) {
      case QuestionLevel.low:
        final pool = [3, 4, 5, 6, 7, 8, 9];
        divisor = pool[_random.nextInt(pool.length)];
        quotient = _random.nextInt(8) + 3; // 3..10
        break;

      case QuestionLevel.medium:
        final pool = [3, 4, 5, 6, 7, 8, 9, 11, 12];
        divisor = pool[_random.nextInt(pool.length)];
        quotient = _random.nextInt(13) + 3; // 3..15
        break;

      case QuestionLevel.advanced:
        final pool = [3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15];
        divisor = pool[_random.nextInt(pool.length)];
        quotient = _random.nextInt(20) + 5; // 5..24
        break;
    }

    final dividend = divisor * quotient;

    return QuizQuestion(
      operand1: dividend,
      operand2: divisor,
      operation: QuizOperation.division.symbol,
      correctAnswer: quotient,
    );
  }
}
