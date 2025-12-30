// ------------------ DASHBOARD RESPONSE ------------------
class DashboardResponse {
  String period;
  int year;
  int month;

  StockSummary stock;
  SalesSummaryFull sales;
  PurchasesSummaryFull purchases;
  OrdersSummary orders;
  FollowupSummary followups;
  StaffSalarySummary staffSalary;
  ChartsSummary charts;

  DashboardResponse({
    required this.period,
    required this.year,
    required this.month,
    required this.stock,
    required this.sales,
    required this.purchases,
    required this.orders,
    required this.followups,
    required this.staffSalary,
    required this.charts,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      period: json['period'] ?? '',
      year: json['year'] ?? 0,
      month: json['month'] ?? 0,
      stock: StockSummary.fromJson(json['stock'] ?? {}),
      sales: SalesSummaryFull.fromJson(json['sales'] ?? {}),
      purchases: PurchasesSummaryFull.fromJson(json['purchases'] ?? {}),
      orders: OrdersSummary.fromJson(json['orders'] ?? {}),
      followups: FollowupSummary.fromJson(json['followups'] ?? {}),
      staffSalary: StaffSalarySummary.fromJson(json['staff_salary'] ?? {}),
      charts: ChartsSummary.fromJson(json['charts'] ?? {}),
    );
  }

  factory DashboardResponse.empty() {
    return DashboardResponse(
      period: '',
      year: 0,
      month: 0,
      stock: StockSummary.empty(),
      sales: SalesSummaryFull.empty(),
      purchases: PurchasesSummaryFull.empty(),
      orders: OrdersSummary.empty(),
      followups: FollowupSummary.empty(),
      staffSalary: StaffSalarySummary.empty(),
      charts: ChartsSummary.empty(),
    );
  }
}

// ------------------ STOCK ------------------
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

// ------------------ SALES ------------------
class SalesSummaryFull {
  int count;
  double totalAmount;
  double todayAmount;
  double monthlyAmount;
  double yearlyAmount;
  List<SaleStockItem> topSales;
  List<SaleStockItem> lowSales;

  SalesSummaryFull({
    required this.count,
    required this.totalAmount,
    required this.todayAmount,
    required this.monthlyAmount,
    required this.yearlyAmount,
    required this.topSales,
    required this.lowSales,
  });

  factory SalesSummaryFull.fromJson(Map<String, dynamic> json) {
    return SalesSummaryFull(
      count: json['count'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      todayAmount: (json['today_amount'] ?? 0).toDouble(),
      monthlyAmount: (json['monthly_amount'] ?? 0).toDouble(),
      yearlyAmount: (json['yearly_amount'] ?? 0).toDouble(),
      topSales: (json['top_sales'] as List? ?? [])
          .map((e) => SaleStockItem.fromJson(e))
          .toList(),
      lowSales: (json['low_sales'] as List? ?? [])
          .map((e) => SaleStockItem.fromJson(e))
          .toList(),
    );
  }

  factory SalesSummaryFull.empty() {
    return SalesSummaryFull(
      count: 0,
      totalAmount: 0,
      todayAmount: 0,
      monthlyAmount: 0,
      yearlyAmount: 0,
      topSales: [],
      lowSales: [],
    );
  }
}

// ------------------ PURCHASES ------------------
class PurchasesSummaryFull {
  int count;
  double totalAmount;
  double todayAmount;
  double monthlyAmount;
  double yearlyAmount;

  PurchasesSummaryFull({
    required this.count,
    required this.totalAmount,
    required this.todayAmount,
    required this.monthlyAmount,
    required this.yearlyAmount,
  });

  factory PurchasesSummaryFull.fromJson(Map<String, dynamic> json) {
    return PurchasesSummaryFull(
      count: json['count'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      todayAmount: (json['today_amount'] ?? 0).toDouble(),
      monthlyAmount: (json['monthly_amount'] ?? 0).toDouble(),
      yearlyAmount: (json['yearly_amount'] ?? 0).toDouble(),
    );
  }

  factory PurchasesSummaryFull.empty() {
    return PurchasesSummaryFull(
      count: 0,
      totalAmount: 0,
      todayAmount: 0,
      monthlyAmount: 0,
      yearlyAmount: 0,
    );
  }
}

// ------------------ ORDERS ------------------
class OrdersSummary {
  int totalOrders;
  double pendingAmount;

  OrdersSummary({required this.totalOrders, required this.pendingAmount});

  factory OrdersSummary.fromJson(Map<String, dynamic> json) {
    return OrdersSummary(
      totalOrders: json['total_orders'] ?? 0,
      pendingAmount: (json['pending_amount'] ?? 0).toDouble(),
    );
  }

