import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// ================= SALE ITEM MODEL =================
class SaleItemModel {
  int? id;
  int itemId;
  String? itemNo;
  String itemName;
  String? category;

  int quantity;
  double salePrice;

  RxDouble totalPrice = 0.0.obs;

  late TextEditingController qtyController;
  late TextEditingController priceController;

  SaleItemModel({
    this.id,
    required this.itemId,
    this.itemNo,
    required this.itemName,
    this.category,
    this.quantity = 1,
    required this.salePrice,
  }) {
    // Controllers are NOT initialized automatically here
    totalPrice.value = quantity * salePrice;
  }

  /// ✅ Initialize controllers if null
  void initControllerIfNull() {
    qtyController = TextEditingController(text: quantity.toString());
    priceController = TextEditingController(text: salePrice.toStringAsFixed(2));

    qtyController.addListener(recalculate);
    priceController.addListener(recalculate);

    recalculate();
  }

  /// 🔹 ONLY quantity × salePrice
  void recalculate() {
    final q = int.tryParse(qtyController.text) ?? 1;
    final p = double.tryParse(priceController.text) ?? 0;

    quantity = q < 1 ? 1 : q;
    salePrice = p < 0 ? 0 : p;

    totalPrice.value = quantity * salePrice;
  }

  /// Copy item (fresh controllers)
  SaleItemModel copy() {
    return SaleItemModel(
      id: id,
      itemId: itemId,
      itemNo: itemNo,
      itemName: itemName,
      category: category,
      quantity: quantity,
      salePrice: salePrice,
    );
  }

  bool isSameItem(SaleItemModel other) {
    if (itemId != 0 && other.itemId != 0) return itemId == other.itemId;
    if (itemNo != null && other.itemNo != null) return itemNo == other.itemNo;
    return false;
  }

  void dispose() {
    qtyController.dispose();
    priceController.dispose();
  }

  // ---------------- BACKEND ----------------
  factory SaleItemModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return SaleItemModel(
        itemId: 0,
        itemName: 'Unknown',
        salePrice: 0,
      );
    }

    return SaleItemModel(
      id: json['id'],
      itemId: json['item'] ?? 0,
      itemNo: json['item_no'],
      itemName: json['item_name'] ?? '',
      category: json['category_name'],
      quantity: json['quantity'] ?? 1,
      salePrice: (json['price'] ?? json['sale_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toBackendJson() {
    return {
      'item': itemId,
      'item_no': itemNo,
      'quantity': quantity,
      'price': salePrice,
    };
  }

  // ---------------- FROM STOCK ----------------
  static SaleItemModel fromStock(dynamic stock) {
    return SaleItemModel(
      itemId: stock.id,
      itemName: stock.name,
      salePrice: stock.salePrice,
    );
  }
}

/// ================= SALE MODEL =================
class SaleModel {
  int? id;
  DateTime saleDate;
  String customerName;
  String? contactNo;
  String? vehicleModel;

  bool isServicing;
  int? kmDriven;

  String? jobCardNo;
  String? bikeRegistrationNo;
  String? vehicleColor;

  DateTime? receivedDate;
  DateTime? deliveryDate;

  String? billNo;
  String? technicianName;

  bool isFreeServicing;
  bool isRepairJob;
  bool isAccident;
  bool isWarrantyJob;

  DateTime? followUpDate;
  DateTime? postServiceFeedbackDate;

  String jobDoneOnVehicle;
  String remarks;

  double totalAmount;
  double labourCharge;
  double paidAmount;
  double remainingAmount;

  String paidFrom;
  String isPaid;
  int? handledBy;

  List<SaleItemModel> items;

  SaleModel({
    this.id,
    required this.saleDate,
    required this.customerName,
    this.contactNo,
    this.vehicleModel,
    required this.isServicing,
    this.kmDriven,
    this.jobCardNo,
    this.bikeRegistrationNo,
    this.vehicleColor,
    this.receivedDate,
    this.deliveryDate,
    this.billNo,
    this.technicianName,
    this.isFreeServicing = false,
    this.isRepairJob = false,
    this.isAccident = false,
    this.isWarrantyJob = false,
    this.followUpDate,
    this.postServiceFeedbackDate,
    required this.jobDoneOnVehicle,
    required this.remarks,
    this.totalAmount = 0,
    this.labourCharge = 0,
    this.paidAmount = 0,
    this.remainingAmount = 0,
    this.paidFrom = '',
    this.isPaid = 'not_paid',
    this.handledBy,
    this.items = const [],
  });

  // ---------------- BACKEND RESPONSE ----------------
  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'],
      saleDate: _parse(json['sale_date']) ?? DateTime.now(),
      customerName: json['customer_name'] ?? '',
      contactNo: json['contact_no'],
      vehicleModel: json['vehicle_model'],
      isServicing: json['is_servicing'] ?? false,
      kmDriven: json['km_driven'],
      jobCardNo: json['job_card_no'],
      bikeRegistrationNo: json['bike_registration_no'],
      vehicleColor: json['vehicle_color'],
      receivedDate: _parse(json['received_date']),
      deliveryDate: _parse(json['delivery_date']),
      billNo: json['bill_no'],
      technicianName: json['technician_name'],
      isFreeServicing: json['is_free_servicing'] ?? false,
      isRepairJob: json['is_repair_job'] ?? false,
      isAccident: json['is_accident'] ?? false,
      isWarrantyJob: json['is_warranty_job'] ?? false,
      followUpDate: _parse(json['follow_up_date']),
      postServiceFeedbackDate: _parse(json['post_service_feedback_date']),
      jobDoneOnVehicle: json['job_done_on_vehicle'] ?? '',
      remarks: json['remarks'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      labourCharge: (json['labour_charge'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0).toDouble(),
      paidFrom: json['paid_from'] ?? '',
      isPaid: json['is_paid'] ?? 'not_paid',
      handledBy: json['handled_by'],
      items: (json['items'] as List? ?? [])
          .map((e) => SaleItemModel.fromJson(e))
          .toList(),
    );
  }

  // ---------------- BACKEND PAYLOAD ----------------
  Map<String, dynamic> toBackendJson() {
    final df = DateFormat('yyyy-MM-dd');
    return {
      'sale_date': df.format(saleDate),
      'customer_name': customerName,
      'contact_no': contactNo,
      'vehicle_model': vehicleModel,
      'is_servicing': isServicing,
      'km_driven': kmDriven,
      'job_card_no': jobCardNo,
      'bike_registration_no': bikeRegistrationNo,
      'vehicle_color': vehicleColor,
      'received_date': receivedDate != null ? df.format(receivedDate!) : null,
      'delivery_date': deliveryDate != null ? df.format(deliveryDate!) : null,
      'bill_no': billNo,
      'technician_name': technicianName,
      'is_free_servicing': isFreeServicing,
      'is_repair_job': isRepairJob,
      'is_accident': isAccident,
      'is_warranty_job': isWarrantyJob,
      'follow_up_date': followUpDate?.toIso8601String(),
      'post_service_feedback_date': postServiceFeedbackDate?.toIso8601String(),
      'job_done_on_vehicle': jobDoneOnVehicle,
      'remarks': remarks,
      'total_amount': totalAmount,
      'labour_charge': labourCharge,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'paid_from': paidFrom,
      'handled_by': handledBy,
      'is_paid': isPaid,
      'items': items.map((e) => e.toBackendJson()).toList(),
    };
  }

  static DateTime? _parse(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString());
}
