/// ===============================
/// Purchase Models
/// ===============================
class PurchaseModel {
  final int? id; // optional for creation
  final int supplier;
  final DateTime date;
  final List<PurchaseItemModel> items;
  final double discountPercentage;
  final double vatPercentage;

  PurchaseModel({
    this.id,
    required this.supplier,
    required this.date,
    required this.items,
    required this.discountPercentage,
    required this.vatPercentage,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'],
      supplier: json['supplier'],
      date: DateTime.parse(json['date']),
      items: (json['items'] as List? ?? [])
          .map((e) => PurchaseItemModel.fromJson(e))
          .toList(),
      discountPercentage:
          (json['discount_percentage'] as num?)?.toDouble() ?? 0.0,
      vatPercentage: (json['vat_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier': supplier,
      'date': date.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'discount_percentage': discountPercentage,
      'vat_percentage': vatPercentage,
    };
  }

  // ===============================
  // Amount Calculations
  // ===============================
  double get subTotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get discountAmount => subTotal * (discountPercentage / 100);

  double get vatAmount => (subTotal - discountAmount) * (vatPercentage / 100);

  double get grandTotal => subTotal - discountAmount + vatAmount;

  // ===============================
  // API JSON for POST/PUT
  // ===============================
  Map<String, dynamic> toJsonForApi() {
    return {
      'supplier': supplier,
      'date': date.toIso8601String(),
      'discount_percentage': discountPercentage,
      'vat_percentage': vatPercentage,
      'items': items.map((e) => e.toJsonForApi()).toList(),
    };
  }
}

class PurchaseItemModel {
  final int item;
  final String? itemName; // optional
  final int quantity;
  final double purchasePrice;
  final double salePrice;
  final double vat;
  final double totalPrice;

  PurchaseItemModel({
    required this.item,
    this.itemName,
    required this.quantity,
    required this.purchasePrice,
    required this.salePrice,
    required this.vat,
    required this.totalPrice,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      item: json['item'],
      itemName: json['item_name'],
      quantity: json['quantity'],
      purchasePrice: (json['purchase_price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['sale_price'] as num?)?.toDouble() ?? 0.0,
      vat: (json['vat'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'item_name': itemName,
      'quantity': quantity,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'vat': vat,
      'total_price': totalPrice,
    };
  }

  Map<String, dynamic> toJsonForApi() {
    return {
      'item': item,
      'quantity': quantity,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'vat': vat,
    };
  }
}

/// ===============================
/// Date Filters Extension
/// ===============================
extension PurchaseDateFilter on List<PurchaseModel> {
  List<PurchaseModel> filterByDate(DateTime date) {
    return where((p) =>
        p.date.year == date.year &&
        p.date.month == date.month &&
        p.date.day == date.day).toList();
  }

  List<PurchaseModel> filterByDateRange(DateTime start, DateTime end) {
    return where((p) => !p.date.isBefore(start) && !p.date.isAfter(end))
        .toList();
  }

  List<PurchaseModel> filterToday() => filterByDate(DateTime.now());

  List<PurchaseModel> filterLastNDays(int days) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days - 1));
    return filterByDateRange(start, now);
  }
}

/// ===============================
/// Category Filter Extension
/// ===============================
extension PurchaseCategoryFilter on List<PurchaseModel> {
  List<PurchaseModel> filterByCategory(String keyword) {
    return where((p) => p.items.any((i) =>
        i.itemName != null &&
        i.itemName!.toLowerCase().contains(keyword.toLowerCase()))).toList();
  }
}
