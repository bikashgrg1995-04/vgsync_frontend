// ---------------- Staff Model ----------------
class StaffModel {
  final int? id;
  final String name;
  final String designation;
  final String salaryMode;
  final String phone;
  final String address;
  final String email;
  final bool isActive;
  final DateTime joinedDate;

  StaffModel({
    this.id,
    required this.name,
    required this.designation,
    required this.salaryMode,
    required this.phone,
    required this.address,
    required this.email,
    required this.isActive,
    required this.joinedDate,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) => StaffModel(
        id: json['id'],
        name: json['name'],
        designation: json['designation'],
        salaryMode: json['salary_mode'],
        phone: json['phone'],
        address: json['address'],
        email: json['email'],
        isActive: json['is_active'],
        joinedDate: DateTime.parse(json['joined_date']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'designation': designation,
        'salary_mode': salaryMode,
        'phone': phone,
        'address': address,
        'email': email,
        'is_active': isActive,
        'joined_date': joinedDate.toIso8601String().split('T')[0],
      };
}

// ---------------- Salary Tracker Model ----------------
class SalaryTrackerModel {
  final int id;
  final int staff;
  final double totalSalary;
  final String paymentDate;
  final String paymentMode;
  final String transactionType;

  SalaryTrackerModel({
    required this.id,
    required this.staff,
    required this.totalSalary,
    required this.paymentDate,
    required this.paymentMode,
    required this.transactionType,
  });

  factory SalaryTrackerModel.fromJson(Map<String, dynamic> json) {
    return SalaryTrackerModel(
      id: json['id'],
      staff: json['staff'],
      totalSalary: (json['total_salary'] ?? 0).toDouble(),
      paymentDate: json['payment_date'],
      paymentMode: json['payment_mode'],
      transactionType: json['transaction_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff': staff,
      'total_salary': totalSalary,
      'payment_date': paymentDate,
      'payment_mode': paymentMode,
      'transaction_type': transactionType,
    };
  }
}

// ---------------- Salary Transaction Model ----------------
class SalaryTransactionModel {
  final int id;
  final int staff;
  final String transactionType;
  final double amount;
  final String paymentDate;
  final String paymentMode;
  final String note;
  final int salaryTracker;

  SalaryTransactionModel({
    required this.id,
    required this.staff,
    required this.transactionType,
    required this.amount,
    required this.paymentDate,
    required this.paymentMode,
    required this.note,
    required this.salaryTracker,
  });

  factory SalaryTransactionModel.fromJson(Map<String, dynamic> json) {
    return SalaryTransactionModel(
      id: json['id'],
      staff: json['staff'],
      transactionType: json['transaction_type'],
      amount: (json['amount'] ?? 0).toDouble(),
      paymentDate: json['payment_date'],
      paymentMode: json['payment_mode'],
      note: json['note'] ?? '',
      salaryTracker: json['salary_tracker'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff': staff,
      'transaction_type': transactionType,
      'amount': amount,
      'payment_date': paymentDate,
      'payment_mode': paymentMode,
      'note': note,
      'salary_tracker': salaryTracker,
    };
  }
}
