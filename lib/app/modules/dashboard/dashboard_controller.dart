// app/modules/dashboard/dashboard_controller.dart
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/models/dashboard/charts.dart';
import 'package:vgsync_frontend/app/data/models/dashboard/credit.dart'
    as credit_model;
import 'package:vgsync_frontend/app/data/models/dashboard/followup.dart'
    as followup_model;
import 'package:vgsync_frontend/app/data/models/dashboard/low_stock.dart'
    as stock_model;
import 'package:vgsync_frontend/app/data/models/dashboard/orders.dart'
    as order_model;
import 'package:vgsync_frontend/app/data/models/dashboard/staffs_salary.dart'
    as staff_model;
import 'package:vgsync_frontend/app/data/repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository dashboardRepository;
  final GlobalController globalController = Get.find<GlobalController>();

  DashboardController({required this.dashboardRepository});

  // ---------------- STATE ----------------
  final Rx<ChartPeriod> selectedPeriod = ChartPeriod.daily.obs;
  final RxString selectedChart = 'income'.obs;

  final RxBool isChartsLoading = false.obs;
  final RxBool isCreditLoading = false.obs;
  final RxBool isLowStockLoading = false.obs;
  final RxBool isOrdersLoading = false.obs;
  final RxBool isStaffSalaryLoading = false.obs;
  final RxBool isFollowupLoading = false.obs;

  final Rx<DashboardChartsOnly> chartsData = DashboardChartsOnly.empty().obs;
  final Rx<credit_model.DashboardCreditPaginated> creditData =
      credit_model.DashboardCreditPaginated.empty().obs;

  final Rx<stock_model.StockPaginatedResponse> stockData =
      stock_model.StockPaginatedResponse.empty().obs;
  final Rx<order_model.OrderPaginatedResponse> orderData =
      order_model.OrderPaginatedResponse.empty().obs;
  final Rx<staff_model.StaffSalaryPaginatedResponse> staffData =
      staff_model.StaffSalaryPaginatedResponse.empty().obs;
  final Rx<followup_model.FollowupPaginatedResponse> followupData =
      followup_model.FollowupPaginatedResponse.empty().obs;

  // ---------------- PAGINATION ----------------
  final RxInt creditCurrentPage = 0.obs;
  final RxInt stockCurrentPage = 0.obs;
  final RxInt ordersCurrentPage = 0.obs;
  final RxInt staffCurrentPage = 0.obs;
  final RxInt followupCurrentPage = 0.obs;

  // ================= LIFECYCLE =================
  @override
  void onInit() {
    super.onInit();

    // Load all dashboard data on start
    loadAllDashboardData();

    // Listen to global refresh triggers
    everAll(
        [globalController.refreshTriggers], (_) => _handleRefreshTriggers());
  }

  // ---------------- LOAD ALL ----------------
  Future<void> loadAllDashboardData() async {
    await Future.wait([
      fetchDashboardCharts(),
      fetchDashboardCredit(),
      fetchAllTables(),
    ]);
  }

  // ---------------- CHARTS ----------------
  Future<void> fetchDashboardCharts() async {
    try {
      isChartsLoading.value = true;
      final newData = await dashboardRepository.getDashboardCharts(
          period: selectedPeriod.value);
      chartsData.value = newData; // assign new value
      chartsData.refresh(); // <-- force rebuild
    } catch (e) {
      print("❌ Charts fetch error: $e");
      chartsData.value = DashboardChartsOnly.empty();
    } finally {
      isChartsLoading.value = false;
    }
  }

  // ---------------- CREDIT ----------------
  Future<void> fetchDashboardCredit() async => fetchCredits(page: 0);

  Future<void> fetchCredits({int page = 0}) async {
    try {
      isCreditLoading.value = true;
      final data = await dashboardRepository.getDashboardCredit(
          period: selectedPeriod.value, page: page + 1);
      creditData.value = data;
      creditCurrentPage.value = page;
    } catch (e) {
      print("❌ Credit fetch error: $e");
      creditData.value = credit_model.DashboardCreditPaginated.empty();
    } finally {
      isCreditLoading.value = false;
    }
  }

  List<credit_model.CreditItem> get pagedCreditItems {
    return selectedChart.value == 'income'
        ? creditData.value.sale.summary
        : creditData.value.purchase.summary;
  }

  int get creditTotalPages {
    return selectedChart.value == 'income'
        ? creditData.value.sale.pagination.totalPages
        : creditData.value.purchase.pagination.totalPages;
  }

  int get creditCurrentPageBackend {
    return selectedChart.value == 'income'
        ? creditData.value.sale.pagination.page
        : creditData.value.purchase.pagination.page;
  }

  // ---------------- TABLES ----------------
  Future<void> fetchAllTables() async {
    await Future.wait([
      fetchLowStock(),
      fetchOrders(),
      fetchStaffSalaries(),
      fetchFollowups()
    ]);
  }

  // ---------- LOW STOCK ----------
  Future<void> fetchLowStock({int page = 0}) async {
    try {
      isLowStockLoading.value = true;
      final data = await dashboardRepository.getLowStock(page: page + 1);
      stockData.value = data;
      stockCurrentPage.value = page;
    } catch (e) {
      print("❌ LowStock error: $e");
      stockData.value = stock_model.StockPaginatedResponse.empty();
    } finally {
      isLowStockLoading.value = false;
    }
  }

  List<stock_model.StockItem> get pagedStockItems => stockData.value.results;
  int get stockTotalPages => stockData.value.pagination.totalPages;
  int get stockCurrentPageBackend => stockData.value.pagination.page;

  // ---------- ORDERS ----------
  Future<void> fetchOrders({int page = 0}) async {
    try {
      isOrdersLoading.value = true;
      final data = await dashboardRepository.getOrders(page: page + 1);
      orderData.value = data;
      ordersCurrentPage.value = page;
    } catch (e) {
      print("❌ Orders error: $e");
      orderData.value = order_model.OrderPaginatedResponse.empty();
    } finally {
      isOrdersLoading.value = false;
    }
  }

  List<order_model.OrderItem> get pagedOrders => orderData.value.results;
  int get ordersTotalPages => orderData.value.pagination.totalPages;
  int get ordersCurrentPageBackend => orderData.value.pagination.page;

  // ---------- STAFF SALARIES ----------
  Future<void> fetchStaffSalaries({int page = 0}) async {
    try {
      isStaffSalaryLoading.value = true;
      final data = await dashboardRepository.getStaffSalaries(page: page + 1);
      staffData.value = data;
      staffCurrentPage.value = page;
    } catch (e) {
      print("❌ Staff salary error: $e");
      staffData.value = staff_model.StaffSalaryPaginatedResponse.empty();
    } finally {
      isStaffSalaryLoading.value = false;
    }
  }

  List<staff_model.StaffSalaryItem> get pagedStaffSalaries =>
      staffData.value.results;
  int get staffTotalPages => staffData.value.pagination.totalPages;
  int get staffCurrentPageBackend => staffData.value.pagination.page;

  // ---------- FOLLOWUPS ----------
  Future<void> fetchFollowups({int page = 0}) async {
    try {
      isFollowupLoading.value = true;
      final data = await dashboardRepository.getFollowups(page: page + 1);
      followupData.value = data;
      followupCurrentPage.value = page;
    } catch (e) {
      print("❌ Followup error: $e");
      followupData.value = followup_model.FollowupPaginatedResponse.empty();
    } finally {
      isFollowupLoading.value = false;
    }
  }

  List<followup_model.FollowupItem> get pagedFollowups =>
      followupData.value.results;
  int get followupTotalPages => followupData.value.pagination.totalPages;
  int get followupCurrentPageBackend => followupData.value.pagination.page;

  // ---------------- PERIOD ----------------
  void changePeriod(ChartPeriod period) {
    if (selectedPeriod.value == period) return;
    selectedPeriod.value = period;
    fetchDashboardCharts();
    fetchDashboardCredit();
  }

  // ---------------- HANDLE REFRESH ----------------
  void _handleRefreshTriggers() async {
    final triggersCopy =
        List<DashboardRefreshType>.from(globalController.refreshTriggers);

    for (var t in triggersCopy) {
      switch (t) {
        case DashboardRefreshType.all:
          await loadAllDashboardData();
          break;
        case DashboardRefreshType.stock:
          await fetchLowStock(page: stockCurrentPageBackend);
          break;
        case DashboardRefreshType.charts:
          await fetchDashboardCharts();
          break;
        case DashboardRefreshType.credit:
          await fetchDashboardCharts();
          await fetchCredits(page: creditCurrentPageBackend);
          break;
        case DashboardRefreshType.staff:
          await fetchDashboardCharts();
          await fetchCredits(page: creditCurrentPageBackend);
          await fetchStaffSalaries(page: staffCurrentPageBackend);
          break;
        case DashboardRefreshType.order:
          await fetchOrders(page: ordersCurrentPageBackend);
          break;
        case DashboardRefreshType.followup:
          await fetchFollowups(page: followupCurrentPageBackend);
          break;
      }

      globalController.removeTrigger(t);
    }
  }

  // ---------------- CHART GETTERS ----------------
  List<ChartPoint> get incomeChart => chartsData.value.income;
  List<ExpenseChartPoint> get expenseChart => chartsData.value.expense;
  bool get hasChartData => incomeChart.isNotEmpty || expenseChart.isNotEmpty;

  Map<String, double> get expensePieData {
    if (selectedChart.value != 'expense') return {};
    final Map<String, double> data = {};
    for (final e in expenseChart) {
      if (e.amount > 0 && e.type.toLowerCase() != 'income') {
        final key = e.type.toLowerCase();
        data[key] = (data[key] ?? 0) + e.amount;
      }
    }
    return data;
  }

  double get totalExpense {
    if (selectedChart.value != 'expense') return 0;
    return expenseChart
        .where((e) => e.type.toLowerCase() != 'income')
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // ---------------- CREDIT GETTERS ----------------
  credit_model.DashboardCreditPaginated get credit => creditData.value;

  double get totalNet => selectedChart.value == 'income'
      ? credit.sale.totals.totalNetAmount
      : credit.purchase.totals.totalNetAmount;

  double get totalPaid => selectedChart.value == 'income'
      ? credit.sale.totals.totalPaidAmount
      : credit.purchase.totals.totalPaidAmount;

  double get totalRemaining => selectedChart.value == 'income'
      ? credit.sale.totals.totalCreditAmount
      : credit.purchase.totals.totalCreditAmount;

  String getCreditName(credit_model.CreditItem item) {
    return selectedChart.value == 'income'
        ? (item.customerName ?? "Unknown Customer")
        : (item.supplierName ?? "Unknown Supplier");
  }

  double getCreditNet(credit_model.CreditItem item) => item.netTotal;
  double getCreditPaid(credit_model.CreditItem item) => item.paidAmount;
  double getCreditRemaining(credit_model.CreditItem item) =>
      item.remainingAmount;
  int getCreditDays(credit_model.CreditItem item) => item.creditDays;

  String getCreditDate(credit_model.CreditItem item) {
    final raw = selectedChart.value == 'income'
        ? (item.saleDate ?? "-")
        : (item.purchaseDate ?? "-");

    if (raw == "-") return raw;

    final dt = DateTime.parse(raw); // Parses as UTC if 'Z' exists
    final localDate = dt.toLocal(); // Convert to local time
    return "${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}";
  }
}
