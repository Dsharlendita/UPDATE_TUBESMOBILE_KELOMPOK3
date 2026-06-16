import 'package:dio/dio.dart';
import '../services/api_service.dart';

class DashboardService {

  final Dio dio =
      ApiService().dio;

  Future<Map<String,dynamic>>
      getCustomerDashboard()
  async {

    try {

      final response =
      await dio.get(
        "/customer/dashboard",
      );

      return {

        "success":true,
        "data":response.data,

      };

    } on DioException catch(e){

      return {

        "success":false,

        "message":

        e.response?.data["message"]
        ??
        "Gagal mengambil dashboard"

      };

    }

  }

  Future<Map<String,dynamic>>
      getOwnerDashboard()
  async {

    try{

      final response=
      await dio.get(
        "/owner/dashboard",
      );

      return{

        "success":true,
        "data":response.data

      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response?.data["message"]
        ??
        "Gagal mengambil dashboard"

      };

    }

  }

}