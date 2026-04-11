import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/models/stock_model.dart';
import 'package:vgsync_frontend/app/data/repositories/stock_repository.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';

class StockController extends GetxController {
  final StockRepository stockRepository;
  final GlobalController globalController = Get.find<GlobalController>();

  StockController({required this.stockRepository});

  // ================= CONFIG =================
  static const double vatRate = 0.13;

  // ================= STATE =================
  var stocks = <StockModel>[].obs;
  var isLoading = false.obs;

  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  // ================= FORM CONTROLLERS =================
  late TextEditingController nameController;
  late TextEditingController groupController;
  late TextEditingController modelController;
  late TextEditingController stockQtyController;
  late TextEditingController purchasePriceController;
  late TextEditingController salePriceController;
  late TextEditingController categorySelectController;
  late TextEditingController itemNoController;
  late TextEditingController blockController;

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
    blockController = TextEditingController();

    purchasePriceController.addListener(_calculateSalePrice);

    //await fetchStocks();
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
    blockController.dispose();

    super.onClose();
  }

  // ================= VAT CALCULATION =================
  void _calculateSalePrice() {
    final text = purchasePriceController.text;
    final purchase = double.tryParse(text) ?? 0.0;
    salePriceController.text = (purchase * (1 + vatRate)).toStringAsFixed(2);
  }

  // ================= API =================

  Future<void> fetchStocks() async {
    try {
      isLoading.value = true;
      final result = await stockRepository.getStocks();
      stocks.assignAll(result);
    } catch (e) {
      stocks.clear();
      DesktopToast.show(
        'Failed to fetch stocks',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Add Stock ----------------
  Future<bool> addStock() async {
   final stock = StockModel(
  id: 0, // 👈 required (backend ignores)
  itemNo: itemNoController.text,
  name: nameController.text,
  group: groupController.text,
  model: modelController.text,
  stock: int.tryParse(stockQtyController.text) ?? 0,
  purchasePrice: double.tryParse(purchasePriceController.text) ?? 0.0,
  salePrice: double.tryParse(salePriceController.text) ?? 0.0,
  category: int.tryParse(categorySelectController.text) ?? 0,
  block: blockController.text,
  image: null,
);

    if ([stock.name, stock.itemNo].any((e) => e.isEmpty)) {
      DesktopToast.show(
        'Item No and Name are required',
        backgroundColor: Colors.redAccent,
      );
      return false;
    }

    try {
      isLoading.value = true;
      final newStock = await stockRepository.create(stock);
      stocks.add(newStock);
      globalController.triggerRefresh(DashboardRefreshType.stock);
      clearForm();
      Get.back(closeOverlays: true);
      DesktopToast.show(
        'Stock added successfully',
        backgroundColor: Colors.greenAccent,
      );

      return true;
    } catch (e) {
      DesktopToast.show(
        'Failed to add stock',
        backgroundColor: Colors.redAccent,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Update Stock ----------------
  Future<bool> updateStock(StockModel oldStock) async {
    final updated = StockModel(
  id: oldStock.id,
  itemNo: itemNoController.text,
  name: nameController.text,
  group: groupController.text,
  model: modelController.text,
  stock: int.tryParse(stockQtyController.text) ?? 0,
  purchasePrice: double.tryParse(purchasePriceController.text) ?? 0.0,
  salePrice: double.tryParse(salePriceController.text) ?? 0.0,
  category: int.tryParse(categorySelectController.text) ?? 0,
  block: blockController.text,
  image: oldStock.image,
);

    if ([updated.name, updated.itemNo].any((e) => e.isEmpty)) {
      DesktopToast.show(
        'Item No and Name are required',
        backgroundColor: Colors.redAccent,
      );
      return false;
    }

    try {
      isLoading.value = true;
      final result = await stockRepository.update(updated);
      final index = stocks.indexWhere((s) => s.id == result.id);
      if (index != -1) stocks[index] = result;

      globalController.triggerRefresh(DashboardRefreshType.stock);
      Get.back(closeOverlays: true);
      DesktopToast.show(
        'Stock updated successfully',
        backgroundColor: Colors.greenAccent,
      );

      return true;
    } catch (e) {
      print('Error updating stock: $e');
      DesktopToast.show(
        'Failed to update stock',
        backgroundColor: Colors.redAccent,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteStock(BuildContext context, int id) async {
    ConfirmDialog.show(
      context,
      title: "Delete Stock",
      message: "Are you sure you want to delete this stock item?",
      confirmText: "Delete",
      cancelText: "Cancel",
      onConfirm: () async {
        try {
          isLoading.value = true;
          final success = await _deleteStockById(id);
          if (!success) {
            Get.back(closeOverlays: true);

            DesktopToast.show(
              'Failed to delete stock',
              backgroundColor: Colors.redAccent,
            );
          }
        } catch (e) {
          DesktopToast.show(
            'Failed to delete stock',
            backgroundColor: Colors.redAccent,
          );
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  // ---------------- Delete Stock ----------------
  Future<bool> _deleteStockById(int id) async {
    try {
      isLoading.value = true;
      await stockRepository.delete(id);
      stocks.removeWhere((s) => s.id == id);
      globalController.triggerRefresh(DashboardRefreshType.stock);
      Get.back(closeOverlays: true);
      DesktopToast.show(
        'Stock deleted successfully',
        backgroundColor: Colors.greenAccent,
      );
      return true;
    } catch (e) {
      DesktopToast.show(
        'Failed to delete stock',
        backgroundColor: Colors.redAccent,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Helper Methods ----------------
  StockModel? getStockById(int id) {
    try {
      return stocks.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void fillForm(StockModel stock) {
    itemNoController.text = stock.itemNo;
    nameController.text = stock.name;
    groupController.text = stock.group;
    modelController.text = stock.model;
    stockQtyController.text = stock.stock.toString();
    purchasePriceController.text = stock.purchasePrice.toString();
    salePriceController.text = stock.salePrice.toString();
    categorySelectController.text = stock.category.toString();
    blockController.text = stock.block.toString();
  }

  void clearForm() {
    itemNoController.clear();
    nameController.clear();
    groupController.clear();
    modelController.clear();
    stockQtyController.clear();
    purchasePriceController.clear();
    salePriceController.clear();
    categorySelectController.clear();
    blockController.clear();
  }

  void updateSearch(String query) {
    searchQuery.value = query.trim().toLowerCase();
  }

  Future<void> refreshStock() async {
    searchController.clear();
    searchQuery.value = '';
    await fetchStocks();
  }
}
