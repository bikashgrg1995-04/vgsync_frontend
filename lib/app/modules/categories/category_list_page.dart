import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../data/models/category_model.dart';
import '../../modules/categories/category_controller.dart';
import '../../themes/app_colors.dart';
import '../../wigdets/custom_form_dialog.dart';

class CategoryListPage extends StatelessWidget {
  CategoryListPage({super.key});

  final controller = Get.find<CategoryController>();

  static const _bg = AppColors.background;
  static const _surface = AppColors.surface;
  static const _primary = AppColors.primary;
  static const _warning = AppColors.warning;
  static const _danger = AppColors.error;
  static const _textDark = AppColors.textPrimary;
  static const _textMid = AppColors.textSecondary;
  static const _border = AppColors.divider;
  static const _shadow = Color(0x0F000000);

  // color ramp for category icons
  static const _categoryColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.success,
    AppColors.info,
    AppColors.warning,
  ];

  static const _categoryIcons = [
    Icons.category_outlined,
    Icons.label_outline_rounded,
    Icons.inventory_2_outlined,
    Icons.tag_rounded,
    Icons.folder_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openCategoryDialog(),
        icon: const Icon(Icons.add, color: AppColors.surface),
        label: const Text('Add Category',
            style: TextStyle(
                color: AppColors.surface, fontWeight: FontWeight.w600)),
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

  Widget _pageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categories',
            style: TextStyle(
                fontSize: SizeConfig.res(7),
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: -0.5)),
        Text('Organise your product categories',
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
        boxShadow: const [
          BoxShadow(color: _shadow, blurRadius: 8, offset: Offset(0, 2))
        ],
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
                  style: TextStyle(
                      fontSize: SizeConfig.res(3.4), color: _textDark),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search,
                        color: _textMid, size: SizeConfig.res(5)),
                    hintText: 'Search categories...',
                    hintStyle: TextStyle(
                        color: _textMid, fontSize: SizeConfig.res(3.4)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: SizeConfig.sh(0.015),
                    ),
                  ),
                  onChanged: controller.onSearchChanged,
                )),
          ),
          SizedBox(width: SizeConfig.sw(0.012)),
          _headerBtn(
            label: 'Refresh',
            icon: Icons.refresh_rounded,
            color: _primary,
            onPressed: controller.refreshCategories,
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

      final filtered = controller.filteredCategories;

      if (filtered.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.category_outlined,
                  size: SizeConfig.res(18), color: _border),
              SizedBox(height: SizeConfig.sh(0.015)),
              Text('No categories found',
                  style:
                      TextStyle(fontSize: SizeConfig.res(4), color: _textMid)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.only(bottom: SizeConfig.sh(0.1)),
        itemCount: filtered.length,
        itemBuilder: (_, index) {
          final c = filtered[index];
          final color = _categoryColors[index % _categoryColors.length];
          final icon = _categoryIcons[index % _categoryIcons.length];

          return Padding(
            padding: EdgeInsets.only(bottom: SizeConfig.sh(0.012)),
            child: Slidable(
              key: ValueKey(c.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.28,
                children: [
                  SlidableAction(
                    onPressed: (_) => openCategoryDialog(category: c),
                    backgroundColor: _warning,
                    foregroundColor: _surface,
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                  ),
                  SlidableAction(
                    onPressed: (_) => controller.delete(c.id),
                    backgroundColor: _danger,
                    foregroundColor: _surface,
                    icon: Icons.delete_rounded,
                    label: 'Delete',
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
                    BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: SizeConfig.sw(0.045),
                      height: SizeConfig.sw(0.045),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.25)),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, color: color, size: SizeConfig.res(5)),
                    ),
                    SizedBox(width: SizeConfig.sw(0.014)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name,
                              style: TextStyle(
                                  fontSize: SizeConfig.res(3.8),
                                  fontWeight: FontWeight.w700,
                                  color: _textDark)),
                          SizedBox(height: SizeConfig.sh(0.004)),
                          Text('Category #${index + 1}',
                              style: TextStyle(
                                  fontSize: SizeConfig.res(3),
                                  color: _textMid)),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(SizeConfig.res(2)),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _border),
                      ),
                      child: Icon(Icons.drag_handle_rounded,
                          color: _textMid, size: SizeConfig.res(4)),
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

  void openCategoryDialog({CategoryModel? category}) {
    final isEdit = category != null;
    if (isEdit) {
      controller.fillForm(category);
    } else {
      controller.clearForm();
    }

    Get.dialog(
      CustomFormDialog(
        title: isEdit ? 'Edit Category' : 'Add Category',
        isEditMode: isEdit,
        width: 0.25,
        height: 0.3,
        content: TextField(
          controller: controller.nameController,
          style: TextStyle(fontSize: SizeConfig.res(3.4), color: _textDark),
          decoration: InputDecoration(
            labelText: 'Name',
            labelStyle:
                TextStyle(fontSize: SizeConfig.res(3.2), color: _textMid),
            prefixIcon: Icon(Icons.category_outlined,
                size: SizeConfig.res(4.5), color: _primary),
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
        ),
        onSave: () => isEdit
            ? controller.updateCategory(category)
            : controller.addCategory(),
        onDelete: isEdit ? () => controller.delete(category.id) : null,
      ),
    );
  }
}
