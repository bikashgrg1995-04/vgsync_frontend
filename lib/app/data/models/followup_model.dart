import 'package:vgsync_frontend/app/data/models/sale_model.dart';

class FollowUpModel {
  // ------------------ BASIC ------------------
  final int id;

  // ------------------ SALE ------------------
  final int? saleId;
  final SaleModel? sale;

  // ------------------ CUSTOMER ------------------
  final String customerName;
  final String? contactNo;
  final String? vehicle;

  // ------------------ DATES ------------------
  final DateTime? deliveryDate;
  final DateTime? postServiceFeedbackDate;
  final DateTime? followUpDate;

  // ------------------ META ------------------
  final String? remarks;
  final String? status;
  final String? assignedTo;
  final String? reason;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  FollowUpModel({
    required this.id,
    this.saleId,
    this.sale,
    required this.customerName,
    this.contactNo,
    this.vehicle,
    this.deliveryDate,
    this.postServiceFeedbackDate,
    this.followUpDate,
    this.remarks,
    this.status,
    this.assignedTo,
    this.reason,
    this.createdAt,
    this.updatedAt,
  });

  // ------------------ FROM JSON ------------------
  factory FollowUpModel.fromJson(Map<String, dynamic> json) {
    final dynamic saleJson = json['sale'];

    int? resolvedSaleId;
    SaleModel? resolvedSale;

    if (saleJson is Map) {
      final saleMap = Map<String, dynamic>.from(saleJson);
      resolvedSaleId = saleMap['id'];
      resolvedSale = SaleModel.fromJson(saleMap);
    } else if (saleJson is int) {
      resolvedSaleId = saleJson;
    } else if (saleJson is String) {
      resolvedSaleId = int.tryParse(saleJson);
    }

    return FollowUpModel(
      id: json['id'] ?? 0,
      saleId: resolvedSaleId,
      sale: resolvedSale,
      customerName: json['customer_name'] ?? '',
      contactNo: json['contact_no']?.toString(),
      vehicle: json['vehicle'],
      deliveryDate: _parseDate(json['delivery_date']),
      postServiceFeedbackDate:
          _parseDate(json['post_service_feedback_date']),
      followUpDate: _parseDate(json['follow_up_date']),
      remarks: json['remarks'],
      status: json['status'],
      assignedTo: json['assigned_to'],
      reason: json['reason'],
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  // ------------------ DATE PARSER ------------------
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  // ------------------ COPY WITH ------------------
  FollowUpModel copyWith({
    int? id,
    int? saleId,
    SaleModel? sale,
    String? customerName,
    String? contactNo,
    String? vehicle,
    DateTime? deliveryDate,
    DateTime? postServiceFeedbackDate,
    DateTime? followUpDate,
    String? remarks,
    String? status,
    String? assignedTo,
    String? reason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FollowUpModel(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      sale: sale ?? this.sale,
      customerName: customerName ?? this.customerName,
      contactNo: contactNo ?? this.contactNo,
      vehicle: vehicle ?? this.vehicle,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      postServiceFeedbackDate:
          postServiceFeedbackDate ?? this.postServiceFeedbackDate,
      followUpDate: followUpDate ?? this.followUpDate,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
