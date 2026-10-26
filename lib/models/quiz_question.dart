/// Model representing a single quiz question for 4th Standard students.
class QuizQuestion {
  final int operand1;
  final int operand2;
  final String operation; // '×', '+', '−', '÷'
  final int correctAnswer;

  const QuizQuestion({
    required this.operand1,
    required this.operand2,
    required this.operation,
    required this.correctAnswer,
  });

  /// The formatted question string, e.g. "5 × 8 = ?"
  String get questionText => '$operand1 $operation $operand2 = ?';

  /// Check whether user's integer answer is correct.
  bool isCorrect(int userAnswer) => userAnswer == correctAnswer;

  @override
  String toString() => '$operand1 $operation $operand2 = $correctAnswer';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizQuestion &&
          runtimeType == other.runtimeType &&
          operand1 == other.operand1 &&
          operand2 == other.operand2 &&
          operation == other.operation;

  @override
  int get hashCode => Object.hash(operand1, operand2, operation);
}
