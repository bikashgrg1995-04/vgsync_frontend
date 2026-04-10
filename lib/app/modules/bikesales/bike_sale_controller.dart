import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/bike_sale_model.dart';
import 'package:vgsync_frontend/app/data/repositories/bike_sale_repository.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_controller.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';

class BikeSaleController extends GetxController {
  final BikeSaleRepository bikeSaleRepository;

  BikeSaleController({required this.bikeSaleRepository});

  // ------------------ Reactive State ------------------
  var bikeSales = <BikeSale>[].obs;
  var emiTrackers = <EmiTracker>[].obs;

  var isLoading = false.obs;
  var isEmiLoading = false.obs;

  var emiFilter = "all".obs;

  // ------------------ Pagination ------------------
  var currentPage = 1;
  var totalCount = 0;
  final int pageSize = 20;

  // ------------------ Search & Filter ------------------
  var searchQuery = ''.obs;
  var saleTypeFilter = Rx<SaleType?>(null);

  // ------------------ Additional Search/Filter ------------------
  final searchController = TextEditingController(); // For the search TextField
  var searchText = ''.obs; // Reactive copy of search query
  var selectedStatus = 'all'.obs; // For the ChoiceChip filter

  final GlobalController globalController = Get.find<GlobalController>();
  final FollowUpController followUpController = Get.find<FollowUpController>();

  //------------------ Sale Date ------------------
  final Rxn<DateTime> saleDate = Rxn<DateTime>();

  // ------------------ TextEditingControllers ------------------
  final customerController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();
  final vehicleModelController = TextEditingController();
  final registrationController = TextEditingController();
  final chassisController = TextEditingController();
  final engineController = TextEditingController();
  final colorController = TextEditingController();
  final kmDrivenController = TextEditingController();
  final totalAmountController = TextEditingController();
  final discountController = TextEditingController();
  final netTotalController = TextEditingController();
  final initialPaidController = TextEditingController();
  final paidAmountController = TextEditingController();
  final remainingController = TextEditingController();
  final remarksController = TextEditingController();
  final emiTenureController = TextEditingController();
  final emiAmountController = TextEditingController();

  var selectedVehicleType = VehicleType.bike.obs;
  var selectedSaleType = SaleType.full.obs;
  var selectedPaymentMethod = PaymentMethod.cash.obs;

// ------------------ Lifecycle ------------------
  @override
  void onInit() {
    super.onInit();
    saleDate.value = DateTime.now();
    searchController.addListener(() {
      searchText.value = searchController.text;
    });
  }

  @override
  void onClose() {
    // Dispose all controllers
    for (var c in [
      searchController,
      customerController,
      contactController,
      addressController,
      vehicleModelController,
      registrationController,
      chassisController,
      engineController,
      colorController,
      kmDrivenController,
      totalAmountController,
      discountController,
      netTotalController,
      initialPaidController,
      paidAmountController,
      remainingController,
      remarksController,
      emiTenureController,
      emiAmountController,
    ]) {
      c.dispose();
    }

    super.onClose();
  }

  // ------------------ Form Helpers ------------------
  void clearForm() {
    for (var c in [
      customerController,
      contactController,
      addressController,
      vehicleModelController,
      registrationController,
      chassisController,
      engineController,
      colorController,
      kmDrivenController,
      totalAmountController,
      discountController,
      netTotalController,
      initialPaidController,
      paidAmountController,
      remainingController,
      remarksController,
      emiTenureController,
      emiAmountController,
    ]) {
      c.clear();
    }

    saleDate.value = DateTime.now();
    selectedVehicleType.value = VehicleType.bike;
    selectedSaleType.value = SaleType.full;
    selectedPaymentMethod.value = PaymentMethod.cash;
  }

  void fillForm(BikeSale sale) {
    customerController.text = sale.customerName;
    contactController.text = sale.contactNo;
    addressController.text = sale.address ?? '';
    vehicleModelController.text = sale.vehicleModel;
    registrationController.text = sale.registrationNo;
    chassisController.text = sale.chassisNo;
    engineController.text = sale.engineNo;
    colorController.text = sale.color ?? '';
    kmDrivenController.text = sale.kmDriven.toString();
    totalAmountController.text = sale.totalAmount.toStringAsFixed(2);

    discountController.text = sale.discount.toStringAsFixed(2);

    netTotalController.text = sale.netTotal.toStringAsFixed(2);
    initialPaidController.text = sale.initialPaidAmount.toStringAsFixed(2);
    paidAmountController.text = sale.paidAmount.toStringAsFixed(2);
    remainingController.text = sale.remainingAmount.toStringAsFixed(2);
    remarksController.text = sale.remarks ?? '';
    emiTenureController.text = sale.emiTenure?.toString() ?? '';
    emiAmountController.text = sale.emiAmount?.toStringAsFixed(2) ?? '';
    saleDate.value = sale.saleDate;

    selectedVehicleType.value = sale.vehicleType;
    selectedSaleType.value = sale.saleType;
    selectedPaymentMethod.value = sale.paymentMethod;
  }

