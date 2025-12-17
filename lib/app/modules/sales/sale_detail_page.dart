import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/sale_model.dart';
import 'sale_controller.dart';

class SaleDetailPage extends StatelessWidget {
  final int saleId;
  SaleDetailPage({super.key, required this.saleId});

  final SaleController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final SaleModel? sale =
          controller.sales.firstWhereOrNull((s) => s.id == saleId);

      if (sale == null) {
        return const Scaffold(
          body: Center(child: Text('Sale not found')),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Sale Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => controller.openEditSaleDialog(sale),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await controller.deleteSale(sale.id!);
                Get.back();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _row('Customer ID', sale.customer.toString()),
              _row('Date', sale.saleDate),
              _row('Type', sale.isServicing ? 'Servicing' : 'Sale'),
              _row('Total Amount', 'Rs. ${sale.totalAmount ?? 0}'),
              const SizedBox(height: 20),
              const Text(
                'Items',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ...sale.items.map(
                (item) => Card(
                  child: ListTile(
                    title: Text('Item ID: ${item.item}'),
                    subtitle: Text(
                      'Qty: ${item.quantity}  |  Price: Rs. ${item.price}',
                    ),
                    trailing: Text(
                      'Rs. ${item.totalPrice ?? item.quantity * item.price}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
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
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
