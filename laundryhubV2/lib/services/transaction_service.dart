import 'package:dio/dio.dart';

import '../models/transaction_model.dart';
import '../models/transaction_service_model.dart';
import 'api_service.dart';

class TransactionService {

  final Dio dio =
      ApiService().dio;

  // =====================================
  // GET TRANSACTIONS
  // =====================================

  Future<Map<String,dynamic>>
      getTransactions({

    String? status,
    String? paymentStatus,
    String? search,
    String? dateFrom,
    String? dateTo,

  }) async {

    try{

      final response =
      await dio.get(

        "/owner/transactions",

        queryParameters:{

          "status":
          status,

          "payment_status":
          paymentStatus,

          "search":
          search,

          "date_from":
          dateFrom,

          "date_to":
          dateTo,

        },

      );

      final List data =

      response.data["data"]
      ["transactions"]["data"];

      List<TransactionModel>
      transactions =

      data.map(

        (e)=>

        TransactionModel
            .fromJson(e),

      ).toList();

      return{

        "success":true,

        "transactions":
        transactions,

        "summary":

        response.data
        ["data"]["summary"]

      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response
        ?.data["message"]

        ??

        "Gagal memuat transaksi"

      };

    }

  }

  // =====================================
  // CREATE DATA
  // =====================================

  Future<Map<String,dynamic>>
  createData() async {

    try {

      final response =
          await dio.get(

        "/owner/transactions/create-data",

      );

      final List servicesData =

          response.data["data"]
              ["services"];

      final List fragrancesData =

          response.data["data"]
              ["fragrances"];

      List<TransactionServiceModel>
          services =

          servicesData.map(

        (e) =>

            TransactionServiceModel
                .fromJson(e),

      ).toList();

      return {

        "success": true,

        "services":
            services,

        "fragrances":
            fragrancesData,

      };

    }

    on DioException catch (e) {

      return {

        "success": false,

        "message":

            e.response
                    ?.data["message"]

                ??

                "Gagal memuat data transaksi",

      };

    }

  }

  Future<Map<String, dynamic>>
  findCustomerByPhone(
    String phone,
  ) async {

    try {

      final response = await dio.get(

        "/owner/customers/find-by-phone",

        queryParameters: {
          "phone": phone,
        },

      );

      print("========== FIND CUSTOMER ==========");
      print(response.data);
      print("===================================");

      return {

        "success":
            response.data["success"],

        "customer":
            response.data["customer"],

      };

    }

    on DioException catch (e) {

      return {

        "success": false,

        "message":

            e.response
                    ?.data["message"]

                ??

                "Customer tidak ditemukan",

      };

    }

  }

  // =====================================
  // STORE TRANSACTION
  // =====================================

  Future<Map<String,dynamic>>
  storeTransaction({

    required String customerName,

    required String customerPhone,

    required String customerEmail,

    required String paymentMethod,

    required String notes,

    required List<Map<String,dynamic>>
        services,

    required List<int>
        fragrances,

  }) async {

    try {

      final List serviceIds =

          services.map((item) {

        return item["service_id"];

      }).toList();

      final List weights =

          services.map((item) {

        return item["weight"];

      }).toList();

      final response =
          await dio.post(

        "/owner/transactions",

        data: {

          "customer_name":
              customerName,

          "customer_phone":
              customerPhone,

          "customer_email":
              customerEmail,

          "payment_method":
              paymentMethod,

          "notes":
              notes,

          "services":
              serviceIds,

          "weights":
              weights,

          "fragrances":
              fragrances,

        },

      );

      return {

        "success": true,

        "message":
            response.data["message"],

        "data":
            response.data["data"],

      };

    }

    on DioException catch (e) {

      return {

        "success": false,

        "message":

            e.response
                    ?.data["message"]

                ??

                "Gagal membuat transaksi",

      };

    }

  }

  // =====================================
  // GET DETAIL TRANSACTION
  // =====================================

  Future<TransactionModel?>
  getTransactionDetail(
    int id,
  ) async {

    try {

      final response = await dio.get(
        "/owner/transactions/$id",
      );

      return TransactionModel.fromJson(
        response.data["data"],
      );

    }

    on DioException {

      return null;

    }

  }

  Future<bool> updateStatus({
    required int id,
    required String status,
  }) async {

    try {

      await dio.patch(
        "/owner/transactions/$id/status",
        data: {
          "status": status,
        },
      );

      return true;

    } catch (_) {

      return false;

    }

  }

  Future<bool> updateWeight({

    required int id,

    required double weight,

  }) async {

    try {

      await dio.patch(

        "/owner/transactions/$id/weight",

        data: {

          "weight": weight,

        },

      );

      return true;

    } catch (_) {

      return false;

    }

  }

  Future<bool> updatePaymentStatus({

    required int id,

    required String status,

  }) async {

    try {

      await dio.patch(

        "/owner/transactions/$id/payment",

        data: {

          "payment_status": status,

        },

      );

      return true;

    }

    on DioException {

      return false;

    }

  }
}
