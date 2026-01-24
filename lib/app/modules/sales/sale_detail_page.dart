// app/modules/sales/sale_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/sale_model.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_controller.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';
import 'package:vgsync_frontend/app/wigdets/custom_form_dialog.dart';
import 'package:vgsync_frontend/utils/size_config.dart';

class SaleDetailPage extends StatelessWidget {
  final SaleModel sale;

  SaleDetailPage({super.key, required this.sale});

  final SalesController controller = Get.find();
  final StaffController staffController = Get.find<StaffController>();
  final StockController stockController = Get.find<StockController>();

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _openSaleDialog(context, sale: sale);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => controller.deleteSale(context, sale.id!),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeConfig.res(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryCard(),
            const SizedBox(height: 16),
            _itemsCard(),
            _calculationSummary(),
          ],
        ),
      ),
    );
  }

  // ---------------- SUMMARY ----------------
  Widget _summaryCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Date', sale.saleDate.toIso8601String().split('T').first),
            _row('Bill No', sale.billNo ?? '-'),
            _row('Customer', sale.customerName.capitalizeFirst ?? ""),
            _row('Contact Number', sale.contactNo.toString()),
            _row(
                'Handled By',
                staffController.staffs
                    .where((v) => v.id == sale.handledBy)
                    .first
                    .name
                    .toString()),
            const Divider(),
            if (sale.isServicing) ...[
              const SizedBox(height: 16),
              _servicingCard(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _calculationSummary() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Grand Total', sale.grandTotal.toStringAsFixed(2)),
            _row('Discount', '${sale.discountPercentage}%'),
            _row('Net Total', sale.netTotal.toStringAsFixed(2)),
            _row('Paid', sale.paidAmount.toStringAsFixed(2)),
            _row('Remaining', sale.remainingAmount.toStringAsFixed(2)),
            _row(
              'Status',
              sale.isPaid.replaceAll('_', ' ').toUpperCase(),
              color: _statusColor(sale.isPaid),
            ),
          ],
        ),
      ),
    );
  }

