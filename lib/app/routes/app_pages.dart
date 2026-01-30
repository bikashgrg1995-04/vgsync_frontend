import 'package:get/get.dart';
import 'package:vgsync_frontend/app/modules/bikesales/bike_sale_binding.dart';
import 'package:vgsync_frontend/app/modules/bikesales/bike_sale_list_page.dart';
import 'package:vgsync_frontend/app/modules/categories/category_list_page.dart';
import 'package:vgsync_frontend/app/modules/dashboard/dashboard_binding.dart';
import 'package:vgsync_frontend/app/modules/expenses/expense_binding.dart';
import 'package:vgsync_frontend/app/modules/expenses/expense_list_page.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_binding.dart';
import 'package:vgsync_frontend/app/modules/orders/order_binding.dart';
import 'package:vgsync_frontend/app/modules/orders/order_list_page.dart';
import 'package:vgsync_frontend/app/modules/purchases/purchase_binding.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_binding.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_binding.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_list_page.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_binding.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_list_page.dart';
import 'package:vgsync_frontend/app/modules/navigation/navigation_page.dart';
import 'package:vgsync_frontend/app/modules/purchases/purchase_list_page.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_list_page.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_binding.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_list_page.dart';
import 'package:vgsync_frontend/app/modules/spalsh/splash_page.dart';
import 'app_routes.dart';

// Import pages
import '../modules/auth/login_page.dart';
import '../modules/dashboard/dashboard_page.dart';
import '../modules/followups/followup_list_page.dart';

class AppPages {
  static final pages = [
    // ---------- SPLASH ----------
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
    ),

    // ---------- AUTH ----------
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ---------- AUTH ----------
    GetPage(
      name: AppRoutes.navigation,
      page: () => NavigationPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ---------- DASHBOARD ----------
    GetPage(
        name: AppRoutes.dashboard,
        page: () => DashboardPage(),
        transition: Transition.zoom,
        transitionDuration: const Duration(milliseconds: 300),
        binding: DashboardBinding()),

    // ---------- SUPPLIERS ----------
    GetPage(
        name: AppRoutes.suppliers,
        page: () => SupplierListPage(),
        transition: Transition.rightToLeftWithFade,
        transitionDuration: const Duration(milliseconds: 300),
        binding: SupplierBinding()),

    // ---------- ITEMS ----------
    GetPage(
        name: AppRoutes.stock,
        page: () => StockListPage(),
        transition: Transition.rightToLeftWithFade,
        transitionDuration: const Duration(milliseconds: 300),
        binding: StockBinding()),

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
      binding: SaleBinding(),
    ),

       // ---------- SALES ----------
    GetPage(
      name: AppRoutes.bikesales,
      page: () => BikeSaleListPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
      binding: BikeSaleBinding(),
    ),

    // ---------- PURCHASES ----------
    GetPage(
      name: AppRoutes.purchases,
      page: () => PurchaseListPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
      binding: PurchaseBinding(),
    ),

    // ---------- FOLLOWUPS ----------
    GetPage(
      name: AppRoutes.followups,
      page: () => FollowUpListPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
      binding: FollowUpBinding(),
    ),

    // ---------- ORDERS ----------
    GetPage(
      name: AppRoutes.orders,
      page: () => OrderListPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
      binding: OrderBinding(),
    ),

    // ---------- EXPENSES ----------
    GetPage(
      name: AppRoutes.expenses,
      page: () => ExpenseListPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
      binding: ExpenseBinding(),
    ),

    // ---------- STAFFS ----------
    GetPage(
      name: AppRoutes.staffs,
      page: () => StaffListPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
      binding: StaffBinding(),
    ),
  ];
}
