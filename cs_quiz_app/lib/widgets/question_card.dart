import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../core/constants.dart';

class QuestionCard extends StatelessWidget {
  final QuestionModel question;
  
  const QuestionCard({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  question.difficulty,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Icon(
                Icons.help_outline,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.questionText,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
