// ---------------- DashboardPage.dart ----------------
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/dashboard_model.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import 'dashboard_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final DashboardController controller = Get.find<DashboardController>();
  final dateFormatter = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: controller.loadDashboardData,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.sw(0.03), vertical: SizeConfig.sh(0.02)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryCardsSection(),
              SizedBox(height: SizeConfig.sh(0.03)),
              _chartsSection(), // charts directly after summary cards
              SizedBox(height: SizeConfig.sh(0.03)),
              _lowStockFollowupRow(), // low stock & follow-ups side by side
              SizedBox(height: SizeConfig.sh(0.03)),
              _staffOrdersSection(), // staff & orders tables
              SizedBox(height: SizeConfig.sh(0.03)),
            ],
          ),
        ),
      );
    });
  }

  // ---------------- Summary Cards Section ----------------
  Widget _summaryCardsSection() {
    final stock = controller.stock;
    final orders = controller.orders;
    final staff = controller.staffSalary;
    final income = controller.income;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _summaryCard(
              "Total Items", stock.totalItems.toString(), Colors.green),
          _summaryCard(
              "Low Stock", stock.lowStockCount.toString(), Colors.orange),
          _summaryCard(
              "Total Orders", orders.totalOrders.toString(), Colors.purple),
          _summaryCard(
              "Staffs", staff.totalStaff.toString(), Colors.blueAccent),
          _summaryCard(
              "Income Today", income.today.toStringAsFixed(2), Colors.teal),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: SizeConfig.sw(0.12),
      height: SizeConfig.sh(0.12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.white70, fontSize: SizeConfig.res(3.5))),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.res(4.5),
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ---------------- Charts Section ----------------
  Widget _chartsSection() {
    return LayoutBuilder(builder: (context, constraints) {
      bool isWide = constraints.maxWidth > 600;
      return isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _expenseChartCard()),
                SizedBox(width: SizeConfig.sw(0.03)),
                Expanded(child: _profitLossChartCard()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _expenseChartCard(),
                SizedBox(height: SizeConfig.sh(0.02)),
                _profitLossChartCard(),
              ],
            );
    });
  }

  Widget _expenseChartCard() {
    final categories = controller.expense.categories;
    double total = categories.fold(0.0, (sum, e) => sum + e.amount);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Expense Distribution"),
            SizedBox(height: SizeConfig.sh(0.02)),

            // Pie chart
            SizedBox(
              height: SizeConfig.sh(0.25),
              child: categories.isEmpty
                  ? const Center(child: Text("No expense data"))
                  : PieChart(
                      PieChartData(
                        sections: categories.map((e) {
                          final perc =
                              total == 0 ? 0 : (e.amount / total) * 100;
                          return PieChartSectionData(
                            value: e.amount,
                            title: "${perc.toStringAsFixed(1)}%",
                            color: _getColorForCategory(e.category),
                            radius: 60,
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                      ),
                    ),
            ),

            SizedBox(height: SizeConfig.sh(0.02)),

            // Expense indicators + amounts
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categories.map((e) {
                final color = _getColorForCategory(e.category);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      // Indicator
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: SizeConfig.sw(0.02)),

                      // Category name
                      SizedBox(
                        width: SizeConfig.sw(0.08),
                        child: Text(
                          e.category,
                          style: TextStyle(fontSize: SizeConfig.res(3.5)),
                        ),
                      ),

                      // Amount
                      Text(
                        e.amount.toStringAsFixed(2),
                        style: TextStyle(
                            fontSize: SizeConfig.res(3.5),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profitLossChartCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Profit / Loss"),
            SizedBox(height: SizeConfig.sh(0.01)),
            _chartSelector(),
            SizedBox(height: SizeConfig.sh(0.02)),
            SizedBox(height: SizeConfig.sh(0.35), child: _lineChart()),
          ],
        ),
      ),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'salary':
        return Colors.blue;
      case 'operational':
        return Colors.orange;
      case 'others':
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  Widget _chartSelector() {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ProfitLossPeriod.values.map((period) {
          final isSelected = controller.selectedPLPeriod.value == period;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () => controller.changeProfitLossPeriod(period),
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
      final pl = controller.profitLoss;
      double maxY =
          [pl.income, pl.expense].reduce((a, b) => a > b ? a : b) * 1.2;

      return LineChart(
        LineChartData(
          minX: 0,
          maxX: 1,
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  if (val == 0) return const Text('Income');
                  if (val == 1) return const Text('Expense');
                  return const Text('');
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [FlSpot(0, pl.income), FlSpot(1, pl.income)],
              color: Colors.green,
              isCurved: true,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData:
                  BarAreaData(show: true, color: Colors.green.withOpacity(0.2)),
            ),
            LineChartBarData(
              spots: [FlSpot(0, pl.expense), FlSpot(1, pl.expense)],
              color: Colors.red,
              isCurved: true,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData:
                  BarAreaData(show: true, color: Colors.red.withOpacity(0.2)),
            ),
          ],
        ),
      );
    });
  }

  // ---------------- Low Stock & Follow-up Row ----------------
  Widget _lowStockFollowupRow() {
    return LayoutBuilder(builder: (context, constraints) {
      bool isWide = constraints.maxWidth > 600;
      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _lowStockSection()),
            SizedBox(width: SizeConfig.sw(0.03)),
            Expanded(child: _followupSection()),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _lowStockSection(),
            SizedBox(height: SizeConfig.sh(0.02)),
            _followupSection(),
          ],
        );
      }
    });
  }

  // ---------------- Low Stock Section ----------------
  Widget _lowStockSection() {
    final lowItems = controller.lowStockItems;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Low Stock Items"),
            SizedBox(height: SizeConfig.sh(0.01)),
            if (lowItems.isEmpty)
              const Center(child: Text("All items are well stocked")),
            if (lowItems.isNotEmpty)
              ...lowItems.map((item) => _lowStockTile(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _lowStockTile(LowStockItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      title:
          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Model: ${item.model} | Category: ${item.categoryName}"),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: item.stock < 5 ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(6)),
        child: Text("Stock: ${item.stock}",
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // ---------------- Follow-up Section ----------------
  Widget _followupSection() {
    final followups = controller.upcomingFollowups
        .where((f) =>
            DateTime.parse(f.followUpDate)
                .isAfter(DateTime.now().subtract(const Duration(days: 1))) &&
            f.status.toLowerCase() != 'terminated')
        .toList()
      ..sort((a, b) => DateTime.parse(a.followUpDate)
          .compareTo(DateTime.parse(b.followUpDate)));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Upcoming Follow-ups"),
            SizedBox(height: SizeConfig.sh(0.01)),
            if (followups.isEmpty)
              const Center(child: Text("No upcoming follow-ups")),
            if (followups.isNotEmpty)
              ...followups
                  .map((f) => ListTile(
                        title: Text(f.customerName),
                        subtitle: Text(
                            "Follow-up: ${f.followUpDate}\nRemarks: ${f.remarks}"),
                        leading: Icon(Icons.follow_the_signs,
                            color: f.statusColor.toLowerCase() == 'orange'
                                ? Colors.orange
                                : Colors.green),
                        trailing: f.isNearest
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(6)),
                                child: const Text("Nearest",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              )
                            : null,
                      ))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: TextStyle(
            fontSize: SizeConfig.res(4.5), fontWeight: FontWeight.bold));
  }

  // ---------------- Staff & Orders Section ----------------
  Widget _staffOrdersSection() {
    return LayoutBuilder(builder: (context, constraints) {
      bool isWide = constraints.maxWidth > 600;
      return isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _staffTableCard()),
                SizedBox(width: SizeConfig.sw(0.03)),
                Expanded(child: _ordersTableCard()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _staffTableCard(),
                SizedBox(height: SizeConfig.sh(0.02)),
                _ordersTableCard(),
              ],
            );
    });
  }

  Widget _staffTableCard() {
    final staffRecords = controller.staffSalaryRecords;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Staff Overview"),
            SizedBox(height: SizeConfig.sh(0.01)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Staff Name")),
                  DataColumn(label: Text("Paid")),
                  DataColumn(label: Text("Pending")),
                  DataColumn(label: Text("Status")),
                ],
                rows: staffRecords
                    .map((s) => DataRow(cells: [
                          DataCell(Text(s.staffName)),
                          DataCell(Text(s.paid.toStringAsFixed(2))),
                          DataCell(Text(s.pending.toStringAsFixed(2),
                              style: TextStyle(
                                  color: s.pending > 0
                                      ? Colors.red
                                      : Colors.green))),
                          DataCell(Text(s.paymentStatus,
                              style: TextStyle(
                                  color:
                                      s.paymentStatus.toLowerCase() == 'pending'
                                          ? Colors.orange
                                          : Colors.green,
                                  fontWeight: FontWeight.bold))),
                        ]))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ordersTableCard() {
    final ordersRecords = controller.orderRecords;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Orders Overview"),
            SizedBox(height: SizeConfig.sh(0.01)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Date")),
                  DataColumn(label: Text("Customer Name")),
                  DataColumn(label: Text("Total Amount")),
                  DataColumn(label: Text("Advance")),
                  DataColumn(label: Text("Pending Amount")),
                ],
                rows: ordersRecords
                    .map((o) => DataRow(cells: [
                          DataCell(Text(o.date.split("T").first)),
                          DataCell(Text(o.customerName)),
                          DataCell(Text(o.totalAmount.toStringAsFixed(2))),
                          DataCell(Text(o.advance.toStringAsFixed(2))),
                          DataCell(Text(o.pendingAmount.toStringAsFixed(2),
                              style: TextStyle(
                                  color: o.pendingAmount > 0
                                      ? Colors.red
                                      : Colors.green))),
                        ]))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
