// app/data/models/sale_model.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/data/models/stock_model.dart';

/// ================= SALE ITEM =================
class SaleItemModel {
  int? id;
  int itemId;
  String itemName;
  String? categoryName;

  int quantity;
  double salePrice;

  // ---------- REACTIVE ----------
  late RxInt quantityRx;
  late RxDouble priceRx;
  late RxDouble totalPrice;

  TextEditingController? quantityController;
  TextEditingController? priceController;

  SaleItemModel({
    this.id,
    required this.itemId,
    required this.itemName,
    this.categoryName,
    required this.quantity,
    required this.salePrice,
  }) {
    initControllerIfNull();
  }

  void initControllerIfNull() {
    quantityRx = quantity.obs;
    priceRx = salePrice.obs;
    totalPrice = (quantity * salePrice).obs;

    quantityController = TextEditingController(text: quantity.toString());
    priceController = TextEditingController(text: salePrice.toStringAsFixed(2));

    quantityController!.addListener(_recalculate);
    priceController!.addListener(_recalculate);
  }

  void _recalculate() {
    quantity = int.tryParse(quantityController!.text) ?? 1;
    salePrice = double.tryParse(priceController!.text) ?? 0;

    if (quantity < 1) quantity = 1;
    if (salePrice < 0) salePrice = 0;

    quantityRx.value = quantity;
    priceRx.value = salePrice;
    totalPrice.value = quantity * salePrice;
  }

  SaleItemModel.fromStock(Result stock)
      : id = null,
        itemId = stock.id ?? 0,
        itemName = stock.name,
        categoryName = stock.categoryName,
        quantity = 1,
        salePrice = stock.salePrice {
    initControllerIfNull();
  }

  SaleItemModel copy() {
    return SaleItemModel(
      id: id,
      itemId: itemId,
      itemName: itemName,
      categoryName: categoryName,
      quantity: quantity,
      salePrice: salePrice,
    );
  }

