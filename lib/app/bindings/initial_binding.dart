import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/auth_controller.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/repositories/auth_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/category_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/customer_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/dashboard_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/followup_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/item_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/purchase_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/sale_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/supplier_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/user_repository.dart';
import 'package:vgsync_frontend/app/data/services/api_service.dart';
import 'package:vgsync_frontend/app/data/services/auth_service.dart';
import 'package:vgsync_frontend/app/data/services/category_service.dart';
import 'package:vgsync_frontend/app/data/services/customer_service.dart';
import 'package:vgsync_frontend/app/data/services/dashboard_service.dart';
import 'package:vgsync_frontend/app/data/services/followup_service.dart';
import 'package:vgsync_frontend/app/data/services/item_service.dart';
import 'package:vgsync_frontend/app/data/services/purchase_service.dart';
import 'package:vgsync_frontend/app/data/services/sale_service.dart';
import 'package:vgsync_frontend/app/data/services/supplier_service.dart';
import 'package:vgsync_frontend/app/data/services/user_service.dart';
import 'package:vgsync_frontend/app/modules/categories/category_controller.dart';
import 'package:vgsync_frontend/app/modules/customers/customer_controller.dart';
import 'package:vgsync_frontend/app/modules/dashboard/dashboard_controller.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_controller.dart';
import 'package:vgsync_frontend/app/modules/items/item_controller.dart';
import 'package:vgsync_frontend/app/modules/purchases/purchase_controller.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_controller.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // -----------------------------
    // Services (singleton)
    // -----------------------------
    Get.put(ApiService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(UserService(), permanent: true);
    Get.put(DashboardService(), permanent: true);
    Get.put(CustomerService(), permanent: true);
    Get.put(SupplierService(), permanent: true);
    Get.put(ItemService(), permanent: true);
    Get.put(CategoryService(), permanent: true);
    Get.put(SaleService(), permanent: true);
    Get.put(PurchaseService(), permanent: true);
    Get.put(FollowUpService(), permanent: true);

    // -----------------------------
    // Repositories (singleton)
    // -----------------------------
    Get.put(AuthRepository(authService: Get.find()), permanent: true);
    Get.put(UserRepository(userService: Get.find()), permanent: true);
    Get.put(DashboardRepository(dashboardService: Get.find()), permanent: true);
    Get.put(CustomerRepository(customerService: Get.find()), permanent: true);
    Get.put(SupplierRepository(supplierService: Get.find()), permanent: true);
    Get.put(ItemRepository(itemService: Get.find()), permanent: true);
    Get.put(CategoryRepository(categoryService: Get.find()), permanent: true);
    Get.put(SaleRepository(saleService: Get.find()), permanent: true);
    Get.put(PurchaseRepository(purchaseService: Get.find()), permanent: true);
    Get.put(FollowUpRepository(followUpService: Get.find()), permanent: true);

    // -----------------------------
    // Controllers
    // -----------------------------
    Get.put(GlobalController(), permanent: true);

    // AuthController depends on AuthRepository & UserRepository
    Get.put(
      AuthController(
        authRepository: Get.find(),
        userRepository: Get.find(),
      ),
      permanent: true,
    );

    // DashboardController depends on multiple repositories
    Get.put(
      DashboardController(
        dashboardRepository: Get.find(),
      ),
      permanent: true,
    );

    Get.put(CustomerController(customerRepository: Get.find()),
        permanent: true);
    Get.put(SupplierController(supplierRepository: Get.find()),
        permanent: true);
    Get.put(CategoryController(categoryRepository: Get.find()),
        permanent: true);
    Get.put(ItemController(itemRepository: Get.find()), permanent: true);

    Get.put(FollowUpController(followUpRepository: Get.find()),
        permanent: true);
    Get.put(SaleController(saleRepository: Get.find()), permanent: true);
    Get.put(PurchaseController(purchaseRepository: Get.find()),
        permanent: true);
  }
}
