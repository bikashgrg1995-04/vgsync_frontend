import '../models/supplier_model.dart';
import '../services/supplier_service.dart';

class SupplierRepository {
  final SupplierService supplierService;

  SupplierRepository({required this.supplierService});

  Future<List<SupplierModel>> getAllSuppliers() async {
    final list = await supplierService.getAllSuppliers();
    return list.map((e) => SupplierModel.fromJson(e)).toList();
  }

  Future<SupplierModel> addSupplier(SupplierModel supplier) async {
    final res = await supplierService.addSupplier(supplier.toJson());
    return SupplierModel.fromJson(res);
  }

  Future<SupplierModel> updateSupplier(SupplierModel supplier) async {
    final res =
        await supplierService.updateSupplier(supplier.id, supplier.toJson());
    return SupplierModel.fromJson(res);
  }

  Future<void> deleteSupplier(int id) async {
    await supplierService.deleteSupplier(id);
  }
}
