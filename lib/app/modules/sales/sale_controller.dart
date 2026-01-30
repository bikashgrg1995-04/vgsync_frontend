// app/modules/sales/sale_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/models/sale_model.dart';
import 'package:vgsync_frontend/app/data/repositories/sale_repository.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_controller.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';

class SaleItemController {
  final SaleItemModel item;
  final SalesController parentController; // 🔥 add reference

  final quantity = 1.obs;
  final price = 0.0.obs;
  final totalPrice = 0.0.obs;

  late TextEditingController quantityController;
  late TextEditingController priceController;

  SaleItemController({
    required this.item,
    required this.parentController, // 🔥 required
  }) {
    quantity.value = item.quantity;
    price.value = item.salePrice;
    totalPrice.value = item.quantity * item.salePrice;

    quantityController = TextEditingController(text: item.quantity.toString());
    priceController =
        TextEditingController(text: item.salePrice.toStringAsFixed(2));

    quantityController.addListener(_recalculate);
    priceController.addListener(_recalculate);
  }

  void _recalculate() {
    final q = int.tryParse(quantityController.text) ?? 1;
    final p = double.tryParse(priceController.text) ?? 0;

    quantity.value = q < 1 ? 1 : q;
    price.value = p < 0 ? 0 : p;
    totalPrice.value = quantity.value * price.value;

    parentController.updateTotals(); // 🔥 notify parent controller
  }

  SaleItemModel toModel() {
    return SaleItemModel(
      id: item.id,
      itemId: item.itemId,
      itemName: item.itemName,
      categoryName: item.categoryName,
      quantity: quantity.value,
      salePrice: price.value,
    );
  }

  void dispose() {
    quantityController.dispose();
    priceController.dispose();
  }
}

class SalesController extends GetxController {
  final SaleRepository saleRepository;

  SalesController({required this.saleRepository});

  final GlobalController globalController = Get.find();
  final StaffController staffController = Get.find();
  final StockController stockController = Get.find();
  final FollowUpController followUpController = Get.find();

  // ---------------- STATE ----------------
  final sales = <SaleModel>[].obs;
  final isLoading = false.obs;

  // ---------------- SEARCH ----------------
  final searchText = ''.obs;
  RxString selectedStatus = 'all'.obs;
  final searchController = TextEditingController();

  Rx<DateTime?> filterSelectedDate = Rx<DateTime?>(null);

  // ---------------- TEXT CONTROLLERS ----------------
  late TextEditingController customerNameController;
  late TextEditingController contactNoController;
  late TextEditingController vehicleModelController;
  late TextEditingController kmDrivenController;
  late TextEditingController jobCardNoController;
  late TextEditingController bikeRegistrationController;
  late TextEditingController vehicleColorController;
  late TextEditingController billNoController;
  late TextEditingController technicianNameController;
  late TextEditingController jobDoneOnVehicleController;
  late TextEditingController remarksController;
  late TextEditingController labourChargeController;
  late TextEditingController paidAmountController;

  // ---------------- FLAGS ----------------
  final isServicing = false.obs;
  final isFreeServicing = false.obs;
  final isRepairJob = false.obs;
  final isAccident = false.obs;
  final isWarrantyJob = false.obs;

  final saleDate = Rx<DateTime?>(null);
  final receivedDate = Rx<DateTime?>(null);
  final deliveryDate = Rx<DateTime?>(null);

  final followUpDate = Rx<DateTime?>(null); // 30 days after delivery
  final postServiceFeedbackDate = Rx<DateTime?>(null); // 3 days after delivery

  // ---------------- ITEMS ----------------
  final selectedItems = <SaleItemController>[].obs;

  // ---------------- TOTALS ----------------
  final itemsTotal = 0.0.obs;
  final labourCharge = 0.0.obs;
  final discountPercent = 0.0.obs;
  final discountAmount = 0.0.obs;
  final totalAmount = 0.0.obs;
  final remainingAmount = 0.0.obs;
  final netAmount = 0.0.obs;

