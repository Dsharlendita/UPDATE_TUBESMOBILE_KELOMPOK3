import 'package:dio/dio.dart';

import '../models/report_model.dart';
import '../services/api_service.dart';

class ReportService {

  final Dio dio =
      ApiService().dio;

  Future<Map<String,dynamic>>
  getOverview() async {

    try{

      final response =
      await dio.get(
        "/owner/reports",
      );

      return{

        "success":true,

        "data":

        ReportOverviewModel
            .fromJson(

          response.data["data"],

        ),

      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response
            ?.data["message"]

            ??

            "Gagal memuat laporan"

      };

    }

  }

}