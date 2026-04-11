import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../themes/app_colors.dart';

// ═══════════════════════════════════════════════════════════════
//  COLOR CONSTANTS  (import once, use everywhere)
// ═══════════════════════════════════════════════════════════════
class AC {
  static const bg       = AppColors.background;
  static const surface  = AppColors.surface;
  static const primary  = AppColors.primary;
  static const success  = AppColors.success;
  static const warning  = AppColors.warning;
  static const danger   = AppColors.error;
  static const info     = AppColors.info;
  static const secondary = AppColors.secondary;
  static const textDark = AppColors.textPrimary;
  static const textMid  = AppColors.textSecondary;
  static const border   = AppColors.divider;
  static const shadow   = Color(0x0F000000);
}

// ═══════════════════════════════════════════════════════════════
//  PAGE TITLE
// ═══════════════════════════════════════════════════════════════
class AppPageTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const AppPageTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: SizeConfig.res(7),
                fontWeight: FontWeight.w800,
                color: AC.textDark,
                letterSpacing: -0.5)),
        Text(subtitle,
            style: TextStyle(fontSize: SizeConfig.res(3.4), color: AC.textMid)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SURFACE CARD  (white box with shadow)
// ═══════════════════════════════════════════════════════════════
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;
  final Color? bgColor;
  final double radius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.bgColor,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(SizeConfig.res(4)),
      decoration: BoxDecoration(
        color: bgColor ?? AC.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? AC.border),
        boxShadow: const [BoxShadow(color: AC.shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SEARCH HEADER  (search + optional buttons)
// ═══════════════════════════════════════════════════════════════
class AppSearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final void Function(String) onChanged;
  final List<Widget> actions;

  const AppSearchHeader({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: SizeConfig.sh(0.055),
              decoration: BoxDecoration(
                color: AC.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AC.border),
              ),
              child: TextField(
                controller: controller,
                style: TextStyle(fontSize: SizeConfig.res(3.4), color: AC.textDark),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: AC.textMid, size: SizeConfig.res(5)),
                  hintText: hint,
                  hintStyle: TextStyle(color: AC.textMid, fontSize: SizeConfig.res(3.4)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: SizeConfig.sh(0.015)),
                ),
                onChanged: onChanged,
              ),
            ),
          ),
          if (actions.isNotEmpty) ...[
            SizedBox(width: SizeConfig.sw(0.012)),
            ...actions,
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  GHOST BUTTON  (outlined action button)
// ═══════════════════════════════════════════════════════════════
class AppGhostBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const AppGhostBtn({
    super.key,
    required this.label,
    required this.icon,
    this.color = AC.primary,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final c = disabled ? AC.textMid : color;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.sw(0.014), vertical: SizeConfig.sh(0.013)),
        decoration: BoxDecoration(
          color: disabled ? AC.border.withOpacity(0.3) : c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: disabled ? AC.border : c.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: SizeConfig.res(4.5), color: c),
            SizedBox(width: SizeConfig.sw(0.005)),
            Text(label,
                style: TextStyle(
                    fontSize: SizeConfig.res(3.2),
                    fontWeight: FontWeight.w600,
                    color: c)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SOLID BUTTON
// ═══════════════════════════════════════════════════════════════
class AppSolidBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback onPressed;

  const AppSolidBtn({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AC.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.sw(0.016), vertical: SizeConfig.sh(0.012)),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: SizeConfig.res(4), color: AC.surface),
              SizedBox(width: SizeConfig.sw(0.005)),
            ],
            Text(label,
                style: TextStyle(
                    fontSize: SizeConfig.res(3.4),
                    fontWeight: FontWeight.w700,
                    color: AC.surface)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  STATUS PILL
// ═══════════════════════════════════════════════════════════════
class AppStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const AppStatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.010), vertical: SizeConfig.sh(0.005)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: SizeConfig.res(2.8),
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  BADGE  (small colored tag)
// ═══════════════════════════════════════════════════════════════
class AppBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const AppBadge({super.key, required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
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
          if (icon != null) ...[
            Icon(icon, size: SizeConfig.res(3), color: color),
            SizedBox(width: SizeConfig.sw(0.003)),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: SizeConfig.res(2.8),
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ACCENT BAR  (left colored stripe on tiles)
// ═══════════════════════════════════════════════════════════════
class AppAccentBar extends StatelessWidget {
  final Color color;
  final double? height;

  const AppAccentBar({super.key, required this.color, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.sw(0.006),
      height: height ?? SizeConfig.sh(0.09),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ICON BOX  (colored icon container)
// ═══════════════════════════════════════════════════════════════
class AppIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double? size;

  const AppIconBox({super.key, required this.icon, required this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.res(2.5)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: size ?? SizeConfig.res(5.5)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  VERTICAL DIVIDER
// ═══════════════════════════════════════════════════════════════
class AppVDivider extends StatelessWidget {
  final double? height;
  const AppVDivider({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: height ?? SizeConfig.sh(0.05),
      color: AC.border,
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.sw(0.012)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CARD TITLE  (icon + text header inside a card)
// ═══════════════════════════════════════════════════════════════
class AppCardTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;

  const AppCardTitle({
    super.key,
    required this.icon,
    required this.title,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AC.primary;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(SizeConfig.res(2.2)),
          decoration: BoxDecoration(
            color: c.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: SizeConfig.res(4.5), color: c),
        ),
        SizedBox(width: SizeConfig.sw(0.01)),
        Text(title,
            style: TextStyle(
                fontSize: SizeConfig.res(4),
                fontWeight: FontWeight.w700,
                color: AC.textDark)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  AMOUNT CHIP  (label + Rs. value)
// ═══════════════════════════════════════════════════════════════
class AppAmountChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const AppAmountChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: SizeConfig.res(2.6), color: AC.textMid)),
        Text('Rs. ${value.toStringAsFixed(0)}',
            style: TextStyle(
                fontSize: SizeConfig.res(3.4),
                fontWeight: FontWeight.w700,
                color: color)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TOTAL TILE  (icon + label + Rs. value — for summary rows)
// ═══════════════════════════════════════════════════════════════
class AppTotalTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;
  final bool isBold;

  const AppTotalTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.res(2.2)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: SizeConfig.res(4.5), color: color),
          ),
          SizedBox(width: SizeConfig.sw(0.01)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: SizeConfig.res(2.8), color: AC.textMid)),
                SizedBox(height: SizeConfig.sh(0.003)),
                Text('Rs. ${value.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: SizeConfig.res(isBold ? 4 : 3.6),
                        fontWeight:
                            isBold ? FontWeight.w800 : FontWeight.w600,
                        color: color),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  INFO ITEM  (label : value row)
// ═══════════════════════════════════════════════════════════════
class AppInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final double labelWidth;

  const AppInfoItem({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 0.09,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.sh(0.008)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: SizeConfig.sw(labelWidth),
            child: Text(label,
                style: TextStyle(
                    fontSize: SizeConfig.res(3.2), color: AC.textMid)),
          ),
          SizedBox(width: SizeConfig.sw(0.01)),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: SizeConfig.res(3.4),
                    fontWeight: FontWeight.w600,
                    color: AC.textDark)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  STYLED TEXT FIELD  (consistent input field)
// ═══════════════════════════════════════════════════════════════
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool enabled;
  final void Function(String)? onChanged;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
          fontSize: SizeConfig.res(3.4),
          color: enabled ? AC.textDark : AC.textMid),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(fontSize: SizeConfig.res(3.2), color: AC.textMid),
        prefixIcon: Icon(icon,
            size: SizeConfig.res(4.5),
            color: enabled ? AC.primary : AC.textMid),
        filled: !enabled,
        fillColor: enabled ? null : AC.bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AC.primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AC.border),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AC.border.withOpacity(0.5)),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  STYLED DROPDOWN
// ═══════════════════════════════════════════════════════════════
class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final IconData? icon;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      style: TextStyle(fontSize: SizeConfig.res(3.4), color: AC.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(fontSize: SizeConfig.res(3.2), color: AC.textMid),
        prefixIcon: icon != null
            ? Icon(icon, size: SizeConfig.res(4.5), color: AC.primary)
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AC.primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AC.border),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TABLE HEADER  (primary-tinted column headers)
// ═══════════════════════════════════════════════════════════════
class AppTableHeader extends StatelessWidget {
  final List<_TableCol> columns;

  const AppTableHeader({super.key, required this.columns});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.sh(0.05),
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.sw(0.012)),
      decoration: BoxDecoration(
        color: AC.primary.withOpacity(0.06),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        border: Border(bottom: BorderSide(color: AC.border)),
      ),
      child: Row(
        children: columns.map((col) {
          if (col.flex != null) {
            return Expanded(
              child: Text(col.label,
                  textAlign: col.align,
                  style: TextStyle(
                      fontSize: SizeConfig.res(3),
                      fontWeight: FontWeight.w700,
                      color: AC.primary)),
            );
          }
          return SizedBox(
            width: col.width,
            child: Text(col.label,
                textAlign: col.align,
                style: TextStyle(
                    fontSize: SizeConfig.res(3),
                    fontWeight: FontWeight.w700,
                    color: AC.primary)),
          );
        }).toList(),
      ),
    );
  }
}

class _TableCol {
  final String label;
  final double? width;
  final int? flex;
  final TextAlign align;

  const _TableCol(this.label,
      {this.width, this.flex, this.align = TextAlign.start});
}

// ═══════════════════════════════════════════════════════════════
//  TABLE INPUT  (compact text field for table rows)
// ═══════════════════════════════════════════════════════════════
InputDecoration appTableInputDecoration() {
  return InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(
        vertical: SizeConfig.sh(0.01), horizontal: SizeConfig.sw(0.004)),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AC.border)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AC.primary, width: 1.5)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AC.border)),
  );
}

