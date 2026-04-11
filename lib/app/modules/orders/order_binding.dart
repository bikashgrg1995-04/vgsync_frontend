import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/order_repository.dart';
import 'package:vgsync_frontend/app/data/repositories/stock_repository.dart';
import 'package:vgsync_frontend/app/data/services/order_service.dart';
import 'package:vgsync_frontend/app/data/services/stock_service.dart';
import 'package:vgsync_frontend/app/modules/orders/order_controller.dart';
import 'package:vgsync_frontend/app/modules/orders/order_form_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/stock_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    // Put the service first
    Get.lazyPut<OrderService>(() => OrderService());

    // Then the repository, which depends on the service
    Get.lazyPut<OrderRepository>(
        () => OrderRepository(orderService: Get.find<OrderService>()));

    // Finally the controller, which depends on the repository
    Get.lazyPut<OrderController>(
        () => OrderController(orderRepository: Get.find<OrderRepository>()));

    //order form
    Get.lazyPut<OrderFormController>(() => OrderFormController(), fenix: true);

    //for stock/ item selection
    //binding stockController is important

    Get.lazyPut<StockService>(
      () => StockService(),
    );

    Get.lazyPut<StockRepository>(
      () => StockRepository(
        stockService: Get.find(),
      ),
    );

    Get.lazyPut<StockController>(
        () => StockController(
              stockRepository: Get.find(),
            ),
        fenix: true);
  }
}