  final paidFrom = 'cash'.obs; // default to 'cash'
  final saleStatus = 'not_paid'.obs;

  late TextEditingController discountController;

  // ---------------- LIFECYCLE ----------------
  @override
  void onReady() {
    super.onReady();
    _initControllers();
    fetchSales();

    // Default paidFrom
    if (!['cash', 'online', 'bank'].contains(paidFrom.value)) {
      paidFrom.value = 'cash';
    }
  }

  void _initControllers() {
    customerNameController = TextEditingController();
    contactNoController = TextEditingController();
    vehicleModelController = TextEditingController();
    kmDrivenController = TextEditingController();
    jobCardNoController = TextEditingController();
    bikeRegistrationController = TextEditingController();
    vehicleColorController = TextEditingController();
    billNoController = TextEditingController();
    technicianNameController = TextEditingController();
    jobDoneOnVehicleController = TextEditingController();
    remarksController = TextEditingController();
    labourChargeController = TextEditingController();
    paidAmountController = TextEditingController();

    labourChargeController.addListener(updateTotals);
    paidAmountController.addListener(updateTotals);

    discountController = TextEditingController();

    discountController.addListener(updateTotals);
  }

  @override
  void onClose() {
    // Dispose form controllers
    customerNameController.dispose();
    contactNoController.dispose();
    vehicleModelController.dispose();
    kmDrivenController.dispose();
    jobCardNoController.dispose();
    bikeRegistrationController.dispose();
    vehicleColorController.dispose();
    billNoController.dispose();
    technicianNameController.dispose();
    jobDoneOnVehicleController.dispose();
    remarksController.dispose();
    labourChargeController.dispose();
    paidAmountController.dispose();
    discountController.dispose();

    // Dispose all selected item controllers
    for (final itemController in selectedItems) {
      itemController.dispose();
    }
    selectedItems.clear();

    super.onClose();
  }

