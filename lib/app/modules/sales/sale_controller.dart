import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/models/sale_model.dart';
import 'package:vgsync_frontend/app/data/repositories/sale_repository.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_controller.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';

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
  final handledBy = 0.obs;

  final followUpDate = Rx<DateTime?>(null); // 30 days after delivery
  final postServiceFeedbackDate = Rx<DateTime?>(null); // 3 days after delivery

  // ---------------- ITEMS ----------------
  final selectedItems = <SaleItemModel>[].obs;

  // ---------------- TOTALS ----------------
  final itemsTotal = 0.0.obs;
  final labourCharge = 0.0.obs;
  final vatPercent = 13.0.obs;
  final vatAmount = 0.0.obs;
  final discountPercent = 0.0.obs;
  final discountAmount = 0.0.obs;
  final totalAmount = 0.0.obs;
  final remainingAmount = 0.0.obs;
  final netAmount = 0.0.obs;

  final paidFrom = 'cash'.obs; // default to 'cash'
  final saleStatus = 'not_paid'.obs;

  late TextEditingController discountController;
  late TextEditingController vatController;

  // ---------------- LIFECYCLE ----------------
  @override
  void onReady() {
    super.onReady();
    _initControllers();
    fetchSales();
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
    vatController = TextEditingController();

    discountController.addListener(updateTotals);
    vatController.addListener(updateTotals);
  }

  @override
  void onClose() {
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
    vatController.dispose();
    for (final i in selectedItems) {
      i.dispose();
    }
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

    // ---------- VAT ----------
    double vat = double.tryParse(vatController.text) ?? vatPercent.value;
    vatPercent.value = vat;

    double subTotal =
        itemsTotal.value + labourCharge.value - discountAmount.value;
    vatAmount.value = subTotal * vat / 100;

    // ---------- TOTAL & NET ----------
    netAmount.value = subTotal + vatAmount.value;
    totalAmount.value =
        itemsTotal.value + labourCharge.value; // optional display if needed

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
    if (selectedItems.any((e) => e.itemId == item.itemId)) {
      Get.snackbar('Info', 'Item already added');
      return;
    }

    final copy = item.copy();
    copy.initControllerIfNull();
    selectedItems.add(copy);
    updateTotals();
  }

  void removeItem(SaleItemModel item) {
    selectedItems.remove(item);
    item.dispose();
    updateTotals();
  }

  // ---------------- ADD SALE ----------------
  Future<void> addSale() async {
    if (!_validateForm()) return;

    final sale = _buildSale();

    try {
      isLoading.value = true;
      final created = isServicing.value
          ? await saleRepository.createServicingSale(
              sale,
              handledBy: handledBy.value,
            )
          : await saleRepository.createStockSale(
              sale,
              handledBy: handledBy.value,
            );

      sales.add(created);
      _postRefresh();
      clearForm();
      Get.back();
      Get.snackbar('Success', 'Sale added');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- UPDATE SALE ----------------
  Future<void> updateSale(int saleId) async {
    if (!_validateForm()) return;

    final index = sales.indexWhere((e) => e.id == saleId);
    if (index == -1) return;

    final updated = _buildSale(id: saleId);

    try {
      isLoading.value = true;
      final result = await saleRepository.updateSale(updated);
      sales[index] = result;
      _postRefresh();
      clearForm();
      Get.back();
      Get.snackbar('Success', 'Sale updated');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- DELETE SALE ----------------
  Future<void> deleteSale(int saleId) async {
    final index = sales.indexWhere((e) => e.id == saleId);
    if (index == -1) return;

    try {
      isLoading.value = true;
      await saleRepository.deleteSale(saleId);
      sales.removeAt(index);
      _postRefresh();
      Get.snackbar('Success', 'Sale deleted');
    } finally {
      isLoading.value = false;
    }
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
    handledBy.value = sale.handledBy ?? 0;

    // ---------------- FILL ITEMS ----------------
    selectedItems.clear();
    for (var item in sale.items) {
      final copy = item.copy();
      copy.initControllerIfNull();
      selectedItems.add(copy);
    }

    // ---------------- UPDATE TOTALS ----------------
    updateTotals();
  }

  // ---------------- BUILD MODEL ----------------
  SaleModel _buildSale({int? id}) {
    final paid = double.tryParse(paidAmountController.text) ?? 0;
    final discount = discountPercent.value;
    final discountAmt = discountAmount.value;
    final vat = vatPercent.value;
    final vatAmt = vatAmount.value;
    final net = netAmount.value;
    final remaining = remainingAmount.value;

    return SaleModel(
      id: id,
      saleDate: saleDate.value ?? DateTime.now(),
      customerName: customerNameController.text,
      contactNo: contactNoController.text,
      handledBy: handledBy.value,
      billNo: billNoController.text,
      remarks: remarksController.text,
      isServicing: isServicing.value,

      // ---------- ITEMS ----------
      items: selectedItems.map((e) => e.copy()).toList(),

      // ---------- TOTALS ----------
      grandTotal: itemsTotal.value + labourCharge.value,
      discountPercentage: discount,
      discountAmount: discountAmt,
      vatPercentage: vat,
      vatAmount: vatAmt,
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
    handledBy.value = 0;

    for (final i in selectedItems) {
      i.dispose();
    }
    selectedItems.clear();

    itemsTotal.value = 0;
    vatAmount.value = 0;
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
  bool _validateForm() {
    if (customerNameController.text.isEmpty) {
      Get.snackbar('Error', 'Customer name required');
      return false;
    }
    if (saleDate.value == null) {
      Get.snackbar('Error', 'Sale date required');
      return false;
    }
    if (handledBy.value == 0) {
      Get.snackbar('Error', 'Select staff');
      return false;
    }
    if (selectedItems.isEmpty) {
      Get.snackbar('Error', 'Add at least one item');
      return false;
    }
    if (isServicing.value == true && deliveryDate.value == null) {
      Get.snackbar('Error', 'Delivery date is required for servicing');
      return false;
    }
    return true;
  }
}
