// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:vgsync_frontend/app/data/models/sale_model.dart';
// import 'package:vgsync_frontend/app/modules/sales/sale_controller.dart';
// import '../controllers/sales_controller.dart';
// import '../models/sale_model.dart';

// class SaleDetailPage extends StatelessWidget {
//   const SaleDetailPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<SalesController>();
//     final int saleId = Get.arguments;

//     final SaleModel sale = controller.getSaleById(saleId);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sale Details'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _sectionTitle('Customer Info'),
//             _infoRow('Name', sale.customerName),
//             _infoRow('Contact', sale.contactNo ?? '-'),
//             _infoRow('Bill No', sale.billNo ?? '-'),
//             const SizedBox(height: 12),
//             _sectionTitle('Payment'),
//             _infoRow('Total', 'Rs ${sale.totalAmount}'),
//             _infoRow('Paid', 'Rs ${sale.paidAmount}'),
//             _infoRow('Remaining', 'Rs ${sale.remainingAmount}'),
//             _infoRow('Status', sale.isPaid),
//             _infoRow('Paid From', sale.paidFrom),
//             const SizedBox(height: 12),
//             _sectionTitle('Vehicle / Service'),
//             _infoRow('Servicing', sale.isServicing ? 'Yes' : 'No'),
//             _infoRow('Bike No', sale.bikeRegistrationNo ?? '-'),
//             _infoRow('KM Driven', sale.kmDriven?.toString() ?? '-'),
//             _infoRow('Vehicle Color', sale.vehicleColor ?? '-'),
//             _infoRow('Labour Charge', 'Rs ${sale.labourCharge}'),
//             const SizedBox(height: 12),
//             _sectionTitle('Purchased Items'),
//             const SizedBox(height: 8),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: sale.items.length,
//               itemBuilder: (context, index) {
//                 final item = sale.items[index];

//                 return Card(
//                   child: ListTile(
//                     title: Text(item.itemName),
//                     subtitle: Text(
//                       'Qty: ${item.quantity}',
//                     ),
//                     trailing: Text(
//                       'Rs ${item.price.toStringAsFixed(2)}',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 16),
//             _sectionTitle('Remarks'),
//             Text(sale.remarks ?? '-'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _sectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }

//   Widget _infoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 130,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }
// }
