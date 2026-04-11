import 'dart:convert';

List<StockModel> stockModelFromJson(String str) =>
    List<StockModel>.from(json.decode(str).map((x) => StockModel.fromJson(x)));

String stockModelToJson(List<StockModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StockModel {
  int id;
  String itemNo;
  String name;
  String group;
  String model;
  int category;
  int stock;
  double purchasePrice;
  double salePrice;
  String? block;
  dynamic image;

  StockModel({
    required this.id,
    required this.itemNo,
    required this.name,
    required this.group,
    required this.model,
    required this.category,
    required this.stock,
    required this.purchasePrice,
    required this.salePrice,
    this.block,
    this.image,
  });

  String get categoryName => category.toString();
  String get displayBlock => block ?? 'N/A';

  factory StockModel.fromJson(Map<String, dynamic> json) => StockModel(
        id: json["id"] is int
            ? json["id"]
            : int.tryParse(json["id"].toString()) ?? 0,
        itemNo: json["item_no"] ?? '',
        name: json["name"] ?? '',
        group: json["group"] ?? '',
        model: json["model"] ?? '',
        category: int.tryParse(json["category"].toString()) ?? 0,
        stock: int.tryParse(json["stock"].toString()) ?? 0,
        purchasePrice:
            double.tryParse(json["purchase_price"].toString()) ?? 0.0,
        salePrice:
            double.tryParse(json["sale_price"].toString()) ?? 0.0,
        block: json["block"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "item_no": itemNo,
        "name": name,
        "group": group,
        "model": model,
        "category": category,
        "stock": stock,
        "purchase_price": purchasePrice,
        "sale_price": salePrice,
        "block": block,
        "image": image,
      };
}