import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/supplier_model.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_controller.dart';
import '../../wigdets/custom_form_dialog.dart';

class SupplierListPage extends StatelessWidget {
  SupplierListPage({super.key});

  final controller = Get.find<SupplierController>();
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: (_) => controller.suppliers.refresh(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search suppliers...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final query = searchController.text.toLowerCase();
              final filtered = controller.suppliers.where((c) {
                return c.name.toLowerCase().contains(query) ||
                    c.contact.toLowerCase().contains(query) ||
                    (c.email.toLowerCase().contains(query));
              }).toList();

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final c = filtered[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Slidable(
                      key: ValueKey(c.id),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.35,
                        children: [
                          SlidableAction(
                            onPressed: (_) => openEditDialog(c),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                          SlidableAction(
                            onPressed: (_) => controller.deleteSupplier(c.id),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () => openCustomerDetail(c),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                            title: Text(c.name),
                            subtitle: Text(c.contact),
                            trailing: const Icon(Icons.drag_handle,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Supplier'),
      ),
    );
  }

  void openAddDialog() {
    controller.clearForm();
    Get.dialog(CustomFormDialog(
      title: "Add Supplier",
      isEditMode: false,
      content: Column(
        children: [
          TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(labelText: 'Name')),
          TextField(
              controller: controller.contactController,
              decoration: const InputDecoration(labelText: 'Contact')),
          TextField(
              controller: controller.emailController,
              decoration: const InputDecoration(labelText: 'Email')),
        ],
      ),
      onSave: () => controller.addSupplier(),
    ));
  }

  void openEditDialog(SupplierModel supplier) {
    controller.fillForm(supplier);
    Get.dialog(CustomFormDialog(
      title: "Edit Supplier",
      isEditMode: true,
      content: Column(
        children: [
          TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(labelText: 'Name')),
          TextField(
              controller: controller.contactController,
              decoration: const InputDecoration(labelText: 'Contact')),
          TextField(
              controller: controller.emailController,
              decoration: const InputDecoration(labelText: 'Email')),
        ],
      ),
      onSave: () => controller.updateSupplier(supplier),
      onDelete: () => controller.deleteSupplier(supplier.id),
    ));
  }

  void openCustomerDetail(SupplierModel supplier) {
    //Get.to(() => SupplierDetailPage(supplierId: supplier.id));
  }
}
