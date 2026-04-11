import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/followup_repository.dart';
import 'package:vgsync_frontend/app/data/services/followup_service.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_controller.dart';

class FollowUpBinding extends Bindings {
  @override
  void dependencies() {
    // Service
    final followUpService = FollowUpService();

    // Repository
    final followUpRepository =
        FollowUpRepository(followUpService: followUpService);

    // Controller
    Get.put<FollowUpController>(
      FollowUpController(followUpRepository: followUpRepository),
    );
  }
}
