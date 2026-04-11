// app/data/models/dashboard/orders.dart
// =======================================================
// ORDER ITEM (Paginated)
// =======================================================

class OrderItem {
  int id;
  String customerName;
  String contactNo;
  String vehicleModel;
  String orderDate;
  double totalAmount;
  double advance;
  double remainingAmount;
  String status;

  OrderItem({
    required this.id,
    required this.customerName,
    required this.contactNo,
    required this.vehicleModel,
    required this.orderDate,
    required this.totalAmount,
    required this.advance,
    required this.remainingAmount,
    required this.status,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      contactNo: json['contact_no'] ?? '',
      vehicleModel: json['vehicle_model'] ?? '',
      orderDate: json['order_date'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      advance: (json['advance'] ?? 0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'contact_no': contactNo,
      'vehicle_model': vehicleModel,
      'order_date': orderDate,
      'total_amount': totalAmount,
      'advance': advance,
      'remaining_amount': remainingAmount,
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
// ORDER PAGINATED RESPONSE
// =======================================================
class OrderPaginatedResponse {
  List<OrderItem> results;
  Pagination pagination;

  OrderPaginatedResponse({
    required this.results,
    required this.pagination,
  });

  /// Factory for empty response
  factory OrderPaginatedResponse.empty() {
    return OrderPaginatedResponse(
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

  factory OrderPaginatedResponse.fromJson(Map<String, dynamic> json) {
    return OrderPaginatedResponse(
      results: (json['results'] as List? ?? [])
          .map((e) => OrderItem.fromJson(e))
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
