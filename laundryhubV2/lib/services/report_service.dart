import 'package:dio/dio.dart';
import '../models/report_model.dart';
import 'api_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ReportService {
  final Dio dio = ApiService().dio;

  // 1. Mengambil data Overview (Halaman Utama)
  Future<Map<String, dynamic>> getOverview() async {
    try {
      final response = await dio.get("/owner/reports");
      return {
        "success": true,
        "data": ReportOverviewModel.fromJson(response.data["data"]),
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response?.data["message"] ?? "Gagal memuat laporan"
      };
    }
  }

  // 2. Mengambil data Laporan Transaksi
  Future<Map<String, dynamic>> getTransactions() async {
    try {
      final response = await dio.get("/owner/reports/transactions");
      return {
        "success": true,
        // Mengembalikan raw data JSON karena kita belum buat TransactionModel
        "data": response.data["data"], 
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response?.data["message"] ?? "Gagal memuat transaksi"
      };
    }
  }

  // 3. Mengambil data Laporan Pendapatan (Grafik)
  Future<Map<String, dynamic>> getRevenue({int? year}) async {
    try {
      // Jika tahun dipilih, kirim sebagai parameter. Jika tidak, ambil tahun ini.
      year ??= DateTime.now().year;
      final response = await dio.get("/owner/reports/revenue?year=$year");
      return {
        "success": true,
        "data": response.data["data"],
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response?.data["message"] ?? "Gagal memuat grafik pendapatan"
      };
    }
  }

  // 4. Mengambil data Laporan Layanan
  Future<Map<String, dynamic>> getServices() async {
    try {
      final response = await dio.get("/owner/reports/services");
      return {
        "success": true,
        "data": List<Map<String, dynamic>>.from(response.data["data"]),
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response?.data["message"] ?? "Gagal memuat laporan layanan"
      };
    }
  }
  // --- 5. Fungsi Download dan Simpan PDF ---
  Future<Map<String, dynamic>> downloadPdf(
    String type, {
    int? year,
  }) async {
    try {

      String url =
          "/owner/reports/export/$type";

      if (type == 'revenue' &&
          year != null) {
        url += "?year=$year";
      }

      final Directory dir =
          await getApplicationDocumentsDirectory();

      final String savePath =
          '${dir.path}/laporan_${type}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final response =
          await dio.download(
        url,
        savePath,
        options: Options(
          responseType:
              ResponseType.bytes,
        ),
      );

      print(
          "STATUS: ${response.statusCode}");
      print("FILE: $savePath");

      final file = File(savePath);

      print(
          "EXISTS: ${await file.exists()}");
      print(
          "SIZE: ${await file.length()}");

      return {
        "success": true,
        "path": savePath,
      };
    } catch (e, s) {

      print(
          "========== PDF ERROR ==========");
      print(e);
      print(s);
      print(
          "================================");

      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
}