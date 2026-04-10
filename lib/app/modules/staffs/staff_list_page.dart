import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_detail_page.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../data/models/staff_model.dart';
import '../../themes/app_colors.dart';
import 'staff_controller.dart';
import '../../wigdets/custom_form_dialog.dart';

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  final StaffController controller = Get.find<StaffController>();
  final GlobalController globalController = Get.find<GlobalController>();

  // ── Color aliases ──────────────────────────────────────────────────────────
  static const _bg       = AppColors.background;
  static const _surface  = AppColors.surface;
  static const _primary  = AppColors.primary;
  static const _success  = AppColors.success;
  static const _warning  = AppColors.warning;
  static const _danger   = AppColors.error;
  static const _info     = AppColors.info;
  static const _textDark = AppColors.textPrimary;
  static const _textMid  = AppColors.textSecondary;
  static const _border   = AppColors.divider;
  static const _shadow   = Color(0x0F000000);

  // designation → color mapping
  static const _designationColors = {
    'admin':       AppColors.primary,
    'accountant':  AppColors.info,
    'technician':  AppColors.warning,
    'helper':      AppColors.success,
    'sales':       AppColors.secondary,
    'other':       AppColors.textSecondary,
  };

  static const _designationIcons = {
    'admin':       Icons.admin_panel_settings_outlined,
    'accountant':  Icons.calculate_outlined,
    'technician':  Icons.build_outlined,
    'helper':      Icons.handyman_outlined,
    'sales':       Icons.storefront_outlined,
    'other':       Icons.person_outline_rounded,
  };

  final List<String> designations = [
    'admin', 'accountant', 'technician', 'helper', 'sales', 'other',
  ];
  final List<String> salaryModes = ['daily', 'monthly'];

  Color _designationColor(String designation) =>
      _designationColors[designation.toLowerCase()] ?? _textMid;

  IconData _designationIcon(String designation) =>
      _designationIcons[designation.toLowerCase()] ?? Icons.person_outline_rounded;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openStaffDialog(),
        icon: const Icon(Icons.add, color: AppColors.surface),
        label: const Text('Add Staff',
            style: TextStyle(color: AppColors.surface, fontWeight: FontWeight.w600)),
        backgroundColor: _primary,
        elevation: 2,
      ),
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.res(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.sh(0.015)),
            _pageTitle(),
            SizedBox(height: SizeConfig.sh(0.018)),
            _buildHeader(),
            SizedBox(height: SizeConfig.sh(0.016)),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  // ── Page title ─────────────────────────────────────────────────────────────
  Widget _pageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Staff',
            style: TextStyle(
                fontSize: SizeConfig.res(7),
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: -0.5)),
        Text('Manage your team members',
            style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textMid)),
      ],
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(SizeConfig.res(4)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: const [BoxShadow(color: _shadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
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
                controller: controller.searchController,
                style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: _textMid, size: SizeConfig.res(5)),
                  hintText: 'Search staff...',
                  hintStyle: TextStyle(color: _textMid, fontSize: SizeConfig.res(3.4)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: SizeConfig.sh(0.015)),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.012)),
          _headerBtn(
            label: 'Refresh',
            icon: Icons.refresh_rounded,
            color: _primary,
            onPressed: controller.setStaffFilters,
          ),
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
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: SizeConfig.res(4.5), color: color),
            SizedBox(width: SizeConfig.sw(0.005)),
            Text(label,
                style: TextStyle(
                    fontSize: SizeConfig.res(3.2),
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }

  // ── List ────────────────────────────────────────────────────────────────────
  Widget _buildList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: _primary));
      }

      final filtered = controller.filterStaffs(
          query: controller.searchController.text);

      if (filtered.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline, size: SizeConfig.res(18), color: _border),
              SizedBox(height: SizeConfig.sh(0.015)),
              Text('No staff found',
                  style: TextStyle(fontSize: SizeConfig.res(4), color: _textMid)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.only(bottom: SizeConfig.sh(0.1)),
        itemCount: filtered.length,
        itemBuilder: (_, index) {
          final staff = filtered[index];
          return _staffTile(staff, index);
        },
      );
    });
  }

  Widget _staffTile(StaffModel staff, int index) {
    final desgColor = _designationColor(staff.designation);
    final desgIcon  = _designationIcon(staff.designation);
    final initials  = staff.name.trim().split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.sh(0.012)),
      child: Slidable(
        key: ValueKey(staff.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.28,
          children: [
            SlidableAction(
              onPressed: (_) => openStaffDialog(staff),
              backgroundColor: _warning,
              foregroundColor: _surface,
              icon: Icons.edit_rounded,
              label: 'Edit',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            SlidableAction(
              onPressed: (_) => controller.deleteStaff(staff.id ?? 0),
              backgroundColor: _danger,
              foregroundColor: _surface,
              icon: Icons.delete_rounded,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => Get.to(() => StaffDetailPage(staff: staff)),
          child: Container(
            padding: EdgeInsets.all(SizeConfig.res(3.5)),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
              boxShadow: const [BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Row(
              children: [
                // ── Avatar ──────────────────────────────────────────────────
                Container(
                  width: SizeConfig.sw(0.05),
                  height: SizeConfig.sw(0.05),
                  decoration: BoxDecoration(
                    color: desgColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: desgColor.withOpacity(0.3), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(initials,
                      style: TextStyle(
                          fontSize: SizeConfig.res(4),
                          fontWeight: FontWeight.w800,
                          color: desgColor)),
                ),
                SizedBox(width: SizeConfig.sw(0.014)),

                // ── Info ────────────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(staff.name,
                                style: TextStyle(
                                    fontSize: SizeConfig.res(4),
                                    fontWeight: FontWeight.w700,
                                    color: _textDark),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Row(
                            children: [
                              _designationBadge(staff.designation, desgColor, desgIcon),
                              SizedBox(width: SizeConfig.sw(0.006)),
                              _salaryModeBadge(staff.salaryMode),
                              SizedBox(width: SizeConfig.sw(0.006)),
                              _activeBadge(staff.isActive),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: SizeConfig.sh(0.006)),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined,
                              size: SizeConfig.res(3.2), color: _textMid),
                          SizedBox(width: SizeConfig.sw(0.004)),
                          Text(staff.phone,
                              style: TextStyle(
                                  fontSize: SizeConfig.res(3.2), color: _textMid)),
                          if (staff.email != null && staff.email!.isNotEmpty) ...[
                            SizedBox(width: SizeConfig.sw(0.016)),
                            Icon(Icons.email_outlined,
                                size: SizeConfig.res(3.2), color: _textMid),
                            SizedBox(width: SizeConfig.sw(0.004)),
                            Expanded(
                              child: Text(staff.email!,
                                  style: TextStyle(
                                      fontSize: SizeConfig.res(3.2), color: _textMid),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ],
                      ),
                      if (staff.address != null && staff.address!.isNotEmpty) ...[
                        SizedBox(height: SizeConfig.sh(0.004)),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: SizeConfig.res(3.2), color: _textMid),
                            SizedBox(width: SizeConfig.sw(0.004)),
                            Expanded(
                              child: Text(staff.address!,
                                  style: TextStyle(
                                      fontSize: SizeConfig.res(3.2), color: _textMid),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: _textMid, size: SizeConfig.res(5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _designationBadge(String designation, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.008), vertical: SizeConfig.sh(0.004)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: SizeConfig.res(3), color: color),
          SizedBox(width: SizeConfig.sw(0.004)),
          Text(designation.capitalizeFirst ?? designation,
              style: TextStyle(
                  fontSize: SizeConfig.res(2.8),
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  Widget _salaryModeBadge(String mode) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.008), vertical: SizeConfig.sh(0.004)),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _primary.withOpacity(0.2)),
      ),
      child: Text(mode.capitalizeFirst ?? mode,
          style: TextStyle(
              fontSize: SizeConfig.res(2.8),
              fontWeight: FontWeight.w600,
              color: _primary)),
    );
  }

  Widget _activeBadge(bool isActive) {
    final color = isActive ? _success : _danger;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.007), vertical: SizeConfig.sh(0.004)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: SizeConfig.res(2.5),
            height: SizeConfig.res(2.5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: SizeConfig.sw(0.004)),
          Text(isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                  fontSize: SizeConfig.res(2.8),
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  // ── Dialog ─────────────────────────────────────────────────────────────────
  void openStaffDialog([StaffModel? staff]) {
    final isEdit = staff != null;
    controller.clearControllers();
    if (isEdit) controller.fillStaffForm(staff);

    Get.dialog(
      CustomFormDialog(
        title: isEdit ? 'Edit Staff' : 'Add Staff',
        isEditMode: isEdit,
        width: 0.3,
        height: 0.72,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _formSection('Personal Info', Icons.person_outline_rounded),
              SizedBox(height: SizeConfig.sh(0.012)),
              _field(controller.nameController, 'Full Name', Icons.person_outline_rounded),
              SizedBox(height: SizeConfig.sh(0.012)),
              _field(controller.phoneController, 'Phone', Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              SizedBox(height: SizeConfig.sh(0.012)),
              _field(controller.emailController, 'Email', Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              SizedBox(height: SizeConfig.sh(0.012)),
              _field(controller.addressController, 'Address', Icons.location_on_outlined),
              SizedBox(height: SizeConfig.sh(0.02)),
              _formSection('Employment Info', Icons.work_outline_rounded),
              SizedBox(height: SizeConfig.sh(0.012)),
              _styledDropdown(
                  controller.designationController, designations, 'Designation'),
              SizedBox(height: SizeConfig.sh(0.012)),
              _styledDropdown(
                  controller.salaryModeController, salaryModes, 'Salary Mode'),
              SizedBox(height: SizeConfig.sh(0.012)),
              Obx(() => Container(
                    decoration: BoxDecoration(
                      color: controller.isActiveController.value
                          ? _success.withOpacity(0.06)
                          : _bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: controller.isActiveController.value
                            ? _success.withOpacity(0.3)
                            : _border,
                      ),
                    ),
                    child: SwitchListTile(
                      title: Text('Active',
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.4),
                              fontWeight: FontWeight.w600,
                              color: controller.isActiveController.value
                                  ? _success
                                  : _textMid)),
                      value: controller.isActiveController.value,
                      activeColor: _success,
                      onChanged: (val) =>
                          controller.isActiveController.value = val,
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.sw(0.012)),
                    ),
                  )),
            ],
          ),
        ),
        onSave: () async =>
            isEdit ? await controller.updateStaff(staff) : await controller.addStaff(),
        onDelete: isEdit ? () => controller.deleteStaff(staff.id ?? 0) : null,
      ),
    );
  }

  Widget _formSection(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(SizeConfig.res(2)),
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: SizeConfig.res(4), color: _primary),
        ),
        SizedBox(width: SizeConfig.sw(0.01)),
        Text(title,
            style: TextStyle(
                fontSize: SizeConfig.res(4),
                fontWeight: FontWeight.w700,
                color: _textDark)),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
        prefixIcon: Icon(icon, size: SizeConfig.res(4.5), color: _primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _border),
        ),
      ),
    );
  }

  Widget _styledDropdown(
      TextEditingController ctrl, List<String> options, String label) {
    return DropdownButtonFormField<String>(
      value: ctrl.text.isEmpty ? null : ctrl.text,
      style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
      items: options
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e.capitalizeFirst ?? e),
              ))
          .toList(),
      onChanged: (val) => ctrl.text = val ?? '',
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _border),
        ),
      ),
    );
  }
}