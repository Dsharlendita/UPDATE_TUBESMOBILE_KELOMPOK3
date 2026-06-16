import 'package:dio/dio.dart';
import '../models/service_model.dart';
import 'api_service.dart';

class ServiceService {

  final Dio dio =
      ApiService().dio;

  /// =========================
  /// GET ALL SERVICES
  /// =========================

  Future<Map<String,dynamic>>
  getServices({

    String? search,
    String? status,

  }) async {

    try{

      final response =
      await dio.get(

        "/owner/services",

        queryParameters:{

          "search":search,
          "status":status,

        },

      );

      final List data =

      response.data["data"]
      ["services"]["data"];

      List<ServiceModel>
      services =

      data.map(

        (e)=>

        ServiceModel.fromJson(e),

      ).toList();

      return{

        "success":true,

        "services":
        services,

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

        "Gagal memuat layanan"

      };

    }

  }

  /// =========================
  /// CREATE SERVICE
  /// =========================

  Future<Map<String,dynamic>>
  createService({

    required String name,
    required String description,
    required double price,
    required int estimatedDays,
    required String icon,

  }) async {

    try{

      final response =
      await dio.post(

        "/owner/services",

        data:{

          "name":name,

          "description":
          description,

          "price_per_kg":
          price,

          "estimated_days":
          estimatedDays,

          "icon":
          icon,

        },

      );

      return{

        "success":true,

        "data":
        response.data,

        "message":
        "Layanan berhasil ditambahkan"

      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response
        ?.data["message"]

        ??

        "Gagal menambahkan layanan"

      };

    }

  }

  /// =========================
  /// UPDATE SERVICE
  /// =========================

  Future<Map<String,dynamic>>
  updateService({

    required int id,
    required String name,
    required String description,
    required double price,
    required int estimatedDays,
    required String icon,

  }) async {

    try{

      final response =
      await dio.put(

        "/owner/services/$id",

        data:{

          "name":name,

          "description":
          description,

          "price_per_kg":
          price,

          "estimated_days":
          estimatedDays,

          "icon":
          icon,

        },

      );

      return{

        "success":true,

        "data":
        response.data,

        "message":
        "Layanan berhasil diperbarui"

      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response
        ?.data["message"]

        ??

        "Gagal memperbarui layanan"

      };

    }

  }

  /// =========================
  /// DETAIL SERVICE
  /// =========================

  Future<Map<String,dynamic>>
  getDetailService(
      int id) async {

    try{

      final response =
      await dio.get(

        "/owner/services/$id",

      );

      return{

        "success":true,

        "service":

        ServiceModel.fromJson(

          response.data["data"],

        )

      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response
        ?.data["message"]

        ??

        "Gagal mengambil detail layanan"

      };

    }

  }

  /// =========================
  /// TOGGLE ACTIVE / NONACTIVE
  /// =========================

  Future<Map<String,dynamic>>
  toggleService(
      int id) async {

    try{

      final response =
      await dio.patch(

        "/owner/services/$id/toggle",

      );

      return{

        "success":true,

        "data":
        response.data,

      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response
        ?.data["message"]

        ??

        "Gagal mengubah status layanan"

      };

    }

  }

  /// =========================
  /// DELETE SERVICE
  /// =========================

  Future<Map<String,dynamic>>
  deleteService(
      int id) async {

    try{

      final response =
      await dio.delete(

        "/owner/services/$id",

      );

      return{

        "success":true,

        "data":
        response.data,

      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response
        ?.data["message"]

        ??

        "Gagal menghapus layanan"

      };

    }

  }

}