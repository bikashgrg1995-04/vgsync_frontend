import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import 'followup_controller.dart';

class FollowUpListPage extends StatefulWidget {
  const FollowUpListPage({super.key});

  @override
  State<FollowUpListPage> createState() => _FollowUpListPageState();
}

class _FollowUpListPageState extends State<FollowUpListPage> {
  final FollowUpController controller = Get.find<FollowUpController>();
  final searchController = TextEditingController();

  final RxString selectedStatus = 'All'.obs;

  @override
  void initState() {
    super.initState();
    controller.fetchFollowUps();
  }

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
                Flexible(
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
                SizedBox(
                  width: SizeConfig.sw(0.12),
                  child: ElevatedButton.icon(
                    onPressed: controller.fetchFollowUps,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text("Refresh"),
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

                final filtered = controller.followUps.where((f) {
                  final query = searchController.text.toLowerCase();

                  final matchesSearch =
                      f.remarks.toString().toLowerCase().contains(query) ||
                          f.customerName.toLowerCase().contains(query) ||
                          f.sale.toString().contains(query);

                  final matchesStatus = selectedStatus.value == 'All' ||
                      f.status?.toLowerCase() ==
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

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.sw(0.01),
                        vertical: SizeConfig.sh(0.005),
                      ),
                      child: Slidable(
                        key: ValueKey(followUp.id),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.35,
                          children: [
                            SlidableAction(
                              onPressed: (_) =>
                                  controller.terminateFollowUp(followUp.id),
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
                                            fontSize: SizeConfig.sw(0.0085),
                                          ),
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
}
