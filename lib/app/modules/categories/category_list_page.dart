import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../data/models/category_model.dart';
import '../../modules/categories/category_controller.dart';
import '../../wigdets/custom_form_dialog.dart';

class CategoryListPage extends StatelessWidget {
  CategoryListPage({super.key});

  final controller = Get.find<CategoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.sw(0.03)),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: SizeConfig.sw(0.45),
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search Category...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.sw(0.02)),
                      ),
                    ),
                    onChanged: (_) => controller.categories.refresh(),
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
                actionButton(
                  label: 'Refresh',
                  icon: Icons.refresh,
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.refreshCategories,
                ),
              ],
            ),
            SizedBox(height: SizeConfig.sh(0.02)),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final query = controller.searchController.text.toLowerCase();
                final filtered = controller.categories.where((c) {
                  return c.name.toLowerCase().contains(query);
                }).toList();

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final c = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Slidable(
                        key: ValueKey(c.id),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.35,
                          children: [
                            SlidableAction(
                              onPressed: (_) => openCategoryDialog(category: c),
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (_) {
                                controller.delete(c.id);
                              },
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
                            trailing: const Icon(Icons.drag_handle,
                                color: Colors.grey),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openCategoryDialog(category: null),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  void openCategoryDialog({CategoryModel? category}) {
    final bool isEditMode = category != null;

    if (isEditMode) {
      controller.fillForm(category);
    } else {
      controller.clearForm();
    }

    Get.dialog(
      CustomFormDialog(
        title: isEditMode ? "Edit Category" : "Add Category",
        isEditMode: isEditMode,
        width: 0.25,
        height: 0.3,
        content: buildTextField(
          controller.nameController,
          'Name',
          Icons.category,
        ),
        onSave: () {
          if (isEditMode) {
            controller.updateCategory(category);
          } else {
            controller.addCategory();
          }
        },
        onDelete: isEditMode
            ? () {
                controller.delete(category.id);
              }
            : null,
      ),
    );
  }
}
