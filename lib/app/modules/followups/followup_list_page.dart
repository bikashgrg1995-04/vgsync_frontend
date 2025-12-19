import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/followup_model.dart';
import 'package:vgsync_frontend/app/data/models/sale_model.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_controller.dart';

class FollowupListPage extends StatelessWidget {
  FollowupListPage({super.key});

  final FollowUpController controller = Get.find();
  final TextEditingController searchController = TextEditingController();

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
                hintText: 'Search followup...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final query = searchController.text.toLowerCase();

              final filtered = controller.followUps.where((followUp) {
                return followUp.sale.toString().contains(query) ||
                    followUp.followUpDate.toLowerCase().contains(query);
              }).toList();

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final p = filtered[index];

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Slidable(
                      key: ValueKey(p.id),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.35,
                        children: [
                          // SlidableAction(
                          //   onPressed: (_) => openEditDialog(p),
                          //   backgroundColor: Colors.orange,
                          //   foregroundColor: Colors.white,
                          //   icon: Icons.edit,
                          //   label: 'Edit',
                          // ),
                          // SlidableAction(
                          //   onPressed: (_) => controller.deleteFollowUp(p.id!),
                          //   backgroundColor: Colors.red,
                          //   foregroundColor: Colors.white,
                          //   icon: Icons.delete,
                          //   label: 'Delete',
                          // ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () => openDetail(p),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                            title: Text(
                              'Customer ID: ${p.sale}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: ${p.followUpDate}'),
                                Text('Total: Rs ${p.remarks}'),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.drag_handle,
                              color: Colors.grey,
                            ),
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
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: controller.openAddFollowUpDialog,
      //   icon: const Icon(Icons.add),
      //   label: const Text('Add Sale'),
      // ),
    );
  }

  void openDetail(FollowUpModel followUp) {
    //Get.to(() => FollowupDetailPage(followUpId: followUp.id));
  }

  void openEditDialog(SaleModel sale) {
    // controller.openAddSaleDialog();
    // controller.openEditSaleDialog(sale);
  }
}
