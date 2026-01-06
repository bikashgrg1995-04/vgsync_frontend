import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_controller.dart';
import '../../data/models/purchase_model.dart';
import '../../data/models/stock_model.dart';
import '../../data/repositories/purchase_repository.dart';
import '../../modules/stock/stock_controller.dart';

/// ===============================
/// Purchase Item Controller
/// ===============================
class PurchaseItemController {
  final PurchaseItemModel item;
  final VoidCallback onChanged; // 🔥 ADD THIS

  final quantity = 1.obs;
  final price = 0.0.obs;

  late TextEditingController quantityController;
  late TextEditingController priceController;

  PurchaseItemController({
    required this.item,
    required this.onChanged, // 🔥 ADD THIS
  }) {
    quantity.value = item.quantity;
    price.value = item.price;

    quantityController = TextEditingController(text: quantity.value.toString());
    priceController =
        TextEditingController(text: price.value.toStringAsFixed(2));

    quantityController.addListener(() {
      quantity.value = int.tryParse(quantityController.text) ?? 1;
      onChanged(); // 🔥 trigger recalculation
    });

    priceController.addListener(() {
      price.value = double.tryParse(priceController.text) ?? 0.0;
      onChanged(); // 🔥 trigger recalculation
    });
  }

  String get itemName => item.itemName ?? '';
  double get totalPrice => quantity.value * price.value;
}

/// ===============================
/// Purchase Controller
/// ===============================
class PurchaseController extends GetxController {
  final PurchaseRepository purchaseRepository;

  PurchaseController({required this.purchaseRepository});

  // ---------------- STATE ----------------
  final purchases = <PurchaseModel>[].obs;
  final items = <PurchaseItemController>[].obs;
  final isLoading = false.obs;
  final message = ''.obs;

  // ---------------- FORM ----------------
  final selectedSupplierId = RxnInt();
  final selectedStaffId = RxnInt(); // Created by staff
  final discountController = TextEditingController(text: '0');
  final vatController = TextEditingController(text: '13');
  final paidController = TextEditingController(text: '0');
  final dateController = TextEditingController();

  // Reactive calculation for remaining & status
  final remaining = 0.0.obs;
  final purchaseStatus = 'not_paid'.obs;

  // ---------------- CONTROLLERS ----------------
  final StockController stockController = Get.find();
  final GlobalController globalController = Get.find();
  final SupplierController supplierController = Get.find();

  @override
  void onInit() {
    super.onInit();
    // Recalculate when items change
    ever(items, (_) => _recalculateTotals());

    // Recalculate when discount changes
    discountController.addListener(_recalculateTotals);

    // Recalculate when VAT changes
    vatController.addListener(_recalculateTotals);

    // Recalculate when paid amount changes
    paidController.addListener(_recalculateTotals);

    supplierController.fetchSuppliers();
  }

  void _recalculateTotals() {
    final t = items.fold<double>(0.0, (s, i) => s + i.totalPrice);
    final disc = double.tryParse(discountController.text) ?? 0;
    final vatP = double.tryParse(vatController.text) ?? 0;
    final discAmount = disc == 0 ? 0 : t * disc / 100;
    final vatAmount = vatP == 0 ? 0 : (t - discAmount) * vatP / 100;
    final net = t - discAmount + vatAmount;

    final paid = double.tryParse(paidController.text) ?? 0;

    remaining.value = net - paid;
    if (paid <= 0) {
      purchaseStatus.value = 'not_paid';
    } else if (remaining.value <= 0) {
      purchaseStatus.value = 'paid';
    } else {
      purchaseStatus.value = 'partial';
    }
  }

  // void _validatePaid() {
  //   double paid = double.tryParse(paidController.text) ?? 0;

  //   // ❌ negative रोक्ने
  //   if (paid < 0) {
  //     paid = 0;
  //   }

  //   // ❌ net total भन्दा बढी रोक्ने
  //   if (paid > netTotal) {
  //     paid = netTotal;
  //   }

  //   // 🔁 update text only if needed (avoid infinite loop)
  //   final fixed = paid.toStringAsFixed(2);
  //   if (paidController.text != fixed) {
  //     paidController.text = fixed;
  //     paidController.selection = TextSelection.collapsed(
  //       offset: fixed.length,
  //     );
  //   }

  //   _recalculateTotals();
  // }

