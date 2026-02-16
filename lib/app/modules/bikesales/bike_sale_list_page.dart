// app/modules/bikesales/bike_sale_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';

import 'package:vgsync_frontend/app/data/models/bike_sale_model.dart';
import 'package:vgsync_frontend/app/modules/bikesales/bike_sale_controller.dart';
import 'package:vgsync_frontend/app/modules/bikesales/bike_sale_detail_page.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_controller.dart';
import 'package:vgsync_frontend/app/wigdets/common_date_picker.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/app/wigdets/custom_form_dialog.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import 'package:vgsync_frontend/utils/size_config.dart';

class BikeSaleListPage extends StatefulWidget {
  const BikeSaleListPage({super.key});

  @override
  State<BikeSaleListPage> createState() => _BikeSaleListPageState();
}

class _BikeSaleListPageState extends State<BikeSaleListPage> {
  final BikeSaleController controller = Get.find();
  final GlobalController globalController = Get.find<GlobalController>();
  late final FollowUpController followUpController;

  final statuses = [
    {'label': 'All', 'value': 'all'},
    {'label': 'Paid', 'value': 'paid'},
    {'label': 'Pending', 'value': 'pending'},
  ];

  @override
  void initState() {
    super.initState();
    followUpController = Get.find<FollowUpController>();

    _loadData();
  }

  _loadData() async {
    await controller.fetchBikeSales(page: 1);
  }

  Future<void> _refresh() async => await controller.fetchBikeSales(page: 1);

