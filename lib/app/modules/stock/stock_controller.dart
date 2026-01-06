import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/stock_model.dart';
import 'package:vgsync_frontend/app/data/repositories/stock_repository.dart';
import '../../controllers/global_controller.dart';

class StockController extends GetxController {
  final StockRepository stockRepository;
  final GlobalController globalController = Get.find<GlobalController>();

  StockController({required this.stockRepository});

  var stocks = <Result>[].obs;
  var isLoading = false.obs;

  late TextEditingController nameController;
  late TextEditingController groupController;
  late TextEditingController modelController;
  late TextEditingController stockQtyController;
  late TextEditingController purchasePriceController;
  late TextEditingController salePriceController;
  late TextEditingController categoryController;
  late TextEditingController itemNoController;

  @override
  void onReady() async {
    super.onReady();
    nameController = TextEditingController();
    groupController = TextEditingController();
    modelController = TextEditingController();
    stockQtyController = TextEditingController();
    purchasePriceController = TextEditingController();
    salePriceController = TextEditingController();
    categoryController = TextEditingController();
    itemNoController = TextEditingController();

    await fetchStocks();
  }

  @override
  void onClose() {
    nameController.dispose();
    groupController.dispose();
    modelController.dispose();
    stockQtyController.dispose();
    purchasePriceController.dispose();
    salePriceController.dispose();
    categoryController.dispose();
    itemNoController.dispose();
    super.onClose();
  }

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
      category: int.tryParse(categoryController.text) ?? 0,
      image: null,
    );

    final newStock = await stockRepository.create(stock);
    stocks.add(newStock);
    globalController.triggerRefresh(DashboardRefreshType.stock);

    clearForm();
    Get.back();
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
      category: int.tryParse(categoryController.text) ?? 0,
      image: oldStock.image,
    );

    final result = await stockRepository.update(updated);

    final index = stocks.indexWhere((s) => s.id == result.id);
    if (index != -1) stocks[index] = result;

    globalController.triggerRefresh(DashboardRefreshType.stock);
    Get.back();
  }

  Future<void> deleteStock(int id) async {
    await stockRepository.delete(id);
    stocks.removeWhere((s) => s.id == id);

    globalController.triggerRefresh(DashboardRefreshType.stock);
  }

  Result? findById(int id) {
    try {
      return stocks.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void fillForm(Result stock) {
    nameController.text = stock.name;
    groupController.text = stock.group;
    modelController.text = stock.model;
    stockQtyController.text = stock.stock.toString();
    purchasePriceController.text = stock.purchasePrice.toString();
    salePriceController.text = stock.salePrice.toString();
    categoryController.text = stock.category.toString();
    itemNoController.text = stock.itemNo.toString();
  }

  void clearForm() {
    nameController.clear();
    groupController.clear();
    modelController.clear();
    stockQtyController.clear();
    purchasePriceController.clear();
    salePriceController.clear();
    categoryController.clear();
    itemNoController.clear();
  }
}
