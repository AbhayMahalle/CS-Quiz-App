import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/quiz_provider.dart';
import '../widgets/option_button.dart';
import '../widgets/progress_bar.dart';
import '../widgets/question_card.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String _selectedOption = '';
  bool _isAnswered = false;

  void _handleOptionTap(String option, QuizProvider provider) {
    if (_isAnswered) return;
    setState(() {
      _selectedOption = option;
      _isAnswered = true;
    });

    // Provide a small delay so user can see what they clicked before moving on
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        provider.submitAnswer(_selectedOption);
        
        if (provider.quizState == QuizState.finished) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ResultScreen()),
          );
        } else {
          setState(() {
            _selectedOption = '';
            _isAnswered = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, child) {
        final question = provider.currentQuestion;

        if (question == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Listen to timer expired
        if (provider.timeLeft == 0 && !_isAnswered) {
          _isAnswered = true;
          Future.delayed(Duration.zero, () {
             if (provider.quizState == QuizState.finished) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ResultScreen()),
                );
             } else {
                setState(() {
                  _selectedOption = '';
                  _isAnswered = false;
                });
             }
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(provider.currentCategory),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _showExitDialog(context, provider);
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.timeLeft}s',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                CustomProgressBar(
                  current: provider.currentQuestionIndex + 1,
                  total: provider.questions.length,
                ),
                const SizedBox(height: 32),
                QuestionCard(question: question),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.builder(
                    itemCount: question.options.length,
                    itemBuilder: (context, index) {
                      final option = question.options[index];
                      return OptionButton(
                        text: option,
                        isSelected: _selectedOption == option,
                        onTap: () => _handleOptionTap(option, provider),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showExitDialog(BuildContext context, QuizProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Quiz?'),
        content: const Text('Are you sure you want to quit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.resetQuiz();
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close quiz screen
            },
            child: const Text('Quit', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
