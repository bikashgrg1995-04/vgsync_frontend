// app/data/models/dashboard/credit.dart
// =======================================================
// CREDIT DASHBOARD (Paginated)
// =======================================================
class DashboardCreditPaginated {
  CreditSummaryPaginated sale;
  CreditSummaryPaginated purchase;

  DashboardCreditPaginated({
    required this.sale,
    required this.purchase,
  });

  factory DashboardCreditPaginated.fromJson(Map<String, dynamic> json) {
    return DashboardCreditPaginated(
      sale: CreditSummaryPaginated.fromJson(json['sale'] ?? {}),
      purchase: CreditSummaryPaginated.fromJson(json['purchase'] ?? {}),
    );
  }

  /// EMPTY constructor
  factory DashboardCreditPaginated.empty() {
    return DashboardCreditPaginated(
      sale: CreditSummaryPaginated.empty(),
      purchase: CreditSummaryPaginated.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sale': sale.toJson(),
      'purchase': purchase.toJson(),
    };
  }
}

// =======================================================
// CREDIT SUMMARY (Paginated)
// =======================================================
class CreditSummaryPaginated {
  List<CreditItem> summary;
  CreditTotals totals;
  Pagination pagination;

  CreditSummaryPaginated({
    required this.summary,
    required this.totals,
    required this.pagination,
  });

  factory CreditSummaryPaginated.fromJson(Map<String, dynamic> json) {
    return CreditSummaryPaginated(
      summary: (json['summary'] as List? ?? [])
          .map((e) => CreditItem.fromJson(e))
          .toList(),
      totals: CreditTotals.fromJson(json['totals'] ?? {}),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  /// EMPTY constructor
  factory CreditSummaryPaginated.empty() {
    return CreditSummaryPaginated(
      summary: [],
      totals: CreditTotals.empty(),
      pagination: Pagination.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.map((e) => e.toJson()).toList(),
      'totals': totals.toJson(),
      'pagination': pagination.toJson(),
    };
  }
}

// =======================================================
// CREDIT ITEM
// =======================================================
class CreditItem {
  int id;
  String? customerName; // sale only
  String? contactNo; // sale only
  String? supplierName; // purchase only
  double netTotal;
  double paidAmount;
  double remainingAmount;
  String status;
  int creditDays;
  String? saleDate; // sale only
  String? purchaseDate; // purchase only

  CreditItem({
    required this.id,
    this.customerName,
    this.contactNo,
    this.supplierName,
    required this.netTotal,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
    required this.creditDays,
    this.saleDate,
    this.purchaseDate,
  });

  factory CreditItem.fromJson(Map<String, dynamic> json) {
    return CreditItem(
      id: json['id'] ?? 0,
      customerName: json['customer_name'],
      contactNo: json['contact_no'],
      supplierName: json['supplier_name'],
      netTotal: (json['net_total'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      creditDays: json['credit_days'] ?? 0,
      saleDate: json['sale_date'],
      purchaseDate: json['purchase_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'contact_no': contactNo,
      'supplier_name': supplierName,
      'net_total': netTotal,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'status': status,
      'credit_days': creditDays,
      'sale_date': saleDate,
      'purchase_date': purchaseDate,
    };
  }
}

// =======================================================
// CREDIT TOTALS
// =======================================================
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

  /// EMPTY constructor
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

// =======================================================
// PAGINATION
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

  /// EMPTY constructor
  factory Pagination.empty() {
    return Pagination(
      page: 1,
      pageSize: 5,
      totalPages: 1,
      totalItems: 0,
      hasNext: false,
      hasPrevious: false,
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