// ═══════════════════════════════════════════════════════════════
//  SLIDABLE TILE  (list tile with edit/delete swipe)
// ═══════════════════════════════════════════════════════════════
class AppSlidableTile extends StatelessWidget {
  final Object tileKey;
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final double extentRatio;

  const AppSlidableTile({
    super.key,
    required this.tileKey,
    required this.child,
    this.onEdit,
    this.onDelete,
    this.extentRatio = 0.28,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(tileKey),
      endActionPane: (onEdit == null && onDelete == null)
          ? null
          : ActionPane(
              motion: const DrawerMotion(),
              extentRatio: extentRatio,
              children: [
                if (onEdit != null)
                  SlidableAction(
                    onPressed: (_) => onEdit!(),
                    backgroundColor: AC.warning,
                    foregroundColor: AC.surface,
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                    borderRadius: BorderRadius.horizontal(
                      left: const Radius.circular(12),
                      right: onDelete == null
                          ? const Radius.circular(12)
                          : Radius.zero,
                    ),
                  ),
                if (onDelete != null)
                  SlidableAction(
                    onPressed: (_) => onDelete!(),
                    backgroundColor: AC.danger,
                    foregroundColor: AC.surface,
                    icon: Icons.delete_rounded,
                    label: 'Delete',
                    borderRadius: BorderRadius.horizontal(
                      left: onEdit == null
                          ? const Radius.circular(12)
                          : Radius.zero,
                      right: const Radius.circular(12),
                    ),
                  ),
              ],
            ),
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════════════════════════
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const AppEmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: SizeConfig.res(18), color: AC.border),
          SizedBox(height: SizeConfig.sh(0.015)),
          Text(message,
              style: TextStyle(fontSize: SizeConfig.res(4), color: AC.textMid)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  APP BAR  (consistent back button + title)
// ═══════════════════════════════════════════════════════════════
PreferredSizeWidget appBar({
  required String title,
  String? subtitle,
  List<Widget> actions = const [],
  VoidCallback? onBack,
}) {
  return AppBar(
    backgroundColor: AC.surface,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    leading: GestureDetector(
      onTap: onBack ?? () => Get.back(),
      child: Container(
        margin: EdgeInsets.all(SizeConfig.res(2.5)),
        decoration: BoxDecoration(
          color: AC.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AC.border),
        ),
        child: Icon(Icons.arrow_back_rounded,
            color: AC.textDark, size: SizeConfig.res(5)),
      ),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: SizeConfig.res(4.8),
                fontWeight: FontWeight.w800,
                color: AC.textDark,
                letterSpacing: -0.3)),
        if (subtitle != null)
          Text(subtitle,
              style: TextStyle(fontSize: SizeConfig.res(3), color: AC.textMid)),
      ],
    ),
    actions: actions,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: AC.border),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  FAB  (consistent floating action button)
