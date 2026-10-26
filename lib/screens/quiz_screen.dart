import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/quiz_question.dart';
import '../models/score_record.dart';
import '../services/quiz_service.dart';
import '../services/score_storage_service.dart';
import '../widgets/quiz_question_card.dart';
import 'result_screen.dart';

/// Screen where students answer the 15 quiz questions one by one.
class QuizScreen extends StatefulWidget {
  final QuizOperation operation;
  final List<QuizQuestion> questions;
  final ScoreStorageService? storageService;

  const QuizScreen({
    super.key,
    required this.operation,
    required this.questions,
    this.storageService,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _answerFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  void _submitAnswer() async {
    if (_isSubmitting) return;

    final rawInput = _answerController.text.trim();
    if (rawInput.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your answer.';
      });
      return;
    }

    final int? userAnswer = int.tryParse(rawInput);
    if (userAnswer == null) {
      setState(() {
        _errorMessage = 'Please enter a valid whole number.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final currentQuestion = widget.questions[_currentIndex];
    final isCorrect = currentQuestion.isCorrect(userAnswer);

    if (isCorrect) {
      _score++;
    }

    // Check if this was the last question
    if (_currentIndex + 1 >= widget.questions.length) {
      // Quiz completed!
      final totalQuestions = widget.questions.length;
      final record = ScoreRecord.create(
        operation: widget.operation.displayName,
        score: _score,
        totalQuestions: totalQuestions,
        timestamp: DateTime.now(),
      );

      // Automatically save to local storage
      final storage = widget.storageService ?? ScoreStorageService.instance;
      try {
        await storage.insertScore(record);
      } catch (e) {
        debugPrint('Error saving quiz result: $e');
      }

      if (!mounted) return;

      // Navigate to Results Screen replacing the quiz screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            record: record,
            operation: widget.operation,
          ),
        ),
      );
    } else {
      // Advance to next question
      setState(() {
        _currentIndex++;
        _answerController.clear();
        _isSubmitting = false;
      });
      _answerFocusNode.requestFocus();
    }
  }

  Future<bool> _onWillPop() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Leave Quiz?'),
        content: const Text(
          'Are you sure you want to exit? Your progress in this quiz will not be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalQuestions = widget.questions.length;
    final currentQuestion = widget.questions[_currentIndex];
    final progress = (_currentIndex + 1) / totalQuestions;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _onWillPop();
        if (shouldLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.operation.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status bar: Question X of 15 | Score: Y
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withAlpha(150),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.format_list_numbered_rounded,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Question ${_currentIndex + 1} of $totalQuestions',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  'Score: $_score',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Question Card
                    QuizQuestionCard(
                      question: currentQuestion,
                      questionNumber: _currentIndex + 1,
                      totalQuestions: totalQuestions,
                    ),

                    const SizedBox(height: 28),

                    // Answer Input Field
                    TextField(
                      controller: _answerController,
                      focusNode: _answerFocusNode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitAnswer(),
                      onChanged: (val) {
                        if (_errorMessage != null) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Your Answer',
                        labelStyle: const TextStyle(fontSize: 18),
                        hintText: 'Type number here',
                        hintStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.normal,
                        ),
                        errorText: _errorMessage,
                        errorStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        prefixIcon: const Icon(Icons.edit_rounded, size: 24),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: theme.colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withAlpha(120),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Prominent Submit Answer Button
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentIndex + 1 == totalQuestions
                                      ? 'Finish Quiz'
                                      : 'Submit Answer',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  _currentIndex + 1 == totalQuestions
                                      ? Icons.check_circle_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 24,
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