  void updateTotals() {
    final total = double.tryParse(totalAmountController.text) ?? 0;
    final discountAmount = double.tryParse(discountController.text) ?? 0;
    final netTotal = total - discountAmount;
    netTotalController.text = netTotal.toStringAsFixed(2);

    final initialPaid = double.tryParse(initialPaidController.text) ?? 0;
    final paidAmount = double.tryParse(paidAmountController.text) ?? 0;

    if (initialPaid < 0 || paidAmount < 0) {
      DesktopToast.show("Paid amounts cannot be negative",
          backgroundColor: Colors.redAccent);
      return;
    }

    double remaining;

    if (selectedSaleType.value == SaleType.full) {
      // ✅ full मा पनि paid amount बाट remaining calculate गर्नु
      remaining = netTotal - paidAmount;
      if (remaining < 0) remaining = 0;
    } else if (selectedSaleType.value == SaleType.downpayment) {
      remaining =
          paidAmount > 0 ? netTotal - paidAmount : netTotal - initialPaid;
    } else {
      // emi
      remaining = netTotal - paidAmount;
    }

    remainingController.text = remaining.toStringAsFixed(2);

    // EMI calculation
    if ((selectedSaleType.value == SaleType.emi ||
            selectedSaleType.value == SaleType.downpayment) &&
        emiTenureController.text.isNotEmpty) {
      final tenure = int.tryParse(emiTenureController.text) ?? 0;
      if (tenure > 0) {
        emiAmountController.text = (remaining / tenure).toStringAsFixed(2);
      }
    }
  }

