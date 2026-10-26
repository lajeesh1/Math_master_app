import 'package:intl/intl.dart';

/// Model representing a stored score record from a completed quiz.
class ScoreRecord {
  final int? id;
  final String operation;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final double percentage;
  final String resultStatus; // 'PASSED!' or 'TRY AGAIN!'
  final DateTime timestamp;

  const ScoreRecord({
    this.id,
    required this.operation,
    required this.score,
    this.totalQuestions = 15,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.percentage,
    required this.resultStatus,
    required this.timestamp,
  });

  /// Factory constructor to create a ScoreRecord from a completed quiz.
  factory ScoreRecord.create({
    int? id,
    required String operation,
    required int score,
    int totalQuestions = 15,
    DateTime? timestamp,
  }) {
    final correct = score;
    final incorrect = totalQuestions - score;
    final pct = totalQuestions > 0 ? (score / totalQuestions) * 100.0 : 0.0;
    // Pass rule: strictly greater than 10 (> 10)
    final status = score > 10 ? 'PASSED!' : 'TRY AGAIN!';
    return ScoreRecord(
      id: id,
      operation: operation,
      score: score,
      totalQuestions: totalQuestions,
      correctAnswers: correct,
      incorrectAnswers: incorrect,
      percentage: pct,
      resultStatus: status,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Convert to SQLite map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'operation': operation,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'incorrect_answers': incorrectAnswers,
      'percentage': percentage,
      'result_status': resultStatus,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from SQLite map
  factory ScoreRecord.fromMap(Map<String, dynamic> map) {
    return ScoreRecord(
      id: map['id'] as int?,
      operation: map['operation'] as String,
      score: map['score'] as int,
      totalQuestions: map['total_questions'] as int? ?? 15,
      correctAnswers: map['correct_answers'] as int,
      incorrectAnswers: map['incorrect_answers'] as int,
      percentage: (map['percentage'] as num).toDouble(),
      resultStatus: map['result_status'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  /// Formatted date string, e.g. "26 Oct 2026"
  String get formattedDate => DateFormat('dd MMM yyyy').format(timestamp);

  /// Formatted time string, e.g. "10:30 AM"
  String get formattedTime => DateFormat('hh:mm a').format(timestamp);

  /// Formatted percentage, e.g. "80.0%"
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';

  /// Whether the student passed
  bool get isPassed => score > 10;
}
