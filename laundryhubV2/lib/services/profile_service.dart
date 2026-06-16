import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart'; // Diperlukan untuk membaca tipe data PlatformFile
import '../models/profile_model.dart';
import '../../services/api_service.dart';

class ProfileService {
  final Dio dio = ApiService().dio;

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await dio.get("/owner/profile");
      return {
        "success": true,
        "data": ProfileModel.fromJson(response.data["data"]),
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response?.data["message"] ?? "Gagal memuat profil"
      };
    }
  }

  // UPDATE: Sekarang mendukung upload file avatar & logo dengan aman (Cross-platform Mobile/Web)
  Future<Map<String, dynamic>> updateProfile({
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
    PlatformFile? avatarFile, // Tambahkan parameter file avatar
    PlatformFile? logoFile,   // Tambahkan parameter file logo
  }) async {
    try {
      // 1. Definisikan field text biasa
      Map<String, dynamic> dataMap = {
        "_method": "PUT", // Trik Method Tunneling agar file gambar terbaca di rute PUT Laravel
        "name": name,
        "phone": phone,
        "laundry_name": laundryName,
        "laundry_address": laundryAddress,
        "laundry_phone": laundryPhone,
        "laundry_email": laundryEmail,
        "laundry_description": description,
        "latitude": latitude,
        "longitude": longitude,
        "radius_km": radiusKm,
      };

      // 2. Olah file avatar jika dipilih pengguna
      if (avatarFile != null) {
        if (avatarFile.path != null) {
          // Jalur untuk Mobile/Desktop app
          dataMap["avatar"] = await MultipartFile.fromFile(
            avatarFile.path!,
            filename: avatarFile.name,
          );
        } else if (avatarFile.bytes != null) {
          // Jalur alternatif jika dijalankan di Flutter Web
          dataMap["avatar"] = MultipartFile.fromBytes(
            avatarFile.bytes!,
            filename: avatarFile.name,
          );
        }
      }

      // 3. Olah file logo jika dipilih pengguna
      if (logoFile != null) {
        if (logoFile.path != null) {
          dataMap["logo"] = await MultipartFile.fromFile(
            logoFile.path!,
            filename: logoFile.name,
          );
        } else if (logoFile.bytes != null) {
          dataMap["logo"] = MultipartFile.fromBytes(
            logoFile.bytes!,
            filename: logoFile.name,
          );
        }
      }

      // 4. Bungkus ke dalam FormData
      FormData formData = FormData.fromMap(dataMap);

      // 5. Tembak menggunakan POST (karena membawa file Multipart) menuju rute profil
      final response = await dio.post("/owner/profile", data: formData);

      return {
        "success": true,
        "message": response.data["message"] ?? "Profil berhasil diperbarui",
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response?.data["message"] ?? "Gagal update profil"
      };
    }
  }

  Future<Map<String, dynamic>> updateOperational({
    required String openingTime,
    required String closingTime,
    required List<String> operatingDays,
  }) async {
    try {
      await dio.patch(
        "/owner/profile/operational",
        data: {
          "opening_time": openingTime,
          "closing_time": closingTime,
          "operating_days": operatingDays,
        },
      );
      return {"success": true};
    } on DioException catch (e) {
      return {
        "success": false,
        "message": e.response?.data["message"] ?? "Gagal update jam operasional"
      };
    }
  }
}