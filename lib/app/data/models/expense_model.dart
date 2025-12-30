class ExpenseResponse {
  final int count;
  final List<ExpenseModel> results;

  ExpenseResponse({
    required this.count,
    required this.results,
  });

  factory ExpenseResponse.fromJson(Map<String, dynamic> json) {
    return ExpenseResponse(
      count: json['count'] ?? 0,
      results: (json['results'] as List? ?? [])
          .map((e) => ExpenseModel.fromJson(e))
          .toList(),
    );
  }
}

/* ======================================================== */

class ExpenseModel {
  final int id;
  final DateTime expenseDate;
  final String title;
  final String expenseType; // salary | other | operational
  final double amount;
  final String paymentMode;
  final String? referenceType;
  final int? referenceId;
  final String? note;
  final int? spentBy;
  final DateTime createdAt;

  ExpenseModel({
    this.id = 0,
    required this.expenseDate,
    required this.title,
    required this.expenseType,
    required this.amount,
    required this.paymentMode,
    this.referenceType,
    this.referenceId,
    this.note,
    this.spentBy,
    required this.createdAt,
  });

  /* ================= JSON ================= */

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? 0,
      expenseDate: DateTime.parse(json['expense_date']),
      title: json['title'] ?? '',
      expenseType: (json['expense_type'] ?? '').toString().toLowerCase(),
      amount: (json['amount'] as num).toDouble(),
      paymentMode: json['payment_mode'] ?? '',
      referenceType: json['reference_type'],
      referenceId: json['reference_id'],
      note: json['note'],
      spentBy: json['spent_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expense_date': expenseDate.toIso8601String().split('T').first,
      'title': title,
      'expense_type': expenseType,
      'amount': amount,
      'payment_mode': paymentMode,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'note': note,
      'spent_by': spentBy,
    };
  }

  /* ================= UI HELPERS ================= */

  /// ❌ salary / system generated expense
  bool get isEditable => expenseType != 'salary' && referenceType == null;

  bool get isSalaryExpense => !isEditable;

  /// 📅 single date filter
  bool isSameDate(DateTime date) =>
      expenseDate.year == date.year &&
      expenseDate.month == date.month &&
      expenseDate.day == date.day;

  /// 🏷 expense type filter
  bool matchExpenseType(String? type) {
    if (type == null || type.isEmpty || type == 'all') return true;
    return expenseType == type.toLowerCase();
  }

  /// 🔍 manual search
  bool matchSearch(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        (note?.toLowerCase().contains(q) ?? false) ||
        paymentMode.toLowerCase().contains(q);
  }

  /* ================= COPY ================= */

  ExpenseModel copyWith({
    DateTime? expenseDate,
    String? title,
    String? expenseType,
    double? amount,
    String? paymentMode,
    String? referenceType,
    int? referenceId,
    String? note,
    int? spentBy,
  }) {
    return ExpenseModel(
      id: id,
      expenseDate: expenseDate ?? this.expenseDate,
      title: title ?? this.title,
      expenseType: expenseType ?? this.expenseType,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      note: note ?? this.note,
      spentBy: spentBy ?? this.spentBy,
      createdAt: createdAt,
    );
  }
}
