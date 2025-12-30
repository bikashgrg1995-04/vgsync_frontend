import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import 'dashboard_controller.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});
  final DashboardController controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final summary = controller.summary;

      return SingleChildScrollView(
        padding: EdgeInsets.all(SizeConfig.sw(0.02)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- Summary Cards ----------------
            Row(
              children: [
                _summaryCard(
                    "Items", summary.totalItems.toString(), Colors.green),
                _summaryCard("Low Stock", summary.lowStockCount.toString(),
                    Colors.orange),
                _summaryCard(
                    "Sales",
                    controller.dashboardData.value.sales.monthlyAmount
                        .toString(),
                    Colors.teal),
                _summaryCard(
                    "Purchases",
                    controller.dashboardData.value.purchases.monthlyAmount
                        .toString(),
                    Colors.red),
                _summaryCard(
                    "Staffs",
                    controller.dashboardData.value.staffSalary.totalStaff
                        .toString(),
                    Colors.blueAccent)
              ],
            ),
            SizedBox(height: SizeConfig.sh(0.03)),

            // ---------------- Low Stock Items ----------------
            Text("Low Stock Items",
                style: TextStyle(
                    fontSize: SizeConfig.res(4.5),
                    fontWeight: FontWeight.bold)),
            SizedBox(height: SizeConfig.sh(0.01)),
            _lowStockList(),

            SizedBox(height: SizeConfig.sh(0.03)),

            // ---------------- Upcoming Follow-ups ----------------
            Text("Upcoming Follow-ups",
                style: TextStyle(
                    fontSize: SizeConfig.res(4.5),
                    fontWeight: FontWeight.bold)),
            SizedBox(height: SizeConfig.sh(0.01)),
            _followupList(),

            SizedBox(height: SizeConfig.sh(0.03)),

            // ---------------- Charts ----------------
            Text("Profit / Loss Chart",
                style: TextStyle(
                    fontSize: SizeConfig.res(4.5),
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _chartSelector(),
            SizedBox(height: 12),
            SizedBox(height: SizeConfig.sh(0.3), child: _lineChart()),
          ],
        ),
      );
    });
  }

  // ---------------- Creative Small Summary Card ----------------
  Widget _summaryCard(String title, String value, Color color) {
    return Container(
      margin: EdgeInsets.all(5),
      width: SizeConfig.sw(0.1),
      height: SizeConfig.sh(0.1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 8,
              offset: Offset(2, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.white70, fontSize: SizeConfig.res(3.5))),
          SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.res(4.5),
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _lowStockList() {
    if (controller.lowStockItems.isEmpty) {
      return const Text("All items are well stocked");
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.lowStockItems.length,
      separatorBuilder: (_, __) => SizedBox(height: SizeConfig.sh(0.01)),
      itemBuilder: (_, index) {
        final item = controller.lowStockItems[index];
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          child: ListTile(
            title: Text(item.name),
            subtitle:
                Text("Model: ${item.model} | Category: ${item.categoryName}"),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: item.stock < 5 ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(6)),
              child: Text("Stock: ${item.stock}",
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

  Widget _followupList() {
    if (controller.upcomingFollowups.isEmpty) {
      return const Text("No upcoming follow-ups");
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.upcomingFollowups.length,
      separatorBuilder: (_, __) => SizedBox(height: SizeConfig.sh(0.01)),
      itemBuilder: (_, index) {
        final f = controller.upcomingFollowups[index];
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          child: ListTile(
            title: Text(f.customerName),
            subtitle:
                Text("Follow-up: ${f.followUpDate}\nRemarks: ${f.remarks}"),
            leading: Icon(Icons.follow_the_signs, color: Colors.blueAccent),
          ),
        );
      },
    );
  }

  Widget _chartSelector() {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ChartPeriod.values.map((period) {
          final isSelected = controller.selectedChartPeriod.value == period;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              onPressed: () => controller.changeChartPeriod(period),
              child: Text(period.name.toUpperCase(),
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black)),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _lineChart() {
    return Obx(() {
      final chartData = controller.chartData;

      if (chartData.income.isEmpty && chartData.expense.isEmpty) {
        return const Center(child: Text("No chart data available"));
      }

      List<FlSpot> incomeSpots = [];
      List<FlSpot> expenseSpots = [];
      List<String> bottomLabels = [];

      double maxY = 0;

      // Prepare income spots and bottom labels
      for (int i = 0; i < chartData.income.length; i++) {
        final item = chartData.income[i];
        incomeSpots.add(FlSpot(i.toDouble(), item.amount));
        bottomLabels.add(
            item.month != null ? "M${item.month}" : ""); // label like M1, M2
        if (item.amount > maxY) maxY = item.amount;
      }

      // Prepare expense spots
      for (int i = 0; i < chartData.expense.length; i++) {
        final item = chartData.expense[i];
        expenseSpots.add(FlSpot(i.toDouble(), item.amount));
        if (item.amount > maxY) maxY = item.amount;
      }

      return LineChart(
        LineChartData(
          minX: 0,
          maxX: (incomeSpots.length > expenseSpots.length
                  ? incomeSpots.length - 1
                  : expenseSpots.length - 1)
              .toDouble(),
          minY: 0,
          maxY: maxY * 1.2, // add top padding
          gridData: FlGridData(show: true, drawVerticalLine: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < bottomLabels.length) {
                    return Text(bottomLabels[index],
                        style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: incomeSpots,
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
            LineChartBarData(
              spots: expenseSpots,
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      );
    });
  }
}
