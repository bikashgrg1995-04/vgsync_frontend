import '../services/supplier_service.dart';

class SupplierRepository {
  final SupplierService supplierService;

  SupplierRepository({required this.supplierService});

  Future<List> getAllSuppliers() {
    return supplierService.getAllSuppliers();
  }
}
