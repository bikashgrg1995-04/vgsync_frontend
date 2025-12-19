import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/modules/categories/category_list_page.dart';
import 'package:vgsync_frontend/app/modules/customers/customer_list_page.dart';
import 'package:vgsync_frontend/app/modules/dashboard/dashboard_controller.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_list_page.dart';
import 'package:vgsync_frontend/app/modules/items/item_list_page.dart';
import 'package:vgsync_frontend/app/modules/purchases/purchase_list_page.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_list_page.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_list_page.dart';
import 'package:vgsync_frontend/app/wigdets/app_card.dart';
import 'package:vgsync_frontend/app/wigdets/sidebar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardController controller = Get.find();
  final GlobalController globalController = Get.find();

  @override
  void initState() {
    super.initState();
    controller.loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),

          /// -------- MAIN CONTENT ----------
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Switch content based on selected menu
              switch (globalController.selectedMenu.value) {
                case 'Sales':
                  return SaleListPage();
                case 'Purchases':
                  return PurchaseListPage();
                case 'Customers':
                  return CustomerListPage();
                case 'Follow-ups':
                  return FollowupListPage();
                case 'Suppliers':
                  return SupplierListPage();
                case 'Items':
                  return ItemListPage();
                case 'Categories':
                  return CategoryListPage();
                default:
                  return _dashboardOverview();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _dashboardOverview() {
    final summary = controller.summary.value;
    final lowStockItems = controller.lowStockItems; // List<ItemModel>
    final upcomingFollowups =
        controller.upcomingFollowups; // List<FollowUpModel>

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Row(
            children: [
              SizedBox(
                width: 600,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          /// SUMMARY CARDS
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _statCard('Customers', summary.customers),
              _statCard('Suppliers', summary.suppliers),
              _statCard('Categories', summary.categories),
              _statCard('Items', summary.items),
              _statCard('Sales', summary.sales.count),
              _statCard('Purchases', summary.purchases.count),
              _statCard('Follow-ups', upcomingFollowups.length),
            ],
          ),
          const SizedBox(height: 32),

          /// SALES VS PURCHASES CHART
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sales vs Purchases',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: _buildChart(
                    summary.sales.amount,
                    summary.purchases.amount,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          /// LOW STOCK ITEMS
          if (lowStockItems.isNotEmpty) ...[
            const Text(
              'Low Stock Items',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Item')),
                  DataColumn(label: Text('Stock')),
                  DataColumn(label: Text('Alert')),
                ],
                rows: lowStockItems.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item.name)),
                      DataCell(Text(item.stock.toString())),
                      DataCell(
                        item.stock <= 5 // Threshold
                            ? const Text(
                                'Low',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              )
                            : const Text(''),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
          ],

          /// UPCOMING FOLLOW-UPS
          if (upcomingFollowups.isNotEmpty) ...[
            const Text(
              'Upcoming Follow-ups (Next 7 Days)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Status')),
                ],
                rows: upcomingFollowups.map((fup) {
                  return DataRow(
                    cells: [
                      DataCell(Text(fup.customerName)),
                      DataCell(Text(fup.date)),
                      DataCell(
                        fup.priority.toString() == 'High'
                            ? const Text(
                                'Due Soon',
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold),
                              )
                            : const Text(''),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// -------- STAT CARD ----------
  Widget _statCard(String title, int value) {
    return AppCard(
      width: 120,
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// -------- CHART ----------
  Widget _buildChart(double sales, double purchases) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: sales,
            title: 'Sales\nRs.${sales.toStringAsFixed(0)}',
            color: Colors.purple,
            radius: 80,
            titleStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            value: purchases,
            title: 'Purchase\nRs.${purchases.toStringAsFixed(0)}',
            color: Colors.green,
            radius: 80,
            titleStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
