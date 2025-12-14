class FollowUpModel {
  final int id;
  final int sale;
  final String serviceDate;
  final String followUpDate;
  final bool completed;
  final String remarks;

  FollowUpModel({
    required this.id,
    required this.sale,
    required this.serviceDate,
    required this.followUpDate,
    required this.completed,
    required this.remarks,
  });

  factory FollowUpModel.fromJson(Map<String, dynamic> json) {
    return FollowUpModel(
      id: json['id'],
      sale: json['sale'],
      serviceDate: json['service_date'],
      followUpDate: json['follow_up_date'],
      completed: json['completed'],
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sale': sale,
      'service_date': serviceDate,
      'follow_up_date': followUpDate,
      'completed': completed,
      'remarks': remarks,
    };
  }

  FollowUpModel copyWith({
    int? id,
    int? sale,
    String? serviceDate,
    String? followUpDate,
    bool? completed,
    String? remarks,
  }) {
    return FollowUpModel(
      id: id ?? this.id,
      sale: sale ?? this.sale,
      serviceDate: serviceDate ?? this.serviceDate,
      followUpDate: followUpDate ?? this.followUpDate,
      completed: completed ?? this.completed,
      remarks: remarks ?? this.remarks,
    );
  }
}
