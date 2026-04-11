import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../themes/app_colors.dart';
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

  // ── Color aliases ──────────────────────────────────────────────────────────
  static const _bg       = AppColors.background;
  static const _surface  = AppColors.surface;
  static const _primary  = AppColors.primary;
  static const _warning  = AppColors.warning;
  static const _danger   = AppColors.error;
  static const _textDark = AppColors.textPrimary;
  static const _textMid  = AppColors.textSecondary;
  static const _border   = AppColors.divider;
  static const _shadow   = Color(0x0F000000);

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'terminated': return _danger;
      default:           return _warning;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.fetchFollowUps());
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: _bg,
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.res(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.sh(0.015)),
            _buildPageTitle(),
            SizedBox(height: SizeConfig.sh(0.018)),
            _buildHeader(),
            SizedBox(height: SizeConfig.sh(0.016)),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Follow-ups',
            style: TextStyle(
                fontSize: SizeConfig.res(7),
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: -0.5)),
        Text('Track and manage customer follow-ups',
            style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textMid)),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(SizeConfig.res(4)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: const [BoxShadow(color: _shadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: SizeConfig.sh(0.055),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: _textMid, size: SizeConfig.res(5)),
                      hintText: 'Search follow-ups...',
                      hintStyle: TextStyle(color: _textMid, fontSize: SizeConfig.res(3.4)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: SizeConfig.sh(0.015)),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.sw(0.012)),
              Obx(() => _headerBtn(
                    label: 'Refresh',
                    icon: Icons.refresh_rounded,
                    color: _primary,
                    onPressed: controller.isLoading.value ? null : controller.fetchFollowUps,
                  )),
            ],
          ),
          SizedBox(height: SizeConfig.sh(0.016)),
          Obx(() => Row(
                children: ['All', 'Pending', 'Terminated'].map((s) {
                  final isSelected = selectedStatus.value == s;
                  final color = s == 'Terminated' ? _danger : s == 'Pending' ? _warning : _primary;
                  return Padding(
                    padding: EdgeInsets.only(right: SizeConfig.sw(0.008)),
                    child: GestureDetector(
                      onTap: () => selectedStatus.value = s,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.sw(0.012),
                            vertical: SizeConfig.sh(0.010)),
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isSelected ? color : color.withOpacity(0.3)),
                        ),
                        child: Text(s,
                            style: TextStyle(
                                fontSize: SizeConfig.res(3),
                                fontWeight: FontWeight.w600,
                                color: isSelected ? _surface : color)),
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _headerBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.sw(0.014), vertical: SizeConfig.sh(0.013)),
        decoration: BoxDecoration(
          color: onPressed == null ? _border.withOpacity(0.3) : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: onPressed == null ? _border : color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: SizeConfig.res(4.5),
                color: onPressed == null ? _textMid : color),
            SizedBox(width: SizeConfig.sw(0.005)),
            Text(label,
                style: TextStyle(
                    fontSize: SizeConfig.res(3.2),
                    fontWeight: FontWeight.w600,
                    color: onPressed == null ? _textMid : color)),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: _primary));
      }

      final query = searchController.text.toLowerCase();
      final filtered = controller.followUps.where((f) {
        final matchSearch = query.isEmpty ||
            f.customerName.toLowerCase().contains(query) ||
            (f.contactNo ?? '').toLowerCase().contains(query) ||
            (f.vehicle ?? '').toLowerCase().contains(query) ||
            (f.remarks ?? '').toLowerCase().contains(query) ||
            f.saleId.toString().contains(query);
        final matchStatus = selectedStatus.value == 'All' ||
            (f.status ?? 'pending').toLowerCase() ==
                selectedStatus.value.toLowerCase();
        return matchSearch && matchStatus;
      }).toList();

      if (filtered.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.support_agent_outlined,
                  size: SizeConfig.res(18), color: _border),
              SizedBox(height: SizeConfig.sh(0.015)),
              Text('No follow-ups found',
                  style: TextStyle(fontSize: SizeConfig.res(4), color: _textMid)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.only(bottom: SizeConfig.sh(0.05)),
        itemCount: filtered.length,
        itemBuilder: (_, index) {
          final f = filtered[index];
          final isTerminated = f.status?.toLowerCase() == 'terminated';
          final statusColor = _statusColor(f.status);

          return Padding(
            padding: EdgeInsets.only(bottom: SizeConfig.sh(0.012)),
            child: Slidable(
              key: ValueKey(f.id),
              endActionPane: isTerminated
                  ? null
                  : ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.22,
                      children: [
                        SlidableAction(
                          onPressed: (_) => _showTerminateDialog(f.id),
                          backgroundColor: _danger,
                          foregroundColor: _surface,
                          icon: Icons.cancel_rounded,
                          label: 'Terminate',
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ],
                    ),
              child: Container(
                padding: EdgeInsets.all(SizeConfig.res(4)),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isTerminated
                        ? _danger.withOpacity(0.2)
                        : _border,
                  ),
                  boxShadow: const [
                    BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    // accent bar
                    Container(
                      width: SizeConfig.sw(0.005),
                      height: SizeConfig.sh(0.09),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: SizeConfig.sw(0.014)),
                    // icon
                    Container(
                      padding: EdgeInsets.all(SizeConfig.res(2.5)),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isTerminated
                            ? Icons.cancel_outlined
                            : Icons.support_agent_outlined,
                        color: statusColor,
                        size: SizeConfig.res(5.5),
                      ),
                    ),
                    SizedBox(width: SizeConfig.sw(0.014)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  f.customerName,
                                  style: TextStyle(
                                      fontSize: SizeConfig.res(4),
                                      fontWeight: FontWeight.w700,
                                      color: _textDark),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _statusPill(f.status ?? 'Pending', statusColor),
                            ],
                          ),
                          SizedBox(height: SizeConfig.sh(0.006)),
                          if (f.vehicle != null)
                            Row(
                              children: [
                                Icon(Icons.two_wheeler,
                                    size: SizeConfig.res(3.5), color: _textMid),
                                SizedBox(width: SizeConfig.sw(0.005)),
                                Text(f.vehicle!,
                                    style: TextStyle(
                                        fontSize: SizeConfig.res(3.2),
                                        color: _textMid)),
                              ],
                            ),
                          SizedBox(height: SizeConfig.sh(0.006)),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: SizeConfig.res(3.2), color: _textMid),
                              SizedBox(width: SizeConfig.sw(0.005)),
                              Text('Delivery: ${_formatDate(f.deliveryDate)}',
                                  style: TextStyle(
                                      fontSize: SizeConfig.res(3),
                                      color: _textMid)),
                              SizedBox(width: SizeConfig.sw(0.02)),
                              Icon(Icons.event_note_outlined,
                                  size: SizeConfig.res(3.2), color: _primary),
                              SizedBox(width: SizeConfig.sw(0.005)),
                              Text('Follow-up: ${_formatDate(f.followUpDate)}',
                                  style: TextStyle(
                                      fontSize: SizeConfig.res(3),
                                      fontWeight: FontWeight.w600,
                                      color: _primary)),
                            ],
                          ),
                          if (f.remarks != null && f.remarks!.isNotEmpty) ...[
                            SizedBox(height: SizeConfig.sh(0.006)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.notes_outlined,
                                    size: SizeConfig.res(3.2), color: _textMid),
                                SizedBox(width: SizeConfig.sw(0.005)),
                                Expanded(
                                  child: Text(f.remarks!,
                                      style: TextStyle(
                                          fontSize: SizeConfig.res(3),
                                          color: _textMid),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _statusPill(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.010), vertical: SizeConfig.sh(0.005)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.capitalizeFirst ?? status,
        style: TextStyle(
            fontSize: SizeConfig.res(2.8),
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.2),
      ),
    );
  }

  void _showTerminateDialog(int followUpId) {
    final reasonCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig.res(2.2)),
              decoration: BoxDecoration(
                color: _danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning_amber_rounded,
                  color: _danger, size: SizeConfig.res(5)),
            ),
            SizedBox(width: SizeConfig.sw(0.01)),
            Text('Terminate Follow-up',
                style: TextStyle(
                    fontSize: SizeConfig.res(4.5),
                    fontWeight: FontWeight.w700,
                    color: _textDark)),
          ],
        ),
        content: SizedBox(
          width: SizeConfig.sw(0.3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(SizeConfig.res(3)),
                decoration: BoxDecoration(
                  color: _danger.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _danger.withOpacity(0.15)),
                ),
                child: Text(
                  'Are you sure you want to terminate this follow-up? This action cannot be undone.',
                  style: TextStyle(
                      fontSize: SizeConfig.res(3.4), color: _textMid),
                ),
              ),
              SizedBox(height: SizeConfig.sh(0.016)),
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
                decoration: InputDecoration(
                  labelText: 'Reason (optional)',
                  labelStyle:
                      TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _danger, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _border),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.sw(0.016),
                  vertical: SizeConfig.sh(0.012)),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: Text('Cancel',
                  style: TextStyle(
                      fontSize: SizeConfig.res(3.4), color: _textMid)),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.008)),
          GestureDetector(
            onTap: () async {
              Get.back();
              await controller.terminateFollowUp(followUpId,
                  reason: reasonCtrl.text.trim());
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.sw(0.016),
                  vertical: SizeConfig.sh(0.012)),
              decoration: BoxDecoration(
                color: _danger,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Terminate',
                  style: TextStyle(
                      fontSize: SizeConfig.res(3.4),
                      fontWeight: FontWeight.w700,
                      color: _surface)),
            ),
          ),
        ],
      ),
    );
  }
}