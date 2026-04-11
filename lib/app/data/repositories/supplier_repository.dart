import '../services/supplier_service.dart';
import '../models/supplier_model.dart';

class SupplierRepository {
  final SupplierService supplierService;

  SupplierRepository({required this.supplierService});

  Future<List<SupplierModel>> getAllSuppliers() =>
      supplierService.getAllSuppliers();

  Future<SupplierModel> addSupplier(SupplierModel supplier) async {
    return await supplierService.addSupplier(supplier.toJson());
  }

  Future<SupplierModel> updateSupplier(SupplierModel supplier) async {
    return await supplierService.updateSupplier(supplier.id, supplier.toJson());
  }

  Future<void> deleteSupplier(int id) =>
      supplierService.deleteSupplier(id);
}