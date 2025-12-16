import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/category_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/supplier_repository.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/repositories/sale_repository.dart';
import '../../data/repositories/purchase_repository.dart';
import '../../data/repositories/followup_repository.dart';
import '../../data/models/dashboard_model.dart';

class DashboardController extends GetxController {
  final CustomerRepository customerRepository;
  final CategoryRepository categoryRepository;
  final SupplierRepository supplierRepository;
  final ItemRepository itemRepository;
  final SaleRepository saleRepository;
  final PurchaseRepository purchaseRepository;
  final FollowUpRepository followupRepository;

  DashboardController({
    required this.customerRepository,
    required this.categoryRepository,
    required this.supplierRepository,
    required this.itemRepository,
    required this.saleRepository,
    required this.purchaseRepository,
    required this.followupRepository,
  });

  RxBool isLoading = false.obs;

  // Summary data
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

  // Count values for cards
  RxInt customerCount = 0.obs;
  RxInt categoryCount = 0.obs;
  RxInt supplierCount = 0.obs;
  RxInt itemCount = 0.obs;
  RxInt salesCount = 0.obs;
  RxInt purchaseCount = 0.obs;

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      // Fetch all data
      final summaryData = await Future.wait([
        customerRepository.getCount(),
        categoryRepository.getCount(),
        supplierRepository.getCount(),
        itemRepository.getCount(),
        saleRepository.getCount(),
        purchaseRepository.getCount(),
        followupRepository.getAllFollowUps(),
      ]);

      customerCount.value = summaryData[0] as int;
      categoryCount.value = summaryData[1] as int;
      supplierCount.value = summaryData[2] as int;
      itemCount.value = summaryData[3] as int;
      salesCount.value = summaryData[4] as int;
      purchaseCount.value = summaryData[5] as int;
      upcomingFollowups.value = (summaryData[6] as List)
          .map((f) => FollowupItem(
                customerName: f.customerName,
                date: f.date,
                priority: f.priority,
              ))
          .toList();

      // You can assign lowStockItems and summary if API returns more details
      lowStockItems.clear();
      summary.value = DashboardSummary(
        customers: customerCount.value,
        suppliers: supplierCount.value,
        items: itemCount.value,
        sales: SalesSummary(
            count: salesCount.value,
            amount: 0,
            todayAmount: 0,
            monthlyAmount: 0),
        purchases: SalesSummary(
            count: purchaseCount.value,
            amount: 0,
            todayAmount: 0,
            monthlyAmount: 0),
      );
    } catch (e) {
      print("Dashboard load error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

// Helper classes
class LowStockItem {
  final String name;
  final int stock;
  LowStockItem({required this.name, required this.stock});
}

class FollowupItem {
  final String customerName;
  final String date;
  final String priority;
  FollowupItem(
      {required this.customerName, required this.date, required this.priority});
}
