import 'package:get/get.dart';
import '../../data/repositories/purchase_repository.dart';
import 'purchase_controller.dart';

class PurchaseBinding extends Bindings {
  @override
  void dependencies() {
    final repo = Get.find<PurchaseRepository>();

    // positional argument
    // Use permanent: true so the controller stays alive across navigations
    Get.put(PurchaseController(purchaseRepository: repo), permanent: true);
  }
}
