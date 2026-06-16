import 'package:dio/dio.dart';
import '../services/api_service.dart';

class CustomerOrderService {
  final Dio dio = ApiService().dio;

  Future<Map<String, dynamic>> getServices() async {
    try {
      final response = await dio.get("/customer/services");

      return {"success": true, "data": response.data["data"]};
    } on DioException catch (e) {
      print("ERROR RESPONSE:");
      print(e.response?.data);

      return {"success": false, "message": "Server Error"};
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required int serviceId,
    required double weight,
    String? notes,
  }) async {
    try {
      print("CREATE ORDER DIPANGGIL");
      print("serviceId = $serviceId");
      print("weight = $weight");
      print("notes = $notes");
      final response = await dio.post(
        "/customer/orders",
        data: {"service_id": serviceId, "weight": weight, "notes": notes},
      );

      return {"success": true, "data": response.data};
    } on DioException catch (e) {
      print("ERROR RESPONSE:");
      print(e.response?.data);

      return {"success": false, "message": "Server Error"};
    }
  }
}