// ---------------- ITEMS ----------------
  Widget _itemsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...sale.items.map(
              (i) => ListTile(
                title: Text(i.itemName),
                subtitle: Text(
                    'Qty: ${i.quantity} × ${i.salePrice.toStringAsFixed(2)}'),
                trailing: Text(
                  (i.quantity * i.salePrice).toStringAsFixed(2),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- SERVICING ----------------
  Widget _servicingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Servicing Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _row('Vehicle Model', sale.vehicleModel ?? '-'),
            _row('KM Driven', sale.kmDriven?.toString() ?? '-'),
            _row('Job Card No', sale.jobCardNo ?? '-'),
            _row('Bike Reg No', sale.bikeRegistrationNo ?? '-'),
            _row('Technician', sale.technicianName ?? '-'),
            _row('Labour Charge', sale.labourCharge.toStringAsFixed(2)),
            _row(
              'Delivery Date',
              sale.deliveryDate?.toIso8601String().split('T').first ?? '-',
            ),
          ],
        ),
      ),
    );
  }

  // // ---------------- DELETE ----------------
  // void _confirmDelete() {
  //   Get.dialog(
  //     AlertDialog(
  //       title: const Text('Delete Sale'),
  //       content: const Text('Are you sure you want to delete this sale?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //           onPressed: () async {
  //             await controller.deleteSale(sale.id!);
  //             Get.back(); // dialog
  //             Get.back(); // page
  //           },
  //           child: const Text('Delete'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ---------------- HELPERS ----------------
  Widget _row(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    if (status == 'paid') return Colors.green;
    if (status == 'partial') return Colors.orange;
    return Colors.red;
  }

  // ---------------- ADD / EDIT SALE ----------------
  void _openSaleDialog(BuildContext context, {SaleModel? sale}) {
    final isEdit = sale != null;

    controller.clearForm();
    if (isEdit) controller.fillForEdit(sale);

    controller.isServicing.value = sale?.isServicing ?? false;

    // ---------- Observables ----------
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

    controller.updateTotals(); // recalc grand, net, remaining

    Get.dialog(
      CustomFormDialog(
        title: isEdit ? 'Edit Sale' : 'Add Sale',
        isEditMode: isEdit,
        width: 0.6,
        height: 0.9,
        content: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: SizeConfig.sh(0.02),
              ),

              Row(
                children: [
                  SizedBox(
                      width: SizeConfig.sw(0.1),
                      child: _buildTextField(
                          'Bill No', controller.billNoController)),
                  SizedBox(
                    width: SizeConfig.sw(0.02),
                  ),
                  SizedBox(
                    width: SizeConfig.sw(0.2),
                    child: _buildTextField(
                        'Customer Name', controller.customerNameController),
                  ),
                  SizedBox(
                    width: SizeConfig.sw(0.02),
                  ),
                  SizedBox(
                    width: SizeConfig.sw(0.15),
                    child: _buildTextField(
                        'Contact No', controller.contactNoController),
                  ),
                ],
              ),

              SizedBox(
                height: SizeConfig.sh(0.02),
              ),

              Row(
                children: [
                  SizedBox(
                    width: SizeConfig.sw(0.1),
                    child: _datePickerField(
                        context, 'Sale Date', controller.saleDate,
                        required: true),
                  ),
                  SizedBox(
                    width: SizeConfig.sw(0.02),
                  ),
                  SizedBox(
                    width: SizeConfig.sw(0.15),
                    child: Obx(() {
                      if (staffController.staffs.isEmpty) {
                        return const SizedBox();
                      }

                      // Auto-select first if not selected
                      if (staffSelected.value == 0) {
                        staffSelected.value = staffController.staffs.first.id!;
                      }

                      return DropdownButtonFormField<int>(
                        value: staffSelected.value,
                        items: staffController.staffs
                            .map((s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Text(s.name),
                                ))
                            .toList(),
                        onChanged: (v) => staffSelected.value = v ?? 0,
                        decoration: const InputDecoration(
                          labelText: "Staff",
                          border: OutlineInputBorder(),
                        ),
                      );
                    }),
                  ),
                  SizedBox(
                    width: SizeConfig.sw(0.02),
                  ),
                  SizedBox(
                    width: SizeConfig.sw(0.15),
                    child: Obx(
                      () => SwitchListTile(
                        title: const Text('Servicing Sale'),
                        value: controller.isServicing.value,
                        onChanged: (v) => controller.isServicing.value = v,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: SizeConfig.sh(0.02),
              ),

              // ================= SERVICING SECTION =================
              Obx(() {
                if (!controller.isServicing.value) return const SizedBox();

                return Card(
                  margin: const EdgeInsets.only(top: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------- Header ----------
                        Row(
                          children: const [
                            Icon(Icons.build, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Servicing Details',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ---------- Vehicle Info ----------
                        _sectionTitle("Vehicle Information"),
                        _twoColumnRow(
                          _buildTextField('Vehicle Model',
                              controller.vehicleModelController),
                          _buildTextField('Vehicle Color',
                              controller.vehicleColorController),
                        ),
                        const SizedBox(height: 8),
                        _twoColumnRow(
                          _buildTextField(
                              'KM Driven', controller.kmDrivenController,
                              keyboardType: TextInputType.number),
                          _buildTextField('Bike Reg. No',
                              controller.bikeRegistrationController),
                        ),

                        const SizedBox(height: 16),

                        // ---------- Job Info ----------
                        _sectionTitle("Job Details"),
                        _twoColumnRow(
                          _buildTextField(
                              'Job Card No', controller.jobCardNoController),
                          _buildTextField('Technician',
                              controller.technicianNameController),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField('Job Done On Vehicle',
                            controller.jobDoneOnVehicleController),

                        const SizedBox(height: 16),

                        // ---------- Charges & Dates ----------
                        _sectionTitle("Charges & Dates"),
                        _twoColumnRow(
                          _buildTextField(
                            'Labour Charge',
                            controller.labourChargeController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => controller.updateTotals(),
                          ),
                          _datePickerField(context, 'Received Date',
                              controller.receivedDate),
                        ),
                        const SizedBox(height: 8),
                        _twoColumnRow(
                          _datePickerField(
                            context,
                            'Delivery Date',
                            controller.deliveryDate,
                            required: true,
                          ),
                          _readonlyDateField(
                              'Follow Up Date', controller.followUpDate),
                        ),
                        const SizedBox(height: 8),
                        _readonlyDateField('Post Service Feedback Date',
                            controller.postServiceFeedbackDate),

                        const SizedBox(height: 16),

                        // ---------- Service Flags ----------
                        _sectionTitle("Service Type"),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            _serviceCheck(
                              'Free Servicing',
                              controller.isFreeServicing,
                            ),
                            _serviceCheck(
                              'Repair Job',
                              controller.isRepairJob,
                            ),
                            _serviceCheck(
                              'Accident Case',
                              controller.isAccident,
                            ),
                            _serviceCheck(
                              'Warranty Job',
                              controller.isWarrantyJob,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              SizedBox(
                height: SizeConfig.sh(0.02),
              ),

              Container(
                height: SizeConfig.sh(0.3),
                width: double.infinity,
                padding: EdgeInsets.all(
                    SizeConfig.sw(0.015)), // optional inner padding
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade400, // border color
                    width: 1, // border thickness
                  ),
                  borderRadius: BorderRadius.circular(12), // rounded corners
                ),
                child: Obx(
                  () => Column(
                    children: controller.selectedItems
                        .map((c) => _itemRow(c))
                        .toList(),
                  ),
                ),
              ),

              SizedBox(
                height: SizeConfig.sh(0.02),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: SizeConfig.sw(0.4),
                    child: _buildTextField(
                        'Remarks', controller.remarksController,
                        keyboardType: TextInputType.text),
                  ),
                  // ---------- Items ----------
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                    onPressed: () async {
                      final selectedStock = await _selectStock(context);
                      if (selectedStock != null) {
                        controller
                            .addItem(SaleItemModel.fromStock(selectedStock));
                        controller.updateTotals();
                      }
                    },
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.sh(0.02),
              ),
              _buildSaleTotalsCard(),
            ],
          ),
        ),
        onSave: () async {
          if (controller.validateForm()) return;

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
                await controller.deleteSale(context, sale.id!);
                Get.back();
              }
            : null,
      ),
      barrierDismissible: false,
    );
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _twoColumnRow(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _serviceCheck(String title, RxBool value) {
    return Obx(() => FilterChip(
          label: Text(title),
          selected: value.value,
          onSelected: (v) => value.value = v,
          selectedColor: Colors.blue.shade100,
        ));
  }

  Widget _datePickerField(
      BuildContext context, String label, Rx<DateTime?> dateField,
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

  Widget _buildSaleTotalsCard() {
    final paidFromOptions = ['cash', 'online', 'bank'];
    return Obx(
      () => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: EdgeInsets.symmetric(
          vertical: SizeConfig.sh(0.01),
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
              height: SizeConfig.sh(0.2),
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
                            controller.totalAmount.toStringAsFixed(2),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(width: SizeConfig.sw(0.05)),

                      // Discount % + Amount
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
                                  decoration:
                                      const InputDecoration(isDense: true),
                                  onChanged: (_) => controller.updateTotals(),
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
                            controller.netAmount.toStringAsFixed(2),
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
                              controller: controller.paidAmountController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(isDense: true),
                              onChanged: (_) => controller.updateTotals(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: SizeConfig.sh(0.01)),

                  // ---------- Bottom Row ----------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Remaining
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Remaining',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          SizedBox(height: SizeConfig.sh(0.005)),
                          Text(
                            controller.remainingAmount.toStringAsFixed(2),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(width: SizeConfig.sw(0.04)),

                      // Paid From Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Paid From',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          SizedBox(height: SizeConfig.sh(0.005)),
                          SizedBox(
                            width: SizeConfig.sw(0.1),
                            child: DropdownButtonFormField<String>(
                              value: paidFromOptions
                                      .contains(controller.paidFrom.value)
                                  ? controller.paidFrom.value
                                  : null,
                              items: paidFromOptions
                                  .map((p) => DropdownMenuItem(
                                        value: p,
                                        child: Text(p.toUpperCase()),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                controller.paidFrom.value = v ?? 'cash';
                              },
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 10),
                                border: OutlineInputBorder(),
                              ),
                            ),
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
                            controller.saleStatus.value
                                .replaceAll("_", " ")
                                .toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: controller.saleStatus.value == 'paid'
                                  ? Colors.green
                                  : controller.saleStatus.value == 'partial'
                                      ? Colors.orange
                                      : Colors.red,
                            ),
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

  Future<dynamic> _selectStock(BuildContext context) async {
    final searchCtrl = TextEditingController();
    return showDialog(
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
                                      style: const TextStyle(fontSize: 14),
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
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Selling: ${s.salePrice.toStringAsFixed(2)}",
                                          style: const TextStyle(fontSize: 14),
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
  }

  Widget _itemRow(SaleItemController controller) {
    final item = controller.item;

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
                controller: controller.quantityController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Qty', isDense: true),
                onChanged: (_) => controller.parentController.updateTotals(),
              ),
            ),
            Expanded(
              flex: 2,
              child: TextField(
                controller: controller.priceController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Rate', isDense: true),
                onChanged: (_) => controller.parentController.updateTotals(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Obx(() => Text(
                    'Total: ${controller.totalPrice.value.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  controller.parentController.removeItem(controller),
            ),
          ],
        ),
      ),
    );
  }
}
