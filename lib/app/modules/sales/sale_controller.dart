import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/global_controller.dart';
import '../../data/models/sale_model.dart';
import '../../data/models/sale_item_model.dart';
import '../../data/repositories/sale_repository.dart';
import '../followups/followup_controller.dart';
import '../items/item_controller.dart';

class SaleController extends GetxController {
  final SaleRepository saleRepository;
  final GlobalController globalController = Get.find<GlobalController>();
  final ItemController itemControllerInstance =
      Get.find<ItemController>(); // guaranteed to exist
  final FollowUpController followUpController = Get.find<FollowUpController>();

  SaleController({required this.saleRepository});

  var sales = <SaleModel>[].obs;
  var isLoading = false.obs;

  // Form controllers
  final customerController = TextEditingController();
  final dateController = TextEditingController();
  final isServicingController = TextEditingController();
  final itemController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    fetchSales();
  }

  @override
  void onClose() {
    customerController.dispose();
    dateController.dispose();
    isServicingController.dispose();
    itemController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.onClose();
  }

  Future<void> fetchSales() async {
    try {
      isLoading.value = true;
      final result = await saleRepository.fetchSales();
      sales.assignAll(result); // ✅ better than sales.value =
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSale() async {
    final sale = SaleModel(
      customer: int.parse(customerController.text),
      saleDate: dateController.text,
      isServicing: isServicingController.text.toLowerCase() == 'true',
      items: [
        SaleItemModel(
          item: int.parse(itemController.text),
          quantity: int.parse(quantityController.text),
          price: double.parse(priceController.text),
        ),
      ],
    );

    final created = await saleRepository.addSale(sale);
    sales.add(created);

    await refreshAll();
    Get.back();
  }

  Future<void> updateSale(SaleModel oldSale) async {
    final updatedSale = SaleModel(
      id: oldSale.id,
      customer: int.parse(customerController.text),
      saleDate: dateController.text,
      isServicing: isServicingController.text.toLowerCase() == 'true',
      items: [
        SaleItemModel(
          item: int.parse(itemController.text),
          quantity: int.parse(quantityController.text),
          price: double.parse(priceController.text),
        ),
      ],
    );

    final updated =
        await saleRepository.editSale(oldSale.id!, updatedSale.toJson());

    final index = sales.indexWhere((s) => s.id == updated.id);
    if (index != -1) sales[index] = updated;

    await refreshAll();
    Get.back();
    Get.back();
  }

  Future<void> deleteSale(int id) async {
    await saleRepository.removeSale(id);
    sales.removeWhere((s) => s.id == id);

    await refreshAll();
  }

  // -----------------------------
  // Helpers
  // -----------------------------
  void fillForm(SaleModel sale) {
    customerController.text = sale.customer.toString();
    dateController.text = sale.saleDate;
    isServicingController.text = sale.isServicing.toString();

    if (sale.items.isNotEmpty) {
      itemController.text = sale.items.first.item.toString();
      quantityController.text = sale.items.first.quantity.toString();
      priceController.text = sale.items.first.price.toString();
    }
  }

  void clearForm() {
    customerController.clear();
    dateController.clear();
    isServicingController.clear();
    itemController.clear();
    quantityController.clear();
    priceController.clear();
  }

  Future<void> refreshAll() async {
    await fetchSales();
    await itemControllerInstance.fetchItems();
    await followUpController.fetchFollowUps();

    globalController.triggerRefresh();
    itemControllerInstance.triggerRefresh();
    followUpController.triggerRefresh();
  }

  // -----------------------------
  // Dialogs
  // -----------------------------
  void openAddSaleDialog() {
    clearForm();
    Get.dialog(
      AlertDialog(
        title: const Text('Add Sale'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: customerController,
                decoration: const InputDecoration(labelText: 'Customer ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: dateController,
                decoration:
                    const InputDecoration(labelText: 'Sale Date (YYYY-MM-DD)'),
              ),
              TextField(
                controller: isServicingController,
                decoration: const InputDecoration(
                    labelText: 'Is Servicing (true/false)'),
              ),
              TextField(
                controller: itemController,
                decoration: const InputDecoration(labelText: 'Item ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(onPressed: addSale, child: const Text('Save')),
        ],
      ),
    );
  }

  void openEditSaleDialog(SaleModel sale) {
    fillForm(sale);
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Sale'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: customerController,
                decoration: const InputDecoration(labelText: 'Customer ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Sale Date'),
              ),
              TextField(
                controller: isServicingController,
                decoration: const InputDecoration(
                    labelText: 'Is Servicing (true/false)'),
              ),
              TextField(
                controller: itemController,
                decoration: const InputDecoration(labelText: 'Item ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => updateSale(sale), child: const Text('Update')),
        ],
      ),
    );
  }
}
