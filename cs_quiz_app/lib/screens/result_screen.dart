import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/quiz_provider.dart';
import 'review_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<QuizProvider>(context, listen: false);
    final totalQuestions = provider.questions.length;
    double percentage = totalQuestions > 0 ? (provider.correctCount / totalQuestions) : 0.0;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scoreAnimation = Tween<double>(begin: 0, end: percentage).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, child) {
        final totalQuestions = provider.questions.length;
        final accuracy = totalQuestions > 0 ? (provider.correctCount / totalQuestions) * 100 : 0.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Quiz Result'),
            leading: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                provider.resetQuiz();
                Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Category: ${provider.currentCategory}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 40),
                        // Circular Score Indicator
                        AnimatedBuilder(
                          animation: _scoreAnimation,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 180,
                                  height: 180,
                                  child: CircularProgressIndicator(
                                    value: _scoreAnimation.value,
                                    strokeWidth: 16,
                                    backgroundColor: AppColors.primary.withOpacity(0.2),
                                    color: _getScoreColor(_scoreAnimation.value),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${(_scoreAnimation.value * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: _getScoreColor(_scoreAnimation.value),
                                      ),
                                    ),
                                    Text(
                                      'Score',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        // Stats Box
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildStatRow('Total Questions', '$totalQuestions', Icons.format_list_numbered),
                              const Divider(height: 32),
                              _buildStatRow('Correct Answers', '${provider.correctCount}', Icons.check_circle, color: AppColors.success),
                              const Divider(height: 32),
                              _buildStatRow('Incorrect Answers', '${provider.wrongCount}', Icons.cancel, color: AppColors.error),
                              const Divider(height: 32),
                              _buildStatRow('Accuracy', '${accuracy.toStringAsFixed(1)}%', Icons.track_changes, color: AppColors.secondary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ReviewScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        child: const Text('Review Answers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final category = provider.currentCategory;
                          final oldLimit = provider.questions.length;
                          provider.resetQuiz();
                          await provider.startQuiz(category, oldLimit);
                          if (context.mounted) {
                            Navigator.pop(context); // Pop result screen to go back to quiz screen
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Retry Quiz'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      provider.resetQuiz();
                      Navigator.pop(context);
                    },
                    child: const Text('Back to Home', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 0.8) return AppColors.success;
    if (percentage >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildStatRow(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? AppColors.textSecondary, size: 24),
        const SizedBox(width: 16),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
