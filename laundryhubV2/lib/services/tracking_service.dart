import 'package:dio/dio.dart';

import '../models/tracking_model.dart';
import 'api_service.dart';
import '../models/transaction_detail_model.dart';
import '../models/transaction_fragrance_model.dart';

class TrackingService {

  final Dio dio =
      ApiService().dio;

  Future<TrackingModel?> getTracking(
    String code,
  ) async {

    try {

      final response =
          await dio.get(
        "/tracking/$code",
      );

      final data =
          response.data["data"];

      print(response.data);

      print("TIMELINE = ${data["timeline"]}");
      print("IS PICKUP = ${data["is_pickup"]}");
      print("IS DELIVERY = ${data["is_delivery"]}");

      final trx =
          data["transaction"];

      print(
        "ESTIMATED COMPLETION => ${trx["estimated_completion"]}",
      );

      final laundry =
          trx["laundry"] ?? {};

      

      return TrackingModel(

        invoice:
            trx["invoice_number"] ?? "",

        customerName:
            trx["customer_name"] ?? "",

        customerPhone:
            trx["customer_phone"] ?? "",

        status:
            trx["status"] ?? "",

        paymentStatus:
            trx["payment_status"] ?? "",

        trackingCode:
            trx["tracking_code"] ?? "",

        estimatedCompletion:
            trx["estimated_completion"] ?? "",

        createdAt:
            trx["created_at"] ?? "",

        totalWeight:
            double.tryParse(
                  "${trx["total_weight"] ?? 0}",
                ) ??
                0,

        totalPrice:
            double.tryParse(
                  "${trx["final_price"] ?? 0}",
                ) ??
                0,
                

        notes:
            trx["notes"] ?? "",

        laundryName:
            laundry["name"] ??
                "LaundryHub",

        laundryAddress:
            laundry["address"] ??
                "",
        
        laundryPhone:
            laundry["phone"] ?? "",

        isPickup:
            data["is_pickup"] ?? false,

        isDelivery:
            data["is_delivery"] ?? false,

        timeline:
            data["timeline"] == null
                ? <String>[]
                : (data["timeline"] as List)
                    .map((e) => e.toString())
                    .toList(),

        currentTimelineIndex:
            data["current_timeline_index"] ?? 0,
            

        details:

        (trx["details"] as List?)

        ?.map(

          (e)=>

          TransactionDetailModel
              .fromJson(e),

        )

        .toList()

        ??

        [],

        fragrances:

        (trx["fragrances"] as List?)

        ?.map(

          (e)=>

          TransactionFragranceModel
              .fromJson(e),

        )

        .toList()

        ??

        [],

        progressPercentage:
            data["progress_percentage"] ?? 0,

        currentStatusIndex:
            data["current_status_index"] ?? 0,

      );

    }

    on DioException {

      return null;

    }

  }

}