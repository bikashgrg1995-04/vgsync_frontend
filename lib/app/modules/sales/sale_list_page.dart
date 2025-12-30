import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/utils/size_config.dart';

import '../../data/models/sale_model.dart';
import 'sale_controller.dart';
import '../../wigdets/custom_form_dialog.dart';

class SaleListPage extends StatefulWidget {
  const SaleListPage({super.key});

  @override
  State<SaleListPage> createState() => _SaleListPageState();
}

class _SaleListPageState extends State<SaleListPage> {
  final SalesController controller = Get.find<SalesController>();

  @override
  void initState() {
    super.initState();
    controller.fetchSales();
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
                    controller: controller.customerNameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search by customer...',
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
                    onPressed: controller.fetchSales,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text("Refresh"),
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.sh(0.02)),

            // ---------------- Sale List ----------------
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter by date and customer name
                final filtered = controller.sales.where((sale) {
                  final saleDate = sale.saleDate;
                  bool matchesDate = true;
                  if (controller.startDateController.text.isNotEmpty) {
                    final start =
                        DateTime.parse(controller.startDateController.text);
                    matchesDate = !saleDate.isBefore(start);
                  }
                  if (matchesDate &&
                      controller.endDateController.text.isNotEmpty) {
                    final end =
                        DateTime.parse(controller.endDateController.text);
                    matchesDate = !saleDate.isAfter(end);
                  }

                  final searchText =
                      controller.customerNameController.text.toLowerCase();
                  final matchesSearch =
                      sale.customerName.toLowerCase().contains(searchText);

                  return matchesDate && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No sales found'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final sale = filtered[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.sw(0.01),
                        vertical: SizeConfig.sh(0.005),
                      ),
                      child: Slidable(
                        key: ValueKey(sale.id),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.35,
                          children: [
                            SlidableAction(
                              onPressed: (_) => openEditDialog(sale),
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (_) => controller.updateSale(sale.id),
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
                              sale.customerName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: SizeConfig.sw(0.012),
                              ),
                            ),
                            subtitle: Text(
                              'Date: ${sale.saleDate.toIso8601String().split('T')[0]} | '
                              'Total: ${sale.totalAmount} | Paid: ${sale.paidAmount}',
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
        label: const Text('Add Sale'),
      ),
    );
  }

  // ---------------- Add Sale Dialog ----------------
  void openAddDialog() {
    controller.clearForm();
    controller.fillForEdit(SaleModel(
      id: 0,
      saleDate: DateTime.now(),
      customerName: '',
      totalAmount: 0,
      paidAmount: 0,
      remainingAmount: 0,
      labourCharge: 0,
      isPaid: 'paid',
      paidFrom: 'cash',
      isServicing: false,
      isFreeServicing: false,
      isRepairJob: false,
      isAccident: false,
      isWarrantyJob: false,
      items: const [],
    ));

    Get.dialog(CustomFormDialog(
      title: "Add Sale",
      isEditMode: false,
      width: 0.2,
      height: 0.05,
      content: Column(
        children: [
          TextField(
            controller: controller.customerNameController,
            decoration: const InputDecoration(labelText: 'Customer Name'),
          ),
          TextField(
            controller: controller.totalAmountController,
            decoration: const InputDecoration(labelText: 'Total Amount'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: controller.paidAmountController,
            decoration: const InputDecoration(labelText: 'Paid Amount'),
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
                controller.fillForEdit(SaleModel(
                  id: 0,
                  saleDate: picked,
                  customerName: controller.customerNameController.text,
                  totalAmount:
                      double.tryParse(controller.totalAmountController.text) ??
                          0,
                  paidAmount:
                      double.tryParse(controller.paidAmountController.text) ??
                          0,
                  remainingAmount: 0,
                  labourCharge: 0,
                  isPaid: 'paid',
                  paidFrom: 'cash',
                  isServicing: false,
                  isFreeServicing: false,
                  isRepairJob: false,
                  isAccident: false,
                  isWarrantyJob: false,
                  items: const [],
                ));
                setState(() {});
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text('Select Sale Date'),
          ),
        ],
      ),
      onSave: () => controller.addSale(),
    ));
  }

  // ---------------- Edit Sale Dialog ----------------
  void openEditDialog(SaleModel sale) {
    controller.fillForEdit(sale);

    Get.dialog(CustomFormDialog(
      title: "Edit Sale",
      isEditMode: true,
      width: 0.2,
      height: 0.05,
      content: Column(
        children: [
          TextField(
            controller: controller.customerNameController,
            decoration: const InputDecoration(labelText: 'Customer Name'),
          ),
          TextField(
            controller: controller.totalAmountController,
            decoration: const InputDecoration(labelText: 'Total Amount'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: controller.paidAmountController,
            decoration: const InputDecoration(labelText: 'Paid Amount'),
            keyboardType: TextInputType.number,
          ),
          TextButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: sale.saleDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                sale.saleDate = picked;
                controller.fillForEdit(sale);
                setState(() {});
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(
                'Select Sale Date: ${sale.saleDate.toIso8601String().split('T')[0]}'),
          ),
        ],
      ),
      onSave: () => controller.updateSale(sale.id),
    ));
  }
}
