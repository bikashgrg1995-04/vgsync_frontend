class DashboardCharts {
  List<ChartPoint> saleIncome;
  List<ChartPoint> bikeIncome;
  List<ExpensePeriodPoint> expense;
  List<ChartPoint> profitLoss;

  DashboardCharts({
    required this.saleIncome,
    required this.bikeIncome,
    required this.expense,
    required this.profitLoss,
  });

  factory DashboardCharts.fromJson(Map<String, dynamic> json) => DashboardCharts(
        saleIncome: (json['sale_income'] as List? ?? [])
            .map((e) => ChartPoint.fromJson(e))
            .toList(),
        bikeIncome: (json['bike_income'] as List? ?? [])
            .map((e) => ChartPoint.fromJson(e))
            .toList(),
        expense: (json['expense'] as List? ?? [])
            .map((e) => ExpensePeriodPoint.fromJson(e))
            .toList(),
        profitLoss: (json['profit_loss'] as List? ?? [])
            .map((e) => ChartPoint.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'sale_income': saleIncome.map((e) => e.toJson()).toList(),
        'bike_income': bikeIncome.map((e) => e.toJson()).toList(),
        'expense': expense.map((e) => e.toJson()).toList(),
        'profit_loss': profitLoss.map((e) => e.toJson()).toList(),
      };

  factory DashboardCharts.empty() => DashboardCharts(
        saleIncome: [],
        bikeIncome: [],
        expense: [],
        profitLoss: [],
      );
}


class ChartPoint {
  String period;
  double amount;

  ChartPoint({required this.period, required this.amount});

  factory ChartPoint.fromJson(Map<String, dynamic> json) => ChartPoint(
        period: json['period'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'period': period,
        'amount': amount,
      };
}


class ExpenseTypePoint {
  String type;
  double amount;

  ExpenseTypePoint({required this.type, required this.amount});

  factory ExpenseTypePoint.fromJson(Map<String, dynamic> json) => ExpenseTypePoint(
        type: json['type'] ?? 'other',
        amount: (json['amount'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'amount': amount,
      };
}

class ExpensePeriodPoint {
  String period;
  double amount;
  List<ExpenseTypePoint> types;

  ExpensePeriodPoint({
    required this.period,
    required this.amount,
    required this.types,
  });

  factory ExpensePeriodPoint.fromJson(Map<String, dynamic> json) => ExpensePeriodPoint(
        period: json['period'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        types: (json['types'] as List? ?? [])
            .map((e) => ExpenseTypePoint.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'period': period,
        'amount': amount,
        'types': types.map((e) => e.toJson()).toList(),
      };
}
