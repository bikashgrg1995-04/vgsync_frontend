import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../data/models/supplier_model.dart';
import 'supplier_controller.dart';
import '../../wigdets/custom_form_dialog.dart';

class SupplierListPage extends StatelessWidget {
  SupplierListPage({super.key});

  final SupplierController controller = Get.find<SupplierController>();

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
                  width: SizeConfig.sw(0.45),
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search Suppliers...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.sw(0.02)),
                      ),
                    ),
                    onChanged: (_) => controller.suppliers.refresh(),
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
                actionButton(
                  label: 'Refresh',
                  icon: Icons.refresh,
                  onPressed: controller.refreshSuppliers,
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
                            onPressed: (_) => openSupplierDialog(supplier: c),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                          SlidableAction(
                            onPressed: (_) {
                              controller.deleteSupplier(c.id);
                            },
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
        onPressed: () => openSupplierDialog(supplier: null),
        icon: const Icon(Icons.add),
        label: const Text('Add Supplier'),
      ),
    );
  }

  void openSupplierDialog({SupplierModel? supplier}) {
    final bool isEditMode = supplier != null;

    if (isEditMode) {
      controller.fillForm(supplier);
    } else {
      controller.clearForm();
    }

    Get.dialog(
      CustomFormDialog(
        title: isEditMode ? "Edit Supplier" : "Add Supplier",
        isEditMode: isEditMode,
        width: isEditMode ? 0.25 : 0.22,
        height: 0.65,
        content: Column(
          children: [
            buildTextField(
              controller.nameController,
              "Name",
              Icons.person,
              hintText: "Supplier name",
            ),
            SizedBox(height: SizeConfig.sh(0.02)),
            buildTextField(
              controller.contactController,
              "Contact",
              Icons.phone,
              keyboardType: TextInputType.phone,
              hintText: "Phone number",
            ),
            SizedBox(height: SizeConfig.sh(0.02)),
            buildTextField(
              controller.emailController,
              "Email",
              Icons.email,
              keyboardType: TextInputType.emailAddress,
              hintText: "example@mail.com",
            ),
            SizedBox(height: SizeConfig.sh(0.02)),
            buildTextField(
              controller.addressController,
              "Address",
              Icons.location_on,
              hintText: "Supplier address",
            ),
          ],
        ),
        onSave: () {
          if (isEditMode) {
            controller.updateSupplier(supplier);
          } else {
            controller.addSupplier();
          }
        },
        onDelete: isEditMode
            ? () {
                controller.deleteSupplier(supplier.id);
              }
            : null,
      ),
    );
  }
}
