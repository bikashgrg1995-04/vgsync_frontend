import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';

import '../../data/models/supplier_model.dart';
import '../../data/repositories/supplier_repository.dart';

class SupplierController extends GetxController {
  final SupplierRepository supplierRepository;
  final GlobalController globalController = Get.find<GlobalController>();

  SupplierController({required this.supplierRepository});

  // ---------------- Reactive State ----------------
  final suppliers = <SupplierModel>[].obs; // Full list
  final filteredSuppliers = <SupplierModel>[].obs; // Filtered list
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  // ---------------- Form Controllers ----------------
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final searchController = TextEditingController();

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
          DesktopToast.show(
        'Failed to fetch suppliers',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter() {
    final query = searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredSuppliers.assignAll(suppliers);
      return;
    }

    filteredSuppliers.assignAll(
      suppliers
          .where((s) => s.name.toLowerCase().contains(query))
          .toList(), // ✅ THIS IS REQUIRED
    );
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  // ---------------- Add Supplier ----------------
  Future<void> addSupplier() async {
    final name = nameController.text.trim();
    final contact = contactController.text.trim();
    final email = emailController.text.trim();
    final address = addressController.text.trim();

    if ([name, contact].any((e) => e.isEmpty)) {
          DesktopToast.show(
        'Name and Contact are required',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    try {
      isLoading.value = true;

      final newSupplier = SupplierModel(
        id: suppliers.isEmpty ? 1 : suppliers.last.id + 1, // temp id
        name: name,
        contact: contact,
        email: email.isEmpty ? null : email,
        address: address.isEmpty ? null : address,
      );

      await supplierRepository.addSupplier(newSupplier);
      await fetchSuppliers();
      clearForm();

      Get.back(closeOverlays: true);
          DesktopToast.show(
        "Supplier added",
        backgroundColor: Colors.greenAccent,
      );
    } catch (e) {
          DesktopToast.show(
        'Failed to add supplier',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Update Supplier ----------------
  Future<void> updateSupplier(SupplierModel supplier) async {
    final name = nameController.text.trim();
    final contact = contactController.text.trim();
    final email = emailController.text.trim();
    final address = addressController.text.trim();

    if ([name, contact].any((e) => e.isEmpty)) {
          DesktopToast.show(
        'Name and Contact are required',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    try {
      isLoading.value = true;

      final updatedSupplier = SupplierModel(
        id: supplier.id,
        name: name,
        contact: contact,
        email: email.isEmpty ? null : email,
        address: address.isEmpty ? null : address,
      );

      final updated = await supplierRepository.updateSupplier(updatedSupplier);

      final index = suppliers.indexWhere((s) => s.id == updated.id);
      if (index != -1) suppliers[index] = updated;

      applyFilter();
      clearForm();

      Get.back(closeOverlays: true);
          DesktopToast.show(
        "Supplier updated",
        backgroundColor: Colors.greenAccent,
      );
    } catch (e) {
      Get.back(closeOverlays: true);
          DesktopToast.show(
        'Failed to update supplier',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Delete Supplier ----------------
  Future<void> deleteSupplier(int id) async {
    ConfirmDialog.show(
      Get.context!,
      title: "Delete Supplier",
      message: "Are you sure you want to delete this supplier?",
      onConfirm: () async {
        await supplierRepository.deleteSupplier(id);
        suppliers.removeWhere((s) => s.id == id);

        applyFilter();
        globalController.triggerRefresh(DashboardRefreshType.stock);

        Get.back(closeOverlays: true);
            DesktopToast.show(
        "Supplier deleted successfully",
        backgroundColor: Colors.greenAccent,
      );
      },
      confirmText: "Delete",
      cancelText: "Cancel",
      snackbarColor: Colors.green,
      snackbarIcon: Icons.check_circle,
    );
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
    emailController.text = supplier.email ?? '';
    addressController.text = supplier.address ?? '';
  }

  // ---------------- Refresh ----------------
  Future<void> refreshSuppliers() async {
    searchController.clear();
    searchQuery.value = '';
    await fetchSuppliers();
  }
}
