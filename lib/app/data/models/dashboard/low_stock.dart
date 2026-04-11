// app/data/models/dashboard/low_stock.dart
// =======================================================
// STOCK ITEM (Low Stock / Paginated)
// =======================================================

class StockItem {
  int id;
  String itemNo;
  String name;
  String model;
  int categoryId;
  int stock;
  double salePrice;

  StockItem({
    required this.id,
    required this.itemNo,
    required this.name,
    required this.model,
    required this.categoryId,
    required this.stock,
    required this.salePrice,
  });

  bool get isLowStock => stock <= 5;

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      id: json['id'] ?? 0,
      itemNo: json['item_no'] ?? '',
      name: json['name'] ?? '',
      model: json['model'] ?? '',
      categoryId: json['category_id'] ?? 0,
      stock: json['stock'] ?? 0,
      salePrice: (json['sale_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_no': itemNo,
      'name': name,
      'model': model,
      'category_id': categoryId,
      'stock': stock,
      'sale_price': salePrice,
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
// LOW STOCK PAGINATED RESPONSE
// =======================================================
class StockPaginatedResponse {
  List<StockItem> results;
  Pagination pagination;

  StockPaginatedResponse({
    required this.results,
    required this.pagination,
  });

  /// Factory for empty response (useful for controller initialization)
  factory StockPaginatedResponse.empty() {
    return StockPaginatedResponse(
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

  factory StockPaginatedResponse.fromJson(Map<String, dynamic> json) {
    return StockPaginatedResponse(
      results: (json['results'] as List? ?? [])
          .map((e) => StockItem.fromJson(e))
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
