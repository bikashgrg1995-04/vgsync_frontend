import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/purchase_repository.dart';
import 'package:vgsync_frontend/app/data/services/purchase_service.dart';
import 'package:vgsync_frontend/app/modules/purchases/purchase_controller.dart';

class PurchaseBinding extends Bindings {
  @override
  void dependencies() {
    // Put the service first
    Get.lazyPut<PurchaseService>(() => PurchaseService());

    // Then the repository, which depends on the service
    Get.lazyPut<PurchaseRepository>(
        () => PurchaseRepository(purchaseService: Get.find<PurchaseService>()));

    // Finally the controller, which depends on the repository
    Get.lazyPut<PurchaseController>(() =>
        PurchaseController(purchaseRepository: Get.find<PurchaseRepository>()));
  }
}
