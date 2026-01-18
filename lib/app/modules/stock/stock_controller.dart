import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/stock_model.dart';
import 'package:vgsync_frontend/app/data/repositories/stock_repository.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import '../../controllers/global_controller.dart';

class StockController extends GetxController {
  final StockRepository stockRepository;
  final GlobalController globalController = Get.find<GlobalController>();

  StockController({required this.stockRepository});

  // ================= CONFIG =================
  static const double vatRate = 0.13;

  // ================= STATE =================
  var stocks = <Result>[].obs;
  var isLoading = false.obs;

  RxBool isImporting = false.obs;

  // ================= CONTROLLERS =================
  late TextEditingController nameController;
  late TextEditingController groupController;
  late TextEditingController modelController;
  late TextEditingController stockQtyController;
  late TextEditingController purchasePriceController;
  late TextEditingController salePriceController;
  late TextEditingController categorySelectController;
  late TextEditingController itemNoController;

  final searchController = TextEditingController();

  // ================= LIFECYCLE =================
  @override
  void onReady() async {
    super.onReady();

    nameController = TextEditingController();
    groupController = TextEditingController();
    modelController = TextEditingController();
    stockQtyController = TextEditingController();
    purchasePriceController = TextEditingController();
    salePriceController = TextEditingController();
    categorySelectController = TextEditingController();
    itemNoController = TextEditingController();

    // 🔥 Auto calculate sale price when purchase price changes
    purchasePriceController.addListener(_calculateSalePrice);

    await fetchStocks();
  }

  @override
  void onClose() {
    purchasePriceController.removeListener(_calculateSalePrice);

    nameController.dispose();
    groupController.dispose();
    modelController.dispose();
    stockQtyController.dispose();
    purchasePriceController.dispose();
    salePriceController.dispose();
    categorySelectController.dispose();
    itemNoController.dispose();

    super.onClose();
  }

  // ================= VAT CALCULATION =================
  void _calculateSalePrice() {
    final text = purchasePriceController.text;

    if (text.isEmpty) {
      salePriceController.text = '';
      return;
    }

    final purchase = double.tryParse(text);
    if (purchase == null) {
      salePriceController.text = '';
      return;
    }

    final salePrice = purchase + (purchase * vatRate);
    salePriceController.text = salePrice.toStringAsFixed(2);
  }

  // ================= API =================
  Future<void> fetchStocks() async {
    try {
      isLoading.value = true;
      stocks.value = await stockRepository.getStocks();
    } catch (e) {
      stocks.clear();
      debugPrint("Error fetching stocks: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addStock() async {
    final stock = Result(
      itemNo: itemNoController.text,
      name: nameController.text,
      group: groupController.text,
      model: modelController.text,
      stock: int.tryParse(stockQtyController.text) ?? 0,
      purchasePrice: double.tryParse(purchasePriceController.text) ?? 0.0,
      salePrice: double.tryParse(salePriceController.text) ?? 0.0,
      category: int.tryParse(categorySelectController.text) ?? 0,
      image: null,
    );

    final newStock = await stockRepository.create(stock);

    stocks.add(newStock);
    globalController.triggerRefresh(DashboardRefreshType.stock);

    clearForm();
  }

  Future<void> updateStock(Result oldStock) async {
    final updated = Result(
      id: oldStock.id,
      itemNo: itemNoController.text,
      name: nameController.text,
      group: groupController.text,
      model: modelController.text,
      stock: int.tryParse(stockQtyController.text) ?? 0,
      purchasePrice: double.tryParse(purchasePriceController.text) ?? 0.0,
      salePrice: double.tryParse(salePriceController.text) ?? 0.0,
      category: int.tryParse(categorySelectController.text) ?? 0,
      image: oldStock.image,
    );

    final result = await stockRepository.update(updated);

    final index = stocks.indexWhere((s) => s.id == result.id);
    if (index != -1) stocks[index] = result;

    globalController.triggerRefresh(DashboardRefreshType.stock);
  }

  Future<void> deleteStock(BuildContext context, int id) async {
    ConfirmDialog.show(
      context,
      title: "Delete Stock",
      message: "Are you sure you want to delete this stock item?",
      onConfirm: () async {
        await stockRepository.delete(id);
        stocks.removeWhere((s) => s.id == id);

        globalController.triggerRefresh(DashboardRefreshType.stock);
        Get.back(closeOverlays: true);
        DesktopToast.show(
          "Stock item deleted successfully.",
          backgroundColor: Colors.greenAccent,
        );
      },
      confirmText: "Delete",
      cancelText: "Cancel",
      snackbarColor: Colors.green,
      snackbarIcon: Icons.check_circle,
    );
  }

  Result? getStockById(int id) {
    try {
      return stocks.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ================= FORM =================
  void fillForm(Result stock) {
    nameController.text = stock.name;
    groupController.text = stock.group;
    modelController.text = stock.model;
    stockQtyController.text = stock.stock.toString();
    purchasePriceController.text = stock.purchasePrice.toString();
    salePriceController.text = stock.salePrice.toString();
    categorySelectController.text = stock.category.toString();
    itemNoController.text = stock.itemNo.toString();
  }

  void clearForm() {
    nameController.clear();
    groupController.clear();
    modelController.clear();
    stockQtyController.clear();
    purchasePriceController.clear();
    salePriceController.clear();
    categorySelectController.clear();
    itemNoController.clear();
  }

  Future<void> refreshStock() async {
    searchController.clear();
    await fetchStocks();
  }
}
