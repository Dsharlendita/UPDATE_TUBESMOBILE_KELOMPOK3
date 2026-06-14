import 'package:dio/dio.dart';

import '../models/pickup_model.dart';
import '../models/pickup_detail_model.dart';
import '../services/api_service.dart';

class PickupService {
  final Dio dio = ApiService().dio;

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  String _errorMessage(DioException e, String fallback) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return fallback;
  }

  Future<Map<String, dynamic>> getPickups({
    String? status,
    String? type,
    String? search,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final query = <String, dynamic>{};

      if (status != null && status.isNotEmpty) {
        query['status'] = status;
      }

      if (type != null && type.isNotEmpty) {
        query['type'] = type;
      }

      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }

      if (dateFrom != null && dateFrom.isNotEmpty) {
        query['date_from'] = dateFrom;
      }

      if (dateTo != null && dateTo.isNotEmpty) {
        query['date_to'] = dateTo;
      }

      final response = await dio.get('/owner/pickups', queryParameters: query);

      final body = _asMap(response.data);
      final data = _asMap(body['data']);
      final pickupsData = _asMap(data['pickups']);

      final List rawPickups = pickupsData['data'] is List
          ? pickupsData['data'] as List
          : <dynamic>[];

      final pickups = rawPickups
          .map((item) => PickupModel.fromJson(_asMap(item)))
          .toList();

      return {
        'success': true,
        'pickups': pickups,
        'stats': data['stats'] ?? {},
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _errorMessage(e, 'Gagal memuat pickup'),
        'pickups': <PickupModel>[],
        'stats': {},
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat pickup',
        'pickups': <PickupModel>[],
        'stats': {},
      };
    }
  }

  Future<Map<String, dynamic>> acceptPickup(int id) async {
    try {
      final response = await dio.patch('/owner/pickups/$id/accept');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Pickup diterima',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _errorMessage(e, 'Gagal menerima pickup'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal menerima pickup'};
    }
  }

  Future<Map<String, dynamic>> onTheWayPickup(int id) async {
    try {
      final response = await dio.patch('/owner/pickups/$id/on-the-way');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Status berhasil diperbarui',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _errorMessage(e, 'Gagal update status'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal update status'};
    }
  }

  Future<Map<String, dynamic>> completePickup(int id) async {
    try {
      final response = await dio.patch('/owner/pickups/$id/complete');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Pickup selesai',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _errorMessage(e, 'Gagal menyelesaikan pickup'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal menyelesaikan pickup'};
    }
  }

  Future<Map<String, dynamic>> cancelPickup(int id, String reason) async {
    try {
      final response = await dio.patch(
        '/owner/pickups/$id/cancel',
        data: {'cancellation_reason': reason},
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Pickup dibatalkan',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _errorMessage(e, 'Gagal membatalkan pickup'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal membatalkan pickup'};
    }
  }

  Future<Map<String, dynamic>> getPickupDetail(int id) async {
    try {
      final response = await dio.get('/owner/pickups/$id');

      final body = _asMap(response.data);
      final detail = PickupDetailModel.fromJson(_asMap(body['data']));

      return {'success': true, 'data': detail};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _errorMessage(e, 'Gagal mengambil detail pickup'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengambil detail pickup'};
    }
  }
}
