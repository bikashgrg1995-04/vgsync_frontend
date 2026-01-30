// ================================
// ENUMS
// ================================
enum SaleType { full, downpayment, emi }

enum VehicleType { bike, scooty }

enum PaymentMethod { cash, cheque, online }

enum EmiStatus { paid, pending }

enum EMIPaymentMethod { cash, cheque, online }

// ================================
// API RESPONSE MODELS
// ================================
class BikeSaleResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<BikeSale> results;

  BikeSaleResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory BikeSaleResponse.fromJson(Map<String, dynamic> json) {
    return BikeSaleResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List? ?? [])
          .map((e) => BikeSale.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }
}

class EmiTrackerResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<EmiTracker> results;

  EmiTrackerResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory EmiTrackerResponse.fromJson(Map<String, dynamic> json) {
    return EmiTrackerResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List? ?? [])
          .map((e) => EmiTracker.fromJson(e))
          .toList(),
    );
  }
}

// ================================
// MAIN MODEL
// ================================
class BikeSale {
  final int id;

  // Customer
  final String customerName;
  final String contactNo;
  final String? address;

  // Vehicle
  final VehicleType vehicleType;
  final String vehicleModel;
  final String registrationNo;
  final String chassisNo;
  final String engineNo;
  final String? color;
  final double kmDriven;

  // Sale
  final SaleType saleType;
  final DateTime saleDate;

  // Amount
  final double totalAmount;
  final double discount;
  final double netTotal;
  final double initialPaidAmount; // for downpayment
  final double paidAmount;
  final double remainingAmount;

  // Payment
  final PaymentMethod paymentMethod;
  final String status;

  // EMI
  final int? emiTenure;
  final double? emiAmount;
  final List<EmiTracker>? emiDetails; // optional list of EMIs

  // Extra
  final String? remarks;

  BikeSale({
    required this.id,
    required this.customerName,
    required this.contactNo,
    this.address,
    required this.vehicleType,
    required this.vehicleModel,
    required this.registrationNo,
    required this.chassisNo,
    required this.engineNo,
    this.color,
    required this.kmDriven,
    required this.saleType,
    required this.saleDate,
    required this.totalAmount,
    required this.discount,
    required this.netTotal,
    this.initialPaidAmount = 0.0,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentMethod,
    required this.status,
    this.emiTenure,
    this.emiAmount,
    this.emiDetails,
    this.remarks,
  });

  // ---------------- FROM JSON ----------------
  factory BikeSale.fromJson(Map<String, dynamic> json) {
    return BikeSale(
      id: json['id'],
      customerName: json['customer_name'] ?? '',
      contactNo: json['contact_no'] ?? '',
      address: json['address'],
      vehicleType: _vehicleTypeFromJson(json['vehicle_type']),
      vehicleModel: json['vehicle_model'] ?? '',
      registrationNo: json['registration_no'] ?? '',
      chassisNo: json['chassis_no'] ?? '',
      engineNo: json['engine_no'] ?? '',
      color: json['color'],
      kmDriven: _toDouble(json['km_driven']),
      saleType: _saleTypeFromJson(json['sale_type']),
      saleDate: DateTime.parse(json['sale_date']),
      totalAmount: _toDouble(json['total_amount']),
      discount: _toDouble(json['discount']),
      netTotal: _toDouble(json['net_total']),
      initialPaidAmount: _toDouble(json['initial_paid_amount']),
      paidAmount: _toDouble(json['paid_amount']),
      remainingAmount: _toDouble(json['remaining_amount']),
      paymentMethod: _paymentMethodFromJson(json['payment_method']),
      status: json['status'] ?? '',
      emiTenure: json['emi_tenure'],
      emiAmount:
          json['emi_amount'] != null ? _toDouble(json['emi_amount']) : null,
      emiDetails: (json['emi_details'] as List?)
          ?.map((e) => EmiTracker.fromJson(e))
          .toList(),
      remarks: json['remarks'],
    );
  }

  // ---------------- TO JSON ----------------
  Map<String, dynamic> toJson() {
    return {
      "customer_name": customerName,
      "contact_no": contactNo,
      if (address != null) "address": address,
      "vehicle_type": vehicleType.name,
      "vehicle_model": vehicleModel,
      "registration_no": registrationNo,
      "chassis_no": chassisNo,
      "engine_no": engineNo,
      if (color != null) "color": color,
      "km_driven": kmDriven,
      "sale_type": saleType.name,
      "sale_date": saleDate.toIso8601String().split('T').first,
      "total_amount": totalAmount,
      "discount": discount,
      "net_total": netTotal,
      if (saleType == SaleType.downpayment)
        "initial_paid_amount": initialPaidAmount,
      "paid_amount": paidAmount,
      "remaining_amount": remainingAmount,
      "payment_method": paymentMethod.name,
      "status": status,
      if (saleType != SaleType.full) "emi_tenure": emiTenure,
      if (saleType != SaleType.full) "emi_amount": emiAmount,
      if (remarks != null) "remarks": remarks,
    };
  }

