// app/data/models/dashboard/staffs_salary.dart
// =======================================================
// STAFF SALARY ITEM (Paginated)
// =======================================================

class StaffSalaryItem {
  int staffId;
  String name;
  String designation;
  String salaryMode;
  double lastPaidAmount;
  double totalSalary;
  double remainingAmount;
  String lastPaidDate;
  String status;

  StaffSalaryItem({
    required this.staffId,
    required this.name,
    required this.designation,
    required this.salaryMode,
    required this.lastPaidAmount,
    required this.totalSalary,
    required this.remainingAmount,
    required this.lastPaidDate,
    required this.status,
  });

  factory StaffSalaryItem.fromJson(Map<String, dynamic> json) {
    return StaffSalaryItem(
      staffId: json['staff_id'] ?? 0,
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      salaryMode: json['salary_mode'] ?? '',
      lastPaidAmount: (json['last_paid_amount'] ?? 0).toDouble(),
      totalSalary: (json['total_salary'] ?? 0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0).toDouble(),
      lastPaidDate: json['last_paid_date'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'name': name,
      'designation': designation,
      'salary_mode': salaryMode,
      'last_paid_amount': lastPaidAmount,
      'total_salary': totalSalary,
      'remaining_amount': remainingAmount,
      'last_paid_date': lastPaidDate,
      'status': status,
    };
  }
}

// =======================================================
// PAGINATION INFO
// =======================================================
class Pagination {
  int page;
  int pageSize;
  int totalPages;
  int totalItems;
  bool hasNext;
  bool hasPrevious;

  Pagination({
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totalItems,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 5,
      totalPages: json['total_pages'] ?? 1,
      totalItems: json['total_items'] ?? 0,
      hasNext: json['has_next'] ?? false,
      hasPrevious: json['has_previous'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'total_pages': totalPages,
      'total_items': totalItems,
      'has_next': hasNext,
      'has_previous': hasPrevious,
    };
  }
}

// =======================================================
// STAFF SALARY PAGINATED RESPONSE
// =======================================================
class StaffSalaryPaginatedResponse {
  List<StaffSalaryItem> results;
  Pagination pagination;

  StaffSalaryPaginatedResponse({
    required this.results,
    required this.pagination,
  });

  /// Factory for empty response
  factory StaffSalaryPaginatedResponse.empty() {
    return StaffSalaryPaginatedResponse(
      results: [],
      pagination: Pagination(
        page: 1,
        pageSize: 5,
        totalPages: 1,
        totalItems: 0,
        hasNext: false,
        hasPrevious: false,
      ),
    );
  }

  factory StaffSalaryPaginatedResponse.fromJson(Map<String, dynamic> json) {
    return StaffSalaryPaginatedResponse(
      results: (json['results'] as List? ?? [])
          .map((e) => StaffSalaryItem.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
