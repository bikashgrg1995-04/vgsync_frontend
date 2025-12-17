import 'sale_item_model.dart';

class SaleModel {
  int? id;
  int customer;
  String saleDate;
  bool isServicing;
  List<SaleItemModel> items;
  double? totalAmount;

  SaleModel({
    this.id,
    required this.customer,
    required this.saleDate,
    required this.isServicing,
    required this.items,
    this.totalAmount,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    int parseCustomer(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is Map && value['id'] != null) return value['id'];
      if (value is List && value.isNotEmpty) return value.first;
      return 0;
    }

    return SaleModel(
      id: json['id'],
      customer: parseCustomer(json['customer']),
      saleDate: json['sale_date'].toString(),
      isServicing: json['is_servicing'] ?? false,
      items: (json['items'] as List<dynamic>)
          .map((e) => SaleItemModel.fromJson(e))
          .toList(),
      totalAmount: json['total_amount'] != null
          ? double.tryParse(json['total_amount'].toString())
          : 0,
    );
  }

  /// Used for POST / PATCH only
  Map<String, dynamic> toJson() {
    return {
      "customer": customer,
      "sale_date": saleDate,
      "is_servicing": isServicing,
      "items": items.map((e) => e.toJson()).toList(),
    };
  }

  SaleModel copyWith({
    int? id,
    int? customer,
    String? saleDate,
    bool? isServicing,
    List<SaleItemModel>? items,
    double? totalAmount,
  }) {
    return SaleModel(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      saleDate: saleDate ?? this.saleDate,
      isServicing: isServicing ?? this.isServicing,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
