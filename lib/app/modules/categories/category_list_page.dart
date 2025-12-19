import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import '../../data/models/category_model.dart';
import '../../modules/categories/category_controller.dart';
import '../../wigdets/custom_form_dialog.dart';

class CategoryListPage extends StatelessWidget {
  CategoryListPage({super.key});

  final controller = Get.find<CategoryController>();
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search categories...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final query = searchController.text.toLowerCase();
              final filtered = controller.categories.where((c) {
                return c.name.toLowerCase().contains(query);
              }).toList();

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final c = filtered[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Slidable(
                      key: ValueKey(c.id),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.35,
                        children: [
                          SlidableAction(
                            onPressed: (_) => openEditDialog(c),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                          SlidableAction(
                            onPressed: (_) => controller.delete(c.id),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              '${index + 1}', // numbering
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                          title: Text(c.name),
                          trailing:
                              const Icon(Icons.drag_handle, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  void openAddDialog() {
    controller.clearForm();
    Get.dialog(CustomFormDialog(
      title: "Add Category",
      isEditMode: false,
      content: TextField(
        controller: controller.nameController,
        decoration: const InputDecoration(labelText: 'Name'),
      ),
      onSave: () => controller.addCategory(),
    ));
  }

  void openEditDialog(CategoryModel category) {
    controller.fillForm(category);
    Get.dialog(CustomFormDialog(
      title: "Edit Category",
      isEditMode: true,
      content: TextField(
        controller: controller.nameController,
        decoration: const InputDecoration(labelText: 'Name'),
      ),
      onSave: () => controller.updateCategory(category),
      onDelete: () => controller.delete(category.id),
    ));
  }
}
