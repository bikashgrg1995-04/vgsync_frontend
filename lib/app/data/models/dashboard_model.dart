// dashboard_model.dart

class DashboardResponse {
  final DashboardSummary summary;
  final List<LowStockItem> lowStockItems;
  final int stockThreshold;
  final List<DashboardFollowupItem> upcomingFollowups;

  DashboardResponse({
    required this.summary,
    required this.lowStockItems,
    required this.stockThreshold,
    required this.upcomingFollowups,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      summary: DashboardSummary.fromJson(json['summary']),
      lowStockItems: (json['low_stock_items'] as List)
          .map((e) => LowStockItem.fromJson(e))
          .toList(),
      stockThreshold: json['stock_threshold'] ?? 5,
      upcomingFollowups: (json['upcoming_followups'] as List)
          .map((e) => DashboardFollowupItem.fromJson(e))
          .toList(),
    );
  }
}

// ---------------- Summary ----------------

class DashboardSummary {
  int customers;
  int categories; // added because your new summary includes categories
  int suppliers;
  int items;
  SalesSummary sales;
  SalesSummary purchases;

  DashboardSummary({
    required this.customers,
    required this.categories,
    required this.suppliers,
    required this.items,
    required this.sales,
    required this.purchases,
  });

  // Named constructor for empty/default values
  factory DashboardSummary.empty() {
    return DashboardSummary(
      customers: 0,
      categories: 0,
      suppliers: 0,
      items: 0,
      sales: SalesSummary.empty(),
      purchases: SalesSummary.empty(),
    );
  }

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      customers: json['customers'] ?? 0,
      categories: json['categories'] ?? 0,
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

  // Named constructor for empty/default values
  factory SalesSummary.empty() {
    return SalesSummary(
      count: 0,
      amount: 0,
      todayAmount: 0,
      monthlyAmount: 0,
    );
  }

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      count: json['count'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      todayAmount: (json['today_amount'] ?? 0).toDouble(),
      monthlyAmount: (json['monthly_amount'] ?? 0).toDouble(),
    );
  }
}

// ---------------- Low Stock Item ----------------

class LowStockItem {
  final String name;
  final int stock;

  LowStockItem({required this.name, required this.stock});

  factory LowStockItem.fromJson(Map<String, dynamic> json) {
    return LowStockItem(
      name: json['name'] ?? '',
      stock: json['stock'] ?? 0,
    );
  }
}

// ---------------- Follow-up Item ----------------

class DashboardFollowupItem {
  final String customerName;
  final String date;
  final String priority;

  DashboardFollowupItem({
    required this.customerName,
    required this.date,
    required this.priority,
  });

  factory DashboardFollowupItem.fromJson(Map<String, dynamic> json) {
    return DashboardFollowupItem(
      customerName: json['customer'] ?? '',
      date: json['follow_up_date'] ?? '',
      priority: json['priority'] ?? '',
    );
  }
}
