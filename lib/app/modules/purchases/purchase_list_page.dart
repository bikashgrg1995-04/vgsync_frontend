import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../data/models/purchase_model.dart';
import 'purchase_controller.dart';
import '../../wigdets/custom_form_dialog.dart';

class PurchaseListPage extends StatefulWidget {
  const PurchaseListPage({super.key});

  @override
  State<PurchaseListPage> createState() => _PurchaseListPageState();
}

class _PurchaseListPageState extends State<PurchaseListPage> {
  final PurchaseController controller = Get.find<PurchaseController>();

  @override
  void initState() {
    super.initState();
    controller.fetchPurchases();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.sw(0.03)),
        child: Column(
          children: [
            // ---------------- Date Filters ----------------
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.startDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        controller.startDateController.text =
                            picked.toIso8601String().split('T')[0];
                        setState(() {});
                      }
                    },
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.02)),
                Expanded(
                  child: TextField(
                    controller: controller.endDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        controller.endDateController.text =
                            picked.toIso8601String().split('T')[0];
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.sh(0.02)),
            // ---------------- Search + Refresh ----------------
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search items...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.sw(0.02)),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
                SizedBox(
                  width: SizeConfig.sw(0.12),
                  child: ElevatedButton.icon(
                    onPressed: controller.fetchPurchases,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text("Refresh"),
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.sh(0.02)),
            // ---------------- Purchase List ----------------
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = controller.filterPurchases(
                  query: controller.searchController.text,
                  start: controller.startDateController.text.isEmpty
                      ? null
                      : DateTime.parse(controller.startDateController.text),
                  end: controller.endDateController.text.isEmpty
                      ? null
                      : DateTime.parse(controller.endDateController.text),
                );

                if (filtered.isEmpty) {
                  return const Center(child: Text('No purchases found'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final purchase = filtered[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.sw(0.01),
                        vertical: SizeConfig.sh(0.005),
                      ),
                      child: Slidable(
                        key: ValueKey(purchase.id),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.35,
                          children: [
                            SlidableAction(
                              onPressed: (_) => openEditDialog(purchase),
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (_) =>
                                  controller.deletePurchase(purchase.id),
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
                                BorderRadius.circular(SizeConfig.sw(0.008)),
                          ),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(SizeConfig.sw(0.01)),
                            title: Text(
                              'Supplier: ${purchase.supplier}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: SizeConfig.sw(0.012),
                              ),
                            ),
                            subtitle: Text(
                              'Date: ${purchase.date.toIso8601String().split('T')[0]} | VAT: ${purchase.vatPercentage}% | Discount: ${purchase.discountPercentage}%',
                              style: TextStyle(fontSize: SizeConfig.sw(0.008)),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Purchase'),
      ),
    );
  }

  // ---------------- Add Purchase Dialog ----------------
  void openAddDialog() {
    controller.clearForm();
    controller.dateController.text =
        DateTime.now().toIso8601String().split('T')[0];

    Get.dialog(CustomFormDialog(
      title: "Add Purchase",
      isEditMode: false,
      width: 0.2,
      height: 0.05,
      content: Column(
        children: [
          TextField(
            controller: controller.supplierController,
            decoration: const InputDecoration(labelText: 'Supplier ID'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: controller.discountController,
            decoration: const InputDecoration(labelText: 'Discount %'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: controller.vatController,
            decoration: const InputDecoration(labelText: 'VAT %'),
            keyboardType: TextInputType.number,
          ),
          TextButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                controller.dateController.text =
                    picked.toIso8601String().split('T')[0];
                setState(() {});
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text('Select Date: ${controller.dateController.text}'),
          ),
        ],
      ),
      onSave: () => controller.addPurchase(),
    ));
  }

  // ---------------- Edit Purchase Dialog ----------------
  void openEditDialog(PurchaseModel purchase) {
    controller.populateForm(purchase);

    Get.dialog(CustomFormDialog(
      title: "Edit Purchase",
      isEditMode: true,
      width: 0.2,
      height: 0.05,
      content: Column(
        children: [
          TextField(
            controller: controller.supplierController,
            decoration: const InputDecoration(labelText: 'Supplier ID'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: controller.discountController,
            decoration: const InputDecoration(labelText: 'Discount %'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: controller.vatController,
            decoration: const InputDecoration(labelText: 'VAT %'),
            keyboardType: TextInputType.number,
          ),
          TextButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: purchase.date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                controller.dateController.text =
                    picked.toIso8601String().split('T')[0];
                setState(() {});
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text('Select Date: ${controller.dateController.text}'),
          ),
        ],
      ),
      onSave: () => controller.updatePurchase(purchase),
      onDelete: () => controller.deletePurchase(purchase.id),
    ));
  }
}
