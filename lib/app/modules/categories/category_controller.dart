import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/app/wigdets/custom_notification.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

class CategoryController extends GetxController {
  final CategoryRepository categoryRepository;
  final GlobalController globalController = Get.find<GlobalController>();
  final StockController stockController = Get.find<StockController>();

  CategoryController({required this.categoryRepository});

  var categories = <CategoryModel>[].obs;
  var isLoading = false.obs;
  var isSaving = false.obs;

  final nameController = TextEditingController();

  final searchController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final result = await categoryRepository.getAllCategories();
      categories.assignAll(result); // ✅ better than categories.value =
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    try {
      isSaving.value = true;
     final newCategory = CategoryModel(
  id: 0, // dummy (backend ignores)
  name: name,
);

      final added = await categoryRepository.addCategory(newCategory);
      categories.add(added); // reactive update

      stockController.fetchStocks();
      globalController
          .triggerRefresh(DashboardRefreshType.stock); // ✅ WRITE event

      Get.back(closeOverlays: true);
       DesktopToast.show('Category added successfully',  backgroundColor: Colors.greenAccent,);
  

      clearForm();
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    try {
      isSaving.value = true;
      final updated = CategoryModel(id: category.id, name: name);
      final res = await categoryRepository.updateCategory(updated);

      final index = categories.indexWhere((c) => c.id == res.id);
      if (index != -1) categories[index] = res; // reactive update

      stockController.fetchStocks();
      globalController.triggerRefresh(DashboardRefreshType.stock);

      clearForm();

      Get.back(closeOverlays: true);
      DesktopToast.show('Category updated successfully',  backgroundColor: Colors.greenAccent,);
   
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(int id) async {
    ConfirmDialog.show(
      Get.context!,
      title: "Delete Category",
      message: "Are you sure you want to delete this category?",
      onConfirm: () async {
        await categoryRepository.deleteCategory(id);
        categories.removeWhere((c) => c.id == id);

        globalController.triggerRefresh(DashboardRefreshType.stock);

        Get.back(closeOverlays: true);
         DesktopToast.show("Category deleted successfully.",  backgroundColor: Colors.greenAccent,);
       
      },
      confirmText: "Delete",
      cancelText: "Cancel",
      snackbarColor: Colors.green,
      snackbarIcon: Icons.check_circle,
    );
  }

  void fillForm(CategoryModel category) {
    nameController.text = category.name;
  }

  void clearForm() {
    nameController.clear();
  }

  Future<void> refreshCategories() async {
    // 🔥 RESET FILTERS

    searchController.clear();

    await fetchCategories();
  }
}
