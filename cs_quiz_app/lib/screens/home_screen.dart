import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../models/category_model.dart';
import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/category_card.dart';
import 'login_screen.dart';
import 'quiz_screen.dart';
import 'stats_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void _showModeSelectionDialog(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Select Mode: ${category.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('10 Questions'),
                onTap: () => _startQuiz(context, category, 10, ctx),
              ),
              ListTile(
                title: const Text('20 Questions'),
                onTap: () => _startQuiz(context, category, 20, ctx),
              ),
              ListTile(
                title: const Text('30 Questions'),
                onTap: () => _startQuiz(context, category, 30, ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startQuiz(BuildContext context, CategoryModel category, int limit, BuildContext dialogContext) async {
    Navigator.pop(dialogContext); // Close dialog
    
    final provider = Provider.of<QuizProvider>(context, listen: false);
    
    // Show loading
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator())
    );

    await provider.startQuiz(category.id, limit);
    
    if (context.mounted) {
      Navigator.pop(context); // Remove loading
      if (provider.quizState == QuizState.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Error')));
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QuizScreen()),
      );
    }
  }

  void _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Category & Mode',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a computer science subject and test length.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: appCategories.length,
                itemBuilder: (context, index) {
                  final category = appCategories[index];
                  
                  return CategoryCard(
                    category: category,
                    completedQuizzes: 0, // Migrated to backend general stats
                    onTap: () => _showModeSelectionDialog(context, category),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
