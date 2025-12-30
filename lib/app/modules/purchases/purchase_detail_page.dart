// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../data/models/purchase_model.dart';
// import 'purchase_controller.dart';

// class PurchaseDetailPage extends StatelessWidget {
//   final int purchaseId;
//   PurchaseDetailPage({required this.purchaseId});

//   final controller = Get.find<PurchaseController>();

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final PurchaseModel? purchase =
//           controller.purchases.firstWhereOrNull((p) => p.id == purchaseId);

//       if (purchase == null) {
//         return const Scaffold(
//           body: Center(child: Text('Purchase not found')),
//         );
//       }

//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Purchase Details'),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: () => openEditDialog(purchase),
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: () async {
//                 await controller.deletePurchase(purchase.id!);
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
//               row('Supplier', purchase.supplier.toString()),
//               row('Date', purchase.date),
//               row('Total', 'Rs ${purchase.totalAmount}'),
//               const SizedBox(height: 12),
//               const Text('Items',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//               ...purchase.items.map((i) => ListTile(
//                     title: Text('Item ID: ${i.item}'),
//                     subtitle: Text('Qty: ${i.quantity} × Rs ${i.price}'),
//                     trailing: Text('Rs ${i.totalPrice ?? 0}'),
//                   )),
//             ],
//           ),
//         ),
//       );
//     });
//   }

//   Widget row(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         children: [
//           Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }

//   void openEditDialog(PurchaseModel purchase) {
//     controller.fillForm(purchase);

//     Get.dialog(
//       AlertDialog(
//         title: const Text('Edit Purchase'),
//         content: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(
//                   controller: controller.supplierController,
//                   decoration: const InputDecoration(labelText: 'Supplier')),
//               TextField(
//                   controller: controller.dateController,
//                   decoration: const InputDecoration(labelText: 'Date')),
//               TextField(
//                   controller: controller.itemController,
//                   decoration: const InputDecoration(labelText: 'Item ID')),
//               TextField(
//                   controller: controller.quantityController,
//                   decoration: const InputDecoration(labelText: 'Quantity')),
//               TextField(
//                   controller: controller.priceController,
//                   decoration: const InputDecoration(labelText: 'Price')),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: Get.back, child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () => controller.updatePurchase(purchase),
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }
// }
