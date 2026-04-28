import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/quiz_provider.dart';
import '../widgets/option_button.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Answers'),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          final questions = provider.questions;
          final userAnswers = provider.userAnswers;

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              final userAnswer = userAnswers[question.id] ?? '';
              final isCorrect = userAnswer == question.correctAnswer;

              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isCorrect ? AppColors.success : AppColors.error,
                          radius: 14,
                          child: Icon(
                            isCorrect ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Question ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      question.questionText,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    ...question.options.map((option) {
                      return OptionButton(
                        text: option,
                        isSelected: option == userAnswer || option == question.correctAnswer,
                        isCorrect: option == question.correctAnswer,
                        isWrong: option == userAnswer && option != question.correctAnswer,
                        showResult: true,
                        onTap: () {}, // disabled in review
                      );
                    }).toList(),
                    const Divider(height: 32),
                    const Text(
                      'Explanation:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.explanation,
                      style: const TextStyle(color: AppColors.textPrimary, height: 1.4),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
