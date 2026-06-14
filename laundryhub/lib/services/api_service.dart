import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl =
    'https://laundryhub.my.id/api';

  late Dio dio;

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final String? token = await storage.read(key: 'token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print('\n========== REQUEST ==========');
          print('URL: ${options.uri}');
          print('METHOD: ${options.method}');
          print('BODY: ${options.data}');
          print('HEADERS: ${options.headers}');
          print('=============================\n');

          handler.next(options);
        },
        onResponse: (response, handler) {
          print('\n========== RESPONSE ==========');
          print(response.data);
          print('==============================\n');

          handler.next(response);
        },
        onError: (DioException e, handler) {
          print('\n========== ERROR ==========');
          print('MESSAGE: ${e.message}');
          print('STATUS: ${e.response?.statusCode}');
          print('DATA: ${e.response?.data}');
          print('===========================\n');

          handler.next(e);
        },
      ),
    );
  }

  String getErrorMessage(dynamic error) {
    if (error is DioException) {
      final dynamic data = error.response?.data;

      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      if (data is Map && data['errors'] is Map) {
        final Map errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final dynamic firstValue = errors.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            return firstValue.first.toString();
          }
          return firstValue.toString();
        }
      }

      return error.message ?? 'Terjadi kesalahan koneksi';
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List) {
      return value;
    }

    return <dynamic>[];
  }

  void _throwIfFailed(Map<String, dynamic> body) {
    if (body['success'] == false) {
      throw Exception(body['message']?.toString() ?? 'Request gagal');
    }
  }

  Future<Map<String, dynamic>> getCustomerTransactionDetail(
    dynamic transactionId,
  ) async {
    final Response response = await dio.get(
      '/customer/transactions/$transactionId',
    );

    final Map<String, dynamic> body = _asMap(response.data);
    _throwIfFailed(body);

    return _asMap(body['data']);
  }

  Future<List<dynamic>> getTransactionDeliveryAddresses(
    dynamic transactionId,
  ) async {
    final Response response = await dio.get(
      '/customer/transactions/$transactionId/delivery-form',
    );

    final Map<String, dynamic> body = _asMap(response.data);
    _throwIfFailed(body);

    final Map<String, dynamic> data = _asMap(body['data']);
    return _asList(body['addresses'] ?? data['addresses']);
  }

  Future<Map<String, dynamic>> storeTransactionDelivery({
    required dynamic transactionId,
    required dynamic addressId,
    required String deliveryDate,
    required String deliveryTime,
    String? notes,
  }) async {
    final Response response = await dio.post(
      '/customer/transactions/$transactionId/delivery',
      data: {
        'address_id': addressId,
        'delivery_date': deliveryDate,
        'delivery_time': deliveryTime,
        'notes': notes,
      },
    );

    final Map<String, dynamic> body = _asMap(response.data);
    _throwIfFailed(body);

    return body;
  }
}
