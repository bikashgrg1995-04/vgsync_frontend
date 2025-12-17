import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_detail_page.dart';
import 'sale_controller.dart';

class SaleListPage extends StatelessWidget {
  SaleListPage({super.key});

  final SaleController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales')),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.openAddSaleDialog,
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.sales.isEmpty) {
          return const Center(child: Text('No sales found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.sales.length,
          itemBuilder: (_, i) {
            final sale = controller.sales[i];

            return Slidable(
              key: ValueKey(sale.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => controller.openEditSaleDialog(sale),
                    icon: Icons.edit,
                    backgroundColor: Colors.blue,
                    label: 'Edit',
                  ),
                  SlidableAction(
                    onPressed: (_) => controller.deleteSale(sale.id!),
                    icon: Icons.delete,
                    backgroundColor: Colors.red,
                    label: 'Delete',
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () => Get.to(
                  () => SaleDetailPage(saleId: sale.id!),
                ),
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.point_of_sale),
                    title: Text('Customer ID: ${sale.customer}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${sale.saleDate}'),
                        Text(
                          'Total: Rs. ${sale.totalAmount ?? 0}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    trailing: sale.isServicing
                        ? const Chip(label: Text('Service'))
                        : const Chip(label: Text('Sale')),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
