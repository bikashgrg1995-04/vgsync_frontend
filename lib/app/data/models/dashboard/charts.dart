// app/data/models/dashboard/charts.dart
// =======================================================
// CHARTS DASHBOARD (Income / Expense / Profit & Loss)
// =======================================================

class DashboardChartsOnly {
  List<ChartPoint> income;
  List<ExpenseChartPoint> expense;
  List<ChartPoint> profitLoss;

  DashboardChartsOnly({
    required this.income,
    required this.expense,
    required this.profitLoss,
  });

  factory DashboardChartsOnly.fromJson(Map<String, dynamic> json) {
    return DashboardChartsOnly(
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

  Map<String, dynamic> toJson() {
    return {
      'income': income.map((e) => e.toJson()).toList(),
      'expense': expense.map((e) => e.toJson()).toList(),
      'profit_loss': profitLoss.map((e) => e.toJson()).toList(),
    };
  }

  factory DashboardChartsOnly.empty() {
    return DashboardChartsOnly(
      income: [],
      expense: [],
      profitLoss: [],
    );
  }
}

// =======================================================
// GENERIC CHART POINT (Income / ProfitLoss)
// =======================================================
class ChartPoint {
  String date;
  double amount;

  ChartPoint({
    required this.date,
    required this.amount,
  });

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

// =======================================================
// EXPENSE CHART POINT (Pie / Breakdown)
// =======================================================
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
