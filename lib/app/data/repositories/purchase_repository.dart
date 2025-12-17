import '../models/dashboard_model.dart'; // For SalesSummary
import '../services/purchase_service.dart';

class PurchaseRepository {
  final PurchaseService purchaseService;

  PurchaseRepository({required this.purchaseService});

  Future<List> getAllPurchases() {
    return purchaseService.getAllPurchases();
  }

  // New method to compute purchase summary
  Future<SalesSummary> getSummary() async {
    final purchases = await getAllPurchases();

    double totalAmount = 0;
    double todayAmount = 0;
    double monthlyAmount = 0;

    final now = DateTime.now();

    for (var p in purchases) {
      final date = DateTime.parse(
          p['date']); // assuming purchase has 'date' and 'amount'
      final amount = (p['amount'] ?? 0).toDouble();

      totalAmount += amount;

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        todayAmount += amount;
      }

      if (date.year == now.year && date.month == now.month) {
        monthlyAmount += amount;
      }
    }

    return SalesSummary(
      count: purchases.length,
      amount: totalAmount,
      todayAmount: todayAmount,
      monthlyAmount: monthlyAmount,
    );
  }
}
