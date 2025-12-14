import 'package:get/get.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/supplier_repository.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../../data/repositories/purchase_repository.dart';
import '../../data/repositories/followup_repository.dart';
import '../../data/models/dashboard_model.dart';

class DashboardController extends GetxController {
  final CustomerRepository customerRepository;
  final SupplierRepository supplierRepository;
  final ItemRepository itemRepository;
  final CategoryRepository categoryRepository;
  final SaleRepository saleRepository;
  final PurchaseRepository purchaseRepository;
  final FollowUpRepository followupRepository;

  RxBool isPressed = false.obs;

  DashboardController({
    required this.customerRepository,
    required this.supplierRepository,
    required this.itemRepository,
    required this.categoryRepository,
    required this.saleRepository,
    required this.purchaseRepository,
    required this.followupRepository,
  });

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // ----------------------------
  // Dashboard summary data
  // ----------------------------
  var summary = DashboardSummary(
    customers: 0,
    suppliers: 0,
    items: 0,
    sales: SalesSummary(count: 0, amount: 0, todayAmount: 0, monthlyAmount: 0),
    purchases:
        SalesSummary(count: 0, amount: 0, todayAmount: 0, monthlyAmount: 0),
  ).obs;

  var lowStockItems = <LowStockItem>[].obs;
  var upcomingFollowups = <FollowupItem>[].obs;
  var isLoading = false.obs;

  // Chart data (for plotting in dashboard)
  var salesChart = <ChartData>[].obs;
  var purchaseChart = <ChartData>[].obs;

  // ----------------------------
  // Load dashboard data (demo)
  // ----------------------------
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      await Future.delayed(const Duration(seconds: 1)); // simulate loading

      // ----------------------------
      // Demo summary
      // ----------------------------
      summary.value = DashboardSummary(
        customers: 15,
        suppliers: 8,
        items: 25,
        sales: SalesSummary(
          count: 20,
          amount: 12500,
          todayAmount: 750,
          monthlyAmount: 10250,
        ),
        purchases: SalesSummary(
          count: 10,
          amount: 8200,
          todayAmount: 500,
          monthlyAmount: 7000,
        ),
      );

      // ----------------------------
      // Demo low stock items
      // ----------------------------
      lowStockItems.value = [
        LowStockItem(name: 'Item A', stock: 2),
        LowStockItem(name: 'Item B', stock: 4),
      ];

      // ----------------------------
      // Demo upcoming follow-ups
      // ----------------------------
      upcomingFollowups.value = [
        FollowupItem(
            customerName: 'Customer 1', date: '2025-10-27', priority: 'High'),
        FollowupItem(
            customerName: 'Customer 2', date: '2025-10-28', priority: 'Medium'),
      ];

      // ----------------------------
      // Demo chart data
      // ----------------------------
      salesChart.value = [
        ChartData(label: 'Mon', value: 1200),
        ChartData(label: 'Tue', value: 1500),
        ChartData(label: 'Wed', value: 900),
        ChartData(label: 'Thu', value: 2000),
        ChartData(label: 'Fri', value: 1800),
      ];

      purchaseChart.value = [
        ChartData(label: 'Mon', value: 800),
        ChartData(label: 'Tue', value: 700),
        ChartData(label: 'Wed', value: 950),
        ChartData(label: 'Thu', value: 1100),
        ChartData(label: 'Fri', value: 1000),
      ];
    } catch (e) {
      print('Error loading demo dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

// ----------------------------
// Helper classes
// ----------------------------
class LowStockItem {
  final String name;
  final int stock;
  LowStockItem({required this.name, required this.stock});
}

class FollowupItem {
  final String customerName;
  final String date;
  final String priority;
  FollowupItem({
    required this.customerName,
    required this.date,
    required this.priority,
  });
}

class ChartData {
  final String label;
  final double value;
  ChartData({required this.label, required this.value});
}
