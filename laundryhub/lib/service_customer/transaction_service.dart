import 'package:dio/dio.dart';

import '../models/transaction_model.dart';
import '../models/transaction_service_model.dart';
import '../services/api_service.dart';

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

    try{

      final response =
      await dio.get(
        "/owner/transactions/create",
      );

      final List servicesData =

      response.data["data"]
      ["services"];

      List<TransactionServiceModel>
      services =

      servicesData.map(

        (e)=>

        TransactionServiceModel
            .fromJson(e),

      ).toList();

      return{

        "success":true,

        "services":
        services,

      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response
        ?.data["message"]

        ??

        "Gagal memuat data transaksi"

      };

    }

  }

  // =====================================
  // STORE TRANSACTION
  // =====================================

  Future<Map<String,dynamic>>
      storeTransaction({

    required String
    customerName,

    required String
    customerPhone,

    required String
    customerEmail,

    required String
    paymentMethod,

    required String
    notes,

    required List<Map<String,dynamic>>
    services,

  }) async {

    try{

      final response =
      await dio.post(

        "/owner/transactions",

        data:{

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
          services,

        },

      );

      return{

        "success":true,

        "message":

        response.data["message"]

      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response
        ?.data["message"]

        ??

        "Gagal membuat transaksi"

      };

    }

  }

}