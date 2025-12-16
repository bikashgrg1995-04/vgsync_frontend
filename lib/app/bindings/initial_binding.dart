import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/auth_controller.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/data/repositories/auth_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/category_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/customer_repository.dart';
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
import 'package:vgsync_frontend/app/modules/dashboard/dashboard_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // -----------------------------
    // Services
    // -----------------------------
    Get.put(ApiService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(UserService(), permanent: true);

    Get.lazyPut(() => ApiService());
    Get.lazyPut(() => DashboardService());
    Get.lazyPut(() => CustomerService());
    Get.lazyPut(() => SupplierService());
    Get.lazyPut(() => ItemService());
    Get.lazyPut(() => CategoryService());
    Get.lazyPut(() => SaleService());
    Get.lazyPut(() => PurchaseService());
    Get.lazyPut(() => FollowUpService());

    // -----------------------------
    // Repositories
    // -----------------------------
    Get.put(AuthRepository(authService: Get.find()), permanent: true);
    Get.put(UserRepository(userService: Get.find()), permanent: true);

    Get.lazyPut(() => CustomerRepository(customerService: Get.find()));
    Get.lazyPut(() => SupplierRepository(supplierService: Get.find()));
    Get.lazyPut(() => ItemRepository(itemService: Get.find()));
    Get.lazyPut(() => CategoryRepository(categoryService: Get.find()));
    Get.lazyPut(() => SaleRepository(saleService: Get.find()));
    Get.lazyPut(() => PurchaseRepository(purchaseService: Get.find()));
    Get.lazyPut(() => FollowUpRepository(followUpService: Get.find()));

    // -----------------------------
    // Controllers
    // -----------------------------
    Get.put(GlobalController(), permanent: true);
    Get.put(
        AuthController(authRepository: Get.find(), userRepository: Get.find()),
        permanent: true);

    Get.put(DashboardController(
      customerRepository: Get.find(),
      supplierRepository: Get.find(),
      itemRepository: Get.find(),
      categoryRepository: Get.find(),
      saleRepository: Get.find(),
      purchaseRepository: Get.find(),
      followupRepository: Get.find(),
    ));
  }
}
