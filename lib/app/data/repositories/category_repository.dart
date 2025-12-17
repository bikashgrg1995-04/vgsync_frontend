import '../services/category_service.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final CategoryService categoryService;

  CategoryRepository({required this.categoryService});

  Future<List<CategoryModel>> getAllCategories() =>
      categoryService.getAllCategories();

  Future<CategoryModel> addCategory(CategoryModel category) =>
      categoryService.addCategory(category);

  Future<CategoryModel> updateCategory(CategoryModel category) =>
      categoryService.updateCategory(category);

  Future<void> deleteCategory(int id) => categoryService.deleteCategory(id);
}
