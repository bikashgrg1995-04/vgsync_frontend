import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/item_model.dart';
import 'item_controller.dart';

class ItemDetailPage extends StatelessWidget {
  final int itemId;

  ItemDetailPage({super.key, required this.itemId});

  final ItemController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ItemModel? item =
          controller.items.firstWhereOrNull((i) => i.id == itemId);

      if (item == null) {
        return const Scaffold(
          body: Center(child: Text('Item not found')),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Item Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _openEditDialog(item),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await controller.deleteItem(item.id ?? 0);
                Get.back();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row('Name', item.name),
              _row('Group', item.group),
              _row('Model', item.model),
              _row('Stock', item.stock.toString()),
              _row('Purchase Price', 'Rs. ${item.purchasePrice}'),
              _row('Sale Price', 'Rs. ${item.salePrice}'),
              _row('Category', item.category.toString()),
            ],
          ),
        ),
      );
    });
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _openEditDialog(ItemModel item) {
    controller.fillForm(item);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: controller.groupController,
                decoration: const InputDecoration(labelText: 'Group'),
              ),
              TextField(
                controller: controller.modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: controller.stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock'),
              ),
              TextField(
                controller: controller.purchasePriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Purchase Price'),
              ),
              TextField(
                controller: controller.salePriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sale Price'),
              ),
              TextField(
                controller: controller.categoryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Category ID'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await controller.updateItem(item);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
