import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/auth_controller.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import '../controllers/sidebar_controller.dart';

class Sidebar extends StatelessWidget {
  Sidebar({super.key});

  final SidebarController controller = Get.put(SidebarController());
  final GlobalController globalController = Get.find();
  final AuthController authController = Get.find();

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSub = false,
  }) {
    return Obx(() {
      bool isSelected = globalController.selectedMenu.value == title;
      return InkWell(
        onTap: onTap,
        child: Container(
          color: isSelected ? Colors.blueGrey[700] : Colors.transparent,
          padding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: isSub ? 32 : 20,
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
      width: 260,
      color: const Color(0xFF12121C),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 200),

          _menuItem(
            icon: Icons.home,
            title: 'Dashboard',
            onTap: () => globalController.changeMenu('Dashboard'),
          ),

          _menuItem(
            icon: Icons.sell,
            title: 'Sales',
            onTap: () => globalController.changeMenu('Sales'),
          ),

          _menuItem(
            icon: Icons.shopping_cart,
            title: 'Purchase',
            onTap: () => globalController.changeMenu('Purchases'),
          ),

          _menuItem(
            icon: Icons.alarm,
            title: 'Follow-up',
            onTap: () => globalController.changeMenu('Follow-ups'),
          ),

          /// -------- MORE MENU (HOVER) ----------
          MouseRegion(
            onEnter: (_) => controller.isMoreHovered.value = true,
            onExit: (_) => controller.isMoreHovered.value = false,
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _menuItem(
                    icon: Icons.grid_view,
                    title: 'More',
                    onTap: () {},
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: controller.isMoreHovered.value ? null : 0,
                    child: Visibility(
                      visible: controller.isMoreHovered.value,
                      child: Column(
                        children: [
                          _menuItem(
                            icon: Icons.people,
                            title: 'Customers',
                            isSub: true,
                            onTap: () =>
                                globalController.changeMenu('Customers'),
                          ),
                          _menuItem(
                            icon: Icons.local_shipping,
                            title: 'Suppliers',
                            isSub: true,
                            onTap: () =>
                                globalController.changeMenu('Suppliers'),
                          ),
                          _menuItem(
                            icon: Icons.category,
                            title: 'Categories',
                            isSub: true,
                            onTap: () =>
                                globalController.changeMenu('Categories'),
                          ),
                          _menuItem(
                            icon: Icons.inventory,
                            title: 'Items',
                            isSub: true,
                            onTap: () => globalController.changeMenu('Items'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),

          const Spacer(),
          Divider(color: Colors.white24),
          _menuItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () => authController.logout(),
          ),
        ],
      ),
    );
  }
}