  // ------------------ Fetch Bike Sales ------------------
  Future<void> fetchBikeSales({int page = 1, bool append = false}) async {
    try {
      isLoading.value = true;
      currentPage = page;
      final response = await bikeSaleRepository.getBikeSales(
        saleType: saleTypeFilter.value?.name,
        vehicleType: selectedVehicleType.value.name,
      );
      if (append) {
        bikeSales.addAll(response);
      } else {
        bikeSales.value = response;
      }
      totalCount = response.length;
    } catch (e) {
      DesktopToast.show(
        "Failed to fetch Bike sale: $e",
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

// ------------------ CREATE BIKE SALE ------------------
  Future<BikeSale?> createBikeSale() async {
    try {
      if (!validateForm()) return null;

      isLoading.value = true;
      updateTotals();

      // Ensure required fields are never empty
      final contact = contactController.text.trim().isNotEmpty
          ? contactController.text.trim()
          : "N/A";
      final chassis = chassisController.text.trim().isNotEmpty
          ? chassisController.text.trim()
          : "CH-${DateTime.now().millisecondsSinceEpoch}";
      final engine = engineController.text.trim().isNotEmpty
          ? engineController.text.trim()
          : "EN-${DateTime.now().millisecondsSinceEpoch}";

      final newSale = BikeSale(
        id: 0,
        customerName: customerController.text.trim(),
        contactNo: contact,
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        vehicleType: selectedVehicleType.value,
        vehicleModel: vehicleModelController.text.trim(),
        registrationNo: registrationController.text.trim(),
        chassisNo: chassis,
        engineNo: engine,
        color: colorController.text.trim().isEmpty
            ? null
            : colorController.text.trim(),
        kmDriven: double.tryParse(kmDrivenController.text) ?? 0,
        saleType: selectedSaleType.value,
        saleDate: saleDate.value ?? DateTime.now(),
        totalAmount: double.tryParse(totalAmountController.text) ?? 0,
        discount: double.tryParse(discountController.text) ?? 0,
        netTotal: double.tryParse(netTotalController.text) ?? 0,
        initialPaidAmount: selectedSaleType.value == SaleType.downpayment
            ? double.tryParse(initialPaidController.text) ?? 0
            : 0,
        paidAmount: double.tryParse(paidAmountController.text) ?? 0,
        remainingAmount: double.tryParse(remainingController.text) ?? 0,
        paymentMethod: selectedPaymentMethod.value,
        status: selectedSaleType.value == SaleType.full
            ? 'Paid'
            : selectedSaleType.value == SaleType.downpayment
                ? 'Partially Paid'
                : 'Pending',
        emiTenure: selectedSaleType.value != SaleType.full
            ? int.tryParse(emiTenureController.text)
            : null,
        emiAmount: selectedSaleType.value != SaleType.full
            ? double.tryParse(emiAmountController.text)
            : null,
        remarks: remarksController.text.trim().isEmpty
            ? null
            : remarksController.text.trim(),
      );

      final createdSale = await bikeSaleRepository.createBikeSale(newSale);
      bikeSales.insert(0, createdSale);

      followUpController.fetchFollowUps();
      globalController.triggerRefresh(DashboardRefreshType.all);

      Get.back(closeOverlays: true);
      DesktopToast.show(
        "Bike Sale Added Successfully",
        backgroundColor: Colors.greenAccent,
      );

      return createdSale;
    } catch (e) {
      DesktopToast.show(
        "Failed to add bike sale",
        backgroundColor: Colors.redAccent,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

// ------------------ UPDATE BIKE SALE ------------------
  Future<BikeSale?> updateBikeSale(int saleId) async {
    try {
      if (!validateForm()) return null;

      isLoading.value = true;
      updateTotals();

      // Ensure required fields are never empty
      final contact = contactController.text.trim().isNotEmpty
          ? contactController.text.trim()
          : "N/A";
      final chassis = chassisController.text.trim().isNotEmpty
          ? chassisController.text.trim()
          : "CH-${DateTime.now().millisecondsSinceEpoch}";
      final engine = engineController.text.trim().isNotEmpty
          ? engineController.text.trim()
          : "EN-${DateTime.now().millisecondsSinceEpoch}";

      final updatedSale = BikeSale(
        id: saleId,
        customerName: customerController.text.trim(),
        contactNo: contact,
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        vehicleType: selectedVehicleType.value,
        vehicleModel: vehicleModelController.text.trim(),
        registrationNo: registrationController.text.trim(),
        chassisNo: chassis,
        engineNo: engine,
        color: colorController.text.trim().isEmpty
            ? null
            : colorController.text.trim(),
        kmDriven: double.tryParse(kmDrivenController.text) ?? 0,
        saleType: selectedSaleType.value,
        saleDate: saleDate.value ?? DateTime.now(),
        totalAmount: double.tryParse(totalAmountController.text) ?? 0,
        discount: double.tryParse(discountController.text) ?? 0,
        netTotal: double.tryParse(netTotalController.text) ?? 0,
        initialPaidAmount: selectedSaleType.value == SaleType.downpayment
            ? double.tryParse(initialPaidController.text) ?? 0
            : 0,
        paidAmount: double.tryParse(paidAmountController.text) ?? 0,
        remainingAmount: double.tryParse(remainingController.text) ?? 0,
        paymentMethod: selectedPaymentMethod.value,
        status: selectedSaleType.value == SaleType.full
            ? 'Paid'
            : selectedSaleType.value == SaleType.downpayment
                ? 'Partially Paid'
                : 'Pending',
        emiTenure: selectedSaleType.value != SaleType.full
            ? int.tryParse(emiTenureController.text)
            : null,
        emiAmount: selectedSaleType.value != SaleType.full
            ? double.tryParse(emiAmountController.text)
            : null,
        remarks: remarksController.text.trim().isEmpty
            ? null
            : remarksController.text.trim(),
      );

      print("Updating BikeSale: ${updatedSale.toJson()}");

      final updated = await bikeSaleRepository.updateBikeSale(
        saleId: saleId,
        data: updatedSale.toJson(),
      );

      final index = bikeSales.indexWhere((s) => s.id == saleId);
      if (index != -1) bikeSales[index] = updated;

      followUpController.fetchFollowUps();
      globalController.triggerRefresh(DashboardRefreshType.all);

      Get.back(closeOverlays: true);

      DesktopToast.show(
        "Bike Sale Updated Successfully",
        backgroundColor: Colors.greenAccent,
      );

      return updated;
    } catch (e) {
      DesktopToast.show(
        "Failed to delete bike sale: $e",
        backgroundColor: Colors.redAccent,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteBikeSale(int saleId) async {
    try {
      isLoading.value = true;
      await bikeSaleRepository.deleteBikeSale(saleId);
      bikeSales.removeWhere((s) => s.id == saleId);
      emiTrackers.removeWhere((e) => e.saleId == saleId);
      followUpController.fetchFollowUps();

      return true;
    } catch (e) {
      DesktopToast.show(
        "Failed to delete bike sale: $e",
        backgroundColor: Colors.redAccent,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------ EMI Trackers ------------------
  Future<void> fetchEmiTrackers(int saleId) async {
    try {
      isEmiLoading.value = true;
      final response = await bikeSaleRepository.getEmiTrackers(saleId: saleId);
      emiTrackers.value = response.where((e) => e.saleId == saleId).toList();
    } catch (e) {
      DesktopToast.show(
        "Failed to fetch emi details: $e",
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isEmiLoading.value = false;
    }
  }

  Future<EmiTracker?> updateEmiPayment({
    required int emiId,
    required double paidAmount,
    required DateTime paymentDate,
    required EMIPaymentMethod paymentMethod,
    required EmiStatus status,
    required int parentSaleId,
  }) async {
    isEmiLoading.value = true;

    try {
      // Call repository to update EMI
      final updatedEmi = await bikeSaleRepository.updateEmiPayment(
        emiId: emiId,
        paidAmount: paidAmount,
        paymentDate: paymentDate,
        emiPaymentMethod: paymentMethod,
        status: status,
      );

      // Update reactive list safely
      final index = emiTrackers.indexWhere((e) => e.id == emiId);
      if (index != -1) {
        emiTrackers[index] = updatedEmi;
      } else {
        emiTrackers.add(updatedEmi);
      }

      return updatedEmi;
    } catch (e) {
      // // Log for debugging
      // print("Error updating EMI: $e\n$st");

      // DesktopToast.show(
      //   "Failed to update EMI payment",
      //   backgroundColor: Colors.redAccent,
      // );
      return null;
    } finally {
      isEmiLoading.value = false;
    }
  }

  // ------------------ Validation ------------------
  bool validateForm() {
    if (customerController.text.trim().isEmpty) {
      DesktopToast.show("Customer name is required",
          backgroundColor: Colors.redAccent);
      return false;
    }
    if (vehicleModelController.text.trim().isEmpty) {
      DesktopToast.show("Vehicle model is required",
          backgroundColor: Colors.redAccent);
      return false;
    }
    if (registrationController.text.trim().isEmpty) {
      DesktopToast.show("Registration number is required",
          backgroundColor: Colors.redAccent);
      return false;
    }

    final total = double.tryParse(totalAmountController.text);
    if (total == null || total <= 0) {
      DesktopToast.show("Total amount must be valid",
          backgroundColor: Colors.redAccent);
      return false;
    }

    final discountAmt = double.tryParse(discountController.text) ?? 0;
    if (discountAmt < 0) {
      DesktopToast.show("Discount cannot be negative",
          backgroundColor: Colors.redAccent);
      return false;
    }

    final initialPaid = double.tryParse(initialPaidController.text) ?? 0;
    final paid = double.tryParse(paidAmountController.text) ?? 0;
    if (initialPaid < 0 || paid < 0) {
      DesktopToast.show("Paid amounts cannot be negative",
          backgroundColor: Colors.redAccent);
      return false;
    }

    if (selectedSaleType.value != SaleType.full) {
      final tenure = int.tryParse(emiTenureController.text);
      final emi = double.tryParse(emiAmountController.text);
      if (tenure == null || tenure <= 0) {
        DesktopToast.show("EMI tenure must be valid",
            backgroundColor: Colors.redAccent);
        return false;
      }
      if (emi == null || emi <= 0) {
        DesktopToast.show("EMI amount must be valid",
            backgroundColor: Colors.redAccent);
        return false;
      }
    }

    return true;
  }

  // ------------------ Helpers ------------------
  bool get hasMorePages => bikeSales.length < totalCount;
  int get totalPages => (totalCount / pageSize).ceil();

  List<BikeSale> get filteredSales {
    final query = searchQuery.value.toLowerCase();
    var list = bikeSales.toList();

    if (saleTypeFilter.value != null) {
      list = list.where((s) => s.saleType == saleTypeFilter.value).toList();
    }

    if (query.isNotEmpty) {
      list = list
          .where((s) =>
              s.customerName.toLowerCase().contains(query) ||
              s.vehicleModel.toLowerCase().contains(query) ||
              s.registrationNo.toLowerCase().contains(query))
          .toList();
    }

    return list;
  }

  RxList<EmiTracker?> getFilteredEmis(int saleId) {
    final emiList = emiTrackers.where((e) => e.saleId == saleId).toList();
    final displayList =
        emiList.isEmpty ? List.generate(4, (_) => null) : emiList;
    return displayList
        .where((emi) {
          if (emi == null) return true;
          final isPaid = emi.isPaid;
          if (emiFilter.value == "all") return true;
          if (emiFilter.value == "pending") return !isPaid;
          if (emiFilter.value == "paid") return isPaid;
          return true;
        })
        .toList()
        .obs;
  }
}
