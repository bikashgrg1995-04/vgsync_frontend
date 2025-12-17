class SaleItemModel {
  final int item;
  final int quantity;
  final double price;
  final double? totalPrice;

  SaleItemModel({
    required this.item,
    required this.quantity,
    required this.price,
    this.totalPrice,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      item: json['item'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      totalPrice: json['total_price'] != null
          ? (json['total_price'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "item": item,
      "quantity": quantity,
      "price": price,
    };
  }
}
