import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/purchase_model.dart';
import 'package:vgsync_frontend/app/data/models/stock_model.dart';
import 'package:vgsync_frontend/app/modules/purchases/purchase_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_controller.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_controller.dart';
import 'package:vgsync_frontend/utils/size_config.dart';

class PurchaseDetailPage extends StatefulWidget {
  final PurchaseModel purchase;
  const PurchaseDetailPage({super.key, required this.purchase});

  @override
  State<PurchaseDetailPage> createState() => _PurchaseDetailPageState();
}

class _PurchaseDetailPageState extends State<PurchaseDetailPage> {
  final PurchaseController controller = Get.find<PurchaseController>();
  final StockController stockController = Get.find<StockController>();
  final SupplierController supplierController = Get.find();
  final StaffController staffController = Get.find();

  @override
  void initState() {
    super.initState();
    // Delay reactive updates until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.populateForm(widget.purchase);
      controller.clearModifiedFlag();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase Details"),
        actions: [
          Obx(() {
            if (!controller.isModified.value) return const SizedBox.shrink();
            return IconButton(
              tooltip: "Save Purchase",
              icon: const Icon(Icons.save),
              onPressed: _savePurchase,
            );
          }),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.sw(0.03)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildAddItemButton(),
            const SizedBox(height: 8),
            _buildItemTableHeader(),
            Expanded(child: _buildItemList()),
            const SizedBox(height: 12),
            _buildTotals(),
          ],
        ),
      ),
    );
  }

  // ---------------- Header: Supplier, Staff, Date, Paid ----------------
  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            // ---------------- Purchase Date ----------------
            Expanded(
              child: TextField(
                controller: controller.dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Purchase Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => controller.pickPurchaseDate(context),
              ),
            ),
            const SizedBox(width: 12),

            // ---------------- Supplier Dropdown ----------------
            Expanded(
              child: Obx(() {
                // Show loading if empty
                if (supplierController.suppliers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return DropdownButtonFormField<int>(
                  value: controller.selectedSupplierId.value,
                  items: supplierController.suppliers
                      .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ))
                      .toList(),
                  onChanged: (v) {
                    controller.selectedSupplierId.value = v;
                    controller.isModified.value = true;
                  },
                  decoration: const InputDecoration(
                      labelText: 'Supplier', border: OutlineInputBorder()),
                );
              }),
            ),
            const SizedBox(width: 12),

            // ---------------- Staff Dropdown ----------------
            Expanded(
              child: Obx(() {
                if (staffController.staffs.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return DropdownButtonFormField<int>(
                  value: controller.selectedStaffId.value,
                  items: staffController.staffs
                      .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ))
                      .toList(),
                  onChanged: (v) {
                    controller.selectedStaffId.value = v;
                    controller.isModified.value = true;
                  },
                  decoration: const InputDecoration(
                      labelText: 'Created By', border: OutlineInputBorder()),
                );
              }),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ---------------- Paid Amount ----------------
        TextField(
          controller: controller.paidController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Paid Amount"),
          onChanged: (_) => controller.isModified.value = true,
        ),
      ],
    );
  }

  // ---------------- Add Item Button ----------------
  Widget _buildAddItemButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: _openStockPicker,
        icon: const Icon(Icons.add),
        label: const Text("Add Item"),
      ),
    );
  }

  // ---------------- Item Table Header ----------------
  Widget _buildItemTableHeader() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey.shade300,
      child: Row(
        children: const [
          SizedBox(
              width: 40,
              child: Center(
                  child: Text("SN",
                      style: TextStyle(fontWeight: FontWeight.bold)))),
          Expanded(
              child:
                  Text("Item", style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(
              width: 70,
              child: Center(
                  child: Text("Qty",
                      style: TextStyle(fontWeight: FontWeight.bold)))),
          SizedBox(
              width: 90,
              child: Center(
                  child: Text("Rate",
                      style: TextStyle(fontWeight: FontWeight.bold)))),
          SizedBox(
              width: 90,
              child: Center(
                  child: Text("Total",
                      style: TextStyle(fontWeight: FontWeight.bold)))),
          SizedBox(width: 36),
        ],
      ),
    );
  }

  // ---------------- Item List ----------------
  Widget _buildItemList() {
    return Obx(() => ListView.builder(
          itemCount: controller.items.length,
          itemBuilder: (_, index) {
            final item = controller.items[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: index.isEven ? Colors.grey.shade50 : Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  SizedBox(
                      width: 40, child: Center(child: Text("${index + 1}"))),
                  Expanded(
                      child:
                          Text(item.itemName, overflow: TextOverflow.ellipsis)),
                  SizedBox(
                    width: 70,
                    height: 36,
                    child: TextField(
                      controller: item.quantityController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                          isDense: true, border: OutlineInputBorder()),
                      onChanged: (_) => controller.isModified.value = true,
                    ),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 90,
                    height: 36,
                    child: TextField(
                      controller: item.priceController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                          isDense: true, border: OutlineInputBorder()),
                      onChanged: (_) => controller.isModified.value = true,
                    ),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                      width: 90,
                      height: 36,
                      child: Center(
                          child: Obx(
                              () => Text(item.totalPrice.toStringAsFixed(2))))),
                  SizedBox(
                    width: 36,
                    child: IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        onPressed: () => controller.removeItem(item)),
                  ),
                ],
              ),
            );
          },
        ));
  }

  // ---------------- Totals ----------------
  Widget _buildTotals() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAmountRow("Grand Total", controller.grandTotal),
            _buildAmountRow("Discount", controller.discountAmount),
            const Divider(),
            _buildAmountRow("Net Total", controller.netTotal, isBold: true),
            _buildAmountRow("Remaining", controller.remaining.value,
                isBold: true, valueColor: Colors.red),
          ],
        ));
  }

  Widget _buildAmountRow(String label, double amount,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
        Text(amount.toStringAsFixed(2),
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: valueColor ?? Colors.black)),
      ],
    );
  }

  // ---------------- Save Purchase ----------------
  void _savePurchase() async {
    try {
      // Convert form items back to models
      final updatedItems = controller.items.map((i) => i.toModel()).toList();

      // Create a new updated PurchaseModel
      final updatedPurchase = widget.purchase.copyWith(
        items: updatedItems,
        paidAmount: double.tryParse(controller.paidController.text) ?? 0,
        discountAmount: controller.discountAmount,
        supplier: controller.selectedSupplierId.value,
        createdBy: controller.selectedStaffId.value,
      );

      // Call API
      await controller.updatePurchase(updatedPurchase);

      // Update controller/UI
      controller.populateForm(updatedPurchase);
      controller.clearModifiedFlag();

      //AppSnackbar.success("Purchase updated successfully!");
    } catch (e) {
      //AppSnackbar.error("Failed to update purchase.");
    }
  }

  // ---------------- Stock Picker ----------------
  void _openStockPicker() async {
    final searchCtrl = TextEditingController();
    final Result? selected = await showDialog<Result>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Stock"),
        content: SizedBox(
          width: SizeConfig.sw(0.4),
          height: SizeConfig.sh(0.6),
          child: Column(
            children: [
              TextField(
                controller: searchCtrl,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search stock..."),
                //onChanged: (_) => (context as Element).markNeedsBuild(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  final filtered = stockController.stocks
                      .where((s) => s.name
                          .toLowerCase()
                          .contains(searchCtrl.text.toLowerCase()))
                      .toList();
                  if (filtered.isEmpty) {
                    return const Center(child: Text("No stock found"));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final s = filtered[i];
                      return ListTile(
                        title: Text(s.name),
                        subtitle: Text("Available: ${s.stock}"),
                        trailing: Text(
                            "Price: ${s.purchasePrice.toStringAsFixed(2)}"),
                        onTap: () => Navigator.pop(context, s),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );

    if (selected != null) controller.addItem(selected);
  }
}
