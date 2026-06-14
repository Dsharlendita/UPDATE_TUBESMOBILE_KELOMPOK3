import 'package:dio/dio.dart';

import '../models/fragrance_model.dart';
import '../services/api_service.dart';

class FragranceService {

  final Dio dio =
      ApiService().dio;

  Future<Map<String,dynamic>>
      getFragrances() async {

    try{

      final response =
      await dio.get(
        "/owner/fragrances",
      );

      final List data =
      response.data["data"]["data"];

      List<FragranceModel>
      fragrances =

      data.map(

        (e)=>
        FragranceModel.fromJson(e),

      ).toList();

      return{

        "success":true,
        "fragrances":fragrances,

      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response?.data["message"]

            ??

            "Gagal memuat pewangi"

      };

    }

  }

  Future<Map<String,dynamic>>
      createFragrance({

    required String name,
    required String color,

  }) async {

    try{

      await dio.post(

        "/owner/fragrances",

        data:{

          "name":name,
          "color":color,

        },

      );

      return{
        "success":true,
      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response?.data["message"]

            ??

            "Gagal menambah pewangi"

      };

    }

  }

  Future<Map<String,dynamic>>
      updateFragrance({

    required int id,
    required String name,
    required String color,

  }) async {

    try{

      await dio.put(

        "/owner/fragrances/$id",

        data:{

          "name":name,
          "color":color,

        },

      );

      return{
        "success":true,
      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response?.data["message"]

            ??

            "Gagal update pewangi"

      };

    }

  }

  Future toggleFragrance(
      int id) async {

    await dio.patch(
      "/owner/fragrances/$id/toggle",
    );

  }

  Future deleteFragrance(
      int id) async {

    await dio.delete(
      "/owner/fragrances/$id",
    );

  }

}