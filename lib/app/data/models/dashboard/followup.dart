// app/data/models/dashboard/followup.dart
// =======================================================
// FOLLOW-UP ITEM (Paginated)
// =======================================================

class FollowupItem {
  int id;
  String customerName;
  String contactNo;
  String vehicle;
  String followUpDate; // YYYY-MM-DD string
  String remarks;
  String status;

  FollowupItem({
    required this.id,
    required this.customerName,
    required this.contactNo,
    required this.vehicle,
    required this.followUpDate,
    required this.remarks,
    required this.status,
  });

  factory FollowupItem.fromJson(Map<String, dynamic> json) {
    return FollowupItem(
      id: json['id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      contactNo: json['contact_no'] ?? '',
      vehicle: json['vehicle'] ?? '',
      followUpDate: json['follow_up_date'] ?? '',
      remarks: json['remarks'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'contact_no': contactNo,
      'vehicle': vehicle,
      'follow_up_date': followUpDate,
      'remarks': remarks,
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
// FOLLOW-UP PAGINATED RESPONSE
// =======================================================
class FollowupPaginatedResponse {
  List<FollowupItem> results;
  Pagination pagination;

  FollowupPaginatedResponse({
    required this.results,
    required this.pagination,
  });

  /// Factory for empty response
  factory FollowupPaginatedResponse.empty() {
    return FollowupPaginatedResponse(
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

  factory FollowupPaginatedResponse.fromJson(Map<String, dynamic> json) {
    return FollowupPaginatedResponse(
      results: (json['results'] as List? ?? [])
          .map((e) => FollowupItem.fromJson(e))
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
