import 'package:vgsync_frontend/app/data/models/purchase_model.dart';
import 'package:vgsync_frontend/app/data/services/purchase_service.dart';

class PurchaseRepository {
  final PurchaseService purchaseService;

  PurchaseRepository({required this.purchaseService});

  Future<List<PurchaseModel>> getPurchases() => purchaseService.getPurchases();

  Future<PurchaseModel> create(PurchaseModel purchase) =>
      purchaseService.createPurchase(purchase);

  Future<PurchaseModel> update(PurchaseModel purchase) =>
      purchaseService.updatePurchase(purchase);

  Future<void> delete(int id) => purchaseService.deletePurchase(id);
}
