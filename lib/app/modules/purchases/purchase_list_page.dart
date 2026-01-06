import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_controller.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_controller.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../data/models/purchase_model.dart';
import '../../data/models/stock_model.dart';
import 'purchase_controller.dart';
import '../../wigdets/custom_form_dialog.dart';
import '../../modules/stock/stock_controller.dart';

class PurchaseListPage extends StatefulWidget {
  const PurchaseListPage({super.key});

  @override
  State<PurchaseListPage> createState() => _PurchaseListPageState();
}

class _PurchaseListPageState extends State<PurchaseListPage> {
  final PurchaseController controller = Get.find<PurchaseController>();
  final StockController stockController = Get.find<StockController>();
  final SupplierController supplierController = Get.find();
  final StaffController staffController = Get.find();

  final searchController = TextEditingController();
  final ScrollController _itemScrollCtrl = ScrollController();
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  RxString selectedStatus = 'all'.obs;

  @override
  void initState() {
    super.initState();
    controller.fetchPurchases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildStatusFilter(),
          const SizedBox(height: 8),
          Expanded(child: _buildPurchaseList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Purchase'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by item name...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (_) => controller.purchases.refresh(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: SizeConfig.sw(0.2),
                  child: ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.date_range),
                    label: Obx(() => Text(selectedDate.value == null
                        ? "Select Date"
                        : selectedDate.value!.toIso8601String().split('T')[0])),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                SizedBox(
                  width: SizeConfig.sw(0.15),
                  height: SizeConfig.sh(0.045),
                  child: ElevatedButton.icon(
                    onPressed: controller.fetchPurchases,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    const statusOptions = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Paid', 'value': 'paid'},
      {'label': 'Partial', 'value': 'partial'},
      {'label': 'Not Paid', 'value': 'not_paid'},
    ];

    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: statusOptions
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(s['label']!),
                      selected: selectedStatus.value == s['value'],
                      onSelected: (_) => selectedStatus.value = s['value']!,
                      selectedColor: Colors.deepPurple,
                      labelStyle: TextStyle(
                        color: selectedStatus.value == s['value']
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) selectedDate.value = picked;
  }

  Widget _buildPurchaseList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      List<PurchaseModel> filtered = controller.filteredPurchases(
        query: searchController.text.toLowerCase(),
      );

      if (selectedDate.value != null) {
        filtered = filtered
            .where((p) =>
                p.date.year == selectedDate.value!.year &&
                p.date.month == selectedDate.value!.month &&
                p.date.day == selectedDate.value!.day)
            .toList();
      }

      if (selectedStatus.value != 'all') {
        filtered =
            filtered.where((p) => p.status == selectedStatus.value).toList();
      }

      if (filtered.isEmpty) {
        return const Center(child: Text('No purchases found'));
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 20, left: 12, right: 12),
        itemCount: filtered.length,
        itemBuilder: (_, index) {
          final purchase = filtered[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Slidable(
              key: ValueKey(purchase.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.35,
                children: [
                  SlidableAction(
                    onPressed: (_) => _openEditDialog(purchase),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                  SlidableAction(
                    onPressed: (_) =>
                        controller.deletePurchase(purchase.id ?? 0),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: Colors.grey.withOpacity(0.3),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Supplier: ${supplierController.suppliers.firstWhere(
                                    (s) => s.id == purchase.supplier,
                                  ).name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(
                              purchase.status
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                            backgroundColor: purchase.status == 'paid'
                                ? Colors.green
                                : purchase.status == 'partial'
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ],
                      ),
                      SizedBox(height: SizeConfig.sh(0.01)),
                      Text(
                          'Date: ${purchase.date.toIso8601String().split('T')[0]}'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                              'Total: ${purchase.netTotal.toStringAsFixed(2)}'),
                          SizedBox(width: SizeConfig.sw(0.04)),
                          Text(
                              'Paid: ${purchase.paidAmount.toStringAsFixed(2)}'),
                          SizedBox(width: SizeConfig.sw(0.04)),
                          Text(
                              'Remaining: ${(purchase.remainingAmount).toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  void _openAddDialog() => _openDialog();
  void _openEditDialog(PurchaseModel purchase) =>
      _openDialog(purchase: purchase);

  void _openDialog({PurchaseModel? purchase}) {
    final isEditMode = purchase != null;
    controller.clearForm();
    if (isEditMode) controller.populateForm(purchase);

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => CustomFormDialog(
          title: isEditMode ? "Edit Purchase" : "Add Purchase",
          isEditMode: isEditMode,
          width: 0.5,
          height: 0.85,
          content: SizedBox(
            height: 550, // total height for the content
            child: Column(
              children: [
                // ---------- Header ----------
                _buildFormHeader(),
                const SizedBox(height: 12),

                // ---------- Add Item Button ----------
                _buildAddItemButton(),
                const SizedBox(height: 8),

                // ---------- Scrollable Item List ----------
                _buildItemList(),

                const SizedBox(height: 12),

                // ---------- Totals, Discount, VAT, Paid ----------
                Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grand Total: ${controller.grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: SizeConfig.sh(0.02)),
                        Row(
                          children: [
                            SizedBox(
                              width: SizeConfig.sw(0.1),
                              child: TextField(
                                controller: controller.discountController,
                                decoration: const InputDecoration(
                                    labelText: 'Discount %'),
                                keyboardType: TextInputType.number,
                                onChanged: (_) => controller.items.refresh(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                                width: SizeConfig.sw(0.1),
                                child: Text(
                                    'Discount Amount: ${controller.discountAmount.toStringAsFixed(2)}')),
                            const SizedBox(width: 25),
                            SizedBox(
                              width: SizeConfig.sw(0.1),
                              child: TextField(
                                controller: controller.vatController,
                                decoration:
                                    const InputDecoration(labelText: 'VAT %'),
                                keyboardType: TextInputType.number,
                                onChanged: (_) => controller.items.refresh(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                                width: SizeConfig.sw(0.1),
                                child: Text(
                                    'VAT Amount:         ${controller.vatAmount.toStringAsFixed(2)}')),
                          ],
                        ),
                        SizedBox(height: SizeConfig.sh(0.02)),
                        SizedBox(
                            width: SizeConfig.sw(0.1),
                            child: Text(
                                'Net Total: ${controller.netTotal.toStringAsFixed(2)}')),
                        SizedBox(height: SizeConfig.sh(0.02)),
                        Row(
                          children: [
                            SizedBox(
                              width: SizeConfig.sw(0.1),
                              child: TextField(
                                controller: controller.paidController,
                                decoration: const InputDecoration(
                                    labelText: 'Paid Amount'),
                                keyboardType: TextInputType.number,
                                onChanged: (_) => controller.items.refresh(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Remaining Amount: ${controller.remaining.value.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                        SizedBox(height: SizeConfig.sh(0.02)),
                        Text(
                          'Status: ${controller.purchaseStatus.value.replaceAll("_", " ").toUpperCase()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: controller.purchaseStatus.value == 'paid'
                                ? Colors.green
                                : controller.purchaseStatus.value == 'partial'
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
          onSave: () async {
            if (isEditMode) {
              await controller.updatePurchase(purchase);
            } else {
              await controller.addPurchase();
            }

            if (controller.message.value
                .toLowerCase()
                .contains('successfully')) {
              Get.back();
            }
          },
          onDelete: isEditMode
              ? () async {
                  await controller.deletePurchase(purchase.id ?? 0);
                  Get.back();
                }
              : null,
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildItemList() {
    return SizedBox(
      height: SizeConfig.sh(0.25), // Scrollable height for the item list
      child: Obx(() => Scrollbar(
            controller: _itemScrollCtrl,
            thumbVisibility: true,
            child: ListView.builder(
              controller: _itemScrollCtrl,
              itemCount: controller.items.length,
              itemBuilder: (_, i) {
                final item = List.from(controller.items)[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(child: Text(item.itemName)),
                        SizedBox(
                          width: SizeConfig.sw(0.08),
                          child: TextField(
                            controller: item.quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Qty'),
                            onChanged: (_) => controller.items.refresh(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: SizeConfig.sw(0.1),
                          child: TextField(
                            controller: item.priceController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Price'),
                            onChanged: (_) => controller.items.refresh(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: SizeConfig.sw(0.12),
                          child: Obx(
                              () => Text(item.totalPrice.toStringAsFixed(2))),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            final itemToRemove = controller.items[i];
                            WidgetsBinding.instance.addPostFrameCallback(
                                (_) => controller.items.remove(itemToRemove));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )),
    );
  }

  Widget _buildFormHeader() {
    return Row(
      children: [
        // ---------- Supplier Dropdown ----------
        Expanded(
          child: Obx(() {
            // Fetch suppliers if not already fetched
            if (supplierController.suppliers.isEmpty) {
              supplierController.fetchSuppliers();
            }

            return DropdownButtonFormField<int>(
              value: controller.selectedSupplierId.value,
              items: supplierController.suppliers
                  .map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name),
                      ))
                  .toList(),
              onChanged: (v) => controller.selectedSupplierId.value = v,
              decoration: const InputDecoration(
                labelText: 'Supplier',
                border: OutlineInputBorder(),
              ),
            );
          }),
        ),
        const SizedBox(width: 12),

        // ---------- Staff Dropdown ----------
        Expanded(
          child: Obx(() {
            // Fetch staff if not already fetched
            if (staffController.staffs.isEmpty) {
              staffController.fetchStaff();
            }

            return DropdownButtonFormField<int>(
              value: controller.selectedStaffId.value,
              items: staffController.staffs
                  .map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name),
                      ))
                  .toList(),
              onChanged: (v) => controller.selectedStaffId.value = v,
              decoration: const InputDecoration(
                labelText: 'Created By',
                border: OutlineInputBorder(),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAddItemButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () async {
          final searchCtrl = TextEditingController();

          Result? selected = await showDialog<Result>(
            context: context,
            builder: (_) => StatefulBuilder(
              builder: (_, setState) => AlertDialog(
                title: const Text("Select Stock Item"),
                content: SizedBox(
                  width: SizeConfig.sw(0.4),
                  height: SizeConfig.sh(0.6),
                  child: Column(
                    children: [
                      TextField(
                        controller: searchCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Search Item',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (_) => setState(() {}),
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
                            return const Center(child: Text('No items found'));
                          }
                          return ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (_, index) {
                              final s = filtered[index];
                              return ListTile(
                                title: Text(s.name),
                                subtitle: Text("Stock: ${s.stock}"),
                                trailing: Text(
                                    "Price: ${s.salePrice.toStringAsFixed(2)}"),
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
            ),
          );

          if (selected != null) controller.addItem(selected);
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Item"),
      ),
    );
  }
}
