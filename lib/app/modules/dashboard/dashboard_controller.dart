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
  List<LowStockItem> get lowStockItems =>
      dashboardData.value.stock.lowStockItems;
  List<FollowupItem> get upcomingFollowups =>
      dashboardData.value.followups.records;

  // ---------------- Lifecycle ----------------
  @override
  void onInit() {
    super.onInit();
    loadDashboardData();

    ever<List<DashboardRefreshType>>(globalController.refreshTriggers, (_) {
      if (_.contains(DashboardRefreshType.stock)) {
        _partialRefresh(DashboardRefreshType.stock);
        globalController.removeTrigger(DashboardRefreshType.stock);
      }
      if (_.contains(DashboardRefreshType.staff)) {
        _partialRefresh(DashboardRefreshType.staff);
        globalController.removeTrigger(DashboardRefreshType.staff);
      }

      if (_.contains(DashboardRefreshType.charts)) {
        _partialRefresh(DashboardRefreshType.charts);
        globalController.removeTrigger(DashboardRefreshType.charts);
      }

      if (_.contains(DashboardRefreshType.followup)) {
        _partialRefresh(DashboardRefreshType.followup);
        globalController.removeTrigger(DashboardRefreshType.followup);
      }
    });
  }

  // ---------------- Load full dashboard ----------------
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      final data = await dashboardRepository.getDashboard();
      dashboardData.value = data;
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
