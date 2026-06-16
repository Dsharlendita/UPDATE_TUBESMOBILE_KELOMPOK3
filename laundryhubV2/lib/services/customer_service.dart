import 'package:dio/dio.dart';

import '../models/customer_model.dart';
import 'api_service.dart';

class CustomerService {

  final Dio dio =
      ApiService().dio;

  Future<Map<String,dynamic>>
      getCustomers({

    String? search,
    String? sort,
    String? order,

  }) async {

    try{

      final response =
      await dio.get(

        "/owner/customers",

        queryParameters:{

          "search":search,
          "sort":sort,
          "order":order,

        },

      );

      final List data =
      response.data["data"]
      ["customers"]["data"];

      List<CustomerModel>
      customers =

      data.map(

        (e)=>

        CustomerModel.fromJson(e),

      ).toList();

      return{
        "success":true,

        "owner":
        response.data["data"]["owner"],

        "customers":
        customers,

        "stats":
        response.data["data"]["stats"]
      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response
        ?.data["message"]

            ??

            "Gagal memuat pelanggan"

      };

    }

  }

  Future<Map<String, dynamic>> getCustomerDetail(
    int customerId,
  ) async {
    try {
      final response = await dio
      .get(
        "/owner/customers/$customerId",
      )
      .timeout(
        const Duration(seconds: 10),
      );

      return {
        "success": true,
        "data": response.data["data"],
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "message":
            e.response?.data["message"] ??
                "Gagal mengambil detail customer",
      };
    }
  }

}