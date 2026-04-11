import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/expense_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/followup_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/sale_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/staff_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/stock_repository.dart';
import 'package:vgsync_frontend/app/data/services/expense_service.dart';
import 'package:vgsync_frontend/app/data/services/followup_service.dart';
import 'package:vgsync_frontend/app/data/services/sale_service.dart';
import 'package:vgsync_frontend/app/data/services/staff_service.dart';
import 'package:vgsync_frontend/app/data/services/stock_service.dart';
import 'package:vgsync_frontend/app/modules/expenses/expense_controller.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_controller.dart';
import 'package:vgsync_frontend/app/modules/sales/sale_controller.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';

class SaleBinding extends Bindings {
  @override
  void dependencies() {
    // Put the service first
    Get.lazyPut<SaleService>(() => SaleService());

    // Then the repository, which depends on the service
    Get.lazyPut<SaleRepository>(
        () => SaleRepository(saleService: Get.find<SaleService>()));

    // Finally the controller, which depends on the repository
    Get.lazyPut<SalesController>(
        () => SalesController(saleRepository: Get.find<SaleRepository>()));

    Get.lazyPut<FollowUpService>(() => FollowUpService());

    // Then the repository, which depends on the service
    Get.lazyPut<FollowUpRepository>(
        () => FollowUpRepository(followUpService: Get.find<FollowUpService>()));

    // Finally the controller, which depends on the repository
    Get.lazyPut<FollowUpController>(() =>
        FollowUpController(followUpRepository: Get.find<FollowUpRepository>()));

    Get.lazyPut<StockService>(() => StockService());

    // Then the repository, which depends on the service
    Get.lazyPut<StockRepository>(
        () => StockRepository(stockService: Get.find<StockService>()));

    // Finally the controller, which depends on the repository
    Get.lazyPut<StockController>(
        () => StockController(stockRepository: Get.find<StockRepository>()));

    Get.lazyPut<StaffService>(() => StaffService());

    // Then the repository, which depends on the service
    Get.lazyPut<StaffRepository>(
        () => StaffRepository(staffService: Get.find<StaffService>()));

    // Finally the controller, which depends on the repository
    Get.lazyPut<StaffController>(
        () => StaffController(staffRepository: Get.find<StaffRepository>()));

    Get.lazyPut<ExpenseService>(() => ExpenseService());

    // Lazy inject ExpenseRepository with the service
    Get.lazyPut<ExpenseRepository>(
        () => ExpenseRepository(expenseService: Get.find<ExpenseService>()));

    // Lazy inject ExpenseController with the repository
    Get.lazyPut<ExpenseController>(() =>
        ExpenseController(expenseRepository: Get.find<ExpenseRepository>()));
  }
}
