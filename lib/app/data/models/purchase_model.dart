/// ===============================
/// Purchase Model (API MATCHED)
/// ===============================
class PurchaseModel {
  final int? id;
  final int supplier;
  final DateTime date;
  final String? billNo; // optional, for UI display
  final List<PurchaseItemModel> items;

  final double grandTotal;

  final double discountPercentage;
  final double discountAmount;
  final double amountBeforeTransitDiscount; // ✅ NEW

  final double transitDiscountPercentage; // ✅ NEW
  final double transitDiscountAmount; // ✅ NEW

  final double afterDiscountAmount; // ✅ NEW
  final double vatPercentage; // ✅ NEW
  final double vatAmount; // ✅ NEW

  final double netTotal; // अब यो = afterDiscountAmount + vatAmount
  final double paidAmount;
  final double remainingAmount;
  final String status;
  final bool isMigrated;
  final int? createdBy;

  PurchaseModel({
    this.id,
    required this.supplier,
    required this.date,
    this.billNo,
    required this.items,
    this.grandTotal = 0.0,
    this.discountPercentage = 0.0,
    this.discountAmount = 0.0,
    this.amountBeforeTransitDiscount = 0.0,
    this.transitDiscountPercentage = 0.0,
    this.transitDiscountAmount = 0.0,
    this.afterDiscountAmount = 0.0,
    this.vatPercentage = 0.0,
    this.vatAmount = 0.0,
    this.netTotal = 0.0,
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
      billNo: json['bill_no'], // optional, for UI display
      items: (json['items'] as List? ?? [])
          .map((e) => PurchaseItemModel.fromJson(e))
          .toList(),
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (json['discount_percentage'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      amountBeforeTransitDiscount:
          (json['amount_before_transit_discount'] as num?)?.toDouble() ?? 0.0,
      transitDiscountPercentage:
          (json['transit_discount_percentage'] as num?)?.toDouble() ?? 0.0,
      transitDiscountAmount:
          (json['transit_discount_amount'] as num?)?.toDouble() ?? 0.0,
      afterDiscountAmount: // ✅ NEW
          (json['after_discount_amount'] as num?)?.toDouble() ?? 0.0,
      vatPercentage: // ✅ NEW
          (json['vat_percentage'] as num?)?.toDouble() ?? 0.0,
      vatAmount: (json['vat_amount'] as num?)?.toDouble() ?? 0.0,
      netTotal: (json['net_total'] as num?)?.toDouble() ?? 0.0,
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
      'bill_no': billNo,
      'items': items.map((e) => e.toJsonForApi()).toList(),
      'grand_total': grandTotal,
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'amount_before_transit_discount': amountBeforeTransitDiscount,
      'transit_discount_percentage': transitDiscountPercentage,
      'transit_discount_amount': transitDiscountAmount,
      'after_discount_amount': afterDiscountAmount,
      'vat_percentage': vatPercentage,
      'vat_amount': vatAmount,
      'net_total': netTotal,
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

  double get calculatedAmountBeforeTransitDiscount =>
      grandTotal - discountAmount;

  double get calculatedAfterDiscountAmount => // ✅ RENAMED
      amountBeforeTransitDiscount - transitDiscountAmount;

  double get calculatedNetTotal => afterDiscountAmount + vatAmount; // ✅ CHANGED

  bool get isPaid => remainingAmount <= 0;
}

extension PurchaseModelCopy on PurchaseModel {
  PurchaseModel copyWith({
    int? id,
    int? supplier,
    DateTime? date,
    String? billNo,
    List<PurchaseItemModel>? items,
    double? grandTotal,
    double? discountPercentage,
    double? discountAmount,
    double? amountBeforeTransitDiscount,
    double? transitDiscountPercentage,
    double? transitDiscountAmount,
    double? afterDiscountAmount,
    double? vatPercentage,
    double? vatAmount,
    double? netTotal,
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
      billNo: billNo ?? this.billNo,
      items: items ?? this.items,
      grandTotal: grandTotal ?? this.grandTotal,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      amountBeforeTransitDiscount:
          amountBeforeTransitDiscount ?? this.amountBeforeTransitDiscount,
      transitDiscountPercentage:
          transitDiscountPercentage ?? this.transitDiscountPercentage,
      transitDiscountAmount:
          transitDiscountAmount ?? this.transitDiscountAmount,
      afterDiscountAmount: afterDiscountAmount ?? this.afterDiscountAmount, // ✅
      vatPercentage: vatPercentage ?? this.vatPercentage, // ✅
      vatAmount: vatAmount ?? this.vatAmount,
      netTotal: netTotal ?? this.netTotal,
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
  final int returnedQuantity; // 👈 थप्नुस्
  final DateTime? returnedAt; // 👈 थप्नुस्
  final String? returnReason; // 👈 थप्नुस्

  PurchaseItemModel({
    this.id = 0,
    required this.item,
    required this.quantity,
    required this.price,
    double? totalPrice,
    this.itemName,
    this.returnedQuantity = 0,
    this.returnedAt,
    this.returnReason,
  }) : totalPrice = totalPrice ?? quantity * price;

  int get remainingQuantity => quantity - returnedQuantity; // 👈 थप्नुस्
  bool get isFullyReturned => remainingQuantity <= 0; // 👈 थप्नुस्
  bool get isPartiallyReturned =>
      returnedQuantity > 0 && !isFullyReturned; // 👈 थप्नुस्
  bool get hasReturn => returnedQuantity > 0; // 👈 थप्नुस्

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
      returnedQuantity: json['returned_quantity'] ?? 0,
      returnedAt: json['returned_at'] != null // 👈 थप्नुस्
          ? DateTime.tryParse(json['returned_at'])
          : null,
      returnReason: json['return_reason'],
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
      'returned_quantity': returnedQuantity,
      'returned_at': returnedAt?.toIso8601String(),
      'return_reason': returnReason,
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
