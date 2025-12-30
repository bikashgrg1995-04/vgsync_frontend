// app/modules/dashboard/bindings/dashboard_binding.dart
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/stock_repository.dart';
import 'package:vgsync_frontend/app/data/services/stock_service.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';

class StockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StockService>(
      () => StockService(),
    );

    Get.lazyPut<StockRepository>(
      () => StockRepository(
        stockService: Get.find(),
      ),
    );

    Get.lazyPut<StockController>(
      () => StockController(
        stockRepository: Get.find(),
      ),
    );
  }
}
