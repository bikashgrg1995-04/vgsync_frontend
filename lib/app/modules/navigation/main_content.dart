import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/modules/bikesales/bike_sale_binding.dart';
import 'package:vgsync_frontend/app/modules/bikesales/bike_sale_controller.dart';
import 'package:vgsync_frontend/app/modules/bikesales/bike_sale_list_page.dart';
import 'package:vgsync_frontend/app/modules/categories/category_binding.dart';
import 'package:vgsync_frontend/app/modules/categories/category_controller.dart';
import 'package:vgsync_frontend/app/modules/dashboard/dashboard_binding.dart';
import 'package:vgsync_frontend/app/modules/dashboard/dashboard_controller.dart';
import 'package:vgsync_frontend/app/modules/dashboard/dashboard_page.dart';
import 'package:vgsync_frontend/app/modules/expenses/expense_binding.dart';
import 'package:vgsync_frontend/app/modules/expenses/expense_controller.dart';
import 'package:vgsync_frontend/app/modules/expenses/expense_list_page.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_binding.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_controller.dart';
import 'package:vgsync_frontend/app/modules/orders/order_binding.dart';
import 'package:vgsync_frontend/app/modules/orders/order_controller.dart';
import 'package:vgsync_frontend/app/modules/orders/order_list_page.dart';
import 'package:vgsync_frontend/app/modules/purchases/purchase_binding.dart';
import 'package:vgsync_frontend/app/modules/purchases/purchase_controller.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_binding.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_controller.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_list_page.dart';
import 'package:vgsync_frontend/app/modules/purchases/purchase_list_page.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_list_page.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_binding.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_controller.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_list_page.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_binding.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_list_page.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_binding.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_controller.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_list_page.dart';
import 'package:vgsync_frontend/app/modules/categories/category_list_page.dart';

class MainContent extends StatelessWidget {
  MainContent({super.key});

  final GlobalController globalController = Get.find();

  Widget _getPage(String menu) {
    switch (menu) {
      case 'Dashboard':
        if (!Get.isRegistered<DashboardController>()) {
          DashboardBinding().dependencies();
        }
        return DashboardPage();

      case 'Stock':
        if (!Get.isRegistered<StockController>()) {
          StockBinding().dependencies();
        }
        return StockListPage();

      case 'Purchases':
        if (!Get.isRegistered<PurchaseController>()) {
          PurchaseBinding().dependencies();
        }
        return PurchaseListPage();

      case 'Sales':
        if (!Get.isRegistered<SalesController>()) {
          SaleBinding().dependencies();
        }
        return SaleListPage();
      
      case 'Bike Sales':
        if(!Get.isRegistered<BikeSaleController>()){
          BikeSaleBinding().dependencies();
        }
        return BikeSaleListPage();

      case 'Follow-ups':
        if (!Get.isRegistered<FollowUpController>()) {
          FollowUpBinding().dependencies();
        }
        return FollowUpListPage();

      case 'Orders':
        if (!Get.isRegistered<OrderController>()) {
          OrderBinding().dependencies();
        }
        return OrderListPage();

      case 'Expenses':
        if (!Get.isRegistered<ExpenseController>()) {
          ExpenseBinding().dependencies();
        }
        return ExpenseListPage();

      case 'Suppliers':
        if (!Get.isRegistered<SupplierController>()) {
          SupplierBinding().dependencies();
        }
        return SupplierListPage();

      case 'Staffs':
        if (!Get.isRegistered<StaffController>()) {
          StaffBinding().dependencies();
        }
        return StaffListPage();

      case 'Categories':
        if (!Get.isRegistered<CategoryController>()) {
          CategoryBinding().dependencies();
        }
        return CategoryListPage();

      default:
        if (!Get.isRegistered<DashboardController>()) {
          DashboardBinding().dependencies();
        }
        return DashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        return PageTransitionSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
            return FadeThroughTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: _getPage(globalController.selectedMenu.value),
        );
      }),
    );
  }
}
