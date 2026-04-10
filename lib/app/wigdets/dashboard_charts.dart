// app/modules/dashboard/dashboard_charts.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/dashboard/charts.dart';
import 'package:vgsync_frontend/app/data/repositories/dashboard_repository.dart';
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
        case 'emi':
          return _chartCard(child: _emiBarChart());
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
        // ✅ No fixed SizedBox — fill available space
        child: child,
      ),
    );
  }

  // ---------------- INCOME BAR CHART ----------------
  Widget _incomeBarChart() {
    final saleData = controller.saleIncomeChart;
    final bikeData = controller.bikeIncomeChart;

    if (saleData.isEmpty && bikeData.isEmpty) {
      return const Center(
        child: Text(
          "No income data",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      );
    }

    final length =
        (saleData.length > bikeData.length) ? saleData.length : bikeData.length;

    double maxY = 0;
    for (var i = 0; i < length; i++) {
      final saleAmt = (i < saleData.length) ? saleData[i].amount : 0.0;
      final bikeAmt = (i < bikeData.length) ? bikeData[i].amount : 0.0;
      maxY = [maxY, saleAmt, bikeAmt].reduce((a, b) => a > b ? a : b);
    }
    maxY *= 1.2;

    final barGroups = List.generate(length, (i) {
      final saleAmt = (i < saleData.length) ? saleData[i].amount : 0.0;
      final bikeAmt = (i < bikeData.length) ? bikeData[i].amount : 0.0;

      return BarChartGroupData(
        x: i,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: saleAmt,
            width: 12,
            color: Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: bikeAmt,
            width: 12,
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    final chart = BarChart(
      BarChartData(
        maxY: maxY,
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
                if (index < 0 || index >= length) return const SizedBox.shrink();
                final label = _getLabelForIndex(index, saleData, bikeData);
                return SideTitleWidget(
                  meta: meta,
                  child: Text(label, style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: barGroups,
        gridData: FlGridData(show: true),
        barTouchData: BarTouchData(enabled: true),
      ),
    );

    return Column(
      children: [
        // ✅ Expanded fills remaining space — no fixed height
        Expanded(child: chart),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendIndicator(Colors.blue, "Bike Sale"),
            const SizedBox(width: 16),
            _legendIndicator(Colors.green, "Other Sale"),
          ],
        ),
      ],
    );
  }

  // ---------------- GET X-AXIS LABELS PER PERIOD ----------------
  String _getLabelForIndex(
      int index, List<ChartPoint> saleData, List<ChartPoint> bikeData) {
    final period = controller.selectedPeriod.value;
    String raw = '';
    if (index < saleData.length) {
      raw = saleData[index].period;
    } else if (index < bikeData.length) {
      raw = bikeData[index].period;
    }

    final dt = DateTime.tryParse(raw) ?? DateTime.now();

    switch (period) {
      case ChartPeriod.daily:
        return dt.day.toString().padLeft(2, '0');
      case ChartPeriod.weekly:
        return "W${_weekNumber(dt)}";
      case ChartPeriod.monthly:
        return _monthShort(dt.month);
      case ChartPeriod.threeMonths:
        return _threeMonthLabel(dt);
      case ChartPeriod.sixMonths:
        return _sixMonthLabel(dt);
      case ChartPeriod.yearly:
        return "${dt.year}";
    }
  }

  int _weekNumber(DateTime dt) {
    final firstDay = DateTime(dt.year, dt.month, 1);
    return ((dt.day + firstDay.weekday - 2) / 7).ceil();
  }

  String _monthShort(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _threeMonthLabel(DateTime dt) {
    final quarter = ((dt.month - 1) ~/ 3);
    final startMonth = _monthShort(quarter * 3 + 1);
    final endMonth = _monthShort(quarter * 3 + 3);
    return "$startMonth-$endMonth";
  }

  String _sixMonthLabel(DateTime dt) {
    final half = ((dt.month - 1) ~/ 6);
    final startMonth = _monthShort(half * 6 + 1);
    final endMonth = _monthShort(half * 6 + 6);
    return "$startMonth-$endMonth";
  }

  // ---------------- EMI BAR CHART ----------------
  Widget _emiBarChart() {
    final emiItems = controller.pagedCreditItems;
    if (emiItems.isEmpty) {
      return const Center(
        child: Text(
          "No EMI data",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      );
    }

    final length = emiItems.length;

    double maxY = 0;
    for (var item in emiItems) {
      maxY = [maxY, item.netTotal, item.paidAmount].reduce((a, b) => a > b ? a : b);
    }
    maxY *= 1.2;

    final barGroups = List.generate(length, (i) {
      final item = emiItems[i];
      return BarChartGroupData(
        x: i,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: item.netTotal,
            width: 12,
            color: Colors.orange,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: item.paidAmount,
            width: 12,
            color: Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    final chart = BarChart(
      BarChartData(
        maxY: maxY,
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
                if (index < 0 || index >= length) return const SizedBox.shrink();
                final label = emiItems[index].dueDate?.split('T').first ?? '-';
                return SideTitleWidget(
                  meta: meta,
                  child: Text(label, style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: barGroups,
        gridData: FlGridData(show: true),
        barTouchData: BarTouchData(enabled: true),
      ),
    );

    return Column(
      children: [
        Expanded(child: chart),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendIndicator(Colors.orange, "Total Due"),
            const SizedBox(width: 16),
            _legendIndicator(Colors.green, "Paid"),
          ],
        ),
      ],
    );
  }

  // ---------------- EXPENSE PIE CHART ----------------
  Widget _expensePieChartWithLegend() {
    final data = controller.expensePieData;
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
      Colors.yellow,
    ];

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
            radius: 90,
            titleStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
      ),
    );

    final legend = Wrap(
      spacing: 10,
      runSpacing: 5,
      children: List.generate(filteredData.length, (i) {
        final e = filteredData[i];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[i % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(e.key, style: const TextStyle(fontSize: 12)),
          ],
        );
      }),
    );

    return Column(
      children: [
        Expanded(child: pieChart),
        const SizedBox(height: 8),
        legend,
      ],
    );
  }

  // ---------------- LEGEND ITEM ----------------
  Widget _legendIndicator(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}