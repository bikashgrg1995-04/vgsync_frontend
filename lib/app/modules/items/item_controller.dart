import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/models/item_model.dart';
import 'package:vgsync_frontend/app/data/repositories/item_repository.dart';

class ItemController extends GetxController {
  final ItemRepository itemRepository;
  final GlobalController globalController = Get.find<GlobalController>();

  ItemController({required this.itemRepository});

  var items = <ItemModel>[].obs;
  var isLoading = false.obs;

  // Form controllers
  late TextEditingController nameController;
  late TextEditingController groupController;
  late TextEditingController modelController;
  late TextEditingController stockController;
  late TextEditingController purchasePriceController;
  late TextEditingController salePriceController;
  late TextEditingController categoryController;

  @override
  void onInit() {
    super.onInit();
    fetchItems();

    nameController = TextEditingController();
    groupController = TextEditingController();
    modelController = TextEditingController();
    stockController = TextEditingController();
    purchasePriceController = TextEditingController();
    salePriceController = TextEditingController();
    categoryController = TextEditingController();
  }

  @override
  void onClose() {
    nameController.dispose();
    groupController.dispose();
    modelController.dispose();
    stockController.dispose();
    purchasePriceController.dispose();
    salePriceController.dispose();
    categoryController.dispose();
    super.onClose();
  }

  /// increases whenever any data changes
  final RxInt refreshTick = 0.obs;
  void triggerRefresh() {
    refreshTick.value++;
  }

  Future<void> fetchItems() async {
    try {
      isLoading.value = true;
      items.value = await itemRepository.fetchItems();
    } catch (e) {
      print("Error fetching items: $e");
      items.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addItem() async {
    final newItem = await itemRepository.addItem(
      ItemModel(
        id: 0,
        name: nameController.text,
        group: groupController.text,
        model: modelController.text,
        stock: int.parse(stockController.text),
        purchasePrice: double.parse(purchasePriceController.text),
        salePrice: double.parse(salePriceController.text),
        category: int.parse(categoryController.text),
        image: null,
      ),
    );
    items.add(newItem);

    fetchItems();
    globalController.triggerRefresh();

    clearForm();
    Get.back();
  }

  Future<void> updateItem(ItemModel oldItem) async {
    final updatedItem = await itemRepository.editItem(
      ItemModel(
        id: oldItem.id,
        name: nameController.text,
        group: groupController.text,
        model: modelController.text,
        stock: int.parse(stockController.text),
        purchasePrice: double.parse(purchasePriceController.text),
        salePrice: double.parse(salePriceController.text),
        category: int.parse(categoryController.text),
        image: oldItem.image,
      ),
    );

    final index = items.indexWhere((i) => i.id == updatedItem.id);
    if (index != -1) items[index] = updatedItem;
    fetchItems();
    globalController.triggerRefresh();
    Get.back();
  }

  Future<void> deleteItem(int id) async {
    await itemRepository.removeItem(id);
    items.removeWhere((i) => i.id == id);

    fetchItems();
    globalController.triggerRefresh();
  }

  // Populate form fields for edit
  void fillForm(ItemModel item) {
    nameController.text = item.name;
    groupController.text = item.group;
    modelController.text = item.model;
    stockController.text = item.stock.toString();
    purchasePriceController.text = item.purchasePrice.toString();
    salePriceController.text = item.salePrice.toString();
    categoryController.text = item.category.toString();
  }

  // Populate form fields for edit
  void clearForm() {
    nameController.clear();
    groupController.clear();
    modelController.clear();
    stockController.clear();
    purchasePriceController.clear();
    salePriceController.clear();
    categoryController.clear();
  }
}
