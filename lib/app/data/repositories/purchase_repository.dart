import '../models/purchase_model.dart';
import '../services/purchase_service.dart';

class PurchaseRepository {
  final PurchaseService purchaseService;

  PurchaseRepository({required this.purchaseService});

  Future<List<PurchaseModel>> fetchPurchases() =>
      purchaseService.getPurchases();
  Future<PurchaseModel> addPurchase(PurchaseModel purchase) =>
      purchaseService.createPurchase(purchase);

  Future<PurchaseModel> editPurchase(int id, Map<String, dynamic> data) async {
    return await purchaseService.updatePurchase(id, data);
  }

  Future<void> removePurchase(int id) => purchaseService.deletePurchase(id);
}