  factory OrdersSummary.empty() {
    return OrdersSummary(totalOrders: 0, pendingAmount: 0);
  }
}

// ------------------ FOLLOWUPS ------------------
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

  FollowupItem({
    required this.id,
    required this.customerName,
    required this.vehicle,
    required this.followUpDate,
    required this.remarks,
  });

  factory FollowupItem.fromJson(Map<String, dynamic> json) {
    return FollowupItem(
      id: json['id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      vehicle: json['vehicle'] ?? '',
      followUpDate: json['follow_up_date'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }
}

// ------------------ STAFF SALARY ------------------
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
  List<SalaryTrackerItem> trackers;

  StaffSalaryItem({
    required this.staffId,
    required this.staffName,
    required this.paid,
    required this.pending,
    required this.trackers,
  });

  factory StaffSalaryItem.fromJson(Map<String, dynamic> json) {
    return StaffSalaryItem(
      staffId: json['staff_id'] ?? 0,
      staffName: json['staff_name'] ?? '',
      paid: (json['paid'] ?? 0).toDouble(),
      pending: (json['pending'] ?? 0).toDouble(),
      trackers: (json['trackers'] as List? ?? [])
          .map((e) => SalaryTrackerItem.fromJson(e))
          .toList(),
    );
  }
}

class SalaryTrackerItem {
  String date;
  double totalSalary;
  double paidAmount;
  double? remainingAmount;
  String status;
  String? paymentMode;
  String note;

  SalaryTrackerItem({
    required this.date,
    required this.totalSalary,
    required this.paidAmount,
    this.remainingAmount,
    required this.status,
    this.paymentMode,
    required this.note,
  });

  factory SalaryTrackerItem.fromJson(Map<String, dynamic> json) {
    return SalaryTrackerItem(
      date: json['date'] ?? '',
      totalSalary: (json['total_salary'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      remainingAmount: json['remaining_amount'] != null
          ? (json['remaining_amount'] as num).toDouble()
          : null,
      status: json['status'] ?? '',
      paymentMode: json['payment_mode'],
      note: json['note'] ?? '',
    );
  }
}

// ------------------ CHARTS ------------------
class ChartsSummary {
  ProfitLossChart profitLoss;

  ChartsSummary({required this.profitLoss});

  factory ChartsSummary.fromJson(Map<String, dynamic> json) {
    return ChartsSummary(
      profitLoss: ProfitLossChart.fromJson(json['profit_loss'] ?? {}),
    );
  }

  factory ChartsSummary.empty() {
    return ChartsSummary(profitLoss: ProfitLossChart.empty());
  }
}

class ProfitLossChart {
  ChartData daily;
  ChartData monthly;
  ChartData yearly;

  ProfitLossChart({
    required this.daily,
    required this.monthly,
    required this.yearly,
  });

  factory ProfitLossChart.fromJson(Map<String, dynamic> json) {
    return ProfitLossChart(
      daily: ChartData.fromJson(json['daily'] ?? {}),
      monthly: ChartData.fromJson(json['monthly'] ?? {}),
      yearly: ChartData.fromJson(json['yearly'] ?? {}),
    );
  }

  factory ProfitLossChart.empty() {
    return ProfitLossChart(
      daily: ChartData.empty(),
      monthly: ChartData.empty(),
      yearly: ChartData.empty(),
    );
  }
}

class ChartData {
  List<ChartItem> income;
  List<ChartItem> expense;
  double totalIncome;
  double totalExpense;
  double profit;
  double loss;

  ChartData({
    required this.income,
    required this.expense,
    required this.totalIncome,
    required this.totalExpense,
    required this.profit,
    required this.loss,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      income: (json['income'] as List? ?? [])
          .map((e) => ChartItem.fromJson(e))
          .toList(),
      expense: (json['expense'] as List? ?? [])
          .map((e) => ChartItem.fromJson(e))
          .toList(),
      totalIncome: (json['total_income'] ?? 0).toDouble(),
      totalExpense: (json['total_expense'] ?? 0).toDouble(),
      profit: (json['profit'] ?? 0).toDouble(),
      loss: (json['loss'] ?? 0).toDouble(),
    );
  }

  factory ChartData.empty() {
    return ChartData(
      income: [],
      expense: [],
      totalIncome: 0,
      totalExpense: 0,
      profit: 0,
      loss: 0,
    );
  }
}

class ChartItem {
  int? month;
  int? year;
  double amount;

  ChartItem({this.month, this.year, required this.amount});

  factory ChartItem.fromJson(Map<String, dynamic> json) {
    return ChartItem(
      month: json['month'],
      year: json['year'],
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}
