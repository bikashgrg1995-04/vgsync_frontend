import 'package:dio/dio.dart';
import 'package:vgsync_frontend/app/data/models/bike_sale_model.dart';
import 'api_service.dart';

class BikeSaleService {
  final Dio _dio = ApiService.dio;

  List _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'];
    return [];
  }

  // ===============================
  // GET : List Bike Sales
  // ===============================
  Future<List<BikeSale>> getBikeSales({
    String? saleType,
    String? vehicleType,
  }) async {
    try {
      final response = await _dio.get(
        "/bike-sales/",
        queryParameters: {
          if (saleType != null) 'sale_type': saleType,
          if (vehicleType != null) 'vehicle_type': vehicleType,
        },
      );
      return _extractList(response.data)
          .map((e) => BikeSale.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch bike sales: $e");
    }
  }

  // ===============================
  // POST : Create Bike Sale
  // ===============================
  Future<BikeSale> createBikeSale(BikeSale sale) async {
    try {
      final response = await _dio.post("/bike-sales/", data: sale.toJson());
      return BikeSale.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to create bike sale: $e");
    }
  }

  // ===============================
  // PATCH : Update Bike Sale
  // ===============================
  Future<BikeSale> updateBikeSale({
    required int saleId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.patch("/bike-sales/$saleId/", data: data);
      return BikeSale.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to update bike sale: $e");
    }
  }

  // ===============================
  // DELETE : Delete Bike Sale
  // ===============================
  Future<void> deleteBikeSale(int saleId) async {
    try {
      await _dio.delete("/bike-sales/$saleId/");
    } catch (e) {
      throw Exception("Failed to delete bike sale: $e");
    }
  }

  // ===============================
  // GET : EMI Tracker List
  // ===============================
  Future<List<EmiTracker>> getEmiTrackers({int? saleId}) async {
    try {
      final response = await _dio.get(
        "/emi-tracker/",
        queryParameters: {
          if (saleId != null) 'sale': saleId,
        },
      );
      return _extractList(response.data)
          .map((e) => EmiTracker.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch EMI trackers: $e");
    }
  }

  // ===============================
  // PATCH : Update EMI Payment
  // ===============================
  Future<EmiTracker> updateEmiPayment({
    required int emiId,
    required double paidAmount,
    required DateTime paymentDate,
    required EMIPaymentMethod emiPaymentMethod,
    required EmiStatus status,
  }) async {
    try {
      final response = await _dio.patch(
        "/emi/$emiId/update/",
        data: {
          "paid_amount": paidAmount,
          "payment_date": paymentDate.toIso8601String().split('T').first,
          "payment_method": emiPaymentMethod.name,
          "status": status == EmiStatus.paid ? "Paid" : "Pending",
        },
      );
      return EmiTracker.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to update EMI payment: $e");
    }
  }
}