import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/sale_repository.dart';
import 'package:vgsync_frontend/app/data/services/sale_service.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_controller.dart';

class SaleBinding extends Bindings {
  @override
  void dependencies() {
    // Put the service first
    Get.lazyPut<SaleService>(() => SaleService());

    // Then the repository, which depends on the service
    Get.lazyPut<SaleRepository>(
        () => SaleRepository(saleService: Get.find<SaleService>()));

    // Finally the controller, which depends on the repository
    Get.lazyPut<SalesController>(
        () => SalesController(saleRepository: Get.find<SaleRepository>()));
  }
}
