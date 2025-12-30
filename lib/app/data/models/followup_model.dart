class FollowUpModel {
  int id;
  int sale;
  String customerName;
  String? contactNo;
  String? vehicle;
  DateTime? deliveryDate;
  DateTime? postServiceFeedbackDate;
  DateTime? followUpDate;
  String? remarks;
  int? assignedTo;
  String? status;
  String? reason;
  DateTime createdAt;
  DateTime updatedAt;

  FollowUpModel({
    required this.id,
    required this.sale,
    required this.customerName,
    this.contactNo,
    this.vehicle,
    this.deliveryDate,
    this.postServiceFeedbackDate,
    this.followUpDate,
    this.remarks,
    this.assignedTo,
    this.status,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FollowUpModel.fromJson(Map<String, dynamic> json) {
    return FollowUpModel(
      id: json['id'],
      sale: json['sale'],
      customerName: json['customer_name'],
      contactNo: json['contact_no']?.toString(),
      vehicle: json['vehicle'],
      deliveryDate: json['delivery_date'] != null
          ? DateTime.parse(json['delivery_date'])
          : null,
      postServiceFeedbackDate: json['post_service_feedback_date'] != null
          ? DateTime.parse(json['post_service_feedback_date'])
          : null,
      followUpDate: json['follow_up_date'] != null
          ? DateTime.parse(json['follow_up_date'])
          : null,
      remarks: json['remarks'],
      assignedTo: json['assigned_to'],
      status: json['status'],
      reason: json['reason'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sale': sale,
      'customer_name': customerName,
      'contact_no': contactNo,
      'vehicle': vehicle,
      'delivery_date': deliveryDate?.toIso8601String(),
      'post_service_feedback_date': postServiceFeedbackDate?.toIso8601String(),
      'follow_up_date': followUpDate?.toIso8601String(),
      'remarks': remarks,
      'assigned_to': assignedTo,
      'status': status,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
