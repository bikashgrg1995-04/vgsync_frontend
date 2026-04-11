/// ===============================
/// Purchase Model (API MATCHED)
/// ===============================
class PurchaseModel {
  final int? id;
  final int supplier;
  final DateTime date;
  final List<PurchaseItemModel> items;

  final double discountAmount;
  final double netTotal;
  final double grandTotal;

  final double paidAmount;
  final double remainingAmount;
  final String status;
  final bool isMigrated;
  final int? createdBy;

  PurchaseModel({
    this.id,
    required this.supplier,
    required this.date,
    required this.items,
    this.discountAmount = 0.0,
    this.netTotal = 0.0,
    this.grandTotal = 0.0,
    this.paidAmount = 0.0,
    this.remainingAmount = 0.0,
    this.status = 'pending',
    this.isMigrated = false,
    this.createdBy,
  });

  // ---------------- FROM JSON ----------------
  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'],
      supplier: json['supplier'],
      date: _parseDate(json['date']),
      items: (json['items'] as List? ?? [])
          .map((e) => PurchaseItemModel.fromJson(e))
          .toList(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      netTotal: (json['net_total'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remaining_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      isMigrated: json['is_migrated'] ?? false,
      createdBy: json['created_by'],
    );
  }

  // ---------------- TO JSON (API) ----------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier': supplier,
      'date': date.toIso8601String(),
      'items': items.map((e) => e.toJsonForApi()).toList(),
      'discount_amount': discountAmount,
      'net_total': netTotal,
      'grand_total': grandTotal,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'status': status,
      'is_migrated': isMigrated,
      'created_by': createdBy,
    };
  }

  /// ===============================
  /// SAFE CALCULATIONS
  /// ===============================
  double get subTotal =>
      items.fold<double>(0.0, (sum, i) => sum + i.totalPrice);

  double get calculatedNetTotal => subTotal - discountAmount;

  bool get isPaid => remainingAmount <= 0;
}

extension PurchaseModelCopy on PurchaseModel {
  PurchaseModel copyWith({
    int? id,
    int? supplier,
    DateTime? date,
    List<PurchaseItemModel>? items,
    double? discountAmount,
    double? netTotal,
    double? grandTotal,
    double? paidAmount,
    double? remainingAmount,
    String? status,
    bool? isMigrated,
    int? createdBy,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      supplier: supplier ?? this.supplier,
      date: date ?? this.date,
      items: items ?? this.items,
      discountAmount: discountAmount ?? this.discountAmount,
      netTotal: netTotal ?? this.netTotal,
      grandTotal: grandTotal ?? this.grandTotal,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      status: status ?? this.status,
      isMigrated: isMigrated ?? this.isMigrated,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

/// ===============================
/// Purchase Item Model
/// ===============================
class PurchaseItemModel {
  final int id;
  final int item;
  final int quantity;
  final double price;
  final double totalPrice;
  final String? itemName;

  PurchaseItemModel({
    this.id = 0,
    required this.item,
    required this.quantity,
    required this.price,
    double? totalPrice,
    this.itemName,
  }) : totalPrice = totalPrice ?? quantity * price;

  // ---------------- FROM JSON ----------------
  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    final qty = json['quantity'] as int? ?? 0;
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;

    return PurchaseItemModel(
      id: json['id'] ?? 0,
      item: json['item'],
      quantity: qty,
      price: price,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? qty * price,
      itemName: json['item_name'],
    );
  }

  // ---------------- UI JSON ----------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item': item,
      'quantity': quantity,
      'price': price,
      'total_price': totalPrice,
      'item_name': itemName,
    };
  }

  // ---------------- API JSON ----------------
  Map<String, dynamic> toJsonForApi() {
    return {
      'item': item,
      'quantity': quantity,
      'price': price,
    };
  }
}

/// ===============================
/// DATE PARSER (SAFE FOR DJANGO)
/// ===============================
DateTime _parseDate(dynamic value) {
  if (value == null) return DateTime.now();

  if (value is String) {
    // Django: "2025-12-25 00:00:00"
    return DateTime.parse(value.replaceFirst(' ', 'T'));
  }

  return DateTime.now();
}