  // ---------------- FETCH ----------------
  Future<void> fetchPurchases() async {
    try {
      isLoading.value = true;
      purchases.assignAll(await purchaseRepository.getPurchases());
    } catch (e) {
      message.value = 'Failed to fetch purchases: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // =============================== //
  // CALCULATION BLOCK //
  // ===============================
  double get total => items.fold<double>(0.0, (s, i) => s + i.totalPrice);
  double get discountPercent => double.tryParse(discountController.text) ?? 0;
  double get vatPercent => double.tryParse(vatController.text) ?? 0;
  double get discountAmount =>
      discountPercent == 0 ? 0 : total * discountPercent / 100;
  double get vatAmount =>
      vatPercent == 0 ? 0 : (total - discountAmount) * vatPercent / 100;
  double get netTotal => total - discountAmount + vatAmount;
  double get paidAmount => double.tryParse(paidController.text) ?? 0;
  double get grandTotal => total;

  // =============================== //
  // ITEM MANAGEMENT //
  // ===============================
  void addItem(Result stock) {
    items.add(
      PurchaseItemController(
        item: PurchaseItemModel(
          item: stock.id!,
          itemName: stock.name,
          quantity: 1,
          price: stock.salePrice,
        ),
        onChanged: _recalculateTotals,
      ),
    );
  }

  void removeItem(PurchaseItemController item) => items.remove(item);
  void clearItems() => items.clear();

  // =============================== //
  // FORM OPERATIONS //
  // ===============================
  void clearForm() {
    selectedSupplierId.value = null;
    selectedStaffId.value = null;
    discountController.text = '0';
    vatController.text = '13';
    paidController.text = '0';
    dateController.clear();
    clearItems();
  }

  void populateForm(PurchaseModel purchase) {
    selectedSupplierId.value = purchase.supplier;
    selectedStaffId.value = null; // assign staff if available
    dateController.text = purchase.date.toIso8601String().split('T')[0];

    final itemsTotal =
        purchase.items.fold<double>(0.0, (s, i) => s + (i.price * i.quantity));

    discountController.text = itemsTotal == 0
        ? '0'
        : ((purchase.discountAmount * 100) / itemsTotal).toStringAsFixed(2);

    final vatBase = itemsTotal - purchase.discountAmount;
    vatController.text = vatBase <= 0
        ? '0'
        : ((purchase.vatAmount * 100) / vatBase).toStringAsFixed(2);

    paidController.text = purchase.paidAmount.toString();
    items.assignAll(
      purchase.items.map(
        (i) => PurchaseItemController(
          item: i,
          onChanged: _recalculateTotals,
        ),
      ),
    );
  }

  // =============================== //
  // BUILD PURCHASE (API READY) //
  // ===============================
  PurchaseModel buildPurchase({int id = 0}) {
    return PurchaseModel(
      id: id,
      supplier: selectedSupplierId.value ?? 0,
      date: DateTime.tryParse(dateController.text) ?? DateTime.now(),
      items: items
          .map((i) => PurchaseItemModel(
                id: i.item.id,
                item: i.item.item,
                itemName: i.item.itemName,
                quantity: i.quantity.value,
                price: i.price.value,
              ))
          .toList(),
      grandTotal: total,
      discountAmount: discountAmount,
      vatAmount: vatAmount,
      netTotal: netTotal,
      paidAmount: paidAmount,
      remainingAmount: remaining.value,
      status: purchaseStatus.value,
      createdBy: selectedStaffId.value, // <-- pass the staff who created it
    );
  }

  // =============================== //
  // CRUD OPERATIONS //
  // ===============================
  Future<void> addPurchase() async {
    try {
      isLoading.value = true;
      final purchase = buildPurchase();
      final created = await purchaseRepository.create(purchase);
      purchases.add(created);
      await stockController.fetchStocks();
      globalController.triggerRefresh(DashboardRefreshType.all);
      clearForm();
      message.value = 'Purchase added successfully';
    } catch (e) {
      message.value = 'Failed to add purchase: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePurchase(PurchaseModel purchase) async {
    try {
      isLoading.value = true;
      final updated =
          await purchaseRepository.update(buildPurchase(id: purchase.id ?? 0));
      final index = purchases.indexWhere((p) => p.id == updated.id);
      if (index != -1) purchases[index] = updated;
      await stockController.fetchStocks();
      globalController.triggerRefresh(DashboardRefreshType.all);
      clearForm();
      message.value = 'Purchase updated successfully';
    } catch (e) {
      message.value = 'Failed to update purchase: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePurchase(int id) async {
    try {
      isLoading.value = true;
      await purchaseRepository.delete(id);
      purchases.removeWhere((p) => p.id == id);
      await stockController.fetchStocks();
      globalController.triggerRefresh(DashboardRefreshType.all);
    } catch (e) {
      message.value = 'Failed to delete purchase: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // =============================== //
  // FILTERS //
  // ===============================
  List<PurchaseModel> filteredPurchases({String query = ''}) {
    final q = query.toLowerCase();
    return purchases.where((p) {
      if (selectedSupplierId.value != null &&
          p.supplier != selectedSupplierId.value) {
        return false;
      }
      if (q.isNotEmpty) {
        final matches =
            p.items.any((i) => (i.itemName ?? '').toLowerCase().contains(q));
        if (!matches) return false;
      }
      return true;
    }).toList();
  }
}
