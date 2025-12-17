import '../models/sale_model.dart';
import '../services/sale_service.dart';

class SaleRepository {
  final SaleService saleService;

  SaleRepository({required this.saleService});

  Future<List<SaleModel>> fetchSales() => saleService.fetchSales();
  Future<SaleModel> addSale(SaleModel sale) => saleService.createSale(sale);
  Future<SaleModel> editSale(int id, Map<String, dynamic> data) =>
      saleService.updateSale(id, data);
  Future<void> removeSale(int id) => saleService.deleteSale(id);
}
