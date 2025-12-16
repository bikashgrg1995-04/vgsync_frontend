import 'package:get/get.dart';
import 'package:vgsync_frontend/app/modules/customers/customer_controller.dart';
import 'package:vgsync_frontend/app/modules/dashboard/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController(
          customerRepository: Get.find(),
          supplierRepository: Get.find(),
          itemRepository: Get.find(),
          categoryRepository: Get.find(),
          saleRepository: Get.find(),
          purchaseRepository: Get.find(),
          followupRepository: Get.find(),
        ));
    Get.lazyPut(() => CustomerController(
          customerRepository: Get.find(),
        ));
  }
}
