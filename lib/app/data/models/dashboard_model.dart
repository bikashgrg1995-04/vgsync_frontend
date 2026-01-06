// ================== DASHBOARD RESPONSE ==================
class DashboardResponse {
  String period;
  int year;
  int month;

  StockSummary stock;
  IncomeSummary income; // sale = income
  ExpenseSummary expense;
  ProfitLossSummary profitLoss;
  OrdersSummary orders;
  FollowupSummary followups;
  StaffSalarySummary staffSalary;

  DashboardResponse({
    required this.period,
    required this.year,
    required this.month,
    required this.stock,
    required this.income,
    required this.expense,
    required this.profitLoss,
    required this.orders,
    required this.followups,
    required this.staffSalary,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      period: json['period'] ?? '',
      year: json['year'] ?? 0,
      month: json['month'] ?? 0,
      stock: StockSummary.fromJson(json['stock'] ?? {}),
      income: IncomeSummary.fromJson(json['sale'] ?? {}),
      expense: ExpenseSummary.fromJson(json['expense'] ?? {}),
      profitLoss: ProfitLossSummary.fromJson(json['profit_loss'] ?? {}),
      orders: OrdersSummary.fromJson(json['orders'] ?? {}),
      followups: FollowupSummary.fromJson(json['followups'] ?? {}),
      staffSalary: StaffSalarySummary.fromJson(json['staff_salary'] ?? {}),
    );
  }

  factory DashboardResponse.empty() {
    return DashboardResponse(
      period: '',
      year: 0,
      month: 0,
      stock: StockSummary.empty(),
      income: IncomeSummary.empty(),
      expense: ExpenseSummary.empty(),
      profitLoss: ProfitLossSummary.empty(),
      orders: OrdersSummary.empty(),
      followups: FollowupSummary.empty(),
      staffSalary: StaffSalarySummary.empty(),
    );
  }
}

// ================== STOCK ==================
class StockSummary {
  int totalItems;
  int totalStock;
  int lowStockCount;
  int stockThreshold;
  List<LowStockItem> lowStockItems;
  List<SaleStockItem> highSaleStock;
  List<SaleStockItem> lowSaleStock;

  StockSummary({
    required this.totalItems,
    required this.totalStock,
    required this.lowStockCount,
    required this.stockThreshold,
    required this.lowStockItems,
    required this.highSaleStock,
    required this.lowSaleStock,
  });

  factory StockSummary.fromJson(Map<String, dynamic> json) {
    return StockSummary(
      totalItems: json['total_items'] ?? 0,
      totalStock: json['total_stock'] ?? 0,
      lowStockCount: json['low_stock_count'] ?? 0,
      stockThreshold: json['stock_threshold'] ?? 5,
      lowStockItems: (json['low_stock_items'] as List? ?? [])
          .map((e) => LowStockItem.fromJson(e))
          .toList(),
      highSaleStock: (json['high_sale_stock'] as List? ?? [])
          .map((e) => SaleStockItem.fromJson(e))
          .toList(),
      lowSaleStock: (json['low_sale_stock'] as List? ?? [])
          .map((e) => SaleStockItem.fromJson(e))
          .toList(),
    );
  }

  factory StockSummary.empty() {
    return StockSummary(
      totalItems: 0,
      totalStock: 0,
      lowStockCount: 0,
      stockThreshold: 5,
      lowStockItems: [],
      highSaleStock: [],
      lowSaleStock: [],
    );
  }
}

class LowStockItem {
  int id;
  String name;
  String model;
  int stock;
  String categoryName;

  LowStockItem({
    required this.id,
    required this.name,
    required this.model,
    required this.stock,
    required this.categoryName,
  });

  factory LowStockItem.fromJson(Map<String, dynamic> json) {
    return LowStockItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      model: json['model'] ?? '',
      stock: json['stock'] ?? 0,
      categoryName: json['category__name'] ?? '',
    );
  }
}

class SaleStockItem {
  String itemName;
  int totalQty;

