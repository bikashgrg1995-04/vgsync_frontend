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

  /// ---------------- STOCK SALE ----------------
  /// - Manual UI
  /// - Excel import
  Future<SaleModel> createStockSale(
    SaleModel sale) {
    sale
      ..isServicing = false;
     

    return saleService.createSale(sale);
  }

  /// ---------------- SERVICING SALE ----------------
  /// - Manual UI
  /// - Excel import
  Future<SaleModel> createServicingSale(
    SaleModel sale) {
    sale
      ..isServicing = true;

    return saleService.createSale(sale);
  }

  // ================= UPDATE =================

  /// ---------------- UPDATE SALE ----------------
  /// - Edit mode
  /// - Excel re-import
  Future<SaleModel> updateSale(
    SaleModel sale, {
    bool? isServicingOverride
  }) {
    // 🔒 prevent accidental change
    if (isServicingOverride != null) {
      sale.isServicing = isServicingOverride;
    }
    return saleService.updateSale(sale);
  }

  // ================= DELETE =================
  Future<void> deleteSale(int id) {
    return saleService.deleteSale(id);
  }
}
