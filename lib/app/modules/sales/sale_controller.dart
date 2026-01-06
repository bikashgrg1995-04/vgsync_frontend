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

  // ---------------- OBSERVABLES ----------------
  final sales = <SaleModel>[].obs;
  final isLoading = false.obs;

  // ---------------- SEARCH ----------------
  final searchText = ''.obs;

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

  // ---------------- ITEMS & TOTALS ----------------
  final selectedItems = <SaleItemModel>[].obs;

  final itemsTotal = 0.0.obs;
  final labourCharge = 0.0.obs;
  final totalAmount = 0.0.obs;
  final remainingAmount = 0.0.obs;

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

    for (final item in selectedItems) {
      item.dispose();
    }
    super.onClose();
  }

  // ---------------- FETCH ----------------
  Future<void> fetchSales() async {
    try {
      isLoading.value = true;
      sales.value = await saleRepository.getSales();
      print(sales.first.items.first.itemName);
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- TOTALS ----------------
  void updateTotals() {
    itemsTotal.value =
        selectedItems.fold(0.0, (s, e) => s + e.totalPrice.value);

    labourCharge.value = double.tryParse(labourChargeController.text) ?? 0.0;

    final paid = double.tryParse(paidAmountController.text) ?? 0.0;

    totalAmount.value = itemsTotal.value + labourCharge.value;
    remainingAmount.value = totalAmount.value - paid;
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

    final newSale = SaleModel(
      saleDate: saleDate.value ?? DateTime.now(),
      customerName: customerNameController.text,
      contactNo: contactNoController.text,
      vehicleModel: vehicleModelController.text,
      kmDriven: int.tryParse(kmDrivenController.text),
      jobCardNo: jobCardNoController.text,
      bikeRegistrationNo: bikeRegistrationController.text,
      vehicleColor: vehicleColorController.text,
      receivedDate: receivedDate.value,
      deliveryDate: deliveryDate.value,
      billNo: billNoController.text,
      technicianName: technicianNameController.text,
      isServicing: isServicing.value,
      isFreeServicing: isFreeServicing.value,
      isRepairJob: isRepairJob.value,
      isAccident: isAccident.value,
      isWarrantyJob: isWarrantyJob.value,
      jobDoneOnVehicle: jobDoneOnVehicleController.text,
      remarks: remarksController.text,
      labourCharge: labourCharge.value,
      totalAmount: totalAmount.value,
      paidAmount: double.tryParse(paidAmountController.text) ?? 0.0,
      remainingAmount: remainingAmount.value,
      handledBy: handledBy.value,
      items: selectedItems.map((e) => e.copy()).toList(),
    );

    print(newSale);

    try {
      isLoading.value = true;

      final created = isServicing.value
          ? await saleRepository.createServicingSale(newSale,
              handledBy: handledBy.value)
          : await saleRepository.createStockSale(newSale,
              handledBy: handledBy.value);

      sales.add(created);
      _postMutationRefresh();
      clearForm();
      Get.back();
      Get.snackbar('Success', 'Sale added successfully');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- UPDATE SALE ----------------
  Future<void> updateSale(int saleId) async {
    if (!_validateForm()) return;

    final index = sales.indexWhere((s) => s.id == saleId);
    if (index == -1) return;

    final updatedSale = SaleModel(
      id: saleId,
      saleDate: saleDate.value ?? DateTime.now(),
      customerName: customerNameController.text,
      contactNo: contactNoController.text,
      vehicleModel: vehicleModelController.text,
      kmDriven: int.tryParse(kmDrivenController.text),
      jobCardNo: jobCardNoController.text,
      bikeRegistrationNo: bikeRegistrationController.text,
      vehicleColor: vehicleColorController.text,
      receivedDate: receivedDate.value,
      deliveryDate: deliveryDate.value,
      billNo: billNoController.text,
      technicianName: technicianNameController.text,
      isServicing: isServicing.value,
      isFreeServicing: isFreeServicing.value,
      isRepairJob: isRepairJob.value,
      isAccident: isAccident.value,
      isWarrantyJob: isWarrantyJob.value,
      jobDoneOnVehicle: jobDoneOnVehicleController.text,
      remarks: remarksController.text,
      labourCharge: labourCharge.value,
      totalAmount: totalAmount.value,
      paidAmount: double.tryParse(paidAmountController.text) ?? 0.0,
      remainingAmount: remainingAmount.value,
      handledBy: handledBy.value,
      items: selectedItems.map((e) => e.copy()).toList(),
    );

    try {
      isLoading.value = true;

      final result = await saleRepository.updateSale(updatedSale);

      sales[index] = result;
      _postMutationRefresh();
      clearForm();
      Get.back();
      Get.snackbar('Success', 'Sale updated successfully');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- DELETE SALE ----------------
  Future<void> deleteSale(int saleId) async {
    final index = sales.indexWhere((s) => s.id == saleId);
    if (index == -1) return;

    try {
      isLoading.value = true;
      await saleRepository.deleteSale(saleId);
      sales.removeAt(index);
      _postMutationRefresh();
      Get.snackbar('Success', 'Sale deleted successfully');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- FILL FORM FOR EDIT ----------------
  void fillForEdit(SaleModel sale) {
    clearForm();

    customerNameController.text = sale.customerName;
    contactNoController.text = sale.contactNo ?? '';
    vehicleModelController.text = sale.vehicleModel ?? '';
    kmDrivenController.text = sale.kmDriven?.toString() ?? '';
    jobCardNoController.text = sale.jobCardNo ?? '';
    bikeRegistrationController.text = sale.bikeRegistrationNo ?? '';
    vehicleColorController.text = sale.vehicleColor ?? '';
    billNoController.text = sale.billNo ?? '';
    technicianNameController.text = sale.technicianName ?? '';
    jobDoneOnVehicleController.text = sale.jobDoneOnVehicle;
    remarksController.text = sale.remarks;

    saleDate.value = sale.saleDate;
    receivedDate.value = sale.receivedDate;
    deliveryDate.value = sale.deliveryDate;

    isServicing.value = sale.isServicing;
    isFreeServicing.value = sale.isFreeServicing;
    isRepairJob.value = sale.isRepairJob;
    isAccident.value = sale.isAccident;
    isWarrantyJob.value = sale.isWarrantyJob;

    handledBy.value = sale.handledBy ?? 0;

    labourChargeController.text = sale.labourCharge.toString();
    paidAmountController.text = sale.paidAmount.toString();

    // resolve items
    selectedItems.clear();
    for (final saleItem in sale.items) {
      final stock = stockController.stocks.firstWhereOrNull(
        (s) => s.id == saleItem.itemId,
      );

      final resolved = SaleItemModel(
        id: saleItem.id,
        itemId: saleItem.itemId,
        itemNo: saleItem.itemNo,
        itemName: stock?.name != null && stock!.name.isNotEmpty
            ? stock.name
            : (saleItem.itemName.isNotEmpty ? saleItem.itemName : 'Unknown'),
        category: saleItem.category,
        quantity: saleItem.quantity,
        salePrice: stock?.salePrice ?? saleItem.salePrice,
      );

      resolved.initControllerIfNull();
      selectedItems.add(resolved);
    }

    updateTotals();
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
    labourCharge.value = 0;
    totalAmount.value = 0;
    remainingAmount.value = 0;
  }

  // ---------------- COMMON REFRESH ----------------
  void _postMutationRefresh() {
    stockController.fetchStocks();
    followUpController.fetchFollowUps();
    globalController.triggerRefresh(DashboardRefreshType.all);
  }

  // ---------------- VALIDATION ----------------
  bool _validateForm() {
    if (customerNameController.text.isEmpty) {
      Get.snackbar('Error', 'Customer name is required');
      return false;
    }
    if (saleDate.value == null) {
      Get.snackbar('Error', 'Sale date is required');
      return false;
    }
    if (handledBy.value == 0) {
      Get.snackbar('Error', 'Please select handled by staff');
      return false;
    }
    if (isServicing.value && jobDoneOnVehicleController.text.isEmpty) {
      Get.snackbar('Error', 'Job Done On Vehicle is required');
      return false;
    }
    if (selectedItems.isEmpty) {
      Get.snackbar('Error', 'At least one item must be added');
      return false;
    }
    return true;
  }
}
