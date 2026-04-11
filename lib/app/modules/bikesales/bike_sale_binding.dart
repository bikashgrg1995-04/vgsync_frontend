import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/followup_repository.dart';
import 'package:vgsync_frontend/app/data/services/bike_sale_service.dart';
import 'package:vgsync_frontend/app/data/repositories/bike_sale_repository.dart';
import 'package:vgsync_frontend/app/data/services/followup_service.dart';
import 'package:vgsync_frontend/app/modules/bikesales/bike_sale_controller.dart';
import 'package:vgsync_frontend/app/modules/followups/followup_controller.dart';

class BikeSaleBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy inject BikeSaleService
    Get.lazyPut<BikeSaleService>(() => BikeSaleService());

    // Lazy inject BikeSaleRepository with the service
    Get.lazyPut<BikeSaleRepository>(
      () => BikeSaleRepository(bikeSaleService: Get.find<BikeSaleService>()),
    );

    // Lazy inject BikeSaleController with the repository
    Get.lazyPut<BikeSaleController>(
      () => BikeSaleController(
        bikeSaleRepository: Get.find<BikeSaleRepository>(),
      ),
    );


    //followup
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
