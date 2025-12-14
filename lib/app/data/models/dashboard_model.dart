class DashboardSummary {
  int customers;
  int suppliers;
  int items;
  SalesSummary sales;
  SalesSummary purchases;

  DashboardSummary({
    required this.customers,
    required this.suppliers,
    required this.items,
    required this.sales,
    required this.purchases,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      customers: json['customers'] ?? 0,
      suppliers: json['suppliers'] ?? 0,
      items: json['items'] ?? 0,
      sales: SalesSummary.fromJson(json['sales']),
      purchases: SalesSummary.fromJson(json['purchases']),
    );
  }
}

class SalesSummary {
  int count;
  double amount;
  double todayAmount;
  double monthlyAmount;

  SalesSummary({
    required this.count,
    required this.amount,
    required this.todayAmount,
    required this.monthlyAmount,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      count: json['count'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      todayAmount: (json['today_amount'] ?? 0).toDouble(),
      monthlyAmount: (json['monthly_amount'] ?? 0).toDouble(),
    );
  }
}
