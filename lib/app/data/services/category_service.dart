import 'package:dio/dio.dart';
import 'api_service.dart';
import '../../data/models/category_model.dart';

class CategoryService {
  final Dio _dio = ApiService.dio;

Future<List<CategoryModel>> getAllCategories() async {
  final res = await _dio.get('/categories/');

  return ((res.data['results'] ?? []) as List)
      .map((e) => CategoryModel.fromJson(e))
      .toList();
}

  Future<CategoryModel> addCategory(CategoryModel category) async {
    final res = await _dio.post('/categories/', data: category.toJson());
    return CategoryModel.fromJson(res.data);
  }

  Future<CategoryModel> updateCategory(CategoryModel category) async {
    final res =
        await _dio.put('/categories/${category.id}/', data: category.toJson());
    return CategoryModel.fromJson(res.data);
  }

  Future<void> deleteCategory(int id) async {
    await _dio.delete('/categories/$id/');
  }
}
