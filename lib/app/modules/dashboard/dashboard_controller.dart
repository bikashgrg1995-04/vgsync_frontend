import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository dashboardRepository;
  final GlobalController globalController = Get.find<GlobalController>();

  DashboardController({required this.dashboardRepository});

  RxBool isLoading = false.obs;

  // -------------------------
  // Reactive data
  // -------------------------
  var summary = DashboardSummary.empty().obs;
  var lowStockItems = <LowStockItem>[].obs;
  var upcomingFollowups = <DashboardFollowupItem>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Load initial data
    loadDashboardData();

    // 🔥 LISTEN TO GLOBAL REFRESH
    ever(globalController.refreshTick, (_) {
      loadDashboardData();
    });
  }

  // -------------------------
  // Load dashboard data
  // -------------------------
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      final data = await dashboardRepository.getDashboard();

      print('Dashboard data loaded: $data');

      // Update reactive fields
      summary.value = data.summary;
      lowStockItems.value = data.lowStockItems;
      upcomingFollowups.value = data.upcomingFollowups;
    } catch (e) {
      print('Dashboard error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
