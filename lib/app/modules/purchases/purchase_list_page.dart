import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
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
  final searchController = TextEditingController();
  final ScrollController _itemScrollCtrl = ScrollController();

  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

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
          // ---------------- Header Section ----------------
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      SizedBox(
                        width: SizeConfig.sh(1),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search by item name...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onChanged: (_) => controller.purchases.refresh(),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: SizeConfig.sw(0.15),
                            child: ElevatedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.date_range),
                              label: Obx(() => Text(selectedDate.value == null
                                  ? "Select Date"
                                  : selectedDate.value!
                                      .toIso8601String()
                                      .split('T')[0])),
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
                      )
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ---------------- Purchase List ----------------
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

      List<PurchaseModel> filtered = controller.filterPurchases(
          query: searchController.text.toLowerCase());

      if (selectedDate.value != null) {
        filtered = filtered
            .where((p) =>
                p.date.year == selectedDate.value!.year &&
                p.date.month == selectedDate.value!.month &&
                p.date.day == selectedDate.value!.day)
            .toList();
      }

      if (filtered.isEmpty) {
        return const Center(child: Text('No purchases found'));
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
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
                elevation: 3,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    'Supplier: ${purchase.supplier}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Date: ${purchase.date.toIso8601String().split('T')[0]}'),
                      Text(
                          'VAT: ${purchase.vatPercentage}% | Discount: ${purchase.discountPercentage}%'),
                      Text(
                          'Items: ${purchase.items.map((e) => e.itemName).join(", ")}'),
                      Text(
                          'Grand Total: ${purchase.grandTotal.toStringAsFixed(2)}'),
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
      CustomFormDialog(
        title: isEditMode ? "Edit Purchase" : "Add Purchase",
        isEditMode: isEditMode,
        width: 0.6,
        height: 0.75,
        content: SizedBox(
          height: 500,
          child: Column(
            children: [
              // Supplier / Discount / VAT
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.supplierController,
                      decoration:
                          const InputDecoration(labelText: 'Supplier ID'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller.discountController,
                      decoration:
                          const InputDecoration(labelText: 'Discount %'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller.vatController,
                      decoration: const InputDecoration(labelText: 'VAT %'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // -------- Add Item Button --------
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final stockCtrl = Get.find<StockController>();
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
                                    final filtered = stockCtrl.stocks
                                        .where((s) => s.name
                                            .toLowerCase()
                                            .contains(
                                                searchCtrl.text.toLowerCase()))
                                        .toList();
                                    if (filtered.isEmpty) {
                                      return const Center(
                                          child: Text('No items found'));
                                    }
                                    return ListView.builder(
                                      itemCount: filtered.length,
                                      itemBuilder: (_, index) {
                                        final s = filtered[index];
                                        return ListTile(
                                          title: Text(s.name),
                                          subtitle: Text("Stock: ${s.stock}"),
                                          trailing: Text(
                                              "Price: ${s.purchasePrice.toStringAsFixed(2)}"),
                                          onTap: () =>
                                              Navigator.pop(context, s),
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
              ),
              const SizedBox(height: 8),
              // -------- Scrollable Item List --------
              Expanded(
                child: Obx(() => Scrollbar(
                      controller: _itemScrollCtrl,
                      thumbVisibility: true,
                      child: ListView.builder(
                        controller: _itemScrollCtrl,
                        itemCount: controller.items.length,
                        itemBuilder: (_, i) {
                          final item =
                              List.from(controller.items)[i]; // copy list
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
                                      decoration: const InputDecoration(
                                          labelText: 'Qty'),
                                      onChanged: (_) =>
                                          controller.items.refresh(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: SizeConfig.sw(0.1),
                                    child: TextField(
                                      controller: item.priceController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                          labelText: 'Price'),
                                      onChanged: (_) =>
                                          controller.items.refresh(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: SizeConfig.sw(0.12),
                                    child: Text(
                                        item.totalPrice.toStringAsFixed(2)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      final itemToRemove = controller.items[i];
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        controller.items.remove(itemToRemove);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )),
              ),
              const SizedBox(height: 12),
              // -------- Grand Total fixed at bottom --------
              Obx(() => Text(
                    'Grand Total: ${controller.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  )),
            ],
          ),
        ),
        onSave: () {
          if (isEditMode) {
            controller.updatePurchase(purchase);
          } else {
            controller.addPurchase();
          }
          Get.back();
        },
        onDelete: isEditMode
            ? () => controller.deletePurchase(purchase.id ?? 0)
            : null,
      ),
    );
  }
}
