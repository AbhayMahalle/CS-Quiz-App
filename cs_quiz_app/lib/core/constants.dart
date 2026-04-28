import 'package:flutter/material.dart';

class AppColors {
  // Primary Color: #4CAF50
  static const Color primary = Color(0xFF4CAF50);
  
  // Secondary Color: #2196F3
  static const Color secondary = Color(0xFF2196F3);

  // Background Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFDD6B20);
}

class AppConstants {
  static const String appName = 'CS Quiz Master';
  
  // Hive Box Names
  static const String userStatsBox = 'userStatsBox';
  static const String quizResultsBox = 'quizResultsBox';
  static const String questionsBox = 'questionsBox';

  // Quiz Limits
  static const int questionsPerQuiz = 10;
  static const int timePerQuestion = 20; // seconds
}
