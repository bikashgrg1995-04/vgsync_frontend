// app/modules/dashboard/bindings/dashboard_binding.dart
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/supplier_repository.dart';
import 'package:vgsync_frontend/app/data/services/supplier_service.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_controller.dart';

class SupplierBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupplierService>(
      () => SupplierService(),
    );

    Get.lazyPut<SupplierRepository>(
      () => SupplierRepository(
        supplierService: Get.find(),
      ),
    );

    Get.lazyPut<SupplierController>(
      () => SupplierController(
        supplierRepository: Get.find(),
      ),
    );
  }
}
