import 'package:get/get.dart';
import 'followup_controller.dart';

class FollowupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FollowUpController(followUpRepository: Get.find()));
  }
}
