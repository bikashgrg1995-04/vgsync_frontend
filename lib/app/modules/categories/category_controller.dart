import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

class CategoryController extends GetxController {
  final CategoryRepository categoryRepository;
  final GlobalController globalController = Get.find<GlobalController>();

  CategoryController({required this.categoryRepository});

  var categories = <CategoryModel>[].obs;
  var isLoading = false.obs;
  var isSaving = false.obs;

  final nameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final list = await categoryRepository.getAllCategories();
      categories.assignAll(list);
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
        id: categories.isEmpty ? 1 : categories.last.id + 1, // temporary id
        name: name,
      );

      final added = await categoryRepository.addCategory(newCategory);
      categories.add(added); // reactive update
      fetchCategories();
      globalController.triggerRefresh(); // ✅ WRITE event
      clearForm();
      Get.back();
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

      fetchCategories();
      globalController.triggerRefresh(); // ✅ WRITE event

      clearForm();
      Get.back();
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(int id) async {
    await categoryRepository.deleteCategory(id);
    categories.removeWhere((c) => c.id == id); // reactive update
    fetchCategories();
    globalController.triggerRefresh(); // ✅ WRITE event
  }

  void fillForm(CategoryModel category) {
    nameController.text = category.name;
  }

  void clearForm() {
    nameController.clear();
  }
}
