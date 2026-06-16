import 'package:dio/dio.dart';

import '../models/pickup_model.dart';
import 'api_service.dart';
import '../models/pickup_detail_model.dart';

class PickupService {

  final Dio dio =
      ApiService().dio;

  Future<Map<String,dynamic>>
  getPickups({

    String? status,
    String? type,
    String? search,
    String? dateFrom,
    String? dateTo,

  }) async {

    try{

      final response =
      await dio.get(

        "/owner/pickups",

        queryParameters:{

          "status":status,
          "type":type,
          "search":search,
          "date_from":dateFrom,
          "date_to":dateTo,

        },

      );

      final List data =

      response.data["data"]
      ["pickups"]["data"];

      List<PickupModel>
      pickups =

      data.map(

        (e)=>

        PickupModel.fromJson(e),

      ).toList();

      return{

        "success":true,

        "pickups":
        pickups,

        "stats":

        response.data
        ["data"]["stats"]

      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response
        ?.data["message"]

        ??

        "Gagal memuat pickup"

      };
    }

    }

    Future<Map<String, dynamic>>
    acceptPickup(
      int id,
    ) async {

      try {

        final response =
            await dio.patch(
          "/owner/pickups/$id/accept",
        );

        return {
          "success": true,
          "message":
              response.data["message"] ??
              "Pickup diterima",
        };

      } on DioException catch (e) {

        return {
          "success": false,
          "message":
              e.response?.data["message"] ??
              "Gagal menerima pickup",
        };

      }

    }

    Future<Map<String, dynamic>>
    cancelPickup(
      int id,
      String reason,
    ) async {

        try {

          final response =
              await dio.patch(
            "/owner/pickups/$id/cancel",
            data: {
              "cancellation_reason": reason,
            },
          );

          return {
            "success": true,
            "message":
                response.data["message"] ??
                "Pickup dibatalkan",
          };

        } on DioException catch (e) {

          return {
            "success": false,
            "message":
                e.response?.data["message"] ??
                "Gagal membatalkan pickup",
          };

        }

      }


      Future<Map<String, dynamic>>
      onTheWayPickup(
        int id,
      ) async {

        try {

          final response =
              await dio.patch(
            "/owner/pickups/$id/on-the-way",
          );

          return {
            "success": true,
            "message":
                response.data["message"],
          };

        } catch (e) {

          return {
            "success": false,
            "message":
                "Gagal update status",
          };

        }

      }

      Future<Map<String, dynamic>>
      completePickup(
        int id,
      ) async {

        try {

          final response =
              await dio.patch(
            "/owner/pickups/$id/complete",
          );

          return {
            "success": true,
            "message":
                response.data["message"],
          };

        }

        on DioException catch (e) {

          return {

            "success": false,

            "message":

                e.response?.data["message"]

                ??

                "Gagal menyelesaikan pickup",

          };

        }

      }

      Future<Map<String,dynamic>>
      getPickupDetail(
        int id,
      ) async {

        try {

          final response =
              await dio.get(
            "/owner/pickups/$id",
          );

          final detail =
              PickupDetailModel.fromJson(
            response.data["data"],
          );

          return {

            "success": true,

            "data": detail,

          };

        }

        on DioException catch(e) {

          return {

            "success": false,

            "message":

                e.response?.data["message"]

                ??

                "Gagal mengambil detail pickup",

          };

        }

      }

  }
