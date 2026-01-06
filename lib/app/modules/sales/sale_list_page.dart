import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import 'package:vgsync_frontend/app/data/models/sale_model.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_controller.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';
import 'package:vgsync_frontend/app/wigdets/custom_form_dialog.dart';
import 'package:vgsync_frontend/utils/size_config.dart';

class SaleListPage extends StatelessWidget {
  SaleListPage({super.key});

  final SalesController controller =
      Get.put(SalesController(saleRepository: Get.find()));
  final StaffController staffController = Get.find();
  final searchController = TextEditingController();
  final RxString selectedSaleType = 'all'.obs;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: const Text('Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetFilters,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.sw(0.03)),
        child: Column(
          children: [
            _searchField(),
            const SizedBox(height: 10),
            _filtersRow(),
            const SizedBox(height: 10),
            _summaryRow(),
            const SizedBox(height: 10),
            Expanded(child: _saleList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSaleDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Sale'),
      ),
    );
  }

  // ---------------- SEARCH ----------------
  Widget _searchField() {
    return TextField(
      controller: searchController,
      onChanged: (val) => controller.searchText.value = val,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search by customer...',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ---------------- FILTERS ----------------
  Widget _filtersRow() {
    return Row(
      children: [
        Expanded(child: _dateFilter()),
        const SizedBox(width: 8),
        Expanded(child: _typeFilter()),
      ],
    );
  }

  Widget _dateFilter() {
    return Obx(() => InkWell(
          onTap: _pickDate,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 6),
                Text(controller.saleDate.value == null
                    ? 'Select date'
                    : controller.saleDate.value!
                        .toIso8601String()
                        .split('T')
                        .first),
              ],
            ),
          ),
        ));
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: controller.saleDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) controller.saleDate.value = picked;
  }

  Widget _typeFilter() {
    return Obx(() => DropdownButtonFormField<String>(
          value: selectedSaleType.value,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All')),
            DropdownMenuItem(value: 'stock', child: Text('Stock')),
            DropdownMenuItem(value: 'service', child: Text('Service')),
          ],
          onChanged: (v) => selectedSaleType.value = v ?? 'all',
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ));
  }

  void _resetFilters() {
    searchController.clear();
    selectedSaleType.value = 'all';
    controller.saleDate.value = null;
    controller.fetchSales();
  }

  // ---------------- SUMMARY ----------------
  Widget _summaryRow() {
    return Obx(() {
      final list = _filteredSales();
      final total = list.fold<double>(0, (sum, e) => sum + e.totalAmount);
      final paid = list.fold<double>(0, (sum, e) => sum + e.paidAmount);
      final remaining =
          list.fold<double>(0, (sum, e) => sum + e.remainingAmount);

      return Row(
        children: [
          _summaryCard('Total', total, Colors.blue),
          _summaryCard('Paid', paid, Colors.green),
          _summaryCard('Remaining', remaining, Colors.red),
        ],
      );
    });
  }

  Widget _summaryCard(String title, double value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: TextStyle(color: color)),
              const SizedBox(height: 4),
              Text(
                value.toStringAsFixed(2),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- FILTER LOGIC ----------------
  List<SaleModel> _filteredSales() {
    final query = controller.searchText.value.toLowerCase();

    return controller.sales.where((sale) {
      if (selectedSaleType.value == 'stock' && sale.isServicing) return false;
      if (selectedSaleType.value == 'service' && !sale.isServicing) {
        return false;
      }

      if (controller.saleDate.value != null) {
        final d = controller.saleDate.value!;
        if (sale.saleDate.year != d.year ||
            sale.saleDate.month != d.month ||
            sale.saleDate.day != d.day) {
          return false;
        }
      }

      if (query.isNotEmpty &&
          !sale.customerName.toLowerCase().contains(query)) {
        return false;
      }

      return true;
    }).toList();
  }

  // ---------------- SALE LIST ----------------
  Widget _saleList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final list = _filteredSales();
      if (list.isEmpty) return const Center(child: Text('No sales found'));

      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) => _saleTile(list[i]),
      );
    });
  }

  Widget _saleTile(SaleModel sale) {
    final badgeColor = sale.isPaid == 'paid'
        ? Colors.green
        : sale.isPaid == 'partial'
            ? Colors.orange
            : Colors.red;

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
        child: ListTile(
          leading: Icon(sale.isServicing ? Icons.build : Icons.shopping_cart),
          title: Text(sale.customerName),
          subtitle: Text(
              'Total: ${sale.totalAmount.toStringAsFixed(2)} | Paid: ${sale.paidAmount.toStringAsFixed(2)} | Remaining: ${sale.remainingAmount.toStringAsFixed(2)}'),
          trailing: Chip(
            label: Text(sale.isPaid.toUpperCase()),
            backgroundColor: badgeColor.withOpacity(0.15),
          ),
        ),
      ),
    );
  }

  // ---------------- SALE FORM ----------------
  void _openSaleDialog({SaleModel? sale}) {
    final stockCtrl = Get.find<StockController>();
    final isEdit = sale != null;

    controller.clearForm();
    if (isEdit) controller.fillForEdit(sale);

    Get.dialog(
      CustomFormDialog(
        title: isEdit ? 'Edit Sale' : 'Add Sale',
        isEditMode: isEdit,
        width: 0.9,
        height: 0.9,
        content: _saleForm(stockCtrl),
        onSave: () async {
          if (!_validateForm(controller.isServicing.value)) return;
          if (isEdit) {
            await controller.updateSale(sale.id!);
          } else {
            await controller.addSale();
          }
          Get.back();
        },
      ),
      barrierDismissible: false,
    );
  }

  bool _validateForm(bool isService) {
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

    if (isService) {
      if (controller.vehicleModelController.text.isEmpty ||
          controller.jobDoneOnVehicleController.text.isEmpty) {
        Get.snackbar('Error', 'Vehicle details are required');
        return false;
      }

      if (controller.receivedDate.value == null ||
          controller.deliveryDate.value == null) {
        Get.snackbar('Error', 'Received & Delivery dates are required');
        return false;
      }
    }

    return true;
  }

  // ---------------- FORM FIELDS ----------------
  Widget _saleForm(StockController stockCtrl) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _input(controller.billNoController, 'Bill No'),
          _input(controller.customerNameController, 'Customer Name'),
          _input(controller.contactNoController, 'Contact No'),
          Obx(() => SwitchListTile(
                title: const Text('Servicing Sale'),
                value: controller.isServicing.value,
                onChanged: (v) => controller.isServicing.value = v,
              )),
          const Divider(),
          Obx(() => controller.isServicing.value
              ? Column(children: _servicingFields())
              : const SizedBox.shrink()),
          const Divider(),
          _datePickerField('Sale Date', controller.saleDate, required: true),
          Obx(() => controller.isServicing.value
              ? _datePickerField('Received Date', controller.receivedDate,
                  required: true)
              : const SizedBox.shrink()),
          Obx(() => controller.isServicing.value
              ? _datePickerField('Delivery Date', controller.deliveryDate,
                  required: true)
              : const SizedBox.shrink()),
          const SizedBox(height: 10),
          const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              onPressed: () async {
                final selectedStock = await _selectStock(stockCtrl);
                if (selectedStock != null) {
                  controller.addItem(SaleItemModel.fromStock(selectedStock));
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Column(
                children: controller.selectedItems.map(_itemRow).toList(),
              )),
          const Divider(),
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Items Total: ${controller.itemsTotal.toStringAsFixed(2)}'),
                  if (controller.isServicing.value)
                    Text(
                        'Labour Charge: ${controller.labourCharge.toStringAsFixed(2)}'),
                  Text(
                      'Total Amount: ${controller.totalAmount.toStringAsFixed(2)}'),
                ],
              )),
          const SizedBox(height: 10),
          Obx(() => DropdownButtonFormField<int>(
                value: controller.handledBy.value,
                items: [
                  const DropdownMenuItem<int>(
                    value: 0,
                    child: Text('Select Staff',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  ...staffController.staffs.map(
                    (s) => DropdownMenuItem<int>(
                      value: s.id,
                      child: Text(s.name),
                    ),
                  ),
                ],
                onChanged: (v) => controller.handledBy.value = v ?? 0,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              )),
          const SizedBox(height: 10),
          _input(controller.paidAmountController, 'Paid Amount',
              type: TextInputType.number),
          _input(controller.remarksController, 'Remarks'),
        ],
      ),
    );
  }

  List<Widget> _servicingFields() => [
        _input(controller.vehicleModelController, 'Vehicle Model'),
        _input(controller.kmDrivenController, 'Km Driven',
            type: TextInputType.number),
        _input(controller.jobCardNoController, 'Job Card No'),
        _input(controller.bikeRegistrationController, 'Bike Registration No'),
        _input(controller.vehicleColorController, 'Vehicle Color'),
        _input(controller.jobDoneOnVehicleController, 'Job Done On Vehicle'),
        _input(controller.labourChargeController, 'Labour Charge',
            type: TextInputType.number),
        _checkbox('Free Servicing', controller.isFreeServicing),
        _checkbox('Repair Job', controller.isRepairJob),
        _checkbox('Accident', controller.isAccident),
        _checkbox('Warranty Job', controller.isWarrantyJob),
      ];

  Widget _itemRow(SaleItemModel item) {
    item.initControllerIfNull(); // Ensure controllers exist

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(flex: 3, child: Text(item.itemName)), // Item Name
            Expanded(
              flex: 2,
              child: TextField(
                controller: item.qtyController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Qty', isDense: true),
                onChanged: (_) {
                  item.recalculate();
                  controller.updateTotals();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: item.priceController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Rate', isDense: true),
                onChanged: (_) {
                  item.recalculate();
                  controller.updateTotals();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Obx(() => Text(
                  'Total: ${item.totalPrice.value.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => controller.removeItem(item),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _selectStock(StockController stockCtrl) async {
    final searchCtrl = TextEditingController();
    return showDialog(
      context: Get.context!,
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
                    final filtered = stockCtrl.stocks
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
                          onTap: () => Get.back(result: s),
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

  Widget _datePickerField(String label, Rx<DateTime?> dateField,
      {bool required = false}) {
    return Obx(() => InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: Get.context!,
              initialDate: dateField.value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) dateField.value = picked;
          },
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: required && dateField.value == null
                    ? Colors.red
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 10),
                Text(
                  dateField.value == null
                      ? '$label ${required ? "*" : ""}'
                      : dateField.value!.toIso8601String().split('T').first,
                  style: TextStyle(
                      color: required && dateField.value == null
                          ? Colors.red
                          : Colors.black),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _input(TextEditingController c, String label,
          {TextInputType type = TextInputType.text}) =>
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: TextField(
          controller: c,
          keyboardType: type,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      );
}

Widget _checkbox(String label, RxBool value) {
  return Obx(() => CheckboxListTile(
        title: Text(label),
        value: value.value,
        onChanged: (v) => value.value = v ?? false,
      ));
}
