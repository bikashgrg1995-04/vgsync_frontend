import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_detail_page.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../data/models/staff_model.dart';
import 'staff_controller.dart';
import '../../wigdets/custom_form_dialog.dart';

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  final StaffController controller = Get.find<StaffController>();

  final globalController = Get.find<GlobalController>();

  final List<String> designations = [
    'admin',
    'accountant',
    'technician',
    'helper',
    'sales',
    'other',
  ];

  final List<String> salaryMode = ['daily', 'monthly'];

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.sw(0.03)),
        child: Column(
          children: [
            // Search + Refresh
            Row(
              children: [
                SizedBox(
                  width: SizeConfig.sw(0.45),
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search staff...',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(SizeConfig.sw(0.02)))),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.01)),
                actionButton(
                  label: 'Refresh',
                  icon: Icons.refresh,
                  onPressed: controller.setStaffFilters,
                ),
              ],
            ),
            SizedBox(height: SizeConfig.sh(0.02)),

            // Staff List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = controller.filterStaffs(
                    query: controller.searchController.text);

                if (filtered.isEmpty) {
                  return const Center(child: Text('No staff found'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final staff = filtered[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.sw(0.01),
                          vertical: SizeConfig.sh(0.005)),
                      child: Slidable(
                        key: ValueKey(staff.id),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.35,
                          children: [
                            SlidableAction(
                              onPressed: (_) => openStaffDialog(staff),
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (_) =>
                                  controller.deleteStaff(staff.id ?? 0),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(SizeConfig.sw(0.01))),
                          elevation: 3,
                          child: Row(
                            children: [
                              SizedBox(
                                width: SizeConfig.sw(0.02),
                              ),
                              SizedBox(
                                width: SizeConfig.sw(0.05),
                                height: SizeConfig.sw(0.05),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColorLight,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(SizeConfig.sw(0.04)),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: SizeConfig.res(14),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: SizeConfig.sw(0.01),
                              ),
                              Expanded(
                                child: ListTile(
                                  onTap: () => Get.to(
                                      () => StaffDetailPage(staff: staff)),
                                  contentPadding:
                                      EdgeInsets.all(SizeConfig.sw(0.01)),
                                  title: Text(
                                    staff.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: SizeConfig.res(6)),
                                  ),
                                  subtitle: Text(
                                    '${staff.designation.capitalizeFirst} | ${staff.salaryMode.capitalizeFirst} | ${staff.phone}',
                                    style: TextStyle(
                                        fontSize: SizeConfig.res(4.5)),
                                  ),
                                ),
                              ),
                            ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openStaffDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Staff'),
      ),
    );
  }

  // ---------------- Add/Edit Staff Dialog ----------------
  void openStaffDialog([StaffModel? staff]) async {
    final isEdit = staff != null;
    controller.clearControllers();

    if (isEdit) {
      controller.fillStaffForm(staff);
    }

    Get.dialog(CustomFormDialog(
      title: isEdit ? "Edit Staff" : "Add Staff",
      isEditMode: isEdit,
      width: 0.3,
      height: 0.7,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Info
            Text('Personal Info',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: SizeConfig.sh(0.01)),
            buildTextField(
                controller.nameController, 'Full Name', Icons.person),
            SizedBox(height: SizeConfig.sh(0.005)),
            buildTextField(controller.phoneController, 'Phone', Icons.phone),
            SizedBox(height: SizeConfig.sh(0.005)),
            buildTextField(controller.emailController, 'Email', Icons.email),
            SizedBox(height: SizeConfig.sh(0.005)),
            buildTextField(controller.addressController, 'Address', Icons.home),
            SizedBox(height: SizeConfig.sh(0.01)),

            // Employment Info
            Text('Employment Info',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: SizeConfig.sh(0.01)),
            _buildDropdown(
                controller.designationController, designations, 'Designation'),
            SizedBox(height: SizeConfig.sh(0.005)),
            _buildDropdown(
                controller.salaryModeController, salaryMode, 'Salary Mode'),
            SizedBox(height: SizeConfig.sh(0.005)),
            Row(
              children: [
                const Text('Active:'),
                Obx(() => Switch(
                      value: controller.isActiveController.value,
                      onChanged: (val) =>
                          controller.isActiveController.value = val,
                    )),
              ],
            ),
          ],
        ),
      ),
      onSave: () async {
        if (isEdit) {
          await controller.updateStaff(staff);
        } else {
          await controller.addStaff();
        }
      },
      onDelete: isEdit ? () => controller.deleteStaff(staff.id ?? 0) : null,
    ));
  }

  Widget _buildDropdown(
      TextEditingController controller, List<String> options, String label) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      items: options
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e[0].toUpperCase() + e.substring(1)),
              ))
          .toList(),
      onChanged: (val) => controller.text = val ?? '',
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
            vertical: SizeConfig.sh(0.015), horizontal: SizeConfig.sw(0.02)),
      ),
    );
  }
}
