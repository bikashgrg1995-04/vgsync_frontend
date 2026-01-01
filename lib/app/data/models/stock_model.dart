import 'dart:convert';

StockModel stockModelFromJson(String str) =>
    StockModel.fromJson(json.decode(str));

String stockModelToJson(StockModel data) => json.encode(data.toJson());

class StockModel {
  int count;
  dynamic next;
  dynamic previous;
  List<Result> results;

  StockModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) => StockModel(
        count: json["count"] is int
            ? json["count"]
            : int.tryParse(json["count"].toString()) ?? 0,
        next: json["next"],
        previous: json["previous"],
        results: List<Result>.from((json["results"] as List)
            .map((x) => Result.fromJson(x as Map<String, dynamic>))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "next": next,
        "previous": previous,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class Result {
  int? id;
  String itemNo;
  String name;
  String group;
  String model;
  int category;
  int stock;
  double purchasePrice;
  double salePrice;
  double vat;
  dynamic image;

  Result({
    this.id,
    required this.itemNo,
    required this.name,
    required this.group,
    required this.model,
    required this.category,
    required this.stock,
    required this.purchasePrice,
    required this.salePrice,
    required this.vat,
    this.image,
  });

  // GETTER to show category as string (for UI)
  String get categoryName => category.toString(); // or map int->name

  factory Result.fromJson(Map<String, dynamic> json) => Result(
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
        salePrice: double.tryParse(json["sale_price"].toString()) ?? 0.0,
        vat: double.tryParse(json["vat"].toString()) ?? 0.0,
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
        "vat": vat,
        "image": image,
      };
}
