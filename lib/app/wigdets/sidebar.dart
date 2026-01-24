import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/utils/constants.dart';
import '../controllers/global_controller.dart';
import '../controllers/sidebar_controller.dart';
import '../controllers/auth_controller.dart';

class Sidebar extends StatelessWidget {
  Sidebar({super.key});

  final SidebarController controller = Get.put(SidebarController());
  final GlobalController globalController = Get.find();
  final AuthController authController = Get.find();

  double _sidebarWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 280; // desktop
    if (width >= 800) return 240; // tablet
    return 200; // small screens
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSub = false,
  }) {
    return Obx(() {
      final isSelected = globalController.selectedMenu.value == title;

      return InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: isSub ? 32 : 20,
          ),
          color: isSelected
              ? Colors.blueGrey.shade700
              : title == 'Logout'
                  ? Colors.red.shade700
                  : Colors.transparent,
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Colors.white70,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _sidebarWidth(context),
      color: const Color(0xFF12121C),
      child: Column(
        children: [
          /// Logo
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Image.asset(
              AppConstants.logo,
              width: 120,
              fit: BoxFit.contain,
            ),
          ),

          /// Scrollable Menu Area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _menuItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    onTap: () => globalController.changeMenu('Dashboard'),
                  ),
                  _menuItem(
                    icon: Icons.inventory,
                    title: 'Stock',
                    onTap: () => globalController.changeMenu('Stock'),
                  ),
                  _menuItem(
                    icon: Icons.shopping_cart,
                    title: 'Purchases',
                    onTap: () => globalController.changeMenu('Purchases'),
                  ),
                  _menuItem(
                    icon: Icons.sell,
                    title: 'Sales',
                    onTap: () => globalController.changeMenu('Sales'),
                  ),
                  _menuItem(
                    icon: Icons.alarm,
                    title: 'Follow-ups',
                    onTap: () => globalController.changeMenu('Follow-ups'),
                  ),
                  _menuItem(
                    icon: Icons.list_alt,
                    title: 'Orders',
                    onTap: () => globalController.changeMenu('Orders'),
                  ),

                  /// More Menu (Hover)
                  MouseRegion(
                    onEnter: (_) => controller.isMoreHovered.value = true,
                    onExit: (_) => controller.isMoreHovered.value = false,
                    child: Column(
                      children: [
                        _menuItem(
                          icon: Icons.grid_view,
                          title: 'More',
                          onTap: () {},
                        ),
                        Obx(() => AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              child: controller.isMoreHovered.value
                                  ? Column(
                                      children: [
                                        _menuItem(
                                          icon: Icons.people,
                                          title: 'Suppliers',
                                          isSub: true,
                                          onTap: () => globalController
                                              .changeMenu('Suppliers'),
                                        ),
                                        _menuItem(
                                          icon: Icons.money,
                                          title: 'Expenses',
                                          isSub: true,
                                          onTap: () => globalController
                                              .changeMenu('Expenses'),
                                        ),
                                        _menuItem(
                                          icon: Icons.badge,
                                          title: 'Staffs',
                                          isSub: true,
                                          onTap: () => globalController
                                              .changeMenu('Staffs'),
                                        ),
                                        _menuItem(
                                          icon: Icons.category,
                                          title: 'Categories',
                                          isSub: true,
                                          onTap: () => globalController
                                              .changeMenu('Categories'),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Logout (Pinned Bottom)
          const Divider(color: Colors.white24),
          // Example: Logout button in Sidebar
        _menuItem(
  icon: Icons.logout,
  title: 'Logout',
  onTap: () {
    ConfirmDialog.show(
      context,
      title: "Logout",
      message: "Are you sure you want to logout?",
      confirmText: "Logout",
      cancelText: "Cancel",
      onConfirm: () {
        authController.logout();
        globalController.changeMenu('Dashboard');
      },
    );
  },
),


          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
