import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/modules/expenses/expense_controller.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_controller.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
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

  // Convert reactive form back to model
  PurchaseItemModel toModel() {
    final qty = int.tryParse(quantityController.text) ?? 0;
    final price = double.tryParse(priceController.text) ?? 0.0;
    return PurchaseItemModel(
      id: item.id,
      item: item.item,
      quantity: qty,
      price: price,
      totalPrice: qty * price,
      itemName: item.itemName,
    );
  }

  String get itemName => item.itemName ?? '';
  double get totalPrice => quantity.value * price.value;
}

/// ===============================
/// Purchase Controller (VAT removed)
/// ===============================
class PurchaseController extends GetxController {
  final PurchaseRepository purchaseRepository;

  PurchaseController({required this.purchaseRepository});

  // ---------------- STATE ----------------
  final purchases = <PurchaseModel>[].obs;
  final items = <PurchaseItemController>[].obs;
  final isLoading = false.obs;

  final isModified = false.obs;

  // ---------------- FORM ----------------
  final selectedSupplierId = RxnInt();
  final selectedStaffId = RxnInt(); // Created by staff
  final discountController = TextEditingController(text: '0');
  final paidController = TextEditingController(text: '0');
  final dateController = TextEditingController();

  // Reactive calculation for remaining & status
  final remaining = 0.0.obs;
  final purchaseStatus = 'not_paid'.obs;

  // ---------------- CONTROLLERS ----------------
  final StockController stockController = Get.find();
  final GlobalController globalController = Get.find();
  final SupplierController supplierController = Get.find();
  final ExpenseController expenseController = Get.find();

  //filter
  Rx<DateTime?> filterSelectedDate = Rx<DateTime?>(null);
  RxString selectedStatus = 'all'.obs;
  final searchController = TextEditingController();
  final searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Recalculate when items change
    ever(items, (_) => _recalculateTotals());

    // Recalculate when discount changes
    discountController.addListener(_recalculateTotals);

    // Recalculate when paid amount changes
    paidController.addListener(_recalculateTotals);

