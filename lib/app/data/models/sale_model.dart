class SaleItem {
  final int itemId;
  final String itemName;
  final double quantity;
  final double price;

  SaleItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      itemId: json['item'] ?? 0,
      itemName: json['item_name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      price: (json['total_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': itemId,
      'item_name': itemName,
      'quantity': quantity,
      'total_price': price,
    };
  }
}

class SaleModel {
  final int id;
  DateTime saleDate;
  final String customerName;
  final String? contactNo;
  final bool isServicing;
  final String? billNo;
  final String? remarks;
  final double paidAmount;
  final double remainingAmount;
  final double totalAmount;
  final String isPaid;
  final String paidFrom;
  final double labourCharge;
  final String? jobCardNo;
  final String? bikeRegistrationNo;
  final String? vehicleColor;
  final int? kmDriven;
  final bool isFreeServicing;
  final bool isRepairJob;
  final bool isAccident;
  final bool isWarrantyJob;
  final String? jobDoneOnVehicle;
  final DateTime? receivedDate;
  final DateTime? deliveryDate;
  final DateTime? followUpDate;
  final DateTime? postServiceFeedbackDate;
  final List<SaleItem> items;

  SaleModel({
    required this.id,
    required this.saleDate,
    required this.customerName,
    this.contactNo,
    required this.isServicing,
    this.billNo,
    this.remarks,
    required this.paidAmount,
    required this.remainingAmount,
    required this.totalAmount,
    required this.isPaid,
    required this.paidFrom,
    required this.labourCharge,
    this.jobCardNo,
    this.bikeRegistrationNo,
    this.vehicleColor,
    this.kmDriven,
    required this.isFreeServicing,
    required this.isRepairJob,
    required this.isAccident,
    required this.isWarrantyJob,
    this.jobDoneOnVehicle,
    this.receivedDate,
    this.deliveryDate,
    this.followUpDate,
    this.postServiceFeedbackDate,
    required this.items,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'],
      saleDate: DateTime.parse(json['sale_date']),
      customerName: json['customer_name'] ?? '',
      contactNo: json['contact_no']?.toString(),
      isServicing: json['is_servicing'] ?? false,
      billNo: json['bill_no'],
      remarks: json['remarks'],
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      isPaid: json['is_paid'] ?? 'unpaid',
      paidFrom: json['paid_from'] ?? 'cash',
      labourCharge: (json['labour_charge'] ?? 0).toDouble(),
      jobCardNo: json['job_card_no'],
      bikeRegistrationNo: json['bike_registration_no'],
      vehicleColor: json['vehicle_color'],
      kmDriven: json['km_driven'] != null
          ? int.tryParse(json['km_driven'].toString())
          : null,
      isFreeServicing: json['is_free_servicing'] ?? false,
      isRepairJob: json['is_repair_job'] ?? false,
      isAccident: json['is_accident'] ?? false,
      isWarrantyJob: json['is_warranty_job'] ?? false,
      jobDoneOnVehicle: json['job_done_on_vehicle'],
      receivedDate: json['received_date'] != null
          ? DateTime.parse(json['received_date'])
          : null,
      deliveryDate: json['delivery_date'] != null
          ? DateTime.parse(json['delivery_date'])
          : null,
      followUpDate: json['follow_up_date'] != null
          ? DateTime.parse(json['follow_up_date'])
          : null,
      postServiceFeedbackDate: json['post_service_feedback_date'] != null
          ? DateTime.parse(json['post_service_feedback_date'])
          : null,
      items: json['items'] != null
          ? (json['items'] as List).map((e) => SaleItem.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sale_date': saleDate.toIso8601String(),
      'customer_name': customerName,
      'contact_no': contactNo,
      'is_servicing': isServicing,
      'bill_no': billNo,
      'remarks': remarks,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'total_amount': totalAmount,
      'is_paid': isPaid,
      'paid_from': paidFrom,
      'labour_charge': labourCharge,
      'job_card_no': jobCardNo,
      'bike_registration_no': bikeRegistrationNo,
      'vehicle_color': vehicleColor,
      'km_driven': kmDriven,
      'is_free_servicing': isFreeServicing,
      'is_repair_job': isRepairJob,
      'is_accident': isAccident,
      'is_warranty_job': isWarrantyJob,
      'job_done_on_vehicle': jobDoneOnVehicle,
      'received_date': receivedDate?.toIso8601String(),
      'delivery_date': deliveryDate?.toIso8601String(),
      'follow_up_date': followUpDate?.toIso8601String(),
      'post_service_feedback_date': postServiceFeedbackDate?.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
