import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/repositories/dashboard_repository.dart';

enum ChartPeriod { monthly, yearly }

class DashboardController extends GetxController {
  final DashboardRepository dashboardRepository;
  final GlobalController globalController = Get.find<GlobalController>();

  DashboardController({required this.dashboardRepository});

  RxBool isLoading = false.obs;
  var dashboardData = DashboardResponse.empty().obs;

  // Reactive low stock list
  var lowStockItems = <LowStockItem>[].obs;

  // Selected Chart
  Rx<ChartPeriod> selectedChartPeriod = ChartPeriod.monthly.obs;

  ChartData get chartData {
    switch (selectedChartPeriod.value) {
      case ChartPeriod.monthly:
        return dashboardData.value.charts.profitLoss.monthly;
      case ChartPeriod.yearly:
        return dashboardData.value.charts.profitLoss.yearly;
    }
  }

  // ---------------- Dashboard getters ----------------
  StockSummary get summary => dashboardData.value.stock;
  List<FollowupItem> get upcomingFollowups =>
      dashboardData.value.followups.records;

  // ---------------- Lifecycle ----------------
  @override
  void onInit() {
    super.onInit();
    loadDashboardData();

    ever<List<DashboardRefreshType>>(globalController.refreshTriggers, (_) {
      for (var type in _) {
        _partialRefresh(type);
        globalController.removeTrigger(type);
      }
    });
  }

  // ---------------- Load full dashboard ----------------
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      final data = await dashboardRepository.getDashboard();
      dashboardData.value = data;
      lowStockItems.assignAll(data.stock.lowStockItems); // reactive
    } catch (e) {
      print('Dashboard load error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Partial refresh ----------------
  void _partialRefresh(DashboardRefreshType type) async {
    try {
      isLoading.value = true;
      final data = await dashboardRepository.getDashboard();

      dashboardData.update((val) {
        if (val == null) return;

        switch (type) {
          case DashboardRefreshType.stock:
            val.stock = data.stock;
            lowStockItems
                .assignAll(data.stock.lowStockItems); // update reactive list
            break;
          case DashboardRefreshType.purchase:
            val.purchases = data.purchases;
            break;
          case DashboardRefreshType.sale:
            val.sales = data.sales;
            break;
          case DashboardRefreshType.order:
            val.orders = data.orders;
            break;
          case DashboardRefreshType.staff:
            val.staffSalary = data.staffSalary;
            break;
          case DashboardRefreshType.followup:
            val.followups = data.followups;
            break;
          case DashboardRefreshType.charts:
            val.charts = data.charts;
            break;
          case DashboardRefreshType.all:
            dashboardData.value = data;
            lowStockItems.assignAll(data.stock.lowStockItems);
            break;
        }
      });
    } catch (e) {
      print('Dashboard partial refresh error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Chart period switch ----------------
  void changeChartPeriod(ChartPeriod period) {
    selectedChartPeriod.value = period;
  }
}
