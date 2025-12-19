import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/categories/category_controller.dart';
import '../data/models/category_model.dart';

class CategoryDropdown extends StatelessWidget {
  final TextEditingController groupController;
  final TextEditingController categoryIdController;

  CategoryDropdown({
    super.key,
    required this.groupController,
    required this.categoryIdController,
  });

  final CategoryController categoryController = Get.find<CategoryController>();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: groupController,
      readOnly: true, // 🔑 IMPORTANT
      decoration: const InputDecoration(
        labelText: 'Group',
        suffixIcon: Icon(Icons.arrow_drop_down),
      ),
      onTap: _openCategoryPicker, // ✅ ALWAYS FIRES
    );
  }

  void _openCategoryPicker() {
    final List<CategoryModel> allCategories =
        List.from(categoryController.categories);

    final searchController = TextEditingController();
    List<CategoryModel> filtered = allCategories;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: 420,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search category...',
                  ),
                  onChanged: (value) {
                    setState(() {
                      filtered = allCategories
                          .where((c) => c.name
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No categories found'))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, index) {
                            final category = filtered[index];
                            return ListTile(
                              title: Text(category.name),
                              onTap: () {
                                groupController.text = category.name;
                                categoryIdController.text =
                                    category.id.toString();
                                Get.back();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
