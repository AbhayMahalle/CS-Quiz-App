import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constants.dart';

class CorrectIncorrectPieChart extends StatelessWidget {
  final int correct;
  final int incorrect;

  const CorrectIncorrectPieChart({
    super.key,
    required this.correct,
    required this.incorrect,
  });

  @override
  Widget build(BuildContext context) {
    int total = correct + incorrect;
    if (total == 0) {
      return const Center(child: Text("No data available"));
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              color: AppColors.success,
              value: correct.toDouble(),
              title: '${((correct / total) * 100).toStringAsFixed(1)}%',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: AppColors.error,
              value: incorrect.toDouble(),
              title: '${((incorrect / total) * 100).toStringAsFixed(1)}%',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryPerformanceBarChart extends StatelessWidget {
  final Map<String, double> categoryScores;

  const CategoryPerformanceBarChart({
    super.key,
    required this.categoryScores,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryScores.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    List<BarChartGroupData> barGroups = [];
    int x = 0;
    categoryScores.forEach((category, score) {
      barGroups.add(
        BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: score,
              color: AppColors.primary,
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
      x++;
    });

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= categoryScores.length) {
                    return const Text('');
                  }
                  String category = categoryScores.keys.elementAt(value.toInt());
                  // Shorten category name if too long
                  if (category.length > 8) {
                    category = category.substring(0, 6) + '..';
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      category,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
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
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }
}
