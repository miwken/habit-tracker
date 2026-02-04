import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressChart extends StatelessWidget {
  final int completed;
  final int total;
  final double size;
  final bool showText;

  const ProgressChart({
    super.key,
    required this.completed,
    required this.total,
    this.size = 60,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final completedPercent = total > 0 ? (completed / total) : 0.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Круговая диаграмма
          PieChart(
            PieChartData(
              sections: _createSections(completedPercent),
              centerSpaceRadius: size * 0.4,
              sectionsSpace: 1,
            ),
          ),

          // Текст в центре (только если showText = true)
          if (showText)
            Center(
              child: Text(
                '$completed',
                style: TextStyle(
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createSections(double completedPercent) {
    return [
      // Зеленый сектор - выполненные
      PieChartSectionData(
        color: Colors.green,
        value: completedPercent * 100,
        radius: size * 0.35,
        title: '',
      ),

      // Красный сектор - невыполненные
      PieChartSectionData(
        color: Colors.redAccent,
        value: (1 - completedPercent) * 100,
        radius: size * 0.35,
        title: '',
      ),
    ];
  }
}
