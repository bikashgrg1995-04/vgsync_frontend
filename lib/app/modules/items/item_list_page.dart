import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/item_model.dart';
import 'package:vgsync_frontend/app/modules/customers/customer_detail_page.dart';
import 'package:vgsync_frontend/app/modules/items/item_controller.dart';
import 'package:vgsync_frontend/app/modules/items/item_detail_page.dart';
import '../../data/models/customer_model.dart';
import '../../modules/customers/customer_controller.dart';
import '../../wigdets/custom_form_dialog.dart';

class ItemListPage extends StatelessWidget {
  ItemListPage({super.key});

  final itemController = Get.find<ItemController>();
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Items')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: (_) => itemController.items.refresh(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search items...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (itemController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final query = searchController.text.toLowerCase();
              final filtered = itemController.items.where((c) {
                return c.name.toLowerCase().contains(query) ||
                    c.group.toLowerCase().contains(query) ||
                    (c.model.toLowerCase().contains(query));
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
                            onPressed: (_) =>
                                itemController.deleteItem(c.id ?? 0),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () => openItemDetail(c),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                            title: Text(c.name),
                            subtitle: Text(c.stock.toString()),
                            trailing: const Icon(Icons.drag_handle,
                                color: Colors.grey),
                          ),
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
        label: const Text('Add Item'),
      ),
    );
  }

  void openAddDialog() {
    itemController.clearForm();
    Get.dialog(CustomFormDialog(
      title: "Add Item",
      isEditMode: false,
      content: Column(
        children: [
          TextField(
              controller: itemController.nameController,
              decoration: const InputDecoration(labelText: 'Name')),
          TextField(
              controller: itemController.groupController,
              decoration: const InputDecoration(labelText: 'Group')),
          TextField(
              controller: itemController.modelController,
              decoration: const InputDecoration(labelText: 'Model')),
          TextField(
              controller: itemController.stockController,
              decoration: const InputDecoration(labelText: 'Stock')),
          TextField(
              controller: itemController.purchasePriceController,
              decoration: const InputDecoration(labelText: 'Purchase Price')),
          TextField(
              controller: itemController.salePriceController,
              decoration: const InputDecoration(labelText: 'Sale Price')),
          TextField(
              controller: itemController.categoryController,
              decoration: const InputDecoration(labelText: 'Category')),
        ],
      ),
      onSave: () => itemController.addItem(),
    ));
  }

  void openEditDialog(ItemModel item) {
    itemController.fillForm(item);
    Get.dialog(CustomFormDialog(
      title: "Edit Item",
      isEditMode: true,
      content: Column(
        children: [
          TextField(
              controller: itemController.nameController,
              decoration: const InputDecoration(labelText: 'Name')),
          TextField(
              controller: itemController.groupController,
              decoration: const InputDecoration(labelText: 'Group')),
          TextField(
              controller: itemController.modelController,
              decoration: const InputDecoration(labelText: 'Model')),
          TextField(
              controller: itemController.stockController,
              decoration: const InputDecoration(labelText: 'Stock')),
          TextField(
              controller: itemController.purchasePriceController,
              decoration: const InputDecoration(labelText: 'Purchase Price')),
          TextField(
              controller: itemController.salePriceController,
              decoration: const InputDecoration(labelText: 'Sale Price')),
          TextField(
              controller: itemController.categoryController,
              decoration: const InputDecoration(labelText: 'Category')),
        ],
      ),
      onSave: () => itemController.updateItem(item),
      onDelete: () => itemController.deleteItem(item.id ?? 0),
    ));
  }

  void openItemDetail(ItemModel item) {
    Get.to(() => ItemDetailPage(itemId: item.id ?? 0));
  }
}
