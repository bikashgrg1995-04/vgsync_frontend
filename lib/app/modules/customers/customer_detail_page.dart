import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/customer_model.dart';
import 'customer_controller.dart';

class CustomerDetailPage extends StatelessWidget {
  final int customerId;

  CustomerDetailPage({super.key, required this.customerId});

  final CustomerController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final CustomerModel? customer =
          controller.customers.firstWhereOrNull((c) => c.id == customerId);

      if (customer == null) {
        return const Scaffold(
          body: Center(child: Text('Customer not found')),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Customer Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _openEditDialog(customer),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await controller.deleteCustomer(customer.id);
                Get.back();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row('Name', customer.name),
              _row('Contact', customer.contact),
              _row('Email', customer.email ?? 'N/A'),
            ],
          ),
        ),
      );
    });
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _openEditDialog(CustomerModel customer) {
    controller.fillForm(customer);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: controller.contactController,
              decoration: const InputDecoration(labelText: 'Contact'),
            ),
            TextField(
              controller: controller.emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await controller.updateCustomer(customer);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
