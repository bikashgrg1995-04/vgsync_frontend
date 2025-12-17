import 'package:get/get.dart';
import 'package:vgsync_frontend/app/modules/categories/category_binding.dart';
import 'package:vgsync_frontend/app/modules/categories/category_list_page.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_binding.dart';
import 'package:vgsync_frontend/app/modules/items/item_binding.dart';
import 'package:vgsync_frontend/app/modules/items/item_list_page.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_binding.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_list_page.dart';
import 'app_routes.dart';

// Import pages
import '../modules/auth/login_page.dart';
import '../modules/dashboard/dashboard_page.dart';
import '../modules/customers/customer_list_page.dart';
import '../modules/customers/customer_binding.dart';
import '../modules/followups/followup_list_page.dart';

class AppPages {
  static const initial = AppRoutes.login;

  static final pages = [
    // ---------- AUTH ----------
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
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
      binding: CustomerBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ---------- SUPPLIERS ----------
    GetPage(
      name: AppRoutes.suppliers,
      page: () => SupplierListPage(),
      binding: SupplierBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // ---------- ITEMS ----------
    GetPage(
      name: AppRoutes.items,
      page: () => ItemListPage(),
      binding: ItemBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // ---------- CATEGORIES ----------
    GetPage(
      name: AppRoutes.categories,
      page: () => CategoryListPage(),
      binding: CategoryBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ---------- SALES ----------
    // GetPage(
    //   name: AppRoutes.sales,
    //   page: () => SaleListPage(),
    //   binding: SaleBinding(),
    //   transition: Transition.rightToLeftWithFade,
    //   transitionDuration: const Duration(milliseconds: 400),
    // ),

    // ---------- PURCHASES ----------
    // GetPage(
    //   name: AppRoutes.purchases,
    //   page: () => PurchaseListPage(),
    //   binding: PurchaseBinding(),
    //   transition: Transition.rightToLeftWithFade,
    //   transitionDuration: const Duration(milliseconds: 400),
    // ),

    // ---------- FOLLOWUPS ----------
    GetPage(
      name: AppRoutes.followups,
      page: () => FollowupListPage(),
      binding: FollowupBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
