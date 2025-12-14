import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository.dart';

class CustomerController extends GetxController {
  final CustomerRepository customerRepository;

  CustomerController({required this.customerRepository});

  var customers = <CustomerModel>[].obs;
  var isLoading = false.obs;
  var isSaving = false.obs;

  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final imageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    try {
      isLoading.value = true;
      final list = await customerRepository.getAllCustomers();
      customers.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCustomer() async {
    final name = nameController.text.trim();
    final contact = contactController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty || contact.isEmpty) return;

    try {
      isSaving.value = true;

      final newCustomer = CustomerModel(
        id: customers.isEmpty ? 1 : customers.last.id + 1, // temp id
        name: name,
        contact: contact,
        email: email.isEmpty ? null : email,
        image: imageController.text.isEmpty ? null : imageController.text,
      );

      final added = await customerRepository.addCustomer(newCustomer);
      customers.add(added);

      clearForm();
      Get.back();
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    final name = nameController.text.trim();
    final contact = contactController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty || contact.isEmpty) return;

    try {
      isSaving.value = true;

      final updated = CustomerModel(
        id: customer.id,
        name: name,
        contact: contact,
        email: email.isEmpty ? null : email,
        image: imageController.text.isEmpty ? null : imageController.text,
      );

      final res = await customerRepository.updateCustomer(updated);

      final index = customers.indexWhere((c) => c.id == res.id);
      if (index != -1) customers[index] = res;

      clearForm();
      Get.back();
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteCustomer(int id) async {
    await customerRepository.deleteCustomer(id);
    customers.removeWhere((c) => c.id == id);
  }

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