  // ---------------- COPY WITH ----------------
  BikeSale copyWith({
    String? customerName,
    String? contactNo,
    String? address,
    VehicleType? vehicleType,
    String? vehicleModel,
    String? registrationNo,
    String? chassisNo,
    String? engineNo,
    String? color,
    double? kmDriven,
    SaleType? saleType,
    DateTime? saleDate,
    double? totalAmount,
    double? discount,
    double? netTotal,
    double? initialPaidAmount,
    double? paidAmount,
    double? remainingAmount,
    PaymentMethod? paymentMethod,
    String? status,
    int? emiTenure,
    double? emiAmount,
    List<EmiTracker>? emiDetails,
    String? remarks,
  }) {
    return BikeSale(
      id: id,
      customerName: customerName ?? this.customerName,
      contactNo: contactNo ?? this.contactNo,
      address: address ?? this.address,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      registrationNo: registrationNo ?? this.registrationNo,
      chassisNo: chassisNo ?? this.chassisNo,
      engineNo: engineNo ?? this.engineNo,
      color: color ?? this.color,
      kmDriven: kmDriven ?? this.kmDriven,
      saleType: saleType ?? this.saleType,
      saleDate: saleDate ?? this.saleDate,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      netTotal: netTotal ?? this.netTotal,
      initialPaidAmount: initialPaidAmount ?? this.initialPaidAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      emiTenure: emiTenure ?? this.emiTenure,
      emiAmount: emiAmount ?? this.emiAmount,
      emiDetails: emiDetails ?? this.emiDetails,
      remarks: remarks ?? this.remarks,
    );
  }

  // ---------------- EMPTY MODEL ----------------
  factory BikeSale.empty() {
    return BikeSale(
      id: 0,
      customerName: '',
      contactNo: '',
      address: null,
      vehicleType: VehicleType.bike,
      vehicleModel: '',
      registrationNo: '',
      chassisNo: '',
      engineNo: '',
      color: null,
      kmDriven: 0.0,
      saleType: SaleType.full,
      saleDate: DateTime.now(),
      totalAmount: 0.0,
      discount: 0.0,
      netTotal: 0.0,
      initialPaidAmount: 0.0,
      paidAmount: 0.0,
      remainingAmount: 0.0,
      paymentMethod: PaymentMethod.cash,
      status: '',
      emiTenure: null,
      emiAmount: null,
      emiDetails: null,
      remarks: null,
    );
  }

  // ---------------- UI HELPERS ----------------
  bool get isPaid => remainingAmount == 0;
  bool get isEmi =>
      saleType == SaleType.emi || saleType == SaleType.downpayment;
  bool get isPartial => remainingAmount > 0;

  // ---------------- INTERNAL HELPERS ----------------
  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static SaleType _saleTypeFromJson(String? value) {
    switch (value) {
      case 'emi':
        return SaleType.emi;
      case 'downpayment':
        return SaleType.downpayment;
      default:
        return SaleType.full;
    }
  }

  static VehicleType _vehicleTypeFromJson(String? value) {
    return value == 'scooty' ? VehicleType.scooty : VehicleType.bike;
  }

  static PaymentMethod _paymentMethodFromJson(String? value) {
    switch (value) {
      case 'cheque':
        return PaymentMethod.cheque;
      case 'online':
        return PaymentMethod.online;
      default:
        return PaymentMethod.cash;
    }
  }
}

// ================================
// EMI TRACKER MODEL
// ================================
class EmiTracker {
  final int id;
  final int installmentNo;
  final DateTime dueDate;
  final double amountDue;
  final double paidAmount;
  final DateTime? paymentDate;
  final EMIPaymentMethod? paymentMethod; // nullable
  final EmiStatus status;
  final int saleId;

  EmiTracker({
    required this.id,
    required this.installmentNo,
    required this.dueDate,
    required this.amountDue,
    required this.paidAmount,
    this.paymentDate,
    this.paymentMethod,
    required this.status,
    required this.saleId,
  });

  factory EmiTracker.fromJson(Map<String, dynamic> json) {
    return EmiTracker(
      id: json['id'] ?? (throw Exception("EMI ID is missing in API response")),
      installmentNo: json['installment_no'] ?? 0,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : DateTime.now(),
      amountDue: _toDouble(json['amount_due']),
      paidAmount: _toDouble(json['paid_amount']),
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
      paymentMethod: _paymentMethod(json['payment_method']),
      status: _emiStatus(json['status']),
      saleId: json['sale'] ?? 0,
    );
  }

  // ---------------- TO JSON ----------------
  Map<String, dynamic> toJson() {
    return {
      'installment_no': installmentNo,
      'due_date': dueDate.toIso8601String(),
      'amount_due': amountDue,
      'paid_amount': paidAmount,
      'payment_date': paymentDate?.toIso8601String(),
      'payment_method': paymentMethod?.name, // null-safe
      'status': status.name,
      'sale': saleId,
    };
  }

  // ---------------- COPY WITH ----------------
  EmiTracker copyWith({
    double? paidAmount,
    DateTime? paymentDate,
    EMIPaymentMethod? paymentMethod,
    EmiStatus? status,
  }) {
    return EmiTracker(
      id: id,
      installmentNo: installmentNo,
      dueDate: dueDate,
      amountDue: amountDue,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      saleId: saleId,
    );
  }

  // ---------------- EMPTY MODEL ----------------
  factory EmiTracker.empty() {
    return EmiTracker(
      id: 0,
      installmentNo: 0,
      dueDate: DateTime.now(),
      amountDue: 0.0,
      paidAmount: 0.0,
      paymentDate: null,
      paymentMethod: null,
      status: EmiStatus.pending,
      saleId: 0,
    );
  }

  // ---------------- UI HELPERS ----------------
  bool get isPaid => status == EmiStatus.paid;
  bool get isPending => status == EmiStatus.pending;
  bool get isOverdue => isPending && dueDate.isBefore(DateTime.now());

  // ---------------- INTERNAL HELPERS ----------------
  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static EmiStatus _emiStatus(String? v) {
    return v?.toLowerCase() == 'paid' ? EmiStatus.paid : EmiStatus.pending;
  }

  static EMIPaymentMethod? _paymentMethod(String? v) {
    if (v == null) return null;
    switch (v.toLowerCase()) {
      case 'cheque':
        return EMIPaymentMethod.cheque;
      case 'online':
        return EMIPaymentMethod.online;
      default:
        return EMIPaymentMethod.cash;
    }
  }
}
