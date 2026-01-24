// app/modules/dashboard/dashboard_charts.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/modules/dashboard/dashboard_controller.dart';

class DashboardCharts extends StatelessWidget {
  DashboardCharts({super.key});

  final DashboardController controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isChartsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      switch (controller.selectedChart.value) {
        case 'income':
          return _chartCard(child: _incomeBarChart());
        case 'expense':
          return _chartCard(child: _expensePieChartWithLegend());
        default:
          return const Center(child: Text("No chart selected"));
      }
    });
  }

  // ---------------- CHART CARD ----------------
  Widget _chartCard({required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 300, // increased height to fit legend
          child: child,
        ),
      ),
    );
  }

  // ---------------- INCOME BAR CHART ----------------
  Widget _incomeBarChart() {
    final data = controller.incomeChart;

    if (data.isEmpty) {
      return const Center(
        child: Text(
          "No income data",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      );
    }

    final barGroups = data.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: point.amount,
            width: 16,
            color: Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: data.map((e) => e.amount).reduce((a, b) => a > b ? a : b) * 1.2,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox.shrink();
                final label = data[index].date;
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    label.split('T').first,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: barGroups,
      ),
    );
  }

  // ---------------- EXPENSE PIE CHART WITH LEGEND ----------------
  Widget _expensePieChartWithLegend() {
    final data = controller.expensePieData; // Only expenses
    final filteredData = data.entries.where((e) => e.value > 0).toList();

    if (filteredData.isEmpty) {
      return const Center(
        child: Text(
          "No expense data",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      );
    }

    final colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.yellow
    ];

    // ---------------- PIE CHART ----------------
    final pieChart = PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        sections: List.generate(filteredData.length, (i) {
          final e = filteredData[i];
          return PieChartSectionData(
            value: e.value,
            color: colors[i % colors.length],
            title: e.value.toStringAsFixed(0),
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
      ),
    );

    
    

    // ---------------- LEGEND ----------------
    final legend = Wrap(
      spacing: 10,
      runSpacing: 5,
      children: List.generate(filteredData.length, (i) {
        final e = filteredData[i];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 16, height: 16, color: colors[i % colors.length]),
            const SizedBox(width: 4),
            Text(
              e.key,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         SizedBox(height: 20),
        SizedBox(height: 180, child: pieChart),
        SizedBox(height: 60),
        legend,
      ],
    );
  }
}
