import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_service.dart';

class AuthService {

  final Dio _dio =
      ApiService().dio;

  final FlutterSecureStorage
  _storage =
      const FlutterSecureStorage();

  // ================= LOGIN =================

  Future<Map<String, dynamic>>
      login({

    required String email,
    required String password,

  }) async {

    try {

      final response =
          await _dio.post(

        '/login',

        data: {

          'email': email.trim(),

          'password': password,

        },
      );

      final data =
          response.data;

      print("========== LOGIN RESPONSE ==========");
      print(response.data);
      print("TOKEN = ${data['token']}");
      print("===================================");

      await _storage.write(
        key: 'token',
        value: data['token'],
      );

      // simpan token

      await _storage.write(

        key: 'token',

        value:
            data['token'],

      );

      // simpan user

      await _storage.write(

        key: 'user',

        value: jsonEncode(
          data['user'],
        ),

      );

      return {

        'success': true,

        'message':
            data['message'],

        'data':
            data,

      };

    }
    on DioException catch(e){

      return {

        'success': false,

        'message':
            e.response
                    ?.data?['message']
                ??
            'Login gagal',

      };

    }
    catch(e){

      return {

        'success': false,

        'message':
            'Terjadi kesalahan',

      };

    }

  }

  // ================= REGISTER =================

  Future<Map<String, dynamic>> register({

    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String role,
    required bool terms,
    // OWNER
    String? laundryName,
    String? laundryAddress,
    String? laundryPhone,
    String? laundryEmail,
    String? laundryDescription,

  }) async {

    try {

      final response = await _dio.post(

        '/register',

        data: {

          'name': name.trim(),

          'email': email.trim(),

          'phone': _formatPhone(phone),

          'password':
              password,

          'password_confirmation':
              passwordConfirmation,

          'role': role,

          'terms': terms,

          // owner only
          'laundry_name':
              laundryName?.trim(),

          'laundry_address':
              laundryAddress?.trim(),

          'laundry_phone':
            laundryPhone != null
                ? _formatPhone(laundryPhone)
                : null,

          'laundry_email':
              laundryEmail?.trim(),

          'laundry_description':
              laundryDescription?.trim(),

        },

      );

      return {

        'success': true,

        'message':
            response.data['message'],

        'data':
            response.data,

      };

    }

    on DioException catch (e) {

    String message =
        e.response?.data?['message']
        ?? 'Registrasi gagal';

    final errors =
        e.response?.data?['errors'];

    if (errors != null &&
        errors is Map<String, dynamic>) {

      message = errors.values
          .expand(
            (item) => List<String>.from(item),
          )
          .join('\n');
    }

    return {

      'success': false,

      'message': message,

      'errors': errors,

    };
  }

    catch (e) {

      return {

        'success': false,

        'message':
            'Terjadi kesalahan'

      };

    }

  }

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '/forgot-password',
        data: {
          'email': email,
        },
      );

      return {
        'success': true,
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data?['message']
            ?? 'Gagal mengirim email reset',
      };
    }
  }

  String _formatPhone(String phone) {
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.startsWith('0')) {
      return '62${phone.substring(1)}';
    }

    if (!phone.startsWith('62')) {
      return '62$phone';
    }

    return phone;
  }

  // ================= LOGOUT =================

  Future<void>
      logout() async {

    await _storage
        .deleteAll();

  }

  // ================= GET TOKEN =================

  Future<String?>
      getToken() async {

    return await _storage.read(
      key:'token',
    );

  }

  // ================= GET USER =================

  Future<Map<String,dynamic>?>
      getUser() async {

    final user=

        await _storage.read(
          key:'user',
        );

    if(user==null){

      return null;

    }

    return jsonDecode(
      user,
    );

  }

  // ================= CHECK LOGIN =================

  Future<bool>
      isLoggedIn() async {

    final token=

        await _storage.read(
          key:'token',
        );

    return token!=null;

  }

}