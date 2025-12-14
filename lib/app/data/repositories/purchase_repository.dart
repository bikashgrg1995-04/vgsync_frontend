import '../services/purchase_service.dart';

class PurchaseRepository {
  final PurchaseService purchaseService;

  PurchaseRepository({required this.purchaseService});

  Future<List> getAllPurchases() {
    return purchaseService.getAllPurchases();
  }
}
