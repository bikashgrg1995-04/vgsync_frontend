import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/models/bike_sale_model.dart';
import 'package:vgsync_frontend/app/modules/bikesales/bike_sale_controller.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import 'package:vgsync_frontend/utils/size_config.dart';

class BikeSaleDetailPage extends StatefulWidget {
  final BikeSale sale;

  const BikeSaleDetailPage({super.key, required this.sale});

  @override
  State<BikeSaleDetailPage> createState() => _BikeSaleDetailPageState();
}

class _BikeSaleDetailPageState extends State<BikeSaleDetailPage> {
  final BikeSaleController controller = Get.find<BikeSaleController>();
  final GlobalController globalController = Get.find<GlobalController>();

  @override
  void initState() {
    super.initState();
    // Fetch EMI trackers AFTER first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchEmiTrackers(widget.sale.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          // Reactive bike sale update
          final updatedSale = controller.bikeSales.firstWhere(
              (s) => s.id == widget.sale.id,
              orElse: () => widget.sale);

          return Column(
            children: [
              // ---------------- Header ----------------
              _buildHeader(updatedSale),

              SizedBox(height: SizeConfig.sh(0.01)),

              // ---------------- Sale Details ----------------
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: SizeConfig.sw(0.04)),
                  child: ListView(
                    children: [
                      _buildSaleDetailsCard(updatedSale),

                      SizedBox(height: SizeConfig.sh(0.015)),

                      // ---------------- EMI Tracker ----------------
                      if (updatedSale.isEmi ||
                          updatedSale.saleType == SaleType.downpayment)
                        _buildEmiCardSection(updatedSale.id),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ---------------- Header ----------------
  Widget _buildHeader(BikeSale sale) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.04), vertical: SizeConfig.sh(0.025)),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 25),
          ),
          SizedBox(width: SizeConfig.sw(0.03)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.customerName,
                  style: TextStyle(
                      fontSize: SizeConfig.sw(0.015),
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  sale.vehicleModel,
                  style: TextStyle(
                      fontSize: SizeConfig.sw(0.012), color: Colors.white70),
                ),
              ],
            ),
          ),
          Icon(
            sale.vehicleType == VehicleType.bike
                ? Icons.two_wheeler
                : Icons.electric_scooter,
            color: Colors.white,
            size: 28,
          ),
        ],
      ),
    );
  }

  // ---------------- Sale Details Card ----------------
  Widget _buildSaleDetailsCard(BikeSale sale) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.sw(0.01)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Sale Details",
                    style: TextStyle(
                        fontSize: SizeConfig.sw(0.012),
                        fontWeight: FontWeight.bold)),
                _infoRow("Sale Date",
                    sale.saleDate.toIso8601String().split('T').first),
                _infoRow("Status", "${sale.status.capitalizeFirst}"),
              ],
            ),
            Divider(),
            SizedBox(height: SizeConfig.sh(0.008)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: SizeConfig.sw(0.2),
                      child: Column(
                        children: [
                          Text("Customer Details",
                              style: TextStyle(
                                  fontSize: SizeConfig.sw(0.01),
                                  fontWeight: FontWeight.bold)),
                          Divider(),
                        ],
                      ),
                    ),
                    _infoRow("Customer Name",
                        sale.customerName.capitalizeFirst ?? ""),
                    _infoRow("Contact No", sale.contactNo),
                    _infoRow("Address", sale.address?.capitalizeFirst ?? "-"),
                  ],
                ),
                SizedBox(width: SizeConfig.sw(0.1)),
                Column(
                  children: [
                    SizedBox(
                      width: SizeConfig.sw(0.2),
                      child: Column(
                        children: [
                          Text("Vehicle Details",
                              style: TextStyle(
                                  fontSize: SizeConfig.sw(0.01),
                                  fontWeight: FontWeight.bold)),
                          Divider(),
                        ],
                      ),
                    ),
                    _infoRow("Vehicle Type",
                        sale.vehicleType.name.capitalizeFirst ?? ""),
                    _infoRow("Registration No", sale.registrationNo),
                    _infoRow("Vehicle Model",
                        sale.vehicleModel.capitalizeFirst ?? ""),
                    _infoRow("Chassis No", sale.chassisNo),
                    _infoRow("Engine No", sale.engineNo),
                  ],
                ),
                SizedBox(width: SizeConfig.sw(0.1)),
                Column(
                  children: [
                    SizedBox(
                      width: SizeConfig.sw(0.2),
                      child: Column(
                        children: [
                          Text("Payment Details",
                              style: TextStyle(
                                  fontSize: SizeConfig.sw(0.01),
                                  fontWeight: FontWeight.bold)),
                          Divider(),
                        ],
                      ),
                    ),
                    _infoRow(
                        "Sale Type", sale.saleType.name.capitalizeFirst ?? ""),
                    _infoRow(
                        "Net Total", "Rs. ${sale.netTotal.toStringAsFixed(0)}"),
                    sale.saleType.name.toString().toLowerCase() == "downpayment"
                        ? _infoRow("Initial Paid Amount",
                            "Rs. ${sale.initialPaidAmount.toDouble()}")
                        : SizedBox(),
                    _infoRow(
                        "Total Amount Paid", "Rs. ${sale.paidAmount.toDouble()}"),
                    _infoRow("Remaining",
                        "Rs. ${sale.remainingAmount.toStringAsFixed(0)}"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- EMI Card Section ----------------
  Widget _buildEmiCardSection(int saleId) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.sw(0.025)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final filteredList = controller.getFilteredEmis(saleId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header + total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("EMI Schedule",
                          style: TextStyle(
                              fontSize: SizeConfig.sw(0.012),
                              fontWeight: FontWeight.bold)),
                      Text(
                          "Total: ${filteredList.whereType<EmiTracker>().length}",
                          style: TextStyle(
                              fontSize: SizeConfig.sw(0.01),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700)),
                    ],
                  ),
                  Divider(),
                  SizedBox(height: SizeConfig.sh(0.008)),

                  // Filter buttons
                  Row(
                    children: [
                      _filterButton("All", controller.emiFilter.value == "all",
                          () {
                        controller.emiFilter.value = "all";
                      }),
                      SizedBox(width: SizeConfig.sw(0.01)),
                      _filterButton(
                          "Pending", controller.emiFilter.value == "pending",
                          () {
                        controller.emiFilter.value = "pending";
                      }),
                      SizedBox(width: SizeConfig.sw(0.01)),
                      _filterButton(
                          "Paid", controller.emiFilter.value == "paid", () {
                        controller.emiFilter.value = "paid";
                      }),
                    ],
                  ),
                  SizedBox(height: SizeConfig.sh(0.008)),

                  // EMI list
                  if (filteredList.isEmpty)
                    _emptyEmiCard()
                  else
                    Column(
                      children: filteredList.map((emi) {
                        if (emi == null) return _emptyEmiCard();
                        return _emiCard(emi);
                      }).toList(),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ---------------- Info Row ----------------
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConfig.sh(0.003)),
      child: Row(
        children: [
          SizedBox(
            width: SizeConfig.sw(0.1),
            child: Text("$label:",
                style: const TextStyle(color: Colors.black87, fontSize: 14)),
          ),
          SizedBox(width: SizeConfig.sw(0.005)),
          SizedBox(
            width: SizeConfig.sw(0.1),
            child: Text(value,
                textAlign: TextAlign.end,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ---------------- EMI Card ----------------
  Widget _emiCard(EmiTracker emi) {
    // ✅ Determine paid state based on actual amount
    final isPaid = emi.paidAmount >= emi.amountDue;
    final isPartial = emi.paidAmount > 0 && emi.paidAmount < emi.amountDue;
    final paidPercent = (emi.paidAmount / emi.amountDue).clamp(0.0, 1.0);

    Color indicatorColor;
    if (isPaid) {
      indicatorColor = Colors.green;
    } else if (isPartial) {
      indicatorColor = Colors.orange;
    } else {
      indicatorColor = Colors.orange.shade400;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: SizeConfig.sh(0.006)),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.sw(0.025)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Installment ${emi.installmentNo}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConfig.sw(0.012),
                        color: indicatorColor)),
                // ✅ Show Paid icon if fully paid, else show Pay button
                if (isPaid)
                  const Icon(Icons.check_circle, color: Colors.green)
                else if (!isPaid)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.sw(0.03),
                          vertical: SizeConfig.sh(0.02)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () =>
                        _showUpdateEmiDialog(Get.context!, emi, widget.sale.id),
                    child: Text('Pay',
                        style: TextStyle(fontSize: SizeConfig.sw(0.012))),
                  )
                else if (isPartial)
                  const Icon(Icons.remove_circle, color: Colors.orange),
              ],
            ),
            SizedBox(height: SizeConfig.sh(0.005)),
            LinearProgressIndicator(
              value: paidPercent,
              color: indicatorColor,
              backgroundColor: Colors.grey.shade300,
              minHeight: SizeConfig.sh(0.015),
            ),
            SizedBox(height: SizeConfig.sh(0.005)),
            Text(
                'Due: ${emi.dueDate.toIso8601String().split('T').first} | Amount: Rs. ${emi.amountDue.toDouble()} | Paid: Rs. ${emi.paidAmount.toDouble()}',
                style: TextStyle(
                    fontSize: SizeConfig.sw(0.01), color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  // ---------------- Empty EMI Placeholder ----------------
  Widget _emptyEmiCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      margin: EdgeInsets.symmetric(vertical: SizeConfig.sh(0.006)),
      child: Container(
        height: SizeConfig.sh(0.08),
        alignment: Alignment.center,
        child: const Text("No EMI"),
      ),
    );
  }

  // ---------------- Filter Button ----------------
  Widget _filterButton(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.sw(0.03), vertical: SizeConfig.sh(0.005)),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade600 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text,
            style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontSize: SizeConfig.sw(0.01),
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ---------------- UPDATE EMI DIALOG ----------------
  void _showUpdateEmiDialog(BuildContext context, EmiTracker emi, int saleId) {
    final controller = Get.find<BikeSaleController>();

    final amountController =
        TextEditingController(text: emi.paidAmount.toStringAsFixed(0));
    final paymentDateController = TextEditingController(
        text: (emi.paymentDate ?? DateTime.now())
            .toIso8601String()
            .split('T')
            .first);
    EMIPaymentMethod selectedMethod =
        emi.paymentMethod ?? EMIPaymentMethod.cash;

    // Dynamically determine initial status
    EmiStatus selectedStatus =
        emi.paidAmount >= emi.amountDue ? EmiStatus.paid : EmiStatus.pending;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Update EMI Payment #${emi.installmentNo}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Paid Amount
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Paid Amount'),
                  onChanged: (v) {
                    final value = double.tryParse(v) ?? 0.0;
                    setState(() {
                      selectedStatus = value >= emi.amountDue
                          ? EmiStatus.paid
                          : EmiStatus.pending;
                    });
                  },
                ),

                // Payment Date
                TextField(
                  controller: paymentDateController,
                  decoration: const InputDecoration(
                      labelText: 'Payment Date (YYYY-MM-DD)'),
                ),

                // Payment Method
                DropdownButton<EMIPaymentMethod>(
                  value: selectedMethod,
                  items: EMIPaymentMethod.values
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e.name)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedMethod = v);
                  },
                ),

                const SizedBox(height: 8),

                // Status display
                Row(
                  children: [
                    const Text("Status: "),
                    Chip(
                      label: Text(selectedStatus.name.toUpperCase()),
                      backgroundColor: selectedStatus == EmiStatus.paid
                          ? Colors.green
                          : Colors.orange,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),

              // Update Button
              Obx(() {
                final isLoading = controller.isEmiLoading.value;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final paidAmount =
                              double.tryParse(amountController.text) ??
                                  emi.paidAmount;
                          final paymentDate =
                              DateTime.tryParse(paymentDateController.text) ??
                                  DateTime.now();

                          // Call controller to update
                          await controller.updateEmiPayment(
                            emiId: emi.id,
                            paidAmount: paidAmount,
                            paymentDate: paymentDate,
                            paymentMethod: selectedMethod,
                            status: selectedStatus,
                            parentSaleId: saleId,
                          );

                          // Refresh lists
                          await controller.fetchBikeSales();
                          await controller.fetchEmiTrackers(saleId);
                          // Trigger global refresh for dashboards
                          globalController
                              .triggerRefresh(DashboardRefreshType.all);

                          // Close the update dialog
                          if (Get.isDialogOpen ?? false) {
                            Get.back(closeOverlays: true);
                          }

                          // Show success toast
                          DesktopToast.show(
                            "EMI Updated for ${paymentDate.toIso8601String().split('T').first}",
                            backgroundColor: Colors.greenAccent,
                          );

                          Navigator.pop(context);
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Update'),
                );
              }),
            ],
          );
        });
      },
    );
  }
}