  // ---------------- HEADER ----------------
  Widget _header() {
    return Card(
      margin: EdgeInsets.all(SizeConfig.res(4)),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.res(4)),
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
                      hintText: 'Search Bike Sales',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => controller.searchText.value = v,
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
                Obx(
                  () => actionButton(
                    label: 'Refresh',
                    icon: Icons.refresh,
                    onPressed:
                        controller.isLoading.value ? null : () => _refresh(),
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.sh(0.02)),
            Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: statuses
                        .map((s) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(s['label']!),
                                selected: controller.selectedStatus.value ==
                                    s['value'],
                                onSelected: (_) => controller
                                    .selectedStatus.value = s['value']!,
                                selectedColor: Colors.deepPurple,
                                labelStyle: TextStyle(
                                  color: controller.selectedStatus.value ==
                                          s['value']
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ---------------- FILTERED LIST ----------------
  List<BikeSale> _filteredSales() {
    final query = controller.searchText.value.toLowerCase();
    return controller.bikeSales.where((s) {
      if (controller.selectedStatus.value != 'all') {
        final pending = s.remainingAmount > 0;
        if (controller.selectedStatus.value == 'paid' && pending) return false;
        if (controller.selectedStatus.value == 'pending' && !pending) {
          return false;
        }
      }

      if (query.isNotEmpty &&
          !s.customerName.toLowerCase().contains(query) &&
          !s.vehicleModel.toLowerCase().contains(query) &&
          !s.registrationNo.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
  }

  // ---------------- SALE TILE ----------------
  Widget _saleTile(BikeSale sale) {
    final pending = sale.remainingAmount > 0;
    return GestureDetector(
      onTap: () {
        // Navigate to detail page
        Get.to(() => BikeSaleDetailPage(sale: sale));
      },
      child: Slidable(
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
              onPressed: (_) => _deleteSale(sale.id),
            ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.symmetric(
              horizontal: SizeConfig.sw(0.04), vertical: SizeConfig.sh(0.008)),
          child: ListTile(
            leading: Icon(
              sale.vehicleType == VehicleType.bike
                  ? Icons.two_wheeler
                  : Icons.electric_scooter,
              color: Colors.blue,
            ),
            title: Text("${sale.customerName} (${sale.vehicleModel})",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                "Total: Rs ${sale.netTotal.toStringAsFixed(0)} | Total Amount Paid: Rs ${sale.paidAmount.toStringAsFixed(0)} | Remaining: Rs ${sale.remainingAmount.toStringAsFixed(0)} | Payment: ${sale.paymentMethod.name.toUpperCase()}"),
            trailing: Chip(
              label: Text(pending ? "PENDING" : "PAID"),
              backgroundColor: pending ? Colors.orange : Colors.green,
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- ADD / EDIT DIALOG ----------------
  void _openSaleDialog({BikeSale? sale}) {
    final isEdit = sale != null;
    controller.clearForm();
    if (isEdit) controller.fillForm(sale);

    Get.dialog(
      Obx(() => CustomFormDialog(
            title: isEdit ? 'Edit Bike Sale' : 'Add Bike Sale',
            width: 0.8,
            height: 0.85,
            isEditMode: isEdit,
            isSaving: controller.isLoading.value,
            onSave: () async {
              if (!controller.validateForm()) return;
              if (isEdit) {
                await controller.updateBikeSale(sale.id);
              } else {
                await controller.createBikeSale();
              }
            },
            onDelete: isEdit ? () => _deleteSale(sale.id) : null,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------- SALE DATE ----------------
                  Text("Sale Date",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: SizeConfig.sh(0.01)),
                  SizedBox(
                    width: SizeConfig.sw(0.25),
                    child: CommonDatePicker(
                      label: "Select Sale Date",
                      selectedDate: controller.saleDate,
                      firstDate: DateTime(2000),
                    ),
                  ),
                  SizedBox(height: SizeConfig.sh(0.03)),

                  // ---------------- CUSTOMER DETAILS ----------------
                  Text("Customer Details",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: SizeConfig.sh(0.01)),
                  Row(
                    children: [
                      SizedBox(
                          width: SizeConfig.sw(0.25),
                          child: buildTextField(controller.customerController,
                              "Customer Name", Icons.person)),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      SizedBox(
                          width: SizeConfig.sw(0.25),
                          child: buildTextField(
                              controller.vehicleModelController,
                              "Vehicle Model",
                              Icons.directions_bike)),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      SizedBox(
                          width: SizeConfig.sw(0.2),
                          child: buildTextField(controller.contactController,
                              "Contact No", Icons.phone)),
                    ],
                  ),
                  SizedBox(height: SizeConfig.sh(0.02)),

                  // ---------------- VEHICLE DETAILS ----------------
                  Text("Vehicle Details",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: SizeConfig.sh(0.01)),
                  Row(
                    children: [
                      SizedBox(
                          width: SizeConfig.sw(0.2),
                          child: buildTextField(
                              controller.registrationController,
                              "Registration No",
                              Icons.confirmation_number)),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      SizedBox(
                          width: SizeConfig.sw(0.2),
                          child: buildTextField(controller.chassisController,
                              "Chassis No", Icons.production_quantity_limits)),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      SizedBox(
                          width: SizeConfig.sw(0.2),
                          child: buildTextField(controller.engineController,
                              "Engine No", Icons.engineering)),
                    ],
                  ),
                  SizedBox(height: SizeConfig.sh(0.02)),
                  Row(
                    children: [
                      SizedBox(
                          width: SizeConfig.sw(0.2),
                          child: buildTextField(controller.colorController,
                              "Color", Icons.color_lens)),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      SizedBox(
                          width: SizeConfig.sw(0.2),
                          child: buildTextField(controller.kmDrivenController,
                              "KM Driven", Icons.speed,
                              keyboardType: TextInputType.number)),
                    ],
                  ),
                  SizedBox(height: SizeConfig.sh(0.03)),

                  // ---------------- PAYMENT DETAILS ----------------
                  Text("Payment Details",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: SizeConfig.sh(0.01)),
                  Row(
                    children: [
                      // Sale Type Dropdown
                      SizedBox(
                        width: SizeConfig.sw(0.15),
                        child: Obx(() => DropdownButtonFormField<SaleType>(
                              value: controller.selectedSaleType.value,
                              items: SaleType.values
                                  .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.name.toUpperCase())))
                                  .toList(),
                              onChanged: (v) =>
                                  controller.selectedSaleType.value = v!,
                              decoration: const InputDecoration(
                                labelText: "Sale Type",
                                border: OutlineInputBorder(),
                              ),
                            )),
                      ),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      // Total Amount
                      SizedBox(
                        width: SizeConfig.sw(0.15),
                        child: buildTextField(controller.totalAmountController,
                            "Total Amount", Icons.money,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => controller.updateTotals()),
                      ),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      // Discount %
                      SizedBox(
                        width: SizeConfig.sw(0.1),
                        child: buildTextField(
                            controller.discountPercentController,
                            "Discount %",
                            Icons.percent,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => controller.updateTotals()),
                      ),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      // Discount Amount
                      SizedBox(
                        width: SizeConfig.sw(0.15),
                        child: buildTextField(controller.discountController,
                            "Discount Amount", Icons.money_off,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => controller.updateTotals()),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.sh(0.02)),
                  Row(
                    children: [
                      SizedBox(
                        width: SizeConfig.sw(0.15),
                        child: buildTextField(controller.netTotalController,
                            "Net Total", Icons.attach_money,
                            enabled: false),
                      ),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      SizedBox(
                        width: SizeConfig.sw(0.12),
                        child: buildTextField(
                            controller.paidAmountController,
                            controller.selectedSaleType.value ==
                                    SaleType.downpayment
                                ? "Total EMI Paid"
                                : "Paid Amount",
                            Icons.attach_money,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => controller.updateTotals()),
                      ),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      SizedBox(
                        width: SizeConfig.sw(0.12),
                        child: buildTextField(controller.remainingController,
                            "Remaining Amount", Icons.money_off,
                            enabled: false),
                      ),
                      SizedBox(width: SizeConfig.sw(0.02)),
                      Obx(() {
                        if (controller.selectedSaleType.value ==
                            SaleType.downpayment) {
                          return SizedBox(
                            width: SizeConfig.sw(0.12),
                            child: buildTextField(
                                controller.initialPaidController,
                                "Down Payment",
                                Icons.payment,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => controller.updateTotals()),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                  SizedBox(height: SizeConfig.sh(0.02)),

                  // ---------------- CONDITIONAL EMI ----------------
                  Obx(() {
                    if (controller.selectedSaleType.value == SaleType.emi ||
                        controller.selectedSaleType.value ==
                            SaleType.downpayment) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("EMI Details",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: SizeConfig.sh(0.01)),
                          Row(
                            children: [
                              SizedBox(
                                width: SizeConfig.sw(0.2),
                                child: buildTextField(
                                    controller.emiTenureController,
                                    "EMI Tenure (Months)",
                                    Icons.timer,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) =>
                                        controller.updateTotals()),
                              ),
                              SizedBox(width: SizeConfig.sw(0.02)),
                              SizedBox(
                                width: SizeConfig.sw(0.2),
                                child: buildTextField(
                                    controller.emiAmountController,
                                    "EMI Amount",
                                    Icons.attach_money,
                                    enabled: false),
                              ),
                            ],
                          ),
                          SizedBox(height: SizeConfig.sh(0.02)),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // ---------------- PAYMENT METHOD ----------------
                  SizedBox(
                    width: SizeConfig.sw(0.25),
                    child: Obx(() => DropdownButtonFormField<PaymentMethod>(
                          value: controller.selectedPaymentMethod.value,
                          items: PaymentMethod.values
                              .map((e) => DropdownMenuItem(
                                  value: e, child: Text(e.name.toUpperCase())))
                              .toList(),
                          onChanged: (v) =>
                              controller.selectedPaymentMethod.value = v!,
                          decoration: const InputDecoration(
                            labelText: "Payment Method",
                            border: OutlineInputBorder(),
                          ),
                        )),
                  ),
                  SizedBox(height: SizeConfig.sh(0.02)),

                  // ---------------- REMARKS ----------------
                  buildTextField(
                      controller.remarksController, "Remarks", Icons.note),
                ],
              ),
            ),
          )),
      barrierDismissible: false,
    );
  }

  // ---------------- DELETE ----------------
  void _deleteSale(int saleId) async {
    final success = await controller.deleteBikeSale(saleId);
    if (success) {
      followUpController.fetchFollowUps();
      globalController.triggerRefresh(DashboardRefreshType.all);

      Get.back(closeOverlays: true);
      globalController.triggerRefresh(DashboardRefreshType.all);
      DesktopToast.show(
        "Sale deleted successfully",
        backgroundColor: Colors.greenAccent,
      );
    } else {
      DesktopToast.show(
        "Failed to delete sale successfully",
        backgroundColor: Colors.redAccent,
      );
    }
  }

  Widget buildTextField(TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text,
      bool enabled = true,
      void Function(String)? onChanged}) {
    return TextField(
      controller: ctrl,
      enabled: enabled,
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder()),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSaleDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Bike Sale'),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered = _filteredSales();
          return Column(
            children: [
              _header(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: filtered.isEmpty
                      ? const Center(child: Text("No bike sales found"))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _saleTile(filtered[i]),
                        ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
