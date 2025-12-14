import 'package:get/get.dart';
import 'customer_controller.dart';
import '../../data/repositories/customer_repository.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerController>(() => CustomerController(
          customerRepository: Get.find<CustomerRepository>(),
        ));
  }
}
