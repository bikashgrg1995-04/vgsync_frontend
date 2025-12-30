import '../models/sale_model.dart';
import '../services/sale_service.dart';

class SaleRepository {
  final SaleService saleService;

  SaleRepository({required this.saleService});

  Future<List<SaleModel>> getSales() => saleService.fetchSales();

  Future<SaleModel> create(SaleModel sale) => saleService.createSale(sale);

  Future<SaleModel> update(SaleModel sale) => saleService.updateSale(sale);

  Future<void> delete(int id) => saleService.deleteSale(id);
}