// ═══════════════════════════════════════════════════════════════
Widget appFab({required String label, required VoidCallback onPressed}) {
  return FloatingActionButton.extended(
    onPressed: onPressed,
    icon: const Icon(Icons.add, color: AC.surface),
    label: Text(label,
        style: const TextStyle(
            color: AC.surface, fontWeight: FontWeight.w600)),
    backgroundColor: AC.primary,
    elevation: 2,
  );
}

// ═══════════════════════════════════════════════════════════════
//  FILTER CHIP ROW  (animated status filter chips)
// ═══════════════════════════════════════════════════════════════
class AppFilterChips extends StatelessWidget {
  final List<_ChipItem> chips;
  final String selected;
  final void Function(String) onSelect;

  const AppFilterChips({
    super.key,
    required this.chips,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: chips.map((chip) {
        final isSelected = selected == chip.value;
        return Padding(
          padding: EdgeInsets.only(right: SizeConfig.sw(0.008)),
          child: GestureDetector(
            onTap: () => onSelect(chip.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.sw(0.012),
                  vertical: SizeConfig.sh(0.010)),
              decoration: BoxDecoration(
                color: isSelected
                    ? chip.color
                    : chip.color.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSelected
                        ? chip.color
                        : chip.color.withOpacity(0.3)),
              ),
              child: Text(chip.label,
                  style: TextStyle(
                      fontSize: SizeConfig.res(3),
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AC.surface : chip.color)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ChipItem {
  final String label;
  final String value;
  final Color color;
  const _ChipItem(this.label, this.value, this.color);
}

// ─── helpers to build chip lists cleanly ───────────────────────
List<_ChipItem> statusChips() => [
      _ChipItem('All',      'all',      AC.primary),
      _ChipItem('Paid',     'paid',     AC.success),
      _ChipItem('Partial',  'partial',  AC.warning),
      _ChipItem('Not Paid', 'not_paid', AC.danger),
    ];

List<_ChipItem> orderChips() => [
      _ChipItem('All',       'all',       AC.primary),
      _ChipItem('Pending',   'pending',   AC.warning),
      _ChipItem('Received',  'received',  AC.info),
      _ChipItem('Completed', 'completed', AC.success),
    ];