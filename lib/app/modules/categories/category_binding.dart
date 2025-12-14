import 'package:get/get.dart';
import '../../modules/categories/category_controller.dart';

class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryController>(
      () => CategoryController(categoryRepository: Get.find()),
    );
  }
}
