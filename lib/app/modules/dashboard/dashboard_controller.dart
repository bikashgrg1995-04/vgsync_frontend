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
  final RxString selectedChart = 'income'.obs; // 'income', 'expense', 'emi'

  final RxBool isChartsLoading = false.obs;
  final RxBool isCreditLoading = false.obs;
  final RxBool isLowStockLoading = false.obs;
  final RxBool isOrdersLoading = false.obs;
  final RxBool isStaffSalaryLoading = false.obs;
  final RxBool isFollowupLoading = false.obs;

  final Rx<DashboardCharts> chartsData = DashboardCharts.empty().obs;
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
      chartsData.value = newData;
      chartsData.refresh();
    } catch (e) {
      print("❌ Charts fetch error: $e");
      chartsData.value = DashboardCharts.empty();
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
          period: selectedPeriod.value, page: page + 1, pageSize: 5);
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
    switch (selectedChart.value) {
      case 'income':
        return creditData.value.sale.summary;
      case 'expense':
        return creditData.value.purchase.summary;
      case 'emi':
        return creditData.value.emi.summary;
      default:
        return [];
    }
  }

  int get creditTotalPages {
    switch (selectedChart.value) {
      case 'income':
        return creditData.value.sale.pagination.totalPages;
      case 'expense':
        return creditData.value.purchase.pagination.totalPages;
      case 'emi':
        return creditData.value.emi.pagination.totalPages;
      default:
        return 1;
    }
  }

  int get creditCurrentPageBackend {
    switch (selectedChart.value) {
      case 'income':
        return creditData.value.sale.pagination.page;
      case 'expense':
        return creditData.value.purchase.pagination.page;
      case 'emi':
        return creditData.value.emi.pagination.page;
      default:
        return 1;
    }
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

  // ---------------- CHART GETTERS (Updated for new model) ----------------

  /// Income series (normal sale)
  List<ChartPoint> get saleIncomeChart => chartsData.value.saleIncome;

  /// Income series (bike sale)
  List<ChartPoint> get bikeIncomeChart => chartsData.value.bikeIncome;

  /// Expenses per period with breakdown
  List<ExpensePeriodPoint> get expenseChart => chartsData.value.expense;

  /// Total Profit / Loss per period
  List<ChartPoint> get profitLossChart => chartsData.value.profitLoss;

  /// Check if any chart data exists
  bool get hasChartData =>
      saleIncomeChart.isNotEmpty ||
      bikeIncomeChart.isNotEmpty ||
      expenseChart.isNotEmpty;

  /// Flattened Expense Pie chart data (for breakdown across all periods)
  Map<String, double> get expensePieData {
    if (selectedChart.value != 'expense') return {};

    final Map<String, double> data = {};
    for (final periodPoint in expenseChart) {
      for (final typePoint in periodPoint.types) {
        final key = typePoint.type.toLowerCase();
        data[key] = (data[key] ?? 0) + typePoint.amount;
      }
    }
    return data;
  }

  /// Total Expense across all periods
  double get totalExpense {
    if (selectedChart.value != 'expense') return 0;

    double sum = 0;
    for (final periodPoint in expenseChart) {
      sum += periodPoint.amount;
    }
    return sum;
  }

  // ---------------- CREDIT GETTERS ----------------
  credit_model.DashboardCreditPaginated get credit => creditData.value;

  double get totalNet {
    switch (selectedChart.value) {
      case 'income':
        return credit.sale.totals.totalNetAmount;
      case 'expense':
        return credit.purchase.totals.totalNetAmount;
      case 'emi':
        // Use totalNetAmount for EMI
        return credit.emi.totals.totalNetAmount;
      default:
        return 0;
    }
  }

  double get totalPaid {
    switch (selectedChart.value) {
      case 'income':
        return credit.sale.totals.totalPaidAmount;
      case 'expense':
        return credit.purchase.totals.totalPaidAmount;
      case 'emi':
        return credit.emi.totals.totalPaidAmount;
      default:
        return 0;
    }
  }

  double get totalRemaining {
    switch (selectedChart.value) {
      case 'income':
        return credit.sale.totals.totalCreditAmount;
      case 'expense':
        return credit.purchase.totals.totalCreditAmount;
      case 'emi':
        // Use totalCreditAmount for EMI remaining
        return credit.emi.totals.totalCreditAmount;
      default:
        return 0;
    }
  }

  String getCreditName(credit_model.CreditItem item) {
    switch (selectedChart.value) {
      case 'income':
        return item.customerName ?? "Unknown Customer";
      case 'expense':
        return item.supplierName ?? "Unknown Supplier";
      case 'emi':
        return item.customerName ?? "Unknown Customer";
      default:
        return "-";
    }
  }

  double getCreditNet(credit_model.CreditItem item) => item.netTotal;
  double getCreditPaid(credit_model.CreditItem item) => item.paidAmount;
  double getCreditRemaining(credit_model.CreditItem item) =>
      item.remainingAmount;
  int getCreditDays(credit_model.CreditItem item) => item.creditDays;

  String getCreditDate(credit_model.CreditItem item) {
    String? raw;
    switch (selectedChart.value) {
      case 'income':
        raw = item.saleDate;
        break;
      case 'expense':
        raw = item.purchaseDate;
        break;
      case 'emi':
        raw = item.dueDate;
        break;
    }

    if (raw == null || raw.isEmpty) return "-";

    final dt = DateTime.parse(raw);
    final localDate = dt.toLocal();
    return "${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}";
  }
}
