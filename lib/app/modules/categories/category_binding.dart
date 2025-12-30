// app/modules/dashboard/bindings/dashboard_binding.dart
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/repositories/category_repository.dart';
import 'package:vgsync_frontend/app/data/services/category_service.dart';
import 'package:vgsync_frontend/app/modules/categories/category_controller.dart';

class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryService>(
      () => CategoryService(),
    );

    Get.lazyPut<CategoryRepository>(
      () => CategoryRepository(
        categoryService: Get.find(),
      ),
    );

    Get.lazyPut<CategoryController>(
      () => CategoryController(
        categoryRepository: Get.find(),
      ),
    );
  }
}
