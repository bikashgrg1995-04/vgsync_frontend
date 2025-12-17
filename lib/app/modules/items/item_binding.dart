import 'package:get/get.dart';

import 'package:vgsync_frontend/app/data/repositories/item_repository.dart';
import 'package:vgsync_frontend/app/modules/items/item_controller.dart';

class ItemBinding extends Bindings {
  @override
  void dependencies() {
    final repo = Get.find<ItemRepository>();

    // positional argument
    // Use permanent: true so the controller stays alive across navigations
    Get.put(ItemController(itemRepository: repo), permanent: true);
  }
}
