class ExpenseModel {
  final int id;
  final DateTime expenseDate;
  final String title;
  final String expenseType;
  final double amount;
  final String paymentMode;
  final String? referenceType;
  final int? referenceId;
  final String? note;
  final DateTime createdAt;
  final int? spentBy;

  ExpenseModel({
    required this.id,
    required this.expenseDate,
    required this.title,
    required this.expenseType,
    required this.amount,
    required this.paymentMode,
    this.referenceType,
    this.referenceId,
    this.note,
    required this.createdAt,
    this.spentBy,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        id: json['id'],
        expenseDate: DateTime.parse(json['expense_date']),
        title: json['title'],
        expenseType: json['expense_type'],
        amount: (json['amount'] as num).toDouble(),
        paymentMode: json['payment_mode'],
        referenceType: json['reference_type'],
        referenceId: json['reference_id'],
        note: json['note'],
        createdAt: DateTime.parse(json['created_at']),
        spentBy: json['spent_by'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'expense_date': expenseDate.toIso8601String(),
        'title': title,
        'expense_type': expenseType,
        'amount': amount,
        'payment_mode': paymentMode,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'note': note,
        'created_at': createdAt.toIso8601String(),
        'spent_by': spentBy,
      };

  ExpenseModel copyWith({
    int? id,
    DateTime? expenseDate,
    String? title,
    String? expenseType,
    double? amount,
    String? paymentMode,
    String? referenceType,
    int? referenceId,
    String? note,
    DateTime? createdAt,
    int? spentBy,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      expenseDate: expenseDate ?? this.expenseDate,
      title: title ?? this.title,
      expenseType: expenseType ?? this.expenseType,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      spentBy: spentBy ?? this.spentBy,
    );
  }
}
