import 'package:get/get.dart';
import 'customer_controller.dart';
import '../../data/repositories/customer_repository.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    final repo = Get.find<CustomerRepository>();

    // Use permanent: true so the controller stays alive across navigations
    Get.put(CustomerController(customerRepository: repo), permanent: true);
  }
}
