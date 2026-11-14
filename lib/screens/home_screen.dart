import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
import '../widgets/level_dropdown.dart';
import '../widgets/operation_buttons.dart';
import 'quiz_screen.dart';
import 'score_history_screen.dart';
import 'about_screen.dart';

/// The welcoming Home Screen designed to fit completely on one screen without scrolling.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  QuestionLevel _selectedLevel = QuestionLevel.medium;
  QuizOperation? _selectedOperation;
  final QuizService _quizService = QuizService();

  void _startQuiz() {
    if (_selectedOperation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please select a question type to start the quiz!',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.amber.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final questions = _quizService.generateQuestions(
      _selectedOperation!,
      level: _selectedLevel,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          operation: _selectedOperation!,
          level: _selectedLevel,
          questions: questions,
        ),
      ),
    );
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'home':
        break;
      case 'history':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScoreHistoryScreen()),
        );
        break;
      case 'about':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Math Master Quiz',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 19),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 26),
            tooltip: 'Menu',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: _onMenuSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'home',
                child: Row(
                  children: [
                    Icon(Icons.home_rounded, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Home', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Score History', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_rounded, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('About Developer', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final isSpacious = availableHeight >= 680;
            final double cardPaddingV = isSpacious ? 14.0 : 10.0;
            final double cardPaddingH = 14.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: availableHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: isSpacious ? 16.0 : 10.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Welcome Math Champ Box
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: cardPaddingH,
                              vertical: cardPaddingV,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primaryContainer,
                                  theme.colorScheme.secondaryContainer,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withAlpha(25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withAlpha(50),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.school_rounded,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Welcome, Math Champ!',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: theme.colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Mathematic practice',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onPrimaryContainer.withAlpha(220),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(200),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.primary.withAlpha(60),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.quiz_rounded, size: 14, color: theme.colorScheme.primary),
                                      const SizedBox(width: 5),
                                      Text(
                                        '15 Qs',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 2. Question Level Card
                          Card(
                            elevation: 2,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: cardPaddingH,
                                vertical: cardPaddingV,
                              ),
                              child: LevelDropdown(
                                selectedLevel: _selectedLevel,
                                onChanged: (level) {
                                  setState(() {
                                    _selectedLevel = level;
                                  });
                                },
                              ),
                            ),
                          ),

                          // 3. Choose Question Type Card
                          Card(
                            elevation: 2,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: cardPaddingH,
                                vertical: cardPaddingV + 2,
                              ),
                              child: OperationButtons(
                                selectedOperation: _selectedOperation,
                                onSelected: (op) {
                                  setState(() {
                                    _selectedOperation = op;
                                  });
                                },
                              ),
                            ),
                          ),

                          // 4. Action Buttons (Start Quiz & Past Scores)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: _startQuiz,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 3,
                                  shadowColor: theme.colorScheme.primary.withAlpha(80),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_arrow_rounded, size: 28),
                                    SizedBox(width: 8),
                                    Text(
                                      'Start Quiz',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ScoreHistoryScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.history_rounded, size: 20),
                                label: const Text(
                                  'View Past Scores',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
