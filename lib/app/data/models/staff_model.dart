// ---------------- Staff Model ----------------
class StaffModel {
  final int? id;
  final String name;
  final String phone;
  final String? email;
  final String? address; // ✅ nullable
  final String designation;
  final String designationDisplay;
  final String salaryMode;
  final String salaryModeDisplay;
  final DateTime joinedDate;
  final bool isActive;

  StaffModel({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    required this.designation,
    required this.designationDisplay,
    required this.salaryMode,
    required this.salaryModeDisplay,
    required this.joinedDate,
    required this.isActive,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'], // null-safe
      designation: json['designation'] ?? '',
      designationDisplay: json['designation_display'] ?? '',
      salaryMode: json['salary_mode'] ?? '',
      salaryModeDisplay: json['salary_mode_display'] ?? '',
      joinedDate: DateTime.parse(json['joined_date']),
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'designation': designation,
        'designation_display': designationDisplay,
        'salary_mode': salaryMode,
        'salary_mode_display': salaryModeDisplay,
        'joined_date': joinedDate.toIso8601String().split('T')[0],
        'is_active': isActive,
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
