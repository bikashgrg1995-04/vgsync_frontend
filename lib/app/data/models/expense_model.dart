/* ======================================================== */

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
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'results': results.map((e) => e.toJson()).toList(),
    };
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

  /* ================= JSON PARSING ================= */

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? 0,
      expenseDate: _parseDate(json['expense_date']),
      title: (json['title'] ?? '').toString(),
      expenseType: (json['expense_type'] ?? 'other').toString().toLowerCase(),
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMode: (json['payment_mode'] ?? 'cash').toString(),
      referenceType: json['reference_type']?.toString(),
      referenceId: json['reference_id'] != null
          ? int.tryParse(json['reference_id'].toString())
          : null,
      note: json['note']?.toString(),
      spentBy: json['spent_by'] != null
          ? int.tryParse(json['spent_by'].toString())
          : null,
      createdAt: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expense_date': expenseDate.toIso8601String().split('T').first,
      'title': title,
      'expense_type': expenseType,
      'amount': amount,
      'payment_mode': paymentMode,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'note': note,
      'spent_by': spentBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /* ================= HELPERS ================= */

  /// Editable if not salary & not system reference
  bool get isEditable => expenseType != 'salary' && referenceType == null;

  bool get isSalaryExpense => !isEditable;

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

  /* ================= PRIVATE ================= */

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    try {
      return DateTime.parse(date.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}
