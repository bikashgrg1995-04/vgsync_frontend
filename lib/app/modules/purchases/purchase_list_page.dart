// app/modules/purchases/purchase_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/modules/purchases/purchase_detail_page.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_controller.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_controller.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
// import 'package:vgsync_frontend/app/wigdets/file_upload.dart';
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

  final GlobalController globalController = Get.find();

  final ScrollController _itemScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPurchases();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(SizeConfig.res(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.sh(0.02)),
            _buildHeader(),
            SizedBox(height: SizeConfig.sh(0.02)),
            Expanded(child: _buildPurchaseList()),
          ],
        ),
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
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.res(5)),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search Purchases',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (_) => controller.purchases.refresh(),
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
                actionButton(
                  label: 'Refresh',
                  icon: Icons.refresh,
                  onPressed: controller.refreshSales,
                ),
                // SizedBox(width: SizeConfig.sw(0.01)),
                // actionButton(
                //   label: 'Import',
                //   icon: Icons.upload_file,
                //   onPressed: () {
                //     FileUploadDialog.show(
                //       context: context,
                //       title: 'Import Purchases (Excel)',
                //       endpoint: '/upload/purchase-excel/',
                //       fileKey: 'file',
                //       allowedExtensions: ['xls', 'xlsx'],
                //       onSuccess: () async {
                //         await controller.fetchPurchases();
                //         globalController
                //             .triggerRefresh(DashboardRefreshType.all);
                //       },
                //     );
                //   },
                // ),
                // SizedBox(width: SizeConfig.sw(0.01)),
              ],
            ),
            SizedBox(height: SizeConfig.sh(0.04)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: SizeConfig.sw(0.15),
                  child: ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.date_range),
                    label: Obx(() => Text(
                        controller.filterSelectedDate.value == null
                            ? "Select Date"
                            : controller.filterSelectedDate.value!
                                .toIso8601String()
                                .split('T')[0])),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                _buildStatusFilter(),
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
                      selected: controller.selectedStatus.value == s['value'],
                      onSelected: (_) =>
                          controller.selectedStatus.value = s['value']!,
                      selectedColor: Colors.deepPurple,
                      labelStyle: TextStyle(
                        color: controller.selectedStatus.value == s['value']
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
      initialDate: controller.filterSelectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) controller.filterSelectedDate.value = picked;
  }

  Widget _buildPurchaseList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      List<PurchaseModel> filtered = controller.filteredPurchases(
        query: controller.searchController.text.toLowerCase(),
      );

      if (controller.filterSelectedDate.value != null) {
        filtered = filtered
            .where((p) =>
                p.date.year == controller.filterSelectedDate.value!.year &&
                p.date.month == controller.filterSelectedDate.value!.month &&
                p.date.day == controller.filterSelectedDate.value!.day)
            .toList();
      }

      if (controller.selectedStatus.value != 'all') {
        filtered = filtered
            .where((p) => p.status == controller.selectedStatus.value)
            .toList();
      }

      if (filtered.isEmpty) {
        return const Center(child: Text('No purchases found'));
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 20, right: 12),
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
                        controller.deletePurchase(context, purchase.id ?? 0),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // Navigate to detail page
                  Get.to(() => PurchaseDetailPage(purchase: purchase));
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: Colors.grey.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                'Date: ${purchase.date.toIso8601String().split('T')[0]}'),
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
                        Text(
                          'Supplier: ${supplierController.suppliers.firstWhere(
                                (s) => s.id == purchase.supplier,
                              ).name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
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
          height: double.infinity,
          content: SizedBox(
            height: 550, // total height for the content
            child: Column(
              children: [
                // ---------- Header ----------
                _buildFormHeader(),
                SizedBox(height: SizeConfig.sh(0.02)),

                // ---------- Add Item Button ----------
                _buildAddItemButton(),
                SizedBox(height: SizeConfig.sh(0.02)),

                // ---------- Scrollable Item List ----------
                _buildItemList(),

                SizedBox(height: SizeConfig.sh(0.02)),

                // ---------- Totals, Discount, Paid ----------
                _buildTotalsCard()
              ],
            ),
          ),
          onSave: () async {
            if (isEditMode) {
              await controller.updatePurchase(purchase);
            } else {
              await controller.addPurchase();
            }
          },
          onDelete: isEditMode
              ? () async {
                  await controller.deletePurchase(context, purchase.id ?? 0);
                  Get.back();
                }
              : null,
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildTotalsCard() {
    return Obx(
      () => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: EdgeInsets.symmetric(
          vertical: SizeConfig.sh(0.005),
          horizontal: SizeConfig.sw(0.015),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: SizeConfig.sh(0.015),
            horizontal: SizeConfig.sw(0.015),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: double.maxFinite,
              height: SizeConfig.sh(0.14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- Top Row ----------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Grand Total
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grand Total',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                          ),
                          SizedBox(height: SizeConfig.sh(0.01)),
                          Text(
                            controller.grandTotal.toStringAsFixed(2),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(width: SizeConfig.sw(0.05)),

                      // Discount % + Discount Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Discount %',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          SizedBox(height: SizeConfig.sh(0.005)),
                          Row(
                            children: [
                              SizedBox(
                                width: SizeConfig.sw(0.05),
                                height: SizeConfig.sh(0.06),
                                child: TextField(
                                  controller: controller.discountController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    isDense: true,
                                  ),
                                  onChanged: (_) => controller.items.refresh(),
                                ),
                              ),
                              SizedBox(width: SizeConfig.sw(0.02)),
                              Text(
                                '(${controller.discountAmount.toStringAsFixed(2)})',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: SizeConfig.sw(0.04)),

                      // Net Total
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Net Total',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                          ),
                          SizedBox(height: SizeConfig.sh(0.0)),
                          Text(
                            controller.netTotal.toStringAsFixed(2),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),

                      SizedBox(width: SizeConfig.sw(0.04)),
                      // Paid Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Paid Amount',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          SizedBox(height: SizeConfig.sh(0.005)),
                          SizedBox(
                            width: SizeConfig.sw(0.1),
                            height: SizeConfig.sh(0.06),
                            child: TextField(
                              controller: controller.paidController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                isDense: true,
                              ),
                              onChanged: (_) => controller.items.refresh(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // ---------- Bottom Row ----------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Remaining Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Remaining',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          SizedBox(height: SizeConfig.sh(0.005)),
                          Text(
                            controller.remaining.value.toStringAsFixed(2),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(width: SizeConfig.sw(0.04)),

                      // Status
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          SizedBox(height: SizeConfig.sh(0.005)),
                          Text(
                            controller.purchaseStatus.value
                                .replaceAll("_", " ")
                                .toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: controller.purchaseStatus.value == 'paid'
                                    ? Colors.green
                                    : controller.purchaseStatus.value ==
                                            'partial'
                                        ? Colors.orange
                                        : Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemList() {
    return SizedBox(
      height: SizeConfig.sh(0.34), // Scrollable height for the item list
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
                          width: SizeConfig.sw(0.05),
                          child: TextField(
                            controller: item.quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Qty'),
                            onChanged: (_) => controller.items.refresh(),
                          ),
                        ),
                        SizedBox(width: SizeConfig.sw(0.01)),
                        SizedBox(
                          width: SizeConfig.sw(0.08),
                          child: TextField(
                            controller: item.priceController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Price'),
                            onChanged: (_) => controller.items.refresh(),
                          ),
                        ),
                        SizedBox(width: SizeConfig.sw(0.01)),
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
        // ---------- Purchase Date ----------
        SizedBox(
          width: SizeConfig.sw(0.15),
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
        SizedBox(width: SizeConfig.sw(0.01)),

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
        SizedBox(width: SizeConfig.sw(0.01)),

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

          StockModel? selected = await showDialog<StockModel>(
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
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => Navigator.pop(context, s),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        // ---------- Item Name ----------
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            s.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ),

                                        // ---------- Stock ----------
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "Stock: ${s.stock}",
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),

                                        // ---------- Prices ----------
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "Purchase: ${s.purchasePrice.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Selling: ${s.salePrice.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
