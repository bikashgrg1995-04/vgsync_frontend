import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository.dart';

class CustomerController extends GetxController {
  final CustomerRepository customerRepository;
  final GlobalController globalController = Get.find<GlobalController>();

  CustomerController({required this.customerRepository});

  final customers = <CustomerModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final imageController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    fetchCustomers();
  }

  // ----------------------------
  // READ (NO DASHBOARD REFRESH)
  // ----------------------------
  Future<void> fetchCustomers() async {
    try {
      isLoading.value = true;
      final result = await customerRepository.getAllCustomers();
      customers.assignAll(result); // ✅ better than customers.value =
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------
  // CREATE
  // ----------------------------
  Future<void> addCustomer() async {
    if (nameController.text.trim().isEmpty ||
        contactController.text.trim().isEmpty) {
      return;
    }

    try {
      isSaving.value = true;

      final customer = CustomerModel(
        id: 0, // backend generates
        name: nameController.text.trim(),
        contact: contactController.text.trim(),
        email: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        image: imageController.text.isEmpty ? null : imageController.text,
      );

      await customerRepository.addCustomer(customer);
      await fetchCustomers();

      globalController.triggerRefresh(); // ✅ WRITE event

      clearForm();
      Get.back();
    } finally {
      isSaving.value = false;
    }
  }

  // ----------------------------
  // UPDATE
  // ----------------------------
  Future<void> updateCustomer(CustomerModel customer) async {
    if (nameController.text.trim().isEmpty ||
        contactController.text.trim().isEmpty) return;

    try {
      isSaving.value = true;

      final updated = customer.copyWith(
        name: nameController.text.trim(),
        contact: contactController.text.trim(),
        email: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        image: imageController.text.isEmpty ? null : imageController.text,
      );

      await customerRepository.updateCustomer(updated);
      await fetchCustomers();

      globalController.triggerRefresh(); // ✅ WRITE event

      clearForm();
    } finally {
      isSaving.value = false;
    }
  }

  // ----------------------------
  // DELETE
  // ----------------------------
  Future<void> deleteCustomer(int id) async {
    await customerRepository.deleteCustomer(id);
    await fetchCustomers();

    globalController.triggerRefresh(); // ✅ WRITE event
  }

  // ----------------------------
  // FORM HELPERS
  // ----------------------------
  void fillForm(CustomerModel customer) {
    nameController.text = customer.name;
    contactController.text = customer.contact;
    emailController.text = customer.email ?? '';
    imageController.text = customer.image ?? '';
  }

  void clearForm() {
    nameController.clear();
    contactController.clear();
    emailController.clear();
    imageController.clear();
  }
}
