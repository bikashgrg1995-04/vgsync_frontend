import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import '../../data/models/followup_model.dart';
import '../../modules/followups/followup_controller.dart';
import '../../wigdets/common_detail_page.dart';

class FollowupListPage extends StatelessWidget {
  FollowupListPage({super.key});

  final controller = Get.find<FollowUpController>();
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Follow-Ups'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: (_) => controller.followUps.refresh(), // optional
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search follow-ups...',
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
              final filtered = controller.followUps.where((f) {
                return f.sale.toString().contains(query) ||
                    f.remarks.toLowerCase().contains(query) ||
                    f.followUpDate.toLowerCase().contains(query);
              }).toList();

              if (filtered.isEmpty)
                return const Center(child: Text("No follow-ups"));

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final f = filtered[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Slidable(
                      key: ValueKey(f.id),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.35,
                        children: [
                          SlidableAction(
                            onPressed: (_) => openFollowupDetail(f),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                          SlidableAction(
                            onPressed: (_) => controller.delete(f.id),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () => openFollowupDetail(f),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text('Sale #${f.sale}'),
                            subtitle: Text(
                                'Follow-Up Date: ${f.followUpDate}\nRemarks: ${f.remarks}'),
                            isThreeLine: true,
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
    );
  }

  void openFollowupDetail(FollowUpModel f) {
    Get.to(() => CommonDetailPage<FollowUpModel>(
          title: 'Follow-Up #${f.id}',
          data: f,
          fields: [
            FieldData(label: 'Sale ID', getter: (f) => f.sale.toString()),
            FieldData(label: 'Service Date', getter: (f) => f.serviceDate),
            FieldData(label: 'Follow-Up Date', getter: (f) => f.followUpDate),
            FieldData(
                label: 'Completed', getter: (f) => f.completed ? 'Yes' : 'No'),
            FieldData(label: 'Remarks', getter: (f) => f.remarks),
          ],
          formFields: [
            FieldData(
                label: 'Sale ID',
                getter: (f) => f.sale.toString(),
                updateData: (f, v) => f.sale = int.parse(v)),
            FieldData(
                label: 'Service Date',
                getter: (f) => f.serviceDate,
                updateData: (f, v) => f.serviceDate = v),
            FieldData(
                label: 'Follow-Up Date',
                getter: (f) => f.followUpDate,
                updateData: (f, v) => f.followUpDate = v),
            FieldData(
                label: 'Completed',
                getter: (f) => f.completed ? 'Yes' : 'No',
                updateData: (f, v) => f.completed = v.toLowerCase() == 'yes'),
            FieldData(
                label: 'Remarks',
                getter: (f) => f.remarks,
                updateData: (f, v) => f.remarks = v),
          ],
          onUpdate: (f) => controller.updateFollowUp(f),
          onDelete: (f) => controller.delete(f.id),
        ));
  }
}
