import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/repositories/dashboard_repository.dart';

/// Profit & Loss period selection
enum ProfitLossPeriod { today, monthly, yearly }

class DashboardController extends GetxController {
  final DashboardRepository dashboardRepository;
  final GlobalController globalController = Get.find<GlobalController>();

  DashboardController({required this.dashboardRepository});

  // ---------------- Reactive fields ----------------
  RxBool isLoading = false.obs;
  var dashboardData = DashboardResponse.empty().obs;

  var lowStockItems = <LowStockItem>[].obs;
  var orderRecords = <OrderItem>[].obs;
  var staffSalaryRecords = <StaffSalaryItem>[].obs;
  var followupRecords = <FollowupItem>[].obs;

  Rx<ProfitLossPeriod> selectedPLPeriod = ProfitLossPeriod.today.obs;

  // ---------------- Computed getters ----------------
  StockSummary get stock => dashboardData.value.stock;
  IncomeSummary get income => dashboardData.value.income;
  ExpenseSummary get expense => dashboardData.value.expense;
  OrdersSummary get orders => dashboardData.value.orders;
  FollowupSummary get followups => dashboardData.value.followups;
  StaffSalarySummary get staffSalary => dashboardData.value.staffSalary;

  /// Profit/Loss based on selected period
  ProfitLoss get profitLoss => ProfitLoss(
        income: dashboardData.value.profitLoss.income,
        expense: dashboardData.value.profitLoss.expense,
        profit: dashboardData.value.profitLoss.profit,
        loss: dashboardData.value.profitLoss.loss,
      );

  List<FollowupItem> get upcomingFollowups => followupRecords;

  // ---------------- Lifecycle ----------------
  @override
  void onInit() {
    super.onInit();
    loadDashboardData();

    // Listen for dashboard refresh triggers
    ever<List<DashboardRefreshType>>(globalController.refreshTriggers, (_) {
      final triggersCopy =
          List<DashboardRefreshType>.from(globalController.refreshTriggers);

      for (var type in triggersCopy) {
        _partialRefresh(type);
        globalController.removeTrigger(type);
      }
    });
  }

  // ---------------- Load full dashboard ----------------
  Future<void> loadDashboardData() async {
    await _fetchDashboardData(DashboardRefreshType.all);
  }

  // ---------------- Partial / full refresh ----------------
  Future<void> _partialRefresh(DashboardRefreshType type) async {
    await _fetchDashboardData(type);
  }

  /// Internal method to fetch dashboard data and update reactive fields
  Future<void> _fetchDashboardData(DashboardRefreshType type) async {
    try {
      isLoading.value = true;
      final data = await dashboardRepository.getDashboard();

      switch (type) {
        case DashboardRefreshType.stock:
          dashboardData.update((val) {
            val?.stock = data.stock;
          });
          lowStockItems.assignAll(data.stock.lowStockItems);
          break;

        case DashboardRefreshType.income:
        case DashboardRefreshType.expense:
        case DashboardRefreshType.profitLoss:
          dashboardData.update((val) {
            val?.income = data.income;
            val?.expense = data.expense;
            val?.profitLoss = data.profitLoss;
          });
          break;

        case DashboardRefreshType.order:
          dashboardData.update((val) {
            val?.orders = data.orders;
          });
          orderRecords.assignAll(data.orders.records);
          break;

        case DashboardRefreshType.staff:
          dashboardData.update((val) {
            val?.staffSalary = data.staffSalary;
          });
          staffSalaryRecords.assignAll(data.staffSalary.details);
          break;

        case DashboardRefreshType.followup:
          dashboardData.update((val) {
            val?.followups = data.followups;
          });
          followupRecords.assignAll(data.followups.records);
          break;

        case DashboardRefreshType.all:
          dashboardData.value = data;
          lowStockItems.assignAll(data.stock.lowStockItems);
          orderRecords.assignAll(data.orders.records);
          staffSalaryRecords.assignAll(data.staffSalary.details);
          followupRecords.assignAll(data.followups.records);
          break;
      }
    } catch (e) {
      // Handle error or log
      print('Dashboard fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Profit & Loss period switch ----------------
  void changeProfitLossPeriod(ProfitLossPeriod period) {
    selectedPLPeriod.value = period;
  }

  // ---------------- Utility ----------------
  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
