import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/item_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/purchase_repository.dart';
import 'package:vgsync_frontend/app/modules/items/item_controller.dart';
import 'purchase_controller.dart';

class PurchaseBinding extends Bindings {
  @override
  void dependencies() {
    final purchaseRepo = Get.find<PurchaseRepository>();
    final itemRepo = Get.find<ItemRepository>();

    // Only register if not already registered
    if (!Get.isRegistered<PurchaseController>()) {
      Get.put(PurchaseController(purchaseRepository: purchaseRepo),
          permanent: true);
    }

    if (!Get.isRegistered<ItemController>()) {
      Get.put(ItemController(itemRepository: itemRepo), permanent: true);
    }
  }
}
