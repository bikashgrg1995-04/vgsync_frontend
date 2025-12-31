import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/models/purchase_model.dart';
import 'package:vgsync_frontend/app/data/models/stock_model.dart';
import 'package:vgsync_frontend/app/data/repositories/purchase_repository.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';

class PurchaseItemController {
  final PurchaseItemModel item;

  final quantity = 1.obs; // user-editable quantity
  final double price; // fixed from stock

  late TextEditingController quantityController;
  late TextEditingController priceController;

  PurchaseItemController({required this.item})
      : price = item.salePrice.toDouble() {
    quantityController = TextEditingController(text: item.quantity.toString());
    priceController = TextEditingController(text: item.salePrice.toString());

    // Update quantity from TextField
    quantityController.addListener(() {
      final val = int.tryParse(quantityController.text) ?? 0;
      quantity.value = val;
    });

    // If you want price editable
    // priceController.addListener(() {
    //   final val = double.tryParse(priceController.text) ?? price;
    //   // price cannot be final, so consider removing final if editable
    // });
  }

  String get itemName => item.itemName ?? "";

  double get totalPrice => quantity.value * price; // always dynamic
}

class PurchaseController extends GetxController {
  final PurchaseRepository purchaseRepository;

  PurchaseController({required this.purchaseRepository});

  var purchases = <PurchaseModel>[].obs;
  var isLoading = false.obs;

  // ---------------- Form Fields ----------------
  var supplierController = TextEditingController();
  var discountController = TextEditingController();
  var vatController = TextEditingController();
  var dateController = TextEditingController();

  // ---------------- Items List ----------------
  var items = <PurchaseItemController>[].obs;

  final GlobalController globalController = Get.find<GlobalController>();
  final StockController stockController = Get.find<StockController>();

  // ---------------- Fetch ----------------
  Future<void> fetchPurchases() async {
    try {
      isLoading.value = true;
      final data = await purchaseRepository.getPurchases();
      purchases.assignAll(data);
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
      final newPurchase = _getCurrentPurchase(id: 0);
      final created = await purchaseRepository.create(newPurchase);
      purchases.add(created);

      await stockController.fetchStocks();

      globalController.triggerRefresh(DashboardRefreshType.all);

      clearForm();
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
      final updated = _getCurrentPurchase(id: purchase.id ?? 0);
      final res = await purchaseRepository.update(updated);
      final index = purchases.indexWhere((p) => p.id == res.id);
      if (index != -1) purchases[index] = res;

      await stockController.fetchStocks();

      globalController.triggerRefresh(DashboardRefreshType.all);

      clearForm();
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

      await stockController.fetchStocks();

      globalController.triggerRefresh(DashboardRefreshType.all);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete purchase: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Items Management ----------------
  addItem(Result stockItem) {
    final newItem = PurchaseItemController(
      item: PurchaseItemModel(
        item: stockItem.id ?? 0,
        itemName: stockItem.name,
        quantity: 1,
        purchasePrice: stockItem.purchasePrice,
        salePrice: stockItem.salePrice,
        vat: stockItem.vat,
        totalPrice: 0, // remove wrong static value
      ),
    );
    items.add(newItem);
  }

  void removeItem(PurchaseItemController item) {
    items.removeWhere((i) => i == item);
  }

  // ---------------- Total Calculation ----------------
  double get grandTotal {
    final subtotal =
        items.fold<double>(0, (prev, item) => prev + item.totalPrice);
    final discount = double.tryParse(discountController.text) ?? 0;
    final vat = double.tryParse(vatController.text) ?? 0;
    return subtotal * (1 - discount / 100) * (1 + vat / 100);
  }

  // ---------------- Populate Form for Edit ----------------
  void populateForm(PurchaseModel purchase) {
    supplierController.text = purchase.supplier.toString();
    discountController.text = purchase.discountPercentage.toString();
    vatController.text = purchase.vatPercentage.toString();
    dateController.text = purchase.date.toIso8601String().split('T')[0];

    items.clear();
    for (var i in purchase.items) {
      items.add(PurchaseItemController(item: i));
    }
  }

  // ---------------- Clear Form ----------------
  void clearForm() {
    supplierController.clear();
    discountController.clear();
    vatController.clear();
    dateController.clear();
    items.clear();
  }

  // ---------------- Build PurchaseModel from Form ----------------
  PurchaseModel _getCurrentPurchase({required int id}) {
    final itemModels = items.map((i) {
      final qty = i.quantity.value;
      final price = i.price; // always use stock sale price
      return PurchaseItemModel(
        item: i.item.item,
        itemName: i.item.itemName,
        quantity: qty,
        purchasePrice: price,
        salePrice: i.item.salePrice,
        vat: i.item.vat,
        totalPrice: qty * price,
      );
    }).toList();

    return PurchaseModel(
      id: id,
      supplier: int.tryParse(supplierController.text) ?? 0,
      date: DateTime.tryParse(dateController.text) ?? DateTime.now(),
      discountPercentage: double.tryParse(discountController.text) ?? 0,
      vatPercentage: double.tryParse(vatController.text) ?? 0,
      items: itemModels,
    );
  }

  // ---------------- Filter ----------------
  List<PurchaseModel> filterPurchases({String? query}) {
    return purchases.where((p) {
      final matchesQuery = query == null || query.isEmpty
          ? true
          : p.items.any((item) =>
              item.itemName!.toLowerCase().contains(query.toLowerCase()));
      return matchesQuery;
    }).toList();
  }
}
