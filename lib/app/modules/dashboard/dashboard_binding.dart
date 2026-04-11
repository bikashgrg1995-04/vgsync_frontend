// app/modules/dashboard/bindings/dashboard_binding.dart
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/dashboard_repository.dart';
import 'package:vgsync_frontend/app/data/services/dashboard_service.dart';
import 'package:vgsync_frontend/app/modules/dashboard/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardService>(
      () => DashboardService(),
    );

    Get.lazyPut<DashboardRepository>(
      () => DashboardRepository(
        dashboardService: Get.find(),
      ),
    );

    Get.lazyPut<DashboardController>(
      () => DashboardController(
        dashboardRepository: Get.find(),
      ),
    );
  }
}
