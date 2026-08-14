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
  final VoidCallback onChanged;

  final quantity = 1.obs;
  final price = 0.0.obs;

  late TextEditingController quantityController;
  late TextEditingController priceController;

  PurchaseItemController({required this.item, required this.onChanged}) {
    quantity.value = item.quantity;
    price.value = item.price;

    quantityController = TextEditingController(text: quantity.value.toString());
    priceController = TextEditingController(
      text: price.value.toStringAsFixed(2),
    );

    quantityController.addListener(() {
      quantity.value = int.tryParse(quantityController.text) ?? 1;
      onChanged();
    });

    priceController.addListener(() {
      price.value = double.tryParse(priceController.text) ?? 0.0;
      onChanged();
    });
  }

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
  final selectedStaffId = RxnInt();

  // Discount (percent + amount pair)
  final discountPercentController = TextEditingController(text: '0');
  final discountAmountController = TextEditingController(text: '0');

  // Transit Discount (percent + amount pair)
  final transitDiscountPercentController = TextEditingController(text: '0');
  final transitDiscountAmountController = TextEditingController(text: '0');

  final paidController = TextEditingController(text: '0');
  final dateController = TextEditingController();

  // alongside dateController
  final billNoController = TextEditingController();

  final remaining = 0.0.obs;
  final purchaseStatus = 'not_paid'.obs;

  // VAT (percent + amount pair)
  final vatPercentController = TextEditingController(text: '0');
  final vatAmountController = TextEditingController(text: '0');

  // guards to prevent infinite listener loops
  bool _syncingDiscount = false;
  bool _syncingTransit = false;
  bool _syncingVat = false;

  // ✅ tolerance for floating point comparisons (paisa-level rounding noise)
  static const double _epsilon = 0.01;

  final StockController stockController = Get.find();
  final GlobalController globalController = Get.find();
  final SupplierController supplierController = Get.find();
  final ExpenseController expenseController = Get.find();

  Rx<DateTime?> filterSelectedDate = Rx<DateTime?>(null);
  RxString selectedStatus = 'all'.obs;
  final searchController = TextEditingController();
  final searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(items, (_) => _onItemsChanged());

    discountPercentController.addListener(_onDiscountPercentChanged);
    discountAmountController.addListener(_onDiscountAmountChanged);

    transitDiscountPercentController.addListener(_onTransitPercentChanged);
    transitDiscountAmountController.addListener(_onTransitAmountChanged);

    vatPercentController.addListener(_onVatPercentChanged);
    vatAmountController.addListener(_onVatAmountChanged);

    paidController.addListener(_recalculateTotals);

    supplierController.fetchSuppliers();
  }

  // =============================== //
  // ROUNDING HELPER //
  // ===============================
  // ✅ हरेक calculation लाई ठ्याक्कै 2 decimal places मा snap गर्छ,
  //    floating-point precision drift (0.6999999... जस्ता issues) हटाउन
  double _round2(double value) => (value * 100).roundToDouble() / 100;

  // =============================== //
  // SYNC LOGIC — DISCOUNT //
  // ===============================
  void _onDiscountPercentChanged() {
    if (_syncingDiscount) return;
    _syncingDiscount = true;

    final pct = double.tryParse(discountPercentController.text) ?? 0;
    final amount = _round2(total * (pct / 100));
    discountAmountController.text = amount.toStringAsFixed(2);

    _syncingDiscount = false;
    _recalculateTotals();
  }

  void _onDiscountAmountChanged() {
    if (_syncingDiscount) return;
    _syncingDiscount = true;

    final amount = double.tryParse(discountAmountController.text) ?? 0;
    final pct = total > 0 ? (amount / total) * 100 : 0;
    discountPercentController.text = pct.toStringAsFixed(2);

    _syncingDiscount = false;
    _recalculateTotals();
  }

  void _onTransitPercentChanged() {
    if (_syncingTransit) return;
    _syncingTransit = true;

    final pct = double.tryParse(transitDiscountPercentController.text) ?? 0;
    final base = amountBeforeTransitDiscount;
    final amount = _round2(base * (pct / 100));
    transitDiscountAmountController.text = amount.toStringAsFixed(2);

    _syncingTransit = false;
    _resyncVatFromPercent(); // ✅ ADD
    _recalculateTotals();
  }

  void _onTransitAmountChanged() {
    if (_syncingTransit) return;
    _syncingTransit = true;

    final amount = double.tryParse(transitDiscountAmountController.text) ?? 0;
    final base = amountBeforeTransitDiscount;
    final pct = base > 0 ? (amount / base) * 100 : 0;
    transitDiscountPercentController.text = pct.toStringAsFixed(2);

    _syncingTransit = false;
    _resyncVatFromPercent(); // ✅ ADD
    _recalculateTotals();
  }

  void _onItemsChanged() {
    final pct = double.tryParse(discountPercentController.text) ?? 0;
    if (pct > 0) {
      _syncingDiscount = true;
      discountAmountController.text = _round2(
        total * (pct / 100),
      ).toStringAsFixed(2);
      _syncingDiscount = false;
    }

    final transitPct =
        double.tryParse(transitDiscountPercentController.text) ?? 0;
    if (transitPct > 0) {
      _syncingTransit = true;
      transitDiscountAmountController.text = _round2(
        amountBeforeTransitDiscount * (transitPct / 100),
      ).toStringAsFixed(2);
      _syncingTransit = false;
    }

    _resyncVatFromPercent(); // ✅ ADD
    _recalculateTotals();
  }

  // =============================== //
  // SYNC LOGIC — VAT //
  // ===============================
  void _onVatPercentChanged() {
    if (_syncingVat) return;
    _syncingVat = true;

    final pct = double.tryParse(vatPercentController.text) ?? 0;
    final base = afterDiscountAmount;
    final amount = _round2(base * (pct / 100));
    vatAmountController.text = amount.toStringAsFixed(2);

    _syncingVat = false;
    _recalculateTotals();
  }

  void _onVatAmountChanged() {
    if (_syncingVat) return;
    _syncingVat = true;

    final amount = double.tryParse(vatAmountController.text) ?? 0;
    final base = afterDiscountAmount;
    final pct = base > 0 ? (amount / base) * 100 : 0;
    vatPercentController.text = pct.toStringAsFixed(2);

    _syncingVat = false;
    _recalculateTotals();
  }

  // afterDiscountAmount बदलिँदा (item वा transit बदलिँदा) VAT amount
  // लाई current percent अनुसार पुनः calculate गर्ने
  void _resyncVatFromPercent() {
    final vatPct = double.tryParse(vatPercentController.text) ?? 0;
    if (vatPct > 0) {
      _syncingVat = true;
      vatAmountController.text = _round2(
        afterDiscountAmount * (vatPct / 100),
      ).toStringAsFixed(2);
      _syncingVat = false;
    }
  }

  void _recalculateTotals() {
    final net = _round2(netTotal);
    final paid = _round2(double.tryParse(paidController.text) ?? 0);

    remaining.value = _round2(net - paid);

    // ✅ epsilon tolerance — 0.01 भित्रको difference लाई "बराबर" मान्ने
    if (paid <= 0) {
      purchaseStatus.value = 'pending';
    } else if (remaining.value <= _epsilon) {
      purchaseStatus.value = 'paid';
    } else {
      purchaseStatus.value = 'partial';
    }

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
  // CALCULATION BLOCK — rounded getters //
  // ===============================
  double get total =>
      _round2(items.fold<double>(0.0, (s, i) => s + i.totalPrice));

  double get discountPercent =>
      double.tryParse(discountPercentController.text) ?? 0;
  double get discountAmount =>
      _round2(double.tryParse(discountAmountController.text) ?? 0);

  double get amountBeforeTransitDiscount => _round2(total - discountAmount);

  double get transitDiscountPercent =>
      double.tryParse(transitDiscountPercentController.text) ?? 0;
  double get transitDiscountAmount =>
      _round2(double.tryParse(transitDiscountAmountController.text) ?? 0);

  double get afterDiscountAmount => // ✅ NEW
      _round2(amountBeforeTransitDiscount - transitDiscountAmount);

  double get vatPercent => // ✅ NEW
      double.tryParse(vatPercentController.text) ?? 0;
  double get vatAmount => // ✅ NEW
      _round2(double.tryParse(vatAmountController.text) ?? 0);

  double get netTotal => // ✅ CHANGED
      _round2(afterDiscountAmount + vatAmount);

  double get paidAmount => _round2(double.tryParse(paidController.text) ?? 0);
  double get grandTotal => total;

  // =============================== //
  // ITEM MANAGEMENT //
  // ===============================
  void addItem(StockModel stock) {
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
          item: stock.id,
          itemName: stock.name,
          quantity: 1,
          price: stock.purchasePrice,
        ),
        onChanged: _onItemsChanged,
      ),
    );
    isModified.value = true;
  }

  Future<void> pickPurchaseDate(BuildContext context) async {
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
    _onItemsChanged();
  }

  void clearItems() => items.clear();

  // =============================== //
  // FORM OPERATIONS //
  // ===============================
  void clearForm() {
    selectedSupplierId.value = null;
    selectedStaffId.value = null;
    billNoController.clear();
    discountPercentController.text = '0';
    discountAmountController.text = '0';
    transitDiscountPercentController.text = '0';
    transitDiscountAmountController.text = '0';
    vatPercentController.text = '0';    // ✅ ADD
    vatAmountController.text = '0';     // ✅ ADD
    paidController.text = '0';
    dateController.clear();
    clearItems();
  }

  void populateForm(PurchaseModel purchase) {
    selectedSupplierId.value = purchase.supplier;
    selectedStaffId.value = purchase.createdBy;
    billNoController.text = purchase.billNo ?? '';
    dateController.text = purchase.date.toIso8601String().split('T')[0];
    paidController.text = purchase.paidAmount.toStringAsFixed(2);

    discountAmountController.text = purchase.discountAmount.toStringAsFixed(2);
    discountPercentController.text =
        purchase.discountPercentage.toStringAsFixed(2);

    transitDiscountAmountController.text =
        purchase.transitDiscountAmount.toStringAsFixed(2);
    transitDiscountPercentController.text =
        purchase.transitDiscountPercentage.toStringAsFixed(2);

    vatAmountController.text = purchase.vatAmount.toStringAsFixed(2);       // ✅ ADD
    vatPercentController.text = purchase.vatPercentage.toStringAsFixed(2);  // ✅ ADD

    items.assignAll(
      purchase.items.map(
        (i) => PurchaseItemController(item: i, onChanged: _onItemsChanged),
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
      billNo: billNoController.text.trim().isEmpty
          ? null
          : billNoController.text.trim(),
      items: items
          .map(
            (i) => PurchaseItemModel(
              id: i.item.id,
              item: i.item.item,
              itemName: i.item.itemName,
              quantity: i.quantity.value,
              price: i.price.value,
            ),
          )
          .toList(),
      grandTotal: total,
      discountPercentage: discountPercent,
      discountAmount: discountAmount,
      amountBeforeTransitDiscount: amountBeforeTransitDiscount,
      transitDiscountPercentage: transitDiscountPercent,
      transitDiscountAmount: transitDiscountAmount,
      afterDiscountAmount: afterDiscountAmount,   // ✅ ADD
      vatPercentage: vatPercent,                  // ✅ ADD
      vatAmount: vatAmount,                       // ✅ ADD
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
      final updated = await purchaseRepository.update(
        buildPurchase(id: purchase.id ?? 0),
      );
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
    ConfirmDialog.show(
      context,
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
      },
    );
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

  // purchase_controller.dart मा थप्नुस् (SalesController.returnSaleItem जस्तै)

  Future<bool> returnPurchaseItem({
    required int purchaseId,
    required int purchaseItemId,
    required int quantity,
    String? reason,
  }) async {
    try {
      isLoading.value = true;
      await purchaseRepository.returnPurchaseItem(
        purchaseItemId: purchaseItemId,
        quantity: quantity,
        reason: reason,
      );

      // net_total/remaining/status backend मा recalc भइसकेकोले, list refetch गर्नु सजिलो र सुरक्षित छ
      await fetchPurchases();
      stockController.fetchStocks();
      globalController.triggerRefresh(DashboardRefreshType.all);

      DesktopToast.show(
        'Item returned successfully',
        backgroundColor: Colors.greenAccent,
      );
      return true;
    } catch (e) {
      DesktopToast.show(
        'Failed to return item: $e',
        backgroundColor: Colors.redAccent,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
