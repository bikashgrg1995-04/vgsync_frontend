// app/data/models/dashboard_charts-credit.dart
/// =======================================================
/// ROOT CHARTS + CREDIT MODEL
/// =======================================================
class DashboardChartsCredit {
  DashboardCharts charts;
  DashboardCredit credit;

  DashboardChartsCredit({
    required this.charts,
    required this.credit,
  });

  factory DashboardChartsCredit.fromJson(Map<String, dynamic> json) {
    return DashboardChartsCredit(
      charts: DashboardCharts.fromJson(json['charts'] ?? {}),
      credit: DashboardCredit.fromJson(json['credit'] ?? {}),
    );
  }

  factory DashboardChartsCredit.empty() {
    return DashboardChartsCredit(
      charts: DashboardCharts.empty(),
      credit: DashboardCredit.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'charts': charts.toJson(),
      'credit': credit.toJson(),
    };
  }
}

/// =======================================================
/// CHARTS
/// =======================================================
class DashboardCharts {
  List<ChartPoint> income;
  List<ExpenseChartPoint> expense;
  List<ChartPoint> profitLoss;

  DashboardCharts({
    required this.income,
    required this.expense,
    required this.profitLoss,
  });

  factory DashboardCharts.fromJson(Map<String, dynamic> json) {
    return DashboardCharts(
      income: (json['income'] as List? ?? [])
          .map((e) => ChartPoint.fromJson(e))
          .toList(),
      expense: (json['expense'] as List? ?? [])
          .map((e) => ExpenseChartPoint.fromJson(e))
          .toList(),
      profitLoss: (json['profit_loss'] as List? ?? [])
          .map((e) => ChartPoint.fromJson(e))
          .toList(),
    );
  }

  factory DashboardCharts.empty() {
    return DashboardCharts(
      income: [],
      expense: [],
      profitLoss: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'income': income.map((e) => e.toJson()).toList(),
      'expense': expense.map((e) => e.toJson()).toList(),
      'profit_loss': profitLoss.map((e) => e.toJson()).toList(),
    };
  }
}

/// Generic chart point for income / P&L
class ChartPoint {
  String date;
  double amount;

  ChartPoint({required this.date, required this.amount});

  factory ChartPoint.fromJson(Map<String, dynamic> json) {
    return ChartPoint(
      date: json['date'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'amount': amount,
    };
  }
}

/// Pie chart expense point
class ExpenseChartPoint {
  String date;
  String type;
  double amount;

  ExpenseChartPoint({
    required this.date,
    required this.type,
    required this.amount,
  });

  factory ExpenseChartPoint.fromJson(Map<String, dynamic> json) {
    return ExpenseChartPoint(
      date: json['date'] ?? '',
      type: json['type'] ?? 'other',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'type': type,
      'amount': amount,
    };
  }
}

/// =======================================================
/// CREDIT
/// =======================================================
class DashboardCredit {
  CreditSummary sale;
  CreditSummary purchase;

  DashboardCredit({required this.sale, required this.purchase});

  factory DashboardCredit.fromJson(Map<String, dynamic> json) {
    return DashboardCredit(
      sale: CreditSummary.fromJson(json['sale'] ?? {}),
      purchase: CreditSummary.fromJson(json['purchase'] ?? {}),
    );
  }

  factory DashboardCredit.empty() {
    return DashboardCredit(
      sale: CreditSummary.empty(),
      purchase: CreditSummary.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sale': sale.toJson(),
      'purchase': purchase.toJson(),
    };
  }
}

class CreditSummary {
  List<CreditItem> summary;
  CreditTotals totals;

  CreditSummary({required this.summary, required this.totals});

  factory CreditSummary.fromJson(Map<String, dynamic> json) {
    return CreditSummary(
      summary: (json['summary'] as List? ?? [])
          .map((e) => CreditItem.fromJson(e))
          .toList(),
      totals: CreditTotals.fromJson(json['totals'] ?? {}),
    );
  }

  factory CreditSummary.empty() {
    return CreditSummary(
      summary: [],
      totals: CreditTotals.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.map((e) => e.toJson()).toList(),
      'totals': totals.toJson(),
    };
  }
}

class CreditItem {
  int id;
  String customerName;
  String contactNo;
  double netTotal;
  double paidAmount;
  double remainingAmount;
  String status;

  /// NEW: credit_days (days since sale_date / purchase_date)
  int creditDays;

  CreditItem({
    required this.id,
    required this.customerName,
    required this.contactNo,
    required this.netTotal,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
    this.creditDays = 0,
  });

  factory CreditItem.fromJson(Map<String, dynamic> json) {
    return CreditItem(
      id: json['id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      contactNo: json['contact_no'] ?? '',
      netTotal: (json['net_total'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      creditDays: json['credit_days'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'contact_no': contactNo,
      'net_total': netTotal,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'status': status,
      'credit_days': creditDays,
    };
  }
}

class CreditTotals {
  double totalNetAmount;
  double totalPaidAmount;
  double totalCreditAmount;
  int count;

  CreditTotals({
    required this.totalNetAmount,
    required this.totalPaidAmount,
    required this.totalCreditAmount,
    required this.count,
  });

  factory CreditTotals.fromJson(Map<String, dynamic> json) {
    return CreditTotals(
      totalNetAmount: (json['total_net_amount'] ?? 0).toDouble(),
      totalPaidAmount: (json['total_paid_amount'] ?? 0).toDouble(),
      totalCreditAmount: (json['total_credit_amount'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }

  factory CreditTotals.empty() {
    return CreditTotals(
      totalNetAmount: 0,
      totalPaidAmount: 0,
      totalCreditAmount: 0,
      count: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_net_amount': totalNetAmount,
      'total_paid_amount': totalPaidAmount,
      'total_credit_amount': totalCreditAmount,
      'count': count,
    };
  }
}
