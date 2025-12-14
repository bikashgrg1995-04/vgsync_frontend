import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vgsync_frontend/app/controllers/auth_controller.dart';
import 'package:vgsync_frontend/app/routes/app_routes.dart';
import '../../wigdets/app_card.dart';
import 'dashboard_controller.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardController controller = Get.find();
  final AuthController authController = Get.find();

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authController.logout();
              Get.offAllNamed(AppRoutes.login);
            },
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = controller.summary.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- Menu Cards ----------------
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildMenuCard('Customers', summary.customers, Icons.people,
                      Colors.blue),
                  _buildMenuCard('Suppliers', summary.suppliers,
                      Icons.local_shipping, Colors.orange),
                  _buildMenuCard(
                      'Items', summary.items, Icons.inventory, Colors.green),
                  _buildMenuCard(
                      'Categories', 0, Icons.category, Colors.purple),
                  _buildMenuCard(
                      'Sales', summary.sales.count, Icons.sell, Colors.red),
                  _buildMenuCard('Purchases', summary.purchases.count,
                      Icons.shopping_cart, Colors.teal),
                  _buildMenuCard(
                      'Follow-ups',
                      controller.upcomingFollowups.length,
                      Icons.alarm,
                      Colors.brown),
                ],
              ),
              const SizedBox(height: 24),

              // ---------------- Charts ----------------
              const Text('Sales & Purchases Chart',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: _buildChart(
                  summary.sales.amount.toDouble(),
                  summary.purchases.amount.toDouble(),
                ),
              ),

              const SizedBox(height: 24),

              // ---------------- Low Stock Table ----------------
              const Text('Low Stock Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildLowStockTable(),
              ),

              const SizedBox(height: 24),

              // ---------------- Upcoming Follow-ups ----------------
              const Text('Upcoming Follow-ups',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildFollowupTable(),
              ),

              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await authController.logout();
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMenuCard(String title, int count, IconData icon, Color color) {
    final Map<String, String> routeMap = {
      'Customers': AppRoutes.customers,
      'Suppliers': AppRoutes.suppliers,
      'Items': AppRoutes.items,
      'Categories': AppRoutes.categories,
      'Sales': AppRoutes.sales,
      'Purchases': AppRoutes.purchases,
      'Follow-ups': AppRoutes.followups,
    };

    return InkWell(
      onTap: () {
        final route = routeMap[title];
        if (route != null) {
          Get.toNamed(route);
        }
      },
      borderRadius: BorderRadius.circular(16),
      splashColor: color.withOpacity(0.2),
      child: AppCard(
        width: 150,
        height: 150,
        color: color.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('$count',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(double salesAmount, double purchaseAmount) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: salesAmount,
            color: Colors.blue,
            title: 'Sales\nRs.${salesAmount.toStringAsFixed(0)}',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: purchaseAmount,
            color: Colors.green,
            title: 'Purchases\nRs.${purchaseAmount.toStringAsFixed(0)}',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 0,
      ),
    );
  }

  Widget _buildLowStockTable() {
    final items = controller.lowStockItems;
    if (items.isEmpty) return const Text('No low stock items');

    return DataTable(
      columns: const [
        DataColumn(label: Text('Item')),
        DataColumn(label: Text('Stock')),
      ],
      rows: items
          .map((item) => DataRow(cells: [
                DataCell(Text(item.name)),
                DataCell(Text(item.stock.toString())),
              ]))
          .toList(),
    );
  }

  Widget _buildFollowupTable() {
    final followups = controller.upcomingFollowups;
    if (followups.isEmpty) return const Text('No upcoming follow-ups');

    return DataTable(
      columns: const [
        DataColumn(label: Text('Customer')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Priority')),
      ],
      rows: followups
          .map((f) => DataRow(cells: [
                DataCell(Text(f.customerName)),
                DataCell(Text(f.date)),
                DataCell(Text(f.priority)),
              ]))
          .toList(),
    );
  }
}