    supplierController.fetchSuppliers();
  }

  void _recalculateTotals() {
    final t = items.fold<double>(0.0, (s, i) => s + i.totalPrice);
    final disc = double.tryParse(discountController.text) ?? 0;
    final discAmount = disc == 0 ? 0 : t * disc / 100;

    final net = t - discAmount;
    final paid = double.tryParse(paidController.text) ?? 0;

    remaining.value = net - paid;

    if (paid <= 0) {
      purchaseStatus.value = 'not_paid';
    } else if (remaining.value <= 0) {
      purchaseStatus.value = 'paid';
    } else {
      purchaseStatus.value = 'partial';
    }

    // mark as modified whenever totals recalc
    isModified.value = true;
  }

  // ---------------- FETCH ----------------
  Future<void> fetchPurchases() async {
    try {
      isLoading.value = true;
      purchases.assignAll(await purchaseRepository.getPurchases());
    } catch (e) {
      DesktopToast.show(
        'Failed to fetch purchases: $e',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =============================== //
  // CALCULATION BLOCK //
  // ===============================
  double get total => items.fold<double>(0.0, (s, i) => s + i.totalPrice);
  double get discountPercent => double.tryParse(discountController.text) ?? 0;
  double get discountAmount =>
      discountPercent == 0 ? 0 : total * discountPercent / 100;
  double get netTotal => total - discountAmount;
  double get paidAmount => double.tryParse(paidController.text) ?? 0;
  double get grandTotal => total;

  // =============================== //
  // ITEM MANAGEMENT //
  // ===============================
  void addItem(Result stock) {
    // Check if item is already added
    final exists = items.any((i) => i.item.item == stock.id);
    if (exists) {
      DesktopToast.show(
        'This item is already added',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    items.add(
      PurchaseItemController(
        item: PurchaseItemModel(
          item: stock.id!,
          itemName: stock.name,
          quantity: 1,
          price: stock.purchasePrice,
        ),
        onChanged: _recalculateTotals,
      ),
    );
    isModified.value = true;
  }

  Future<void> pickPurchaseDate(BuildContext context) async {
    // Use current date if the field is empty or invalid
    final initialDate =
        DateTime.tryParse(dateController.text) ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      dateController.text = picked.toIso8601String().split('T')[0];
    }
  }

  void removeItem(PurchaseItemController item) {
    items.remove(item);
    _recalculateTotals();
  }

  void clearItems() => items.clear();

  // =============================== //
  // FORM OPERATIONS //
  // ===============================
  void clearForm() {
    selectedSupplierId.value = null;
    selectedStaffId.value = null;
    discountController.text = '0';
    paidController.text = '0';
    dateController.clear();
    clearItems();
  }

  void populateForm(PurchaseModel purchase) {
    selectedSupplierId.value = purchase.supplier;
    selectedStaffId.value = purchase.createdBy;
    dateController.text = purchase.date.toIso8601String().split('T')[0];
    paidController.text = purchase.paidAmount.toString();

    // Calculate discount %
    final itemsTotal = purchase.items
        .fold<double>(0.0, (sum, i) => sum + (i.price * i.quantity));

    discountController.text = itemsTotal == 0
        ? '0'
        : ((purchase.discountAmount * 100) / itemsTotal).toStringAsFixed(2);

    // Replace items list completely with fresh controllers
    items.assignAll(
      purchase.items.map(
        (i) => PurchaseItemController(
          item: i,
          onChanged: _recalculateTotals,
        ),
      ),
    );

    _recalculateTotals();
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
      netTotal: netTotal,
      paidAmount: paidAmount,
      remainingAmount: remaining.value,
      status: purchaseStatus.value,
      createdBy: selectedStaffId.value,
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
      await fetchPurchases();

      await stockController.fetchStocks();
      await expenseController.fetchExpenses();
      globalController.triggerRefresh(DashboardRefreshType.all);
      clearForm();

      Get.back(closeOverlays: true);
      DesktopToast.show(
        'Purchase added successfully',
        backgroundColor: Colors.greenAccent,
      );
    } catch (e) {
      DesktopToast.show(
        'Failed to add purchase: $e',
        backgroundColor: Colors.redAccent,
      );
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
      await fetchPurchases();
      await stockController.fetchStocks();
      await expenseController.fetchExpenses();
      globalController.triggerRefresh(DashboardRefreshType.all);

      clearForm();
      isModified.value = false;
      Get.back(closeOverlays: true);
      DesktopToast.show(
        'Purchase updated successfully',
        backgroundColor: Colors.greenAccent,
      );
    } catch (e) {
      DesktopToast.show(
        'Failed to update purchase: $e',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePurchase(BuildContext context, int id) async {
    ConfirmDialog.show(context,
        title: "Delete Purchase",
        message: "Are you sure you want to delete this Purchase?",
        onConfirm: () async {
      try {
        isLoading.value = true;
        await purchaseRepository.delete(id);
        purchases.removeWhere((o) => o.id == id);
        await fetchPurchases();
        await stockController.fetchStocks();
        await expenseController.fetchExpenses();
        globalController.triggerRefresh(DashboardRefreshType.all);

        Get.back(closeOverlays: true);
        DesktopToast.show(
          "Purchase Deleted: Success",
          backgroundColor: Colors.greenAccent,
        );
      } catch (e) {
        DesktopToast.show(
          "Failed to delete purchase.",
          backgroundColor: Colors.redAccent,
        );
      } finally {
        isLoading.value = false;
      }
    });
  }

  Future<void> refreshSales() async {
    filterSelectedDate.value = null;
    searchText.value = '';
    searchController.clear();
    selectedStatus.value = "all";

    await fetchPurchases();
  }

  void clearModifiedFlag() {
    isModified.value = false;
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

      if (filterSelectedDate.value != null) {
        final date = filterSelectedDate.value!;
        if (p.date.year != date.year ||
            p.date.month != date.month ||
            p.date.day != date.day) {
          return false;
        }
      }

      if (selectedStatus.value != 'all' && p.status != selectedStatus.value) {
        return false;
      }

      if (q.isNotEmpty &&
          !p.items.any((i) => (i.itemName ?? '').toLowerCase().contains(q))) {
        return false;
      }

      return true;
    }).toList();
  }
}
