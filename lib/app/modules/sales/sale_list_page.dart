import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import 'package:vgsync_frontend/app/data/models/sale_model.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_controller.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';
import 'package:vgsync_frontend/app/wigdets/custom_form_dialog.dart';
import 'package:vgsync_frontend/utils/size_config.dart';

class SaleListPage extends StatefulWidget {
  const SaleListPage({super.key});

  @override
  State<SaleListPage> createState() => _SaleListPageState();
}

class _SaleListPageState extends State<SaleListPage> {
  final SalesController controller =
      Get.put(SalesController(saleRepository: Get.find()));
  final StaffController staffController = Get.find();
  final StockController stockController = Get.find();

  final searchController = TextEditingController();
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  RxString selectedStatus = 'all'.obs;

  @override
  void initState() {
    super.initState();
    controller.fetchSales();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: const Text('Sales'),
      ),
      body: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildStatusFilter(),
          const SizedBox(height: 8),
          Expanded(child: _buildSaleList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSaleDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Sale'),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _buildHeader() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search customer...',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => controller.searchText.value = v,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.date_range),
                    label: Obx(() => Text(
                          selectedDate.value == null
                              ? 'Select Date'
                              : selectedDate.value!
                                  .toIso8601String()
                                  .split('T')[0],
                        )),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: controller.fetchSales,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- STATUS FILTER ----------------
  Widget _buildStatusFilter() {
    const statuses = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Paid', 'value': 'paid'},
      {'label': 'Partial', 'value': 'partial'},
      {'label': 'Not Paid', 'value': 'not_paid'},
    ];

    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: statuses
                .map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
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
                    ))
                .toList(),
          ),
        ));
  }

  // ---------------- FILTER LOGIC ----------------
  List<SaleModel> _filteredSales() {
    final query = controller.searchText.value.toLowerCase();

    return controller.sales.where((sale) {
      // Status filter
      if (selectedStatus.value != 'all' &&
          sale.isPaid != selectedStatus.value) {
        return false;
      }

      // Date filter
      if (selectedDate.value != null) {
        final d = selectedDate.value!;
        if (sale.saleDate.year != d.year ||
            sale.saleDate.month != d.month ||
            sale.saleDate.day != d.day) {
          return false;
        }
      }

      // Search by customer
      if (query.isNotEmpty &&
          !sale.customerName.toLowerCase().contains(query)) {
        return false;
      }

      return true;
    }).toList();
  }

  // ---------------- SALE LIST ----------------
  Widget _buildSaleList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final list = _filteredSales();
      if (list.isEmpty) return const Center(child: Text('No sales found'));

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: list.length,
        itemBuilder: (_, i) => _saleTile(list[i]),
      );
    });
  }

  Color _statusColor(String status) {
    if (status == 'paid') return Colors.green;
    if (status == 'partial') return Colors.orange;
    return Colors.red;
  }

  Widget _saleTile(SaleModel sale) {
    return Slidable(
      key: ValueKey(sale.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            icon: Icons.edit,
            backgroundColor: Colors.orange,
            label: 'Edit',
            onPressed: (_) => _openSaleDialog(sale: sale),
          ),
          SlidableAction(
            icon: Icons.delete,
            backgroundColor: Colors.red,
            label: 'Delete',
            onPressed: (_) => controller.deleteSale(sale.id ?? 0),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sale.customerName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Chip(
                    label: Text(
                      sale.isPaid.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _statusColor(sale.isPaid),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Date: ${sale.saleDate.toIso8601String().split('T')[0]}'),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('Total: ${sale.netTotal.toStringAsFixed(2)}'),
                  const SizedBox(width: 12),
                  Text('Paid: ${sale.paidAmount.toStringAsFixed(2)}'),
                  const SizedBox(width: 12),
                  Text(
                    'Remaining: ${sale.remainingAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Paid From: ${sale.paidFrom}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- DATE PICKER ----------------
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) selectedDate.value = picked;
  }

  // ---------------- ADD / EDIT SALE ----------------
  void _openSaleDialog({SaleModel? sale}) {
    final isEdit = sale != null;

    controller.clearForm();
    if (isEdit) controller.fillForEdit(sale);

    // ---------- Observables ----------
    final isServicing = (sale?.isServicing ?? false).obs;
    final staffSelected = (sale?.handledBy ?? 0).obs;

    // Ensure paidFrom is always one of the dropdown options
    final paidFromOptions = ['cash', 'online', 'bank'];
    final initialPaidFrom =
        (sale?.paidFrom != null && paidFromOptions.contains(sale!.paidFrom))
            ? sale.paidFrom
            : 'cash';
    final paidFrom = initialPaidFrom.obs;

    controller.discountController.text =
        (sale?.discountPercentage ?? 0).toString();
    controller.vatController.text =
        (sale?.vatPercentage ?? 13).toString(); // default 13%

    controller.updateTotals(); // recalc grand, net, remaining

    Get.dialog(
      CustomFormDialog(
        title: isEdit ? 'Edit Sale' : 'Add Sale',
        isEditMode: isEdit,
        width: 0.9,
        height: 0.9,
        content: SingleChildScrollView(
          child: Column(
            children: [
              // ---------- Bill No ----------
              _buildTextField('Bill No', controller.billNoController),

              const SizedBox(height: 8),
              // ---------- Customer ----------
              _buildTextField(
                  'Customer Name', controller.customerNameController),
              const SizedBox(height: 8),
              _buildTextField('Contact No', controller.contactNoController),

              const SizedBox(height: 8),
              // ---------- Sale Date ----------
              _datePickerField('Sale Date', controller.saleDate,
                  required: true),

              const SizedBox(height: 8),
              // ---------- Staff Dropdown ----------
              Obx(() {
                return DropdownButtonFormField<int>(
                  value: staffSelected.value > 0 ? staffSelected.value : null,
                  items: staffController.staffs
                      .map((s) => DropdownMenuItem(
                            value: s.id, // int
                            child: Text(s.name),
                          ))
                      .toList(),
                  onChanged: (v) => staffSelected.value = v ?? 0,
                );
              }),

              const SizedBox(height: 8),
              // ---------- Servicing Switch ----------
              Obx(() => SwitchListTile(
                    title: const Text('Servicing Sale'),
                    value: isServicing.value,
                    onChanged: (v) => isServicing.value = v,
                  )),

              const SizedBox(height: 8),
              // ---------- Items ----------
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                  onPressed: () async {
                    final selectedStock = await _selectStock();
                    if (selectedStock != null) {
                      controller
                          .addItem(SaleItemModel.fromStock(selectedStock));
                      controller.updateTotals();
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Column(
                    children: controller.selectedItems.map(_itemRow).toList(),
                  )),

              const SizedBox(height: 8),
              // ---------- Discount & VAT ----------
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                        'Discount %', controller.discountController,
                        keyboardType: TextInputType.number, onChanged: (_) {
                      controller.updateTotals();
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField('VAT %', controller.vatController,
                        keyboardType: TextInputType.number, onChanged: (_) {
                      controller.updateTotals();
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              // ---------- Paid From ----------
              Obx(() {
                return DropdownButtonFormField<String>(
                  value: paidFromOptions.contains(paidFrom.value)
                      ? paidFrom.value
                      : null,
                  items: paidFromOptions
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (v) => paidFrom.value = v ?? 'cash',
                  decoration: const InputDecoration(
                    labelText: 'Paid From',
                    border: OutlineInputBorder(),
                  ),
                );
              }),

              const SizedBox(height: 8),
              // ---------- Paid Amount ----------
              _buildTextField('Paid Amount', controller.paidAmountController,
                  keyboardType: TextInputType.number, onChanged: (_) {
                controller.updateTotals();
              }),

              const SizedBox(height: 8),
              // ---------- Net / Remaining ----------
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Grand Total: ${controller.totalAmount.toStringAsFixed(2)}'),
                      Text(
                          'Discount Amount: ${controller.discountAmount.toStringAsFixed(2)}'),
                      Text(
                          'VAT Amount: ${controller.vatAmount.toStringAsFixed(2)}'),
                      Text(
                          'Net Total: ${controller.netAmount.toStringAsFixed(2)}'),
                      Text(
                          'Remaining: ${controller.remainingAmount.toStringAsFixed(2)}'),
                    ],
                  )),

              const SizedBox(height: 8),
              // ---------- Remarks ----------
              _buildTextField('Remarks', controller.remarksController,
                  keyboardType: TextInputType.text),
            ],
          ),
        ),
        onSave: () async {
          if (!_validateForm()) return;

          // Assign handled_by & paid_from to controller / model
          controller.handledBy.value = staffSelected.value;
          controller.paidFrom.value = paidFrom.value;

          if (isEdit) {
            await controller.updateSale(sale.id!);
          } else {
            await controller.addSale();
          }
          Get.back();
        },
        onDelete: isEdit
            ? () async {
                await controller.deleteSale(sale.id!);
                Get.back();
              }
            : null,
      ),
      barrierDismissible: false,
    );
  }

  // ---------- HELPERS ----------
  bool _validateForm() {
    if (controller.customerNameController.text.isEmpty) {
      Get.snackbar('Error', 'Customer name is required');
      return false;
    }
    if (controller.saleDate.value == null) {
      Get.snackbar('Error', 'Sale date is required');
      return false;
    }
    if (controller.selectedItems.isEmpty) {
      Get.snackbar('Error', 'Please add at least one item');
      return false;
    }
    return true;
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text,
      void Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }

  Widget _datePickerField(String label, Rx<DateTime?> dateField,
      {bool required = false}) {
    return Obx(() => InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: dateField.value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              dateField.value = picked;

              // ✅ Auto-update followUpDate and postServiceFeedbackDate
              if (dateField == controller.deliveryDate) {
                controller.updateDerivedDates();
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: required && dateField.value == null
                      ? Colors.red
                      : Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 10),
                Text(dateField.value == null
                    ? '$label ${required ? "*" : ""}'
                    : dateField.value!.toIso8601String().split('T').first),
              ],
            ),
          ),
        ));
  }

  Widget _readonlyDateField(String label, Rx<DateTime?> dateField) {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              const SizedBox(width: 10),
              Text(dateField.value == null
                  ? label
                  : dateField.value!.toIso8601String().split('T').first),
            ],
          ),
        ));
  }

  Widget _itemRow(SaleItemModel item) {
    item.initControllerIfNull();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(flex: 3, child: Text(item.itemName)),
            Expanded(
              flex: 2,
              child: TextField(
                controller: item.quantityController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Qty', isDense: true),
                onChanged: (_) => controller.updateTotals(),
              ),
            ),
            Expanded(
              flex: 2,
              child: TextField(
                controller: item.priceController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Rate', isDense: true),
                onChanged: (_) => controller.updateTotals(),
              ),
            ),
            Expanded(
                flex: 2,
                child: Obx(() => Text(
                      'Total: ${item.totalPrice.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ))),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => controller.removeItem(item),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _selectStock() async {
    final searchCtrl = TextEditingController();
    return showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          title: const Text('Select Stock'),
          content: SizedBox(
            width: 400,
            height: 300,
            child: Column(
              children: [
                TextField(
                  controller: searchCtrl,
                  decoration: const InputDecoration(labelText: 'Search Stock'),
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
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final s = filtered[i];
                        return ListTile(
                          title: Text(s.name),
                          subtitle: Text('Available: ${s.stock}'),
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
  }
}
