import 'purchase_item_model.dart';

class PurchaseModel {
  int? id;
  int supplier;
  String date;
  List<PurchaseItemModel> items;
  double? totalAmount;

  PurchaseModel({
    this.id,
    required this.supplier,
    required this.date,
    required this.items,
    this.totalAmount,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'],

      /// 🔥 FIX HERE
      supplier: json['supplier'] is int
          ? json['supplier']
          : json['supplier'] is Map
              ? json['supplier']['id']
              : json['supplier'] is List
                  ? json['supplier'].first
                  : 0,

      date: json['date'],

      items: (json['items'] as List<dynamic>)
          .map((e) => PurchaseItemModel.fromJson(e))
          .toList(),

      totalAmount: (json['total_amount'] ?? 0).toDouble(),
    );
  }

  /// ⚠️ Used ONLY for POST / PATCH
  Map<String, dynamic> toJson() {
    return {
      "supplier": supplier,
      "date": date,
      "items": items.map((e) => e.toJson()).toList(),
    };
  }

  PurchaseModel copyWith({
    int? id,
    int? supplier,
    String? date,
    List<PurchaseItemModel>? items,
    double? totalAmount,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      supplier: supplier ?? this.supplier,
      date: date ?? this.date,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
