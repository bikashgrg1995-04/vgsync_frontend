import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/sale_model.dart';
import '../../data/repositories/sale_repository.dart';

class SalesController extends GetxController {
  final SaleRepository saleRepository;

  SalesController({required this.saleRepository});

  // ================= STATE =================
  final RxList<SaleModel> sales = <SaleModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // ================= TEXT CONTROLLERS =================
  final customerNameController = TextEditingController();
  final contactNoController = TextEditingController();
  final billNoController = TextEditingController();
  final remarksController = TextEditingController();
  final totalAmountController = TextEditingController();
  final paidAmountController = TextEditingController();
  final remainingAmountController = TextEditingController();
  final labourChargeController = TextEditingController();
  final bikeRegistrationController = TextEditingController();
  final vehicleColorController = TextEditingController();
  final kmDrivenController = TextEditingController();
  final jobCardController = TextEditingController();
  final jobDoneController = TextEditingController();

  // ================= DATE FILTER =================
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  // ================= DROPDOWN / SWITCH =================
  final RxString paidStatus = 'paid'.obs; // paid | partial | unpaid
  final RxString paidFrom = 'cash'.obs; // cash | online
  final RxBool isServicing = false.obs;
  final RxBool isFreeServicing = false.obs;
  final RxBool isRepairJob = false.obs;
  final RxBool isAccident = false.obs;
  final RxBool isWarrantyJob = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSales();
  }

  // ================= FETCH =================
  Future<void> fetchSales() async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await saleRepository.getSales();
      sales.assignAll(result);
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', error.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ================= ADD =================
  Future<void> addSale() async {
    try {
      isLoading.value = true;

      final sale = SaleModel(
        id: 0,
        saleDate: DateTime.now(),
        customerName: customerNameController.text.trim(),
        contactNo: contactNoController.text.trim().isEmpty
            ? null
            : contactNoController.text.trim(),
        billNo: billNoController.text.trim().isEmpty
            ? null
            : billNoController.text.trim(),
        remarks: remarksController.text.trim().isEmpty
            ? null
            : remarksController.text.trim(),
        totalAmount: double.tryParse(totalAmountController.text) ?? 0,
        paidAmount: double.tryParse(paidAmountController.text) ?? 0,
        remainingAmount: double.tryParse(remainingAmountController.text) ?? 0,
        labourCharge: double.tryParse(labourChargeController.text) ?? 0,
        isPaid: paidStatus.value,
        paidFrom: paidFrom.value,
        isServicing: isServicing.value,
        isFreeServicing: isFreeServicing.value,
        isRepairJob: isRepairJob.value,
        isAccident: isAccident.value,
        isWarrantyJob: isWarrantyJob.value,
        bikeRegistrationNo: bikeRegistrationController.text.trim().isEmpty
            ? null
            : bikeRegistrationController.text.trim(),
        vehicleColor: vehicleColorController.text.trim().isEmpty
            ? null
            : vehicleColorController.text.trim(),
        kmDriven: int.tryParse(kmDrivenController.text),
        jobCardNo: jobCardController.text.trim().isEmpty
            ? null
            : jobCardController.text.trim(),
        jobDoneOnVehicle: jobDoneController.text.trim().isEmpty
            ? null
            : jobDoneController.text.trim(),
        items: const [],
      );

      final created = await saleRepository.create(sale);
      sales.insert(0, created);

      clearForm();
      Get.back();
      Get.snackbar('Success', 'Sale added successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ================= EDIT =================
  Future<void> updateSale(int saleId) async {
    try {
      isLoading.value = true;

      final sale = SaleModel(
        id: saleId,
        saleDate: DateTime.now(),
        customerName: customerNameController.text.trim(),
        contactNo: contactNoController.text.trim().isEmpty
            ? null
            : contactNoController.text.trim(),
        billNo: billNoController.text.trim().isEmpty
            ? null
            : billNoController.text.trim(),
        remarks: remarksController.text.trim().isEmpty
            ? null
            : remarksController.text.trim(),
        totalAmount: double.tryParse(totalAmountController.text) ?? 0,
        paidAmount: double.tryParse(paidAmountController.text) ?? 0,
        remainingAmount: double.tryParse(remainingAmountController.text) ?? 0,
        labourCharge: double.tryParse(labourChargeController.text) ?? 0,
        isPaid: paidStatus.value,
        paidFrom: paidFrom.value,
        isServicing: isServicing.value,
        isFreeServicing: isFreeServicing.value,
        isRepairJob: isRepairJob.value,
        isAccident: isAccident.value,
        isWarrantyJob: isWarrantyJob.value,
        bikeRegistrationNo: bikeRegistrationController.text.trim().isEmpty
            ? null
            : bikeRegistrationController.text.trim(),
        vehicleColor: vehicleColorController.text.trim().isEmpty
            ? null
            : vehicleColorController.text.trim(),
        kmDriven: int.tryParse(kmDrivenController.text),
        jobCardNo: jobCardController.text.trim().isEmpty
            ? null
            : jobCardController.text.trim(),
        jobDoneOnVehicle: jobDoneController.text.trim().isEmpty
            ? null
            : jobDoneController.text.trim(),
        items: const [],
      );

      final updated = await saleRepository.update(sale);
      final index = sales.indexWhere((e) => e.id == saleId);
      if (index != -1) sales[index] = updated;

      clearForm();
      Get.back();
      Get.snackbar('Success', 'Sale updated successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ================= PREFILL EDIT =================
  void fillForEdit(SaleModel sale) {
    customerNameController.text = sale.customerName;
    contactNoController.text = sale.contactNo ?? '';
    billNoController.text = sale.billNo ?? '';
    remarksController.text = sale.remarks ?? '';
    totalAmountController.text = sale.totalAmount.toString();
    paidAmountController.text = sale.paidAmount.toString();
    remainingAmountController.text = sale.remainingAmount.toString();
    labourChargeController.text = sale.labourCharge.toString();
    bikeRegistrationController.text = sale.bikeRegistrationNo ?? '';
    vehicleColorController.text = sale.vehicleColor ?? '';
    kmDrivenController.text = sale.kmDriven?.toString() ?? '';
    jobCardController.text = sale.jobCardNo ?? '';
    jobDoneController.text = sale.jobDoneOnVehicle ?? '';

    paidStatus.value = sale.isPaid;
    paidFrom.value = sale.paidFrom;
    isServicing.value = sale.isServicing;
    isFreeServicing.value = sale.isFreeServicing;
    isRepairJob.value = sale.isRepairJob;
    isAccident.value = sale.isAccident;
    isWarrantyJob.value = sale.isWarrantyJob;
  }

  // ================= CLEAR =================
  void clearForm() {
    customerNameController.clear();
    contactNoController.clear();
    billNoController.clear();
    remarksController.clear();
    totalAmountController.clear();
    paidAmountController.clear();
    remainingAmountController.clear();
    labourChargeController.clear();
    bikeRegistrationController.clear();
    vehicleColorController.clear();
    kmDrivenController.clear();
    jobCardController.clear();
    jobDoneController.clear();

    paidStatus.value = 'paid';
    paidFrom.value = 'cash';
    isServicing.value = false;
    isFreeServicing.value = false;
    isRepairJob.value = false;
    isAccident.value = false;
    isWarrantyJob.value = false;
    startDateController.clear();
    endDateController.clear();
  }

  // ================= FILTER SALES =================
  List<SaleModel> filteredSales() {
    DateTime? start;
    DateTime? end;

    if (startDateController.text.isNotEmpty) {
      start = DateTime.parse(startDateController.text);
    }
    if (endDateController.text.isNotEmpty) {
      end = DateTime.parse(endDateController.text);
    }

    return sales.where((sale) {
      final saleDate = sale.saleDate;
      final afterStart = start == null || !saleDate.isBefore(start);
      final beforeEnd = end == null || !saleDate.isAfter(end);
      return afterStart && beforeEnd;
    }).toList();
  }

  @override
  void onClose() {
    customerNameController.dispose();
    contactNoController.dispose();
    billNoController.dispose();
    remarksController.dispose();
    totalAmountController.dispose();
    paidAmountController.dispose();
    remainingAmountController.dispose();
    labourChargeController.dispose();
    bikeRegistrationController.dispose();
    vehicleColorController.dispose();
    kmDrivenController.dispose();
    jobCardController.dispose();
    jobDoneController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }
}
