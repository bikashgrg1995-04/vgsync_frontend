class PurchaseModel {
  final int id;
  final int supplier;
  final DateTime date;
  final List<PurchaseItemModel> items;
  final double discountPercentage;
  final double vatPercentage;

  PurchaseModel({
    required this.id,
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
      items: (json['items'] as List)
          .map((e) => PurchaseItemModel.fromJson(e))
          .toList(),
      discountPercentage: (json['discount_percentage'] as num).toDouble(),
      vatPercentage: (json['vat_percentage'] as num).toDouble(),
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
}

class PurchaseItemModel {
  final int item;
  final String itemName;
  final int quantity;
  final double purchasePrice;
  final double salePrice;
  final double vat;
  final double totalPrice;

  PurchaseItemModel({
    required this.item,
    required this.itemName,
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
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      salePrice: (json['sale_price'] as num).toDouble(),
      vat: (json['vat'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
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
}