  // ---------------- FETCH ----------------
  Future<void> fetchSales() async {
    try {
      isLoading.value = true;
      sales.value = await saleRepository.getSales();
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- CALCULATIONS ----------------
  void updateTotals() {
    // ---------- ITEMS TOTAL ----------
    itemsTotal.value =
        selectedItems.fold(0.0, (sum, e) => sum + e.totalPrice.value);

    // ---------- LABOUR ----------
    labourCharge.value = double.tryParse(labourChargeController.text) ?? 0;
    if (labourCharge.value < 0) labourCharge.value = 0;

    // ---------- DISCOUNT ----------
    double discount = double.tryParse(discountController.text) ?? 0;
    if (discount < 0) discount = 0;
    discountPercent.value = discount;

    discountAmount.value =
        (itemsTotal.value + labourCharge.value) * discount / 100;

    // ---------- TOTAL & NET ----------
    totalAmount.value = itemsTotal.value + labourCharge.value;
    netAmount.value = totalAmount.value - discountAmount.value;

    // ---------- PAID & REMAINING ----------
    double paid = double.tryParse(paidAmountController.text) ?? 0;
    if (paid < 0) paid = 0;
    if (paid > netAmount.value) paid = netAmount.value;

    remainingAmount.value = netAmount.value - paid;

    // ---------- STATUS ----------
    saleStatus.value = SaleModel.resolvePaidStatus(netAmount.value, paid);
  }

  void updateDerivedDates() {
    if (deliveryDate.value != null) {
      postServiceFeedbackDate.value =
          deliveryDate.value!.add(const Duration(days: 3));
      followUpDate.value = deliveryDate.value!.add(const Duration(days: 30));
    } else {
      postServiceFeedbackDate.value = null;
      followUpDate.value = null;
    }
  }

  // ---------------- ITEM HANDLING ----------------
  void addItem(SaleItemModel item) {
    if (selectedItems.any((e) => e.item.itemId == item.itemId)) {
      DesktopToast.show(
        'Item already added',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    if (item.quantity == 0) {
      DesktopToast.show(
        'This item is Out of Stock',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    final controller = SaleItemController(
      item: item.copy(resetQuantity: true), // quantity starts at 1
      parentController: this,
    );
    selectedItems.add(controller);
    updateTotals();
  }

  void removeItem(SaleItemController itemController) {
    selectedItems.remove(itemController);
    itemController.dispose();
    updateTotals();
  }

  // ---------------- ADD SALE ----------------
  Future<bool> addSale() async {
    if (!validateForm()) return false; // <- return bool

    final sale = _buildSale();

    try {
      isLoading.value = true;
      final created = isServicing.value
          ? await saleRepository.createServicingSale(
              sale
            )
          : await saleRepository.createStockSale(
              sale
            );

      sales.add(created);
      _postRefresh();
      return true; // success
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- UPDATE SALE ----------------
  Future<bool> updateSale(int saleId) async {
    if (!validateForm()) return false;

    final index = sales.indexWhere((e) => e.id == saleId);
    if (index == -1) return false;

    final updated = _buildSale(id: saleId);

    try {
      isLoading.value = true;
      final result = await saleRepository.updateSale(updated);
      sales[index] = result;
      _postRefresh();
      return true;
    } finally {
      isLoading.value = false;
    }
  }

// ---------------- DELETE SALE WITH CONFIRM DIALOG ----------------
  Future<void> deleteSale(BuildContext context, int saleId) async {
    ConfirmDialog.show(
      context,
      title: "Delete Sale",
      message: "Are you sure you want to delete this Sale?",
      onConfirm: () async {
        final index = sales.indexWhere((e) => e.id == saleId);
        if (index == -1) {
          DesktopToast.show(
            "Sale not found",
            backgroundColor: Colors.redAccent,
          );
          return;
        }

        try {
          isLoading.value = true;
          await saleRepository.deleteSale(saleId);
          sales.removeAt(index);
          _postRefresh();
          globalController.triggerRefresh(DashboardRefreshType.all);

          Get.back(closeOverlays: true); // close confirm dialog
          DesktopToast.show(
            "Sale deleted successfully",
            backgroundColor: Colors.greenAccent,
          );
        } catch (e) {
          DesktopToast.show(
            "Failed to delete sale: $e",
            backgroundColor: Colors.redAccent,
          );
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  Future<void> refreshSales() async {
    // 🔥 RESET FILTERS

    filterSelectedDate.value = null;
    searchText.value = '';
    searchController.clear(); // 🔥 VERY IMPORTANT
    selectedStatus.value = "all";

    await fetchSales();
  }

  void fillForEdit(SaleModel sale) {
    // ---------------- FILL FORM ----------------
    customerNameController.text = sale.customerName;
    contactNoController.text = sale.contactNo ?? '';
    vehicleModelController.text = sale.vehicleModel ?? '';
    kmDrivenController.text = sale.kmDriven?.toString() ?? '';
    jobCardNoController.text = sale.jobCardNo ?? '';
    bikeRegistrationController.text = sale.bikeRegistrationNo ?? '';
    vehicleColorController.text = sale.vehicleColor ?? '';
    billNoController.text = sale.billNo ?? '';
    technicianNameController.text = sale.technicianName ?? '';
    jobDoneOnVehicleController.text = sale.jobDoneOnVehicle ?? '';
    remarksController.text = sale.remarks ?? '';
    labourChargeController.text = sale.labourCharge.toStringAsFixed(2);
    paidAmountController.text = sale.paidAmount.toStringAsFixed(2);

    isServicing.value = sale.isServicing;
    isFreeServicing.value = sale.isFreeServicing;
    isRepairJob.value = sale.isRepairJob;
    isAccident.value = sale.isAccident;
    isWarrantyJob.value = sale.isWarrantyJob;

    saleDate.value = sale.saleDate;
    receivedDate.value = sale.receivedDate;
    deliveryDate.value = sale.deliveryDate;

    // ---------------- FILL ITEMS ----------------
    selectedItems.clear();
    for (var item in sale.items) {
      final controller = SaleItemController(
        item: item.copy(), // uses actual quantity
        parentController: this,
      );
      selectedItems.add(controller);
    }

    // ---------------- UPDATE TOTALS ----------------
    updateTotals();
  }

  // ---------------- BUILD MODEL ----------------
  SaleModel _buildSale({int? id}) {
    final paid = double.tryParse(paidAmountController.text) ?? 0;
    final discount = discountPercent.value;
    final discountAmt = discountAmount.value;
    final net = netAmount.value;
    final remaining = remainingAmount.value;

    return SaleModel(
      id: id,
      saleDate: saleDate.value ?? DateTime.now(),
      customerName: customerNameController.text,
      contactNo: contactNoController.text,
      billNo: billNoController.text,
      remarks: remarksController.text,
      isServicing: isServicing.value,

      // ---------- ITEMS ----------
      items: selectedItems.map((e) => e.toModel()).toList(),

      // ---------- TOTALS ----------
      grandTotal: itemsTotal.value + labourCharge.value,
      discountPercentage: discount,
      discountAmount: discountAmt,
      netTotal: net,
      paidAmount: paid,
      remainingAmount: remaining,
      isPaid: SaleModel.resolvePaidStatus(net, paid),

      // ---------- STOCK / SERVICING ----------
      vehicleModel: vehicleModelController.text,
      kmDriven: int.tryParse(kmDrivenController.text),
      jobCardNo: jobCardNoController.text,
      bikeRegistrationNo: bikeRegistrationController.text,
      vehicleColor: vehicleColorController.text,
      labourCharge: labourCharge.value,
      technicianName: technicianNameController.text,
      jobDoneOnVehicle: jobDoneOnVehicleController.text,

      receivedDate: receivedDate.value,
      deliveryDate: deliveryDate.value,
    );
  }

  // ---------------- CLEAR ----------------
  void clearForm() {
    customerNameController.clear();
    contactNoController.clear();
    vehicleModelController.clear();
    kmDrivenController.clear();
    jobCardNoController.clear();
    bikeRegistrationController.clear();
    vehicleColorController.clear();
    billNoController.clear();
    technicianNameController.clear();
    jobDoneOnVehicleController.clear();
    remarksController.clear();
    labourChargeController.clear();
    paidAmountController.clear();

    isServicing.value = false;
    isFreeServicing.value = false;
    isRepairJob.value = false;
    isAccident.value = false;
    isWarrantyJob.value = false;

    saleDate.value = null;
    receivedDate.value = null;
    deliveryDate.value = null;

    for (final i in selectedItems) {
      i.dispose();
    }
    selectedItems.clear();

    itemsTotal.value = 0;
    totalAmount.value = 0;
    remainingAmount.value = 0;
  }

  // ---------------- REFRESH ----------------
  void _postRefresh() {
    stockController.fetchStocks();
    followUpController.fetchFollowUps();
    globalController.triggerRefresh(DashboardRefreshType.all);
  }

  // ---------------- VALIDATION ----------------
  bool validateForm() {
    if (customerNameController.text.isEmpty) {
      DesktopToast.show(
        'Customer name required',
        backgroundColor: Colors.redAccent,
      );
      return false;
    }
    if (saleDate.value == null) {
      DesktopToast.show(
        'Sale date required',
        backgroundColor: Colors.redAccent,
      );

      return false;
    }
    // if (handledBy.value == 0) {
    //   DesktopToast.show(
    //     'Select staff',
    //     backgroundColor: Colors.redAccent,
    //   );
    //   return false;
    // }
    if (selectedItems.isEmpty) {
      DesktopToast.show(
        'Add at least one item',
        backgroundColor: Colors.redAccent,
      );

      return false;
    }
    if (isServicing.value == true && deliveryDate.value == null) {
      DesktopToast.show(
        'Delivery date is required for servicing',
        backgroundColor: Colors.redAccent,
      );
      return false;
    }
    return true;
  }
}
