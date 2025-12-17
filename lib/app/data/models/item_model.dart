class ItemModel {
  int? id;
  String name;
  String group;
  String model;
  int stock;
  double purchasePrice;
  double salePrice;
  String? image;
  int category;

  ItemModel({
    required this.id,
    required this.name,
    required this.group,
    required this.model,
    required this.stock,
    required this.purchasePrice,
    required this.salePrice,
    this.image,
    required this.category,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
        id: json['id'],
        name: json['name'],
        group: json['group'],
        model: json['model'],
        stock: json['stock'],
        purchasePrice: (json['purchase_price'] ?? 0).toDouble(),
        salePrice: (json['sale_price'] ?? 0).toDouble(),
        image: json['image'],
        category: json['category'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'group': group,
        'model': model,
        'stock': stock,
        'purchase_price': purchasePrice,
        'sale_price': salePrice,
        'image': image,
        'category': category,
      };
}
