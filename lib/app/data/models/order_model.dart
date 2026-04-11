class OrderItemModel {
  final int? id;
  final int item;
  final int quantity;
  final double rate;
  final double totalPrice;


  OrderItemModel({
    this.id,
    required this.item,
    required this.quantity,
    required this.rate,
    required this.totalPrice,
    
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      item: json['item'],
      quantity: json['quantity'],
      rate: (json['rate'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item': item,
      'quantity': quantity,
      'rate': rate,
      'total_price': totalPrice,
      
    };
  }
}

class OrderModel {
  final int id;
  final String customerName;
  final String contactNo;
  final String vehicleModel;
  final DateTime orderDate;
  final List<OrderItemModel> items;
  final double totalAmount;
  final double advance;
  final double remainingAmount;
    final String status;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.contactNo,
    required this.vehicleModel,
    required this.orderDate,
    required this.items,
    required this.totalAmount,
    required this.advance,
    required this.remainingAmount,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customerName: json['customer_name'],
      contactNo: json['contact_no'],
      vehicleModel: json['vehicle_model'],
      orderDate: DateTime.parse(json['order_date']),
      items: (json['items'] as List)
          .map((e) => OrderItemModel.fromJson(e))
          .toList(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      advance: (json['advance'] as num).toDouble(),
      remainingAmount: (json['remaining_amount'] as num).toDouble(),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'contact_no': contactNo,
      'vehicle_model': vehicleModel,
      'order_date': orderDate.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'total_amount': totalAmount,
      'advance': advance,
      'remaining_amount': remainingAmount,
      'status': status,
    };
  }
}
