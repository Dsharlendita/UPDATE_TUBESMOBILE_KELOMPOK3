import 'package:dio/dio.dart';

import '../models/profile_model.dart';
import '../services/api_service.dart';

class ProfileService {

  final Dio dio =
      ApiService().dio;

  Future<Map<String,dynamic>>
  getProfile() async {

    try{

      final response =
      await dio.get(
        "/owner/profile",
      );

      return{

        "success":true,

        "data":
        ProfileModel.fromJson(
          response.data["data"],
        ),

      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response?.data["message"]

            ??

            "Gagal memuat profil"

      };

    }

  }

  Future<Map<String,dynamic>>
  updateProfile({

    required String name,
    required String phone,

    required String laundryName,
    required String laundryAddress,

    required String laundryPhone,
    required String laundryEmail,

    required String description,

    required double latitude,
    required double longitude,

    required double radiusKm,

  }) async {

    try{

      await dio.put(

        "/owner/profile",

        data:{

          "name":name,
          "phone":phone,

          "laundry_name":
          laundryName,

          "laundry_address":
          laundryAddress,

          "laundry_phone":
          laundryPhone,

          "laundry_email":
          laundryEmail,

          "laundry_description":
          description,

          "latitude":
          latitude,

          "longitude":
          longitude,

          "radius_km":
          radiusKm,

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

            "Gagal update profil"

      };

    }

  }

  Future<Map<String,dynamic>>
  updateOperational({

    required String openingTime,
    required String closingTime,

    required List<String>
    operatingDays,

  }) async {

    try{

      await dio.patch(

        "/owner/profile/operational",

        data:{

          "opening_time":
          openingTime,

          "closing_time":
          closingTime,

          "operating_days":
          operatingDays,

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

            "Gagal update jam operasional"

      };

    }

  }

}