  SaleStockItem({required this.itemName, required this.totalQty});

  factory SaleStockItem.fromJson(Map<String, dynamic> json) {
    return SaleStockItem(
      itemName: json['item__name'] ?? '',
      totalQty: json['total_qty'] ?? 0,
    );
  }
}

// ================== INCOME (SALES) ==================
class IncomeSummary {
  int count;
  double total;
  double today;
  double monthly;
  double yearly;

  IncomeSummary({
    required this.count,
    required this.total,
    required this.today,
    required this.monthly,
    required this.yearly,
  });

  factory IncomeSummary.fromJson(Map<String, dynamic> json) {
    return IncomeSummary(
      count: json['count'] ?? 0,
      total: (json['total_amount'] ?? 0).toDouble(),
      today: (json['today_amount'] ?? 0).toDouble(),
      monthly: (json['monthly_amount'] ?? 0).toDouble(),
      yearly: (json['yearly_amount'] ?? 0).toDouble(),
    );
  }

  factory IncomeSummary.empty() {
    return IncomeSummary(count: 0, total: 0, today: 0, monthly: 0, yearly: 0);
  }
}

// ================== EXPENSE ==================
class ExpenseSummary {
  double today;
  double monthly;
  double yearly;
  List<ExpenseCategory> categories;

  ExpenseSummary({
    required this.today,
    required this.monthly,
    required this.yearly,
    required this.categories,
  });

  factory ExpenseSummary.fromJson(Map<String, dynamic> json) {
    return ExpenseSummary(
      today: (json['today_amount'] ?? 0).toDouble(),
      monthly: (json['monthly_amount'] ?? 0).toDouble(),
      yearly: (json['yearly_amount'] ?? 0).toDouble(),
      categories: (json['categories'] as List? ?? [])
          .map((e) => ExpenseCategory.fromJson(e))
          .toList(),
    );
  }

  factory ExpenseSummary.empty() {
    return ExpenseSummary(today: 0, monthly: 0, yearly: 0, categories: []);
  }
}

class ExpenseCategory {
  String category;
  double amount;

  ExpenseCategory({required this.category, required this.amount});

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

// ================== PROFIT & LOSS ==================
class ProfitLossSummary {
  double income;
  double expense;
  double profit;
  double loss;

  ProfitLossSummary({
    required this.income,
    required this.expense,
    required this.profit,
    required this.loss,
  });

  factory ProfitLossSummary.fromJson(Map<String, dynamic> json) {
    return ProfitLossSummary(
      income: (json['income'] ?? 0).toDouble(),
      expense: (json['expense'] ?? 0).toDouble(),
      profit: (json['profit'] ?? 0).toDouble(),
      loss: (json['loss'] ?? 0).toDouble(),
    );
  }

  factory ProfitLossSummary.empty() {
    return ProfitLossSummary(income: 0, expense: 0, profit: 0, loss: 0);
  }
}

class ProfitLoss {
  double income;
  double expense;
  double profit;
  double loss;

  ProfitLoss({
    required this.income,
    required this.expense,
    required this.profit,
    required this.loss,
  });

  factory ProfitLoss.fromJson(Map<String, dynamic> json) {
    return ProfitLoss(
      income: (json['income'] ?? 0).toDouble(),
      expense: (json['expense'] ?? 0).toDouble(),
      profit: (json['profit'] ?? 0).toDouble(),
      loss: (json['loss'] ?? 0).toDouble(),
    );
  }

  factory ProfitLoss.empty() {
    return ProfitLoss(income: 0, expense: 0, profit: 0, loss: 0);
  }
}

// ================== ORDERS ==================
class OrdersSummary {
  int totalOrders;
  double pendingAmount;
  List<OrderItem> records;

  OrdersSummary({
    required this.totalOrders,
    required this.pendingAmount,
    required this.records,
  });

