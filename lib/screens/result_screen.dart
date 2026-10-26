import 'package:flutter/material.dart';
import '../models/score_record.dart';
import '../services/quiz_service.dart';
import 'home_screen.dart';
import 'score_history_screen.dart';

/// The Results Screen displayed after a student completes all 15 questions.
class ResultScreen extends StatelessWidget {
  final ScoreRecord record;
  final QuizOperation operation;

  const ResultScreen({
    super.key,
    required this.record,
    required this.operation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPassed = record.isPassed; // strictly > 10

    final Color statusColor = isPassed ? Colors.green.shade700 : Colors.deepOrange.shade600;
    final Color badgeBgColor = isPassed ? Colors.green.shade50 : Colors.deepOrange.shade50;

    final String statusText = record.resultStatus; // 'PASSED!' or 'TRY AGAIN!'
    final String message = isPassed
        ? (record.score == 15
            ? 'Perfect Score! You are a true Math Genius! 🌟'
            : 'Superb job! You passed with flying colors! 🎉')
        : (record.score >= 8
            ? 'Almost there! Practice a little more and you will pass! 💪'
            : 'Good effort! Never give up, practice makes you smarter! 🚀');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz Completed!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevent accidental back to completed quiz
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pass / Try Again Banner Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: statusColor.withAlpha(100), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withAlpha(30),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPassed ? Icons.emoji_events_rounded : Icons.auto_awesome_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: statusColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Operation: ${record.operation}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Score Breakdown Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Final Score Display
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetricItem(
                                title: 'Final Score',
                                value: '${record.score}/${record.totalQuestions}',
                                color: statusColor,
                                icon: Icons.sports_score_rounded,
                              ),
                              Container(
                                width: 1,
                                height: 50,
                                color: Colors.grey.shade300,
                              ),
                              _buildMetricItem(
                                title: 'Percentage',
                                value: record.formattedPercentage,
                                color: theme.colorScheme.primary,
                                icon: Icons.percent_rounded,
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          // Correct & Incorrect Breakdown
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildDetailItem(
                                label: 'Correct',
                                count: record.correctAnswers,
                                color: Colors.green.shade700,
                                icon: Icons.check_circle_outline_rounded,
                              ),
                              _buildDetailItem(
                                label: 'Incorrect',
                                count: record.incorrectAnswers,
                                color: Colors.red.shade700,
                                icon: Icons.highlight_off_rounded,
                              ),
                              _buildDetailItem(
                                label: 'Total',
                                count: record.totalQuestions,
                                color: Colors.blue.shade700,
                                icon: Icons.quiz_outlined,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Action Buttons:
                  // 1. Play Again
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.replay_rounded, size: 26),
                    label: const Text(
                      'Play Again',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 2. View Score History
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScoreHistoryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history_rounded, size: 24),
                    label: const Text(
                      'View Score History',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. Home
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home_rounded, size: 22),
                    label: const Text(
                      'Home',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
