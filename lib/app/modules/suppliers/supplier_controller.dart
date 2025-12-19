import 'package:flutter/widgets.dart';
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

  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    fetchSuppliers();
  }

  Future<void> fetchSuppliers() async {
    try {
      isLoading.value = true;
      final result = await supplierRepository.getAllSuppliers();
      suppliers.assignAll(result); // ✅ better than suppliers.value =
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSupplier() async {
    final name = nameController.text.trim();
    final contact = contactController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty || contact.isEmpty || email.isEmpty) return;

    try {
      isLoading.value = true;
      final newSupplier = SupplierModel(
        id: suppliers.isEmpty ? 1 : suppliers.last.id + 1, // temporary id
        name: name,
        contact: contact,
        email: email,
      );

      await supplierRepository.addSupplier(newSupplier);
      //suppliers.add(added); // reactive update
      fetchSuppliers();
      globalController.triggerRefresh(); // ✅ WRITE event
      clearForm();
      Get.back();
      Get.back();
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

  void clearForm() {
    // Clear any form controllers if needed
    nameController.clear();
    contactController.clear();
    emailController.clear();
  }

  void fillForm(SupplierModel supplier) {
    nameController.text = supplier.name;
    contactController.text = supplier.contact;
    emailController.text = supplier.email;
  }
}
