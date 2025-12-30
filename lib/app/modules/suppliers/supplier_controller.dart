import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import '../../data/models/supplier_model.dart';
import '../../data/repositories/supplier_repository.dart';

class SupplierController extends GetxController {
  final SupplierRepository supplierRepository;
  final GlobalController globalController = Get.find<GlobalController>();

  SupplierController({required this.supplierRepository});

  // ---------------- Reactive State ----------------
  var suppliers = <SupplierModel>[].obs; // Full list
  var filteredSuppliers = <SupplierModel>[].obs; // Filtered for search
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  // ---------------- Form Controllers ----------------
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    fetchSuppliers();
  }

  // ---------------- Fetch Suppliers ----------------
  Future<void> fetchSuppliers() async {
    try {
      isLoading.value = true;
      final result = await supplierRepository.getAllSuppliers();
      suppliers.assignAll(result);
      applyFilter();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch suppliers');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Filter/Search ----------------
  void applyFilter() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredSuppliers.assignAll(suppliers);
    } else {
      filteredSuppliers.assignAll(
        suppliers.where((s) =>
            s.name.toLowerCase().contains(query) ||
            s.contact.toLowerCase().contains(query) ||
            s.email.toLowerCase().contains(query)),
      );
    }
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  // ---------------- CRUD Operations ----------------
  Future<void> addSupplier() async {
    final name = nameController.text.trim();
    final contact = contactController.text.trim();
    final email = emailController.text.trim();
    final address = addressController.text.trim();

    if ([name, contact, email, address].any((e) => e.isEmpty)) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }

    try {
      isLoading.value = true;
      final newSupplier = SupplierModel(
        id: suppliers.isEmpty ? 1 : suppliers.last.id + 1, // temporary
        name: name,
        contact: contact,
        email: email,
        address: address,
      );

      await supplierRepository.addSupplier(newSupplier);
      await fetchSuppliers();

      clearForm();
      Get.back();
      Get.snackbar('Success', 'Supplier added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add supplier');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    final name = nameController.text.trim();
    final contact = contactController.text.trim();
    final email = emailController.text.trim();
    final address = addressController.text.trim();

    if ([name, contact, email, address].any((e) => e.isEmpty)) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }

    try {
      isLoading.value = true;

      final updatedSupplier = SupplierModel(
        id: supplier.id, // keep the same id
        name: name,
        contact: contact,
        email: email,
        address: address,
      );

      final updated = await supplierRepository.updateSupplier(updatedSupplier);

      final index = suppliers.indexWhere((s) => s.id == updated.id);
      if (index != -1) suppliers[index] = updated;

      applyFilter();

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

      applyFilter();

      Get.snackbar('Success', 'Supplier deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete supplier');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Form Helpers ----------------
  void clearForm() {
    nameController.clear();
    contactController.clear();
    emailController.clear();
    addressController.clear();
  }

  void fillForm(SupplierModel supplier) {
    nameController.text = supplier.name;
    contactController.text = supplier.contact;
    emailController.text = supplier.email;
    addressController.text = supplier.address;
  }
}
