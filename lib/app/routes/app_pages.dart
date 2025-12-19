import 'package:get/get.dart';
import 'package:vgsync_frontend/app/modules/categories/category_list_page.dart';
import 'package:vgsync_frontend/app/modules/items/item_list_page.dart';
import 'package:vgsync_frontend/app/modules/purchases/purchase_list_page.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_list_page.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_list_page.dart';
import 'app_routes.dart';

// Import pages
import '../modules/auth/login_page.dart';
import '../modules/dashboard/dashboard_page.dart';
import '../modules/customers/customer_list_page.dart';
import '../modules/followups/followup_list_page.dart';

class AppPages {
  static const initial = AppRoutes.login;

  static final pages = [
    // ---------- AUTH ----------
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ---------- DASHBOARD ----------
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardPage(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ---------- CUSTOMERS ----------
    GetPage(
      name: AppRoutes.customers,
      page: () => CustomerListPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ---------- SUPPLIERS ----------
    GetPage(
      name: AppRoutes.suppliers,
      page: () => SupplierListPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ---------- ITEMS ----------
    GetPage(
      name: AppRoutes.items,
      page: () => ItemListPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ---------- CATEGORIES ----------
    GetPage(
      name: AppRoutes.categories,
      page: () => CategoryListPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ---------- SALES ----------
    GetPage(
      name: AppRoutes.sales,
      page: () => SaleListPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // ---------- PURCHASES ----------
    GetPage(
      name: AppRoutes.purchases,
      page: () => PurchaseListPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ---------- FOLLOWUPS ----------
    GetPage(
      name: AppRoutes.followups,
      page: () => FollowupListPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
