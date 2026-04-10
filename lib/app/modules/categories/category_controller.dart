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

  /// 🔥 MAIN STATE
  var categories = <CategoryModel>[].obs;
  var isLoading = false.obs;
  var isSaving = false.obs;

  /// 🔥 SEARCH STATE (IMPORTANT FIX)
  var searchQuery = ''.obs;

  /// FORM
  final nameController = TextEditingController();
  final searchController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    fetchCategories();
  }

  /// ================= FETCH =================
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final result = await categoryRepository.getAllCategories();
      categories.assignAll(result);
    } catch (e) {
      DesktopToast.show("Failed to load categories", backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= ADD =================
  Future<void> addCategory() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    try {
      isSaving.value = true;

      final newCategory = CategoryModel(
        id: 0,
        name: name,
      );

      final added = await categoryRepository.addCategory(newCategory);
      categories.add(added);

      stockController.fetchStocks();
      globalController.triggerRefresh(DashboardRefreshType.stock);

      Get.back(closeOverlays: true);
      DesktopToast.show('Category added successfully',
          backgroundColor: Colors.greenAccent);

      clearForm();
    } catch (e) {
      DesktopToast.show("Failed to add category", backgroundColor: Colors.red);
    } finally {
      isSaving.value = false;
    }
  }

  /// ================= UPDATE =================
  Future<void> updateCategory(CategoryModel category) async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    try {
      isSaving.value = true;

      final updated = CategoryModel(id: category.id, name: name);
      final res = await categoryRepository.updateCategory(updated);

      final index = categories.indexWhere((c) => c.id == res.id);
      if (index != -1) categories[index] = res;

      stockController.fetchStocks();
      globalController.triggerRefresh(DashboardRefreshType.stock);

      clearForm();

      Get.back(closeOverlays: true);
      DesktopToast.show('Category updated successfully',
          backgroundColor: Colors.greenAccent);
    } catch (e) {
      DesktopToast.show("Failed to update category", backgroundColor: Colors.red);
    } finally {
      isSaving.value = false;
    }
  }

  /// ================= DELETE =================
  Future<void> delete(int id) async {
    ConfirmDialog.show(
      Get.context!,
      title: "Delete Category",
      message: "Are you sure you want to delete this category?",
      onConfirm: () async {
        try {
          await categoryRepository.deleteCategory(id);
          categories.removeWhere((c) => c.id == id);

          globalController.triggerRefresh(DashboardRefreshType.stock);

          Get.back(closeOverlays: true);
          DesktopToast.show("Category deleted successfully.",
              backgroundColor: Colors.greenAccent);
        } catch (e) {
          DesktopToast.show("Delete failed", backgroundColor: Colors.red);
        }
      },
      confirmText: "Delete",
      cancelText: "Cancel",
      snackbarColor: Colors.green,
      snackbarIcon: Icons.check_circle,
    );
  }

  /// ================= FORM =================
  void fillForm(CategoryModel category) {
    nameController.text = category.name;
  }

  void clearForm() {
    nameController.clear();
  }

  /// ================= SEARCH =================
  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  List<CategoryModel> get filteredCategories {
    final query = searchQuery.value.toLowerCase();

    if (query.isEmpty) return categories;

    return categories
        .where((c) => c.name.toLowerCase().contains(query))
        .toList();
  }

  /// ================= REFRESH =================
  Future<void> refreshCategories() async {
    searchController.clear();
    searchQuery.value = '';
    await fetchCategories();
  }
}