  void dispose() {
    quantityController?.dispose();
    priceController?.dispose();
  }

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is Map<String, dynamic> && value['id'] != null) {
        return int.tryParse(value['id'].toString());
      }
      return null;
    }

    return SaleItemModel(
      id: json['id'],
      itemId: parseInt(json['item']) ?? 0,
      itemName: json['item_name'] ?? '',
      categoryName: json['category_name'],
      quantity: json['quantity'] ?? 1,
      salePrice: (json['sale_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toBackendJson() {
    return {
      'item': itemId,
      'quantity': quantity,
      'sale_price': salePrice,
    };
  }
}

/// ================= SALE MODEL =================
class SaleModel {
  int? id;

  DateTime saleDate;
  String customerName;
  String? contactNo;

  bool isServicing;
  int? handledBy;

  // ---------- TOTALS ----------
  double grandTotal;
  double discountPercentage;
  double discountAmount;
  double netTotal;
  double paidAmount;
  double remainingAmount;
  String isPaid;
  String paidFrom;

  // ---------- STOCK ----------
  String? vehicleModel;

  // ---------- SERVICING ----------
  String? billNo;
  String? remarks;
  String? jobCardNo;
  String? bikeRegistrationNo;
  String? vehicleType;
  String? vehicleColor;
  int? kmDriven;
  double labourCharge;

  bool isFreeServicing;
  bool isRepairJob;
  bool isAccident;
  bool isWarrantyJob;

  /// 🆕 NEW FIELDS
  String? jobDoneOnVehicle;
  String? technicianName;

  DateTime? receivedDate;
  DateTime? deliveryDate;
  DateTime? followUpDate;
  DateTime? postServiceFeedbackDate;

  List<SaleItemModel> items;

  SaleModel({
    this.id,
    required this.saleDate,
    required this.customerName,
    this.contactNo,
    required this.isServicing,
    this.handledBy,
    required this.grandTotal,
    required this.discountPercentage,
    required this.discountAmount,
    required this.netTotal,
    required this.paidAmount,
    required this.remainingAmount,
    required this.isPaid,
    this.paidFrom = 'cash',
    this.vehicleType = "bike",
    this.vehicleModel,
    this.billNo,
    this.remarks,
    this.jobCardNo,
    this.bikeRegistrationNo,
    this.vehicleColor,
    this.kmDriven,
    this.labourCharge = 0,
    this.isFreeServicing = false,
    this.isRepairJob = false,
    this.isAccident = false,
    this.isWarrantyJob = false,
    this.jobDoneOnVehicle,
    this.technicianName,
    this.receivedDate,
    this.deliveryDate,
    this.followUpDate,
    this.postServiceFeedbackDate,
    this.items = const [],
  });

  /// Auto resolve paid status
  static String resolvePaidStatus(double net, double paid) {
    if (paid <= 0) return 'not_paid';
    if (paid >= net) return 'paid';
    return 'partial';
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// ---------- FROM BACKEND ----------
  factory SaleModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is Map<String, dynamic> && value['id'] != null) {
        return int.tryParse(value['id'].toString());
      }
      return null;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return SaleModel(
      id: parseInt(json['id']),
      saleDate: parseDate(json['sale_date']) ?? DateTime.now(),
      customerName: json['customer_name'] ?? '',
      contactNo: json['contact_no'],
      isServicing: json['is_servicing'] ?? false,
      handledBy: parseInt(json['handled_by']), // ✅ fixed
      grandTotal: (json['grand_total'] ?? 0).toDouble(),
      discountPercentage: (json['discount_percentage'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      netTotal: (json['net_total'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0).toDouble(),
      isPaid: json['is_paid'] ?? 'not_paid',
      paidFrom: json['paid_from'] ?? 'cash',
      vehicleModel: json['vehicle_model'],
      billNo: json['bill_no'],
      remarks: json['remarks'],
      jobCardNo: json['job_card_no'],
      bikeRegistrationNo: json['bike_registration_no'],
      vehicleType: json['vehicle_type'],
      vehicleColor: json['vehicle_color'],
      kmDriven: parseInt(json['km_driven']),
      labourCharge: (json['labour_charge'] ?? 0).toDouble(),
      isFreeServicing: json['is_free_servicing'] ?? false,
      isRepairJob: json['is_repair_job'] ?? false,
      isAccident: json['is_accident'] ?? false,
      isWarrantyJob: json['is_warranty_job'] ?? false,
      jobDoneOnVehicle: json['job_done_on_vehicle'],
      technicianName: json['technician_name'],
      receivedDate: parseDate(json['received_date']),
      deliveryDate: parseDate(json['delivery_date']),
      followUpDate: parseDate(json['follow_up_date']),
      postServiceFeedbackDate: parseDate(json['post_service_feedback_date']),
      items: (json['items'] as List? ?? [])
          .map((e) => SaleItemModel.fromJson(e))
          .toList(),
    );
  }

  /// ---------- TO BACKEND ----------
  Map<String, dynamic> toBackendJson() {
    return {
      'sale_date': _formatDate(saleDate),
      'customer_name': customerName,
      'contact_no': contactNo,
      'is_servicing': isServicing,
      'handled_by': handledBy,
      'grand_total': grandTotal,
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'net_total': netTotal,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'is_paid': isPaid,
      'paid_from': paidFrom,
      'vehicle_model': vehicleModel,
      'bill_no': billNo,
      'remarks': remarks,
      'job_card_no': jobCardNo,
      'bike_registration_no': bikeRegistrationNo,
      'vehicle_type': vehicleType,
      'vehicle_color': vehicleColor,
      'km_driven': kmDriven,
      'labour_charge': labourCharge,
      'is_free_servicing': isFreeServicing,
      'is_repair_job': isRepairJob,
      'is_accident': isAccident,
      'is_warranty_job': isWarrantyJob,
      'job_done_on_vehicle': jobDoneOnVehicle,
      'received_date': _formatDate(receivedDate),
      'delivery_date': _formatDate(deliveryDate),
      'follow_up_date': _formatDate(followUpDate),
      'post_service_feedback_date': _formatDate(postServiceFeedbackDate),
      'items': items.map((e) => e.toBackendJson()).toList(),
    };
  }
}
