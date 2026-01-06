import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/expense_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/purchase_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/staff_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/stock_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/supplier_repository.dart';
import 'package:vgsync_frontend/app/data/services/expense_service.dart';
import 'package:vgsync_frontend/app/data/services/purchase_service.dart';
import 'package:vgsync_frontend/app/data/services/staff_service.dart';
import 'package:vgsync_frontend/app/data/services/stock_service.dart';
import 'package:vgsync_frontend/app/data/services/supplier_service.dart';
import 'package:vgsync_frontend/app/modules/expenses/expense_controller.dart';
import 'package:vgsync_frontend/app/modules/purchases/purchase_controller.dart';
import 'package:vgsync_frontend/app/modules/staffs/staff_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';
import 'package:vgsync_frontend/app/modules/suppliers/supplier_controller.dart';

class PurchaseBinding extends Bindings {
  @override
  void dependencies() {
    //Purchase
    // Put the service first
    Get.lazyPut<PurchaseService>(() => PurchaseService());

    // Then the repository, which depends on the service
    Get.lazyPut<PurchaseRepository>(
        () => PurchaseRepository(purchaseService: Get.find<PurchaseService>()));

    // Finally the controller, which depends on the repository
    Get.lazyPut<PurchaseController>(() =>
        PurchaseController(purchaseRepository: Get.find<PurchaseRepository>()));

    //Stock
    // Put the service first
    Get.lazyPut<StockService>(() => StockService());

    // Then the repository, which depends on the service
    Get.lazyPut<StockRepository>(
        () => StockRepository(stockService: Get.find<StockService>()));

    // Finally the controller, which depends on the repository
    Get.lazyPut<StockController>(
        () => StockController(stockRepository: Get.find<StockRepository>()));

    //Expenses
    // Put the service first
    Get.lazyPut<ExpenseService>(() => ExpenseService());

    // Then the repository, which depends on the service
    Get.lazyPut<ExpenseRepository>(
        () => ExpenseRepository(expenseService: Get.find<ExpenseService>()));

    // Finally the controller, which depends on the repository
    Get.lazyPut<ExpenseController>(() =>
        ExpenseController(expenseRepository: Get.find<ExpenseRepository>()));

    //Supplier
    // Put the service first
    Get.lazyPut<SupplierService>(() => SupplierService());

    // Then the repository, which depends on the service
    Get.lazyPut<SupplierRepository>(
        () => SupplierRepository(supplierService: Get.find<SupplierService>()));

    // Finally the controller, which depends on the repository
    Get.lazyPut<SupplierController>(() =>
        SupplierController(supplierRepository: Get.find<SupplierRepository>()));

    //Staffs
    // Put the service first
    Get.lazyPut<StaffService>(() => StaffService());

    // Then the repository, which depends on the service
    Get.lazyPut<StaffRepository>(
        () => StaffRepository(staffService: Get.find<StaffService>()));

    // Finally the controller, which depends on the repository
    Get.lazyPut<StaffController>(
        () => StaffController(staffRepository: Get.find<StaffRepository>()));
  }
}
