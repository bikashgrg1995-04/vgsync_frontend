import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import 'followup_controller.dart';

class FollowUpListPage extends StatefulWidget {
  const FollowUpListPage({super.key});

  @override
  State<FollowUpListPage> createState() => _FollowUpListPageState();
}

class _FollowUpListPageState extends State<FollowUpListPage> {
  final FollowUpController controller = Get.find<FollowUpController>();
  final TextEditingController searchController = TextEditingController();

  final RxString selectedStatus = 'All'.obs;

  // ---------------- Helpers ----------------
  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'terminated':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  // ---------------- Status Chips ----------------
  Widget _buildStatusChips() {
    final statuses = ['All', 'Pending', 'Completed', 'Terminated'];

    return Obx(() => Wrap(
          spacing: SizeConfig.sw(0.02),
          children: statuses.map((status) {
            final isSelected = selectedStatus.value == status;

            return ChoiceChip(
              label: Text(status),
              selected: isSelected,
              selectedColor: status == 'All'
                  ? Colors.blue.withOpacity(0.2)
                  : _statusColor(status).withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? (status == 'All' ? Colors.blue : _statusColor(status))
                    : Colors.black,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => selectedStatus.value = status,
            );
          }).toList(),
        ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchFollowUps();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.sw(0.03)),
        child: Column(
          children: [
            SizedBox(height: SizeConfig.sh(0.015)),

            // ---------------- Search + Refresh ----------------
            Row(
              children: [
                SizedBox(
                  width: SizeConfig.sw(0.45),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search follow-ups...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.sw(0.02)),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
                Obx(
                  () => actionButton(
                    label: 'Refresh',
                    icon: Icons.refresh,
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.fetchFollowUps,
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeConfig.sh(0.02)),

            // ---------------- Status Filters ----------------
            _buildStatusChips(),

            SizedBox(height: SizeConfig.sh(0.015)),

            // ---------------- Follow-up List ----------------
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final query = searchController.text.toLowerCase();

                final filtered = controller.followUps.where((f) {
                  final matchesSearch = query.isEmpty ||
                      f.customerName.toLowerCase().contains(query) ||
                      (f.contactNo ?? '').toLowerCase().contains(query) ||
                      (f.vehicle ?? '').toLowerCase().contains(query) ||
                      (f.remarks ?? '').toLowerCase().contains(query) ||
                      f.saleId.toString().contains(query);

                  final matchesStatus = selectedStatus.value == 'All' ||
                      (f.status ?? 'pending').toLowerCase() ==
                          selectedStatus.value.toLowerCase();

                  return matchesSearch && matchesStatus;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No follow-ups found'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final followUp = filtered[index];
                    final isTerminated =
                        followUp.status?.toLowerCase() == 'terminated';

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.sw(0.01),
                        vertical: SizeConfig.sh(0.005),
                      ),
                      child: Slidable(
                        key: ValueKey(followUp.id),
                        endActionPane: isTerminated
                            ? null
                            : ActionPane(
                                motion: const DrawerMotion(),
                                extentRatio: 0.35,
                                children: [
                                  SlidableAction(
                                    onPressed: (_) => _showTerminateDialog(followUp.id),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.cancel,
                                    label: 'Terminate',
                                  ),
                                ],
                              ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(SizeConfig.sw(0.01)),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(SizeConfig.sw(0.012)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ---------- Top ----------
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      followUp.customerName,
                                      style: TextStyle(
                                        fontSize: SizeConfig.sw(0.013),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: SizeConfig.sw(0.015),
                                        vertical: SizeConfig.sh(0.004),
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusColor(followUp.status)
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        followUp.status ?? 'Pending',
                                        style: TextStyle(
                                          color: _statusColor(followUp.status),
                                          fontSize: SizeConfig.sw(0.009),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: SizeConfig.sh(0.006)),

                                if (followUp.vehicle != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.directions_bike,
                                          size: 16, color: Colors.grey),
                                      SizedBox(width: SizeConfig.sw(0.01)),
                                      Text(
                                        followUp.vehicle!,
                                        style: TextStyle(
                                            fontSize: SizeConfig.sw(0.009)),
                                      ),
                                    ],
                                  ),

                                SizedBox(height: SizeConfig.sh(0.006)),

                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 14, color: Colors.grey),
                                    SizedBox(width: SizeConfig.sw(0.01)),
                                    Text(
                                      'Delivery: ${_formatDate(followUp.deliveryDate)}',
                                      style: TextStyle(
                                          fontSize: SizeConfig.sw(0.0085)),
                                    ),
                                    SizedBox(width: SizeConfig.sw(0.03)),
                                    Text(
                                      'Follow-up: ${_formatDate(followUp.followUpDate)}',
                                      style: TextStyle(
                                          fontSize: SizeConfig.sw(0.0085)),
                                    ),
                                  ],
                                ),

                                if (followUp.remarks != null &&
                                    followUp.remarks!.isNotEmpty) ...[
                                  SizedBox(height: SizeConfig.sh(0.006)),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.notes,
                                          size: 14, color: Colors.grey),
                                      SizedBox(width: SizeConfig.sw(0.01)),
                                      Expanded(
                                        child: Text(
                                          followUp.remarks!,
                                          style: TextStyle(
                                              fontSize: SizeConfig.sw(0.0085)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
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
      ),
    );
  }

  void _showTerminateDialog(int followUpId) {
    final TextEditingController reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("Terminate Follow-up"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Are you sure you want to terminate this follow-up?",
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: "Reason (optional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Get.back();
              await controller.terminateFollowUp(
                followUpId,
                reason: reasonController.text.trim(),
              );
            },
            child: const Text("Terminate"),
          ),
        ],
      ),
    );
  }
}
