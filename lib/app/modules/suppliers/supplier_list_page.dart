import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_controller.dart';
import '../../data/models/supplier_model.dart';

class SupplierListPage extends StatelessWidget {
  const SupplierListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SupplierController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showSupplierForm(context, controller);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.suppliers.isEmpty) {
          return const Center(child: Text('No suppliers found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.suppliers.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final supplier = controller.suppliers[index];
            return ListTile(
              leading: CircleAvatar(
                child: supplier.image != null
                    ? Image.network(supplier.image!)
                    : const Icon(Icons.local_shipping),
              ),
              title: Text(supplier.name),
              subtitle: Text('${supplier.contact}\n${supplier.email}'),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      _showSupplierForm(context, controller,
                          supplier: supplier);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      controller.deleteSupplier(supplier.id);
                    },
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _showSupplierForm(BuildContext context, SupplierController controller,
      {SupplierModel? supplier}) {
    final nameController =
        TextEditingController(text: supplier != null ? supplier.name : '');
    final contactController =
        TextEditingController(text: supplier != null ? supplier.contact : '');
    final emailController =
        TextEditingController(text: supplier != null ? supplier.email : '');

    Get.defaultDialog(
      title: supplier == null ? 'Add Supplier' : 'Edit Supplier',
      content: Column(
        children: [
          TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name')),
          TextField(
              controller: contactController,
              decoration: const InputDecoration(labelText: 'Contact')),
          TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email')),
        ],
      ),
      textConfirm: 'Save',
      onConfirm: () {
        final newSupplier = SupplierModel(
          id: supplier?.id ?? 0,
          name: nameController.text,
          contact: contactController.text,
          email: emailController.text,
        );

        if (supplier == null) {
          controller.addSupplier(newSupplier);
        } else {
          controller.updateSupplier(newSupplier);
        }
      },
      textCancel: 'Cancel',
    );
  }
}
