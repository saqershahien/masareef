import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:grade_project/category_icons.dart';

class SpendingPieChart extends StatefulWidget {
  final Map<String, double> spendingData;
  final bool isResponsive;

  const SpendingPieChart({
    super.key,
    required this.spendingData,
    this.isResponsive = false,
  });

  @override
  State<StatefulWidget> createState() => SpendingPieChartState();
}

class SpendingPieChartState extends State<SpendingPieChart> {
  int touchedIndex = -1;
  late List<MapEntry<String, double>> _sortedEntries;
  late double _totalValue;

  @override
  void initState() {
    super.initState();
    _processData();
  }

  @override
  void didUpdateWidget(SpendingPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spendingData != oldWidget.spendingData) {
      _processData();
    }
  }

  void _processData() {
    _sortedEntries = widget.spendingData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _totalValue = _sortedEntries.fold(0, (sum, item) => sum + item.value);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(
            show: false,
          ),
          sectionsSpace: 0,
          centerSpaceRadius:
          widget.isResponsive ? 40 : 60, // Adjust radius based on context
          sections: showingSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    if (_totalValue == 0) {
      return [];
    }

    return List.generate(_sortedEntries.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = widget.isResponsive ? 12.0 : 16.0;
      final radius = isTouched
          ? (widget.isResponsive ? 40.0 : 60.0)
          : (widget.isResponsive ? 30.0 : 50.0);
      final entry = _sortedEntries[i];
      final percentage = (entry.value / _totalValue) * 100;
      final categoryInfo = categoryIcons[entry.key] ?? defaultCategoryInfo;

      return PieChartSectionData(
        color: categoryInfo.color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    });
  }
}
