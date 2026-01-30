import 'package:dio/dio.dart';
import 'package:vgsync_frontend/app/data/models/bike_sale_model.dart';
import 'api_service.dart';

class BikeSaleService {
  final Dio _dio = ApiService.dio;

  // ===============================
  // GET : List Bike Sales
  // ===============================
  Future<BikeSaleResponse> getBikeSales({
    int page = 1,
    String? saleType,
    String? vehicleType,
  }) async {
    try {
      final response = await _dio.get(
        "/bike-sales/",
        queryParameters: {
          'page': page,
          if (saleType != null) 'sale_type': saleType,
          if (vehicleType != null) 'vehicle_type': vehicleType,
        },
      );

      return BikeSaleResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to fetch bike sales: $e");
    }
  }

  // ===============================
  // POST : Create Bike Sale
  // ===============================
  Future<BikeSale> createBikeSale(BikeSale sale) async {
    try {
      final response = await _dio.post(
        "/bike-sales/",
        data: sale.toJson(),
      );

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
      final response = await _dio.patch(
        "/bike-sales/$saleId/",
        data: data,
      );

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
  Future<EmiTrackerResponse> getEmiTrackers({int? saleId}) async {
    try {
      final response = await _dio.get(
        "/emi-tracker/",
        queryParameters: {
          if (saleId != null) 'sale': saleId,
        },
      );

      return EmiTrackerResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to fetch EMI trackers: $e");
    }
  }

  // ===============================
  // PATCH : Update EMI Payment
  // NOTE: Pass emiId, NOT saleId
  // ===============================
  Future<EmiTracker> updateEmiPayment({
    required int emiId,
    required double paidAmount,
    required DateTime paymentDate,
    required EMIPaymentMethod emiPaymentMethod, // from bike_sale_model
    required EmiStatus status, // enum
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