  factory OrdersSummary.fromJson(Map<String, dynamic> json) {
    return OrdersSummary(
      totalOrders: json['total_orders'] ?? 0,
      pendingAmount: (json['pending_amount'] ?? 0).toDouble(),
      records: (json['records'] as List? ?? [])
          .map((e) => OrderItem.fromJson(e))
          .toList(),
    );
  }

  factory OrdersSummary.empty() {
    return OrdersSummary(totalOrders: 0, pendingAmount: 0, records: []);
  }
}

class OrderItem {
  int id;
  String customerName;
  String vehicleModel;
  String date;
  double totalAmount;
  double advance;
  double pendingAmount;

  OrderItem({
    required this.id,
    required this.customerName,
    required this.vehicleModel,
    required this.date,
    required this.totalAmount,
    required this.advance,
    required this.pendingAmount,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      vehicleModel: json['vehicle_model'] ?? '',
      date: json['date'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      advance: (json['advance'] ?? 0).toDouble(),
      pendingAmount: (json['pending_amount'] ?? 0).toDouble(),
    );
  }
}

// ================== FOLLOWUPS ==================
class FollowupSummary {
  int pendingCount;
  List<FollowupItem> records;

  FollowupSummary({required this.pendingCount, required this.records});

  factory FollowupSummary.fromJson(Map<String, dynamic> json) {
    return FollowupSummary(
      pendingCount: json['pending_count'] ?? 0,
      records: (json['records'] as List? ?? [])
          .map((e) => FollowupItem.fromJson(e))
          .toList(),
    );
  }

  factory FollowupSummary.empty() {
    return FollowupSummary(pendingCount: 0, records: []);
  }
}

class FollowupItem {
  int id;
  String customerName;
  String vehicle;
  String followUpDate;
  String remarks;
  String status;
  String statusColor;
  bool isNearest;

  FollowupItem({
    required this.id,
    required this.customerName,
    required this.vehicle,
    required this.followUpDate,
    required this.remarks,
    required this.status,
    required this.statusColor,
    required this.isNearest,
  });

  factory FollowupItem.fromJson(Map<String, dynamic> json) {
    return FollowupItem(
      id: json['id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      vehicle: json['vehicle'] ?? '',
      followUpDate: json['follow_up_date'] ?? '',
      remarks: json['remarks'] ?? '',
      status: json['status'] ?? '',
      statusColor: json['status_color'] ?? 'orange',
      isNearest: json['is_nearest'] ?? false,
    );
  }
}

// ================== STAFF SALARY ==================
class StaffSalarySummary {
  int totalStaff;
  double paid;
  double pending;
  List<StaffSalaryItem> details;

  StaffSalarySummary({
    required this.totalStaff,
    required this.paid,
    required this.pending,
    required this.details,
  });

  factory StaffSalarySummary.fromJson(Map<String, dynamic> json) {
    return StaffSalarySummary(
      totalStaff: json['total_staff'] ?? 0,
      paid: (json['paid'] ?? 0).toDouble(),
      pending: (json['pending'] ?? 0).toDouble(),
      details: (json['details'] as List? ?? [])
          .map((e) => StaffSalaryItem.fromJson(e))
          .toList(),
    );
  }

  factory StaffSalarySummary.empty() {
    return StaffSalarySummary(totalStaff: 0, paid: 0, pending: 0, details: []);
  }
}

class StaffSalaryItem {
  int staffId;
  String staffName;
  double paid;
  double pending;
  String paymentStatus;

  StaffSalaryItem({
    required this.staffId,
    required this.staffName,
    required this.paid,
    required this.pending,
    required this.paymentStatus,
  });

  factory StaffSalaryItem.fromJson(Map<String, dynamic> json) {
    return StaffSalaryItem(
      staffId: json['staff_id'] ?? 0,
      staffName: json['staff_name'] ?? '',
      paid: (json['paid'] ?? 0).toDouble(),
      pending: (json['pending'] ?? 0).toDouble(),
      paymentStatus: json['payment_status'] ?? 'Pending',
    );
  }
}
