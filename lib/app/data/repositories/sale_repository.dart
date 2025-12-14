import 'package:vgsync_frontend/app/data/services/sale_service.dart';

class SaleRepository {
  final SaleService saleService;

  SaleRepository({required this.saleService});

  Future<List> getAllSales() {
    return saleService.getAllSales();
  }
}
