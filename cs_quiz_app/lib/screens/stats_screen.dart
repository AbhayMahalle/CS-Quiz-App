import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../core/constants.dart';
import '../providers/stats_provider.dart';
import '../widgets/stat_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StatsProvider>(context, listen: false).loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics Dashboard'),
      ),
      body: Consumer<StatsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.userStats;
          
          if (stats.totalQuizzes == 0) {
            return const Center(
              child: Text(
                'No quizzes taken yet.\nStart a quiz to see your statistics!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                Row(
                  children: [
                    Expanded(child: _buildOverviewCard('Quizzes', '${stats.totalQuizzes}', Icons.assignment)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildOverviewCard('Questions', '${stats.totalCorrect + stats.totalWrong}', Icons.question_answer)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildOverviewCard('Correct', '${stats.totalCorrect}', Icons.check_circle, color: AppColors.success)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildOverviewCard('Accuracy', '${((stats.totalCorrect / (stats.totalCorrect + stats.totalWrong)) * 100).toStringAsFixed(1)}%', Icons.track_changes, color: AppColors.secondary)),
                  ],
                ),
                const SizedBox(height: 32),

                // Pie Chart: Correct vs Incorrect
                Text('Answers Ratio', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: CorrectIncorrectPieChart(
                    correct: stats.totalCorrect,
                    incorrect: stats.totalWrong,
                  ),
                ),
                const SizedBox(height: 32),

                // Bar Chart: Category Performance
                Text('Category Performance', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: CategoryPerformanceBarChart(categoryScores: provider.categoryPerformance),
                ),
                const SizedBox(height: 32),

                // Line Chart: Quiz Improvement
                Text('Performance Over Time', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: _buildLineChart(provider),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(icon, color: color ?? AppColors.primary, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(StatsProvider provider) {
    if (provider.recentResults.isEmpty) {
      return const Center(child: Text('Not enough data'));
    }

    // Take up to last 10 quizzes, chronological order
    var results = provider.recentResults.take(10).toList().reversed.toList();
    
    if (results.length < 2) {
      return const Center(child: Text('Complete more quizzes to see progress'));
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < results.length; i++) {
       spots.add(FlSpot(i.toDouble(), results[i].score));
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                   int index = value.toInt();
                   if (index >= 0 && index < results.length) {
                     return Padding(
                       padding: const EdgeInsets.only(top: 8.0),
                       child: Text(
                         DateFormat('MM/dd').format(results[index].date),
                         style: const TextStyle(fontSize: 10),
                       ),
                     );
                   }
                   return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                   return Text(
                     value.toInt().toString(),
                     style: const TextStyle(fontSize: 10),
                   );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
