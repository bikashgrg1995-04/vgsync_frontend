import 'package:vgsync_frontend/app/data/services/sale_service.dart';

import '../models/dashboard_model.dart'; // For SalesSummary

class SaleRepository {
  final SaleService saleService;

  SaleRepository({required this.saleService});

  Future<List> getAllSales() {
    return saleService.getAllSales();
  }

  Future<int> getCount() async {
    final sales = await getAllSales();
    return sales.length;
  }

  // New method to compute SalesSummary
  Future<SalesSummary> getSummary() async {
    final sales = await getAllSales();

    double totalAmount = 0;
    double todayAmount = 0;
    double monthlyAmount = 0;

    final now = DateTime.now();

    for (var s in sales) {
      final date =
          DateTime.parse(s['date']); // assuming sale has 'date' and 'amount'
      final amount = (s['amount'] ?? 0).toDouble();

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
      count: sales.length,
      amount: totalAmount,
      todayAmount: todayAmount,
      monthlyAmount: monthlyAmount,
    );
  }
}
