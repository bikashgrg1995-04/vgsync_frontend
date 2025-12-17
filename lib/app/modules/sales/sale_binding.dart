import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/followup_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/item_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/sale_repository.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_controller.dart';
import 'package:vgsync_frontend/app/modules/items/item_controller.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_controller.dart';

class SaleBinding extends Bindings {
  @override
  void dependencies() {
    final saleRepo = Get.find<SaleRepository>();
    final itemRepo = Get.find<ItemRepository>();
    final followRepo = Get.find<FollowUpRepository>();

    // ItemController (must exist before SaleController)
    if (!Get.isRegistered<ItemController>()) {
      Get.put(ItemController(itemRepository: itemRepo), permanent: true);
    }

    // FollowUpController (must exist before SaleController)
    if (!Get.isRegistered<FollowUpController>()) {
      Get.put(FollowUpController(followUpRepository: followRepo),
          permanent: true);
    }

    // SaleController
    if (!Get.isRegistered<SaleController>()) {
      Get.put(
          SaleController(
            saleRepository: saleRepo,
          ),
          permanent: true);
    }
  }
}
