// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:vgsync_frontend/app/wigdets/category_dropdown.dart';
// import 'package:vgsync_frontend/app/wigdets/custom_form_dialog.dart';
// import '../../data/models/stock_model.dart';
// import 'stock_controller.dart';

// class ItemDetailPage extends StatelessWidget {
//   final int itemId;

//   ItemDetailPage({super.key, required this.itemId});

//   final StockController itemController = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final ItemModel? item =
//           itemController.items.firstWhereOrNull((i) => i.id == itemId);

//       if (item == null) {
//         return const Scaffold(
//           body: Center(child: Text('Item not found')),
//         );
//       }

//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Item Details'),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: () => openEditDialog(item),
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: () async {
//                 await itemController.deleteItem(item.id ?? 0);
//                 Get.back();
//               },
//             ),
//           ],
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _row('Name', item.name),
//               _row('Group', item.group),
//               _row('Model', item.model),
//               _row('Stock', item.stock.toString()),
//               _row('Purchase Price', 'Rs. ${item.purchasePrice}'),
//               _row('Sale Price', 'Rs. ${item.salePrice}'),
//               _row('Category', item.category.toString()),
//             ],
//           ),
//         ),
//       );
//     });
//   }

//   Widget _row(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }

//   void openEditDialog(ItemModel item) {
//     itemController.fillForm(item);
//     Get.dialog(CustomFormDialog(
//       title: "Edit Item",
//       isEditMode: true,
//       content: Column(
//         children: [
//           TextField(
//               controller: itemController.nameController,
//               decoration: const InputDecoration(labelText: 'Name')),
//           TextField(
//               controller: itemController.categoryController,
//               enabled: false,
//               decoration: const InputDecoration(labelText: 'Category')),
//           CategoryDropdown(
//             groupController: itemController.groupController,
//             categoryIdController: itemController.categoryController,
//           ),
//           TextField(
//               controller: itemController.modelController,
//               decoration: const InputDecoration(labelText: 'Model')),
//           TextField(
//               controller: itemController.stockController,
//               decoration: const InputDecoration(labelText: 'Stock')),
//           TextField(
//               controller: itemController.purchasePriceController,
//               decoration: const InputDecoration(labelText: 'Purchase Price')),
//           TextField(
//               controller: itemController.salePriceController,
//               decoration: const InputDecoration(labelText: 'Sale Price')),
//         ],
//       ),
//       onSave: () => itemController.updateItem(item),
//       onDelete: () => itemController.deleteItem(item.id ?? 0),
//     ));
//   }
// }
