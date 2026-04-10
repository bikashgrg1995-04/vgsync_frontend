import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../data/models/supplier_model.dart';
import '../../themes/app_colors.dart';
import 'supplier_controller.dart';
import '../../wigdets/custom_form_dialog.dart';

class SupplierListPage extends StatelessWidget {
  SupplierListPage({super.key});

  final SupplierController controller = Get.find<SupplierController>();

  static const _bg       = AppColors.background;
  static const _surface  = AppColors.surface;
  static const _primary  = AppColors.primary;
  static const _warning  = AppColors.warning;
  static const _danger   = AppColors.error;
  static const _success  = AppColors.success;
  static const _textDark = AppColors.textPrimary;
  static const _textMid  = AppColors.textSecondary;
  static const _border   = AppColors.divider;
  static const _shadow   = Color(0x0F000000);

  // avatar color cycle
  static const _avatarColors = [
    AppColors.primary,
    AppColors.success,
    AppColors.warning,
    AppColors.info,
    AppColors.secondary,
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openSupplierDialog(),
        icon: const Icon(Icons.add, color: AppColors.surface),
        label: const Text('Add Supplier',
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
            _buildHeader(context),
            SizedBox(height: SizeConfig.sh(0.016)),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _pageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suppliers',
            style: TextStyle(
                fontSize: SizeConfig.res(7),
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: -0.5)),
        Text('Manage your supplier directory',
            style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textMid)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                  hintText: 'Search suppliers...',
                  hintStyle: TextStyle(color: _textMid, fontSize: SizeConfig.res(3.4)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: SizeConfig.sh(0.015)),
                ),
                onChanged: (_) => controller.suppliers.refresh(),
              ),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.012)),
          _headerBtn(
            label: 'Refresh',
            icon: Icons.refresh_rounded,
            color: _primary,
            onPressed: controller.refreshSuppliers,
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

  Widget _buildList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: _primary));
      }
      final filtered = controller.filteredSuppliers;
      if (filtered.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_shipping_outlined,
                  size: SizeConfig.res(18), color: _border),
              SizedBox(height: SizeConfig.sh(0.015)),
              Text('No suppliers found',
                  style: TextStyle(fontSize: SizeConfig.res(4), color: _textMid)),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.only(bottom: SizeConfig.sh(0.1)),
        itemCount: filtered.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (_, index) {
          final s = filtered[index];
          final avatarColor = _avatarColors[index % _avatarColors.length];
          final initials = s.name.isNotEmpty
              ? s.name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
              : '?';

          return Padding(
            padding: EdgeInsets.only(bottom: SizeConfig.sh(0.012)),
            child: Slidable(
              key: ValueKey(s.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.28,
                children: [
                  SlidableAction(
                    onPressed: (_) => openSupplierDialog(supplier: s),
                    backgroundColor: _warning,
                    foregroundColor: _surface,
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12)),
                  ),
                  SlidableAction(
                    onPressed: (_) => controller.deleteSupplier(s.id),
                    backgroundColor: _danger,
                    foregroundColor: _surface,
                    icon: Icons.delete_rounded,
                    label: 'Delete',
                    borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(12)),
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.all(SizeConfig.res(3.5)),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    // avatar
                    Container(
                      width: SizeConfig.sw(0.045),
                      height: SizeConfig.sw(0.045),
                      decoration: BoxDecoration(
                        color: avatarColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: avatarColor.withOpacity(0.3)),
                      ),
                      alignment: Alignment.center,
                      child: Text(initials,
                          style: TextStyle(
                              fontSize: SizeConfig.res(3.8),
                              fontWeight: FontWeight.w800,
                              color: avatarColor)),
                    ),
                    SizedBox(width: SizeConfig.sw(0.014)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name,
                              style: TextStyle(
                                  fontSize: SizeConfig.res(3.8),
                                  fontWeight: FontWeight.w700,
                                  color: _textDark)),
                          SizedBox(height: SizeConfig.sh(0.005)),
                          Row(
                            children: [
                              Icon(Icons.phone_outlined,
                                  size: SizeConfig.res(3.2), color: _textMid),
                              SizedBox(width: SizeConfig.sw(0.005)),
                              Text(s.contact,
                                  style: TextStyle(
                                      fontSize: SizeConfig.res(3.2),
                                      color: _textMid)),
                              if (s.email != null && s.email!.isNotEmpty) ...[
                                SizedBox(width: SizeConfig.sw(0.014)),
                                Icon(Icons.email_outlined,
                                    size: SizeConfig.res(3.2), color: _textMid),
                                SizedBox(width: SizeConfig.sw(0.005)),
                                Text(s.email!,
                                    style: TextStyle(
                                        fontSize: SizeConfig.res(3.2),
                                        color: _textMid)),
                              ],
                            ],
                          ),
                          if (s.address != null && s.address!.isNotEmpty) ...[
                            SizedBox(height: SizeConfig.sh(0.004)),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: SizeConfig.res(3.2), color: _textMid),
                                SizedBox(width: SizeConfig.sw(0.005)),
                                Expanded(
                                  child: Text(s.address!,
                                      style: TextStyle(
                                          fontSize: SizeConfig.res(3.2),
                                          color: _textMid),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // index badge
                    Container(
                      width: SizeConfig.sw(0.03),
                      height: SizeConfig.sw(0.03),
                      decoration: BoxDecoration(
                        color: _bg,
                        shape: BoxShape.circle,
                        border: Border.all(color: _border),
                      ),
                      alignment: Alignment.center,
                      child: Text('${index + 1}',
                          style: TextStyle(
                              fontSize: SizeConfig.res(2.8),
                              fontWeight: FontWeight.w600,
                              color: _textMid)),
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

  void openSupplierDialog({SupplierModel? supplier}) {
    final isEdit = supplier != null;
    if (isEdit) {
      controller.fillForm(supplier);
    } else {
      controller.clearForm();
    }

    Get.dialog(
      CustomFormDialog(
        title: isEdit ? 'Edit Supplier' : 'Add Supplier',
        isEditMode: isEdit,
        width: isEdit ? 0.25 : 0.22,
        height: 0.65,
        content: Column(
          children: [
            _dialogField(controller.nameController, 'Name', Icons.person_outline_rounded),
            SizedBox(height: SizeConfig.sh(0.02)),
            _dialogField(controller.contactController, 'Contact', Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            SizedBox(height: SizeConfig.sh(0.02)),
            _dialogField(controller.emailController, 'Email', Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            SizedBox(height: SizeConfig.sh(0.02)),
            _dialogField(controller.addressController, 'Address', Icons.location_on_outlined),
          ],
        ),
        onSave: () => isEdit
            ? controller.updateSupplier(supplier)
            : controller.addSupplier(),
        onDelete: isEdit ? () => controller.deleteSupplier(supplier.id) : null,
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label, IconData icon,
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
}