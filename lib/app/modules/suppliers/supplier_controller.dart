import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import '../../data/models/supplier_model.dart';
import '../../data/repositories/supplier_repository.dart';

class SupplierController extends GetxController {
  final SupplierRepository supplierRepository;
  final GlobalController globalController = Get.find<GlobalController>();

  SupplierController({required this.supplierRepository});

  var suppliers = <SupplierModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSuppliers();
  }

  Future<void> fetchSuppliers() async {
    try {
      isLoading.value = true;
      final list = await supplierRepository.getAllSuppliers();
      suppliers.value = list;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load suppliers');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSupplier(SupplierModel supplier) async {
    try {
      isLoading.value = true;
      final newSupplier = await supplierRepository.addSupplier(supplier);
      suppliers.add(newSupplier);

      fetchSuppliers();
      globalController.triggerRefresh(); // ✅ WRITE event

      Get.back(); // Close dialog/page
      Get.snackbar('Success', 'Supplier added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add supplier');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    try {
      isLoading.value = true;
      final updatedSupplier = await supplierRepository.updateSupplier(supplier);
      final index = suppliers.indexWhere((s) => s.id == updatedSupplier.id);
      if (index != -1) suppliers[index] = updatedSupplier;

      fetchSuppliers();
      globalController.triggerRefresh(); // ✅ WRITE event

      Get.back();
      Get.snackbar('Success', 'Supplier updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update supplier');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSupplier(int id) async {
    try {
      isLoading.value = true;
      await supplierRepository.deleteSupplier(id);
      suppliers.removeWhere((s) => s.id == id);

      fetchSuppliers();
      globalController.triggerRefresh(); // ✅ WRITE event

      Get.snackbar('Success', 'Supplier deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete supplier');
    } finally {
      isLoading.value = false;
    }
  }
}
