import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/supplier_repository.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_controller.dart';

class SupplierBinding extends Bindings {
  @override
  void dependencies() {
    final repo = Get.find<SupplierRepository>();

    // Use permanent: true so the controller stays alive across navigations
    Get.put(SupplierController(supplierRepository: repo), permanent: true);
  }
}
