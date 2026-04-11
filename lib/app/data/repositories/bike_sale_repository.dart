import '../models/bike_sale_model.dart';
import '../services/bike_sale_service.dart';

class BikeSaleRepository {
  final BikeSaleService bikeSaleService;

  BikeSaleRepository({required this.bikeSaleService});

  // ===============================
  // Bike Sale Methods
  // ===============================

  Future<List<BikeSale>> getBikeSales({
    String? saleType,
    String? vehicleType,
  }) {
    return bikeSaleService.getBikeSales(
      saleType: saleType,
      vehicleType: vehicleType,
    );
  }

  Future<BikeSale> createBikeSale(BikeSale sale) {
    return bikeSaleService.createBikeSale(sale);
  }

  Future<BikeSale> updateBikeSale({
    required int saleId,
    required Map<String, dynamic> data,
  }) {
    return bikeSaleService.updateBikeSale(saleId: saleId, data: data);
  }

  Future<void> deleteBikeSale(int saleId) {
    return bikeSaleService.deleteBikeSale(saleId);
  }

  // ===============================
  // EMI Tracker Methods
  // ===============================

  Future<List<EmiTracker>> getEmiTrackers({int? saleId}) {
    return bikeSaleService.getEmiTrackers(saleId: saleId);
  }

  Future<EmiTracker> updateEmiPayment({
    required int emiId,
    required double paidAmount,
    required DateTime paymentDate,
    required EMIPaymentMethod emiPaymentMethod,
    required EmiStatus status,
  }) {
    return bikeSaleService.updateEmiPayment(
      emiId: emiId,
      paidAmount: paidAmount,
      paymentDate: paymentDate,
      emiPaymentMethod: emiPaymentMethod,
      status: status,
    );
  }
}