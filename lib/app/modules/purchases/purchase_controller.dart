import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/purchase_model.dart';
import '../../data/repositories/purchase_repository.dart';

class PurchaseController extends GetxController {
  final PurchaseRepository purchaseRepository;

  PurchaseController({required this.purchaseRepository});

  var purchases = <PurchaseModel>[].obs;
  var isLoading = false.obs;

  // ---------------- Text Controllers ----------------
  var startDateController = TextEditingController();
  var endDateController = TextEditingController();
  var searchController = TextEditingController();

  // Add/Edit form controllers
  var supplierController = TextEditingController();
  var dateController = TextEditingController();
  var discountController = TextEditingController();
  var vatController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchPurchases();
  }

  // ---------------- Fetch ----------------
  Future<void> fetchPurchases() async {
    try {
      isLoading.value = true;
      final result = await purchaseRepository.getPurchases();
      purchases.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch purchases: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Add ----------------
  Future<void> addPurchase() async {
    try {
      isLoading.value = true;

      final newPurchase = PurchaseModel(
        id: 0, // backend assigns
        supplier: int.tryParse(supplierController.text) ?? 0,
        date: DateTime.tryParse(dateController.text) ?? DateTime.now(),
        items: [], // Add logic later for items list
        discountPercentage: double.tryParse(discountController.text) ?? 0,
        vatPercentage: double.tryParse(vatController.text) ?? 0,
      );

      final created = await purchaseRepository.create(newPurchase);
      purchases.add(created);
      clearForm();
      Get.back();
      Get.snackbar('Success', 'Purchase added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add purchase: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Update ----------------
  Future<void> updatePurchase(PurchaseModel purchase) async {
    try {
      isLoading.value = true;

      final updatedPurchase = PurchaseModel(
        id: purchase.id,
        supplier: int.tryParse(supplierController.text) ?? purchase.supplier,
        date: DateTime.tryParse(dateController.text) ?? purchase.date,
        items: purchase.items, // Keep existing items, update later if needed
        discountPercentage: double.tryParse(discountController.text) ??
            purchase.discountPercentage,
        vatPercentage:
            double.tryParse(vatController.text) ?? purchase.vatPercentage,
      );

      final updated = await purchaseRepository.update(updatedPurchase);
      final index = purchases.indexWhere((p) => p.id == updated.id);
      if (index != -1) purchases[index] = updated;
      clearForm();
      Get.back();
      Get.snackbar('Success', 'Purchase updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update purchase: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Delete ----------------
  Future<void> deletePurchase(int id) async {
    try {
      isLoading.value = true;
      await purchaseRepository.delete(id);
      purchases.removeWhere((p) => p.id == id);
      Get.snackbar('Success', 'Purchase deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete purchase: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Filter ----------------
  List<PurchaseModel> filterPurchases(
      {String? query, DateTime? start, DateTime? end}) {
    return purchases.where((p) {
      final matchesQuery = query == null || query.isEmpty
          ? true
          : p.items.any((item) =>
              item.itemName.toLowerCase().contains(query.toLowerCase()));
      final matchesStart = start == null || !p.date.isBefore(start);
      final matchesEnd = end == null || !p.date.isAfter(end);
      return matchesQuery && matchesStart && matchesEnd;
    }).toList();
  }

  // ---------------- Form Helper ----------------
  void clearForm() {
    supplierController.clear();
    dateController.clear();
    discountController.clear();
    vatController.clear();
  }

  // ---------------- Populate Form for Edit ----------------
  void populateForm(PurchaseModel purchase) {
    supplierController.text = purchase.supplier.toString();
    dateController.text = purchase.date.toIso8601String().split('T')[0];
    discountController.text = purchase.discountPercentage.toString();
    vatController.text = purchase.vatPercentage.toString();
  }
}
