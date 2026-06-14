import 'package:dio/dio.dart';
import '../services/api_service.dart';

class CustomerTransactionService {
  final Dio dio = ApiService().dio;

  // =========================
  // LIST TRANSAKSI
  // =========================
  Future<Map<String, dynamic>> getTransactions() async {
    try {
      final response = await dio.get("/customer/transactions");

      print("========== TRANSACTION RESPONSE ==========");
      print(response.data);
      print("=========================================");

      return {"success": true, "data": response.data};
    } on DioException catch (e) {
      print("========== TRANSACTION ERROR ==========");
      print(e.response?.data);
      print("======================================");

      return {
        "success": false,
        "message": e.response?.data["message"] ?? "Gagal mengambil transaksi",
      };
    }
  }

  // =========================
  // DETAIL TRANSAKSI
  // =========================
  Future<Map<String, dynamic>> getTransactionDetail(int id) async {
    try {
      final response = await dio.get("/customer/transactions/$id");

      print("========== DETAIL RESPONSE ==========");
      print(response.data);
      print("====================================");

      return {"success": true, "data": response.data};
    } on DioException catch (e) {
      print("========== DETAIL ERROR ==========");
      print(e.response?.data);
      print("==================================");

      return {
        "success": false,
        "message":
            e.response?.data["message"] ?? "Gagal mengambil detail transaksi",
      };
    }
  }
}
