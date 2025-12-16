import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/modules/customers/customer_detail_page.dart';
import '../../data/models/customer_model.dart';
import '../../modules/customers/customer_controller.dart';
import '../../wigdets/custom_form_dialog.dart';

class CustomerListPage extends StatelessWidget {
  CustomerListPage({super.key});

  final controller = Get.find<CustomerController>();
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: (_) => controller.customers.refresh(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search customers...',
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
              final filtered = controller.customers.where((c) {
                return c.name.toLowerCase().contains(query) ||
                    c.contact.toLowerCase().contains(query) ||
                    (c.email?.toLowerCase().contains(query) ?? false);
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
                            onPressed: (_) => controller.deleteCustomer(c.id),
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
        label: const Text('Add Customer'),
      ),
    );
  }

  void openAddDialog() {
    controller.clearForm();
    Get.dialog(CustomFormDialog(
      title: "Add Customer",
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
      onSave: () => controller.addCustomer(),
    ));
  }

  void openEditDialog(CustomerModel customer) {
    controller.fillForm(customer);
    Get.dialog(CustomFormDialog(
      title: "Edit Customer",
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
      onSave: () => controller.updateCustomer(customer),
      onDelete: () => controller.deleteCustomer(customer.id),
    ));
  }

  void openCustomerDetail(CustomerModel customer) {
    Get.to(() => CustomerDetailPage(customerId: customer.id));
  }
}
