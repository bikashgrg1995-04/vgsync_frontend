import '../models/sale_model.dart';
import '../services/sale_service.dart';

class SaleRepository {
  final SaleService saleService;

  SaleRepository({required this.saleService});

  // ================= FETCH =================
  Future<List<SaleModel>> getSales() {
    return saleService.fetchSales();
  }

  // ================= CREATE =================

  /// Create Stock Sale
  /// - UI manual add
  /// - Excel upload
  Future<SaleModel> createStockSale(
    SaleModel sale, {
    int? handledBy,
  }) {
    // business rule
    sale.isServicing = false;
    sale.handledBy = handledBy;

    return saleService.createSale(sale);
  }

  /// Create Servicing Sale
  /// - UI manual add
  /// - Excel upload
  Future<SaleModel> createServicingSale(
    SaleModel sale, {
    int? handledBy,
  }) {
    sale.isServicing = true;
    sale.handledBy = handledBy;

    return saleService.createSale(sale);
  }

  // ================= UPDATE =================

  /// Update Sale
  /// - UI edit
  /// - Excel re-import (update mode)
  Future<SaleModel> updateSale(SaleModel sale) {
    return saleService.updateSale(sale);
  }

  // ================= DELETE =================
  Future<void> deleteSale(int id) {
    return saleService.deleteSale(id);
  }
}
