import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../data/models/supplier_model.dart';
import 'supplier_controller.dart';
import '../../wigdets/custom_form_dialog.dart';

class SupplierListPage extends StatelessWidget {
  SupplierListPage({super.key});

  final SupplierController controller = Get.find<SupplierController>();
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context); // Initialize SizeConfig

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.sw(0.03)), // responsive padding
        child: Column(
          children: [
            // ---------------- Search + Refresh ----------------
            Row(
              children: [
                SizedBox(
                  width: SizeConfig.sw(0.6),
                  child: TextField(
                    controller: searchController,
                    onChanged: controller.updateSearch,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search suppliers...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.sw(0.02)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: controller.fetchSuppliers,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text("Refresh"),
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.sh(0.02)),
            // ---------------- Supplier List ----------------
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = controller.filteredSuppliers;

                if (filtered.isEmpty) {
                  return const Center(child: Text("No suppliers found"));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (_, index) {
                    final c = filtered[index];
                    return Slidable(
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
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(SizeConfig.sw(0.008))),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(SizeConfig.sw(0.01)),
                          leading: CircleAvatar(
                            radius: SizeConfig.sw(0.03),
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.sw(0.02),
                              ),
                            ),
                          ),
                          title: Text(
                            c.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: SizeConfig.sw(0.012),
                            ),
                          ),
                          subtitle: Text(
                            c.contact,
                            style: TextStyle(fontSize: SizeConfig.sw(0.008)),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Supplier'),
      ),
    );
  }

  // ---------------- Add Supplier ----------------
  void openAddDialog() {
    controller.clearForm();
    Get.dialog(CustomFormDialog(
      title: "Add Supplier",
      isEditMode: false,
      width: 0.2,
      height: 0.65,
      content: Column(
        children: [
          TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                contentPadding: EdgeInsets.all(SizeConfig.sw(0.02)),
              )),
          SizedBox(
            height: SizeConfig.sh(0.02),
          ),
          TextField(
              controller: controller.contactController,
              decoration: InputDecoration(
                labelText: 'Contact',
                contentPadding: EdgeInsets.all(SizeConfig.sw(0.02)),
              )),
          SizedBox(
            height: SizeConfig.sh(0.02),
          ),
          TextField(
              controller: controller.emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                contentPadding: EdgeInsets.all(SizeConfig.sw(0.02)),
              )),
          SizedBox(
            height: SizeConfig.sh(0.02),
          ),
          TextField(
              controller: controller.addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                contentPadding: EdgeInsets.all(SizeConfig.sw(0.02)),
              )),
        ],
      ),
      onSave: () => controller.addSupplier(),
    ));
  }

  // ---------------- Edit Supplier ----------------
  void openEditDialog(SupplierModel supplier) {
    controller.fillForm(supplier);
    Get.dialog(CustomFormDialog(
      title: "Edit Supplier",
      isEditMode: true,
      width: 0.25,
      height: 0.65,
      content: Column(
        children: [
          TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                contentPadding: EdgeInsets.all(SizeConfig.sw(0.02)),
              )),
          SizedBox(
            height: SizeConfig.sh(0.02),
          ),
          TextField(
              controller: controller.contactController,
              decoration: InputDecoration(
                labelText: 'Contact',
                contentPadding: EdgeInsets.all(SizeConfig.sw(0.02)),
              )),
          SizedBox(
            height: SizeConfig.sh(0.02),
          ),
          TextField(
              controller: controller.emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                contentPadding: EdgeInsets.all(SizeConfig.sw(0.02)),
              )),
          SizedBox(
            height: SizeConfig.sh(0.02),
          ),
          TextField(
              controller: controller.addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                contentPadding: EdgeInsets.all(SizeConfig.sw(0.02)),
              )),
        ],
      ),
      onSave: () => controller.updateSupplier(supplier),
      onDelete: () => controller.deleteSupplier(supplier.id),
    ));
  }
}
