class PurchaseItemModel {
  int item;
  int quantity;
  double price;
  double? totalPrice;

  PurchaseItemModel({
    required this.item,
    required this.quantity,
    required this.price,
    this.totalPrice,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      item: json['item'],
      quantity: json['quantity'],
      price: (json['price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'item': item,
        'quantity': quantity,
        'price': price,
      };
}
