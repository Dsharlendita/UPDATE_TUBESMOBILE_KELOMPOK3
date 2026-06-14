import 'package:dio/dio.dart';

import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService {

  final Dio dio =
      ApiService().dio;

  Future<Map<String,dynamic>>
  getNotifications({

    String? type,
    String? status,

  }) async {

    try{

      final response =
      await dio.get(

        "/notifications",

        queryParameters:{

          "type":type,
          "status":status,

        },

      );

      final List data =

      response.data["data"]
      ["notifications"]["data"];

      List<NotificationModel>
      notifications =

      data.map(

        (e)=>

        NotificationModel
        .fromJson(e),

      ).toList();

      return{

        "success":true,

        "notifications":
        notifications,

        "unreadCount":

        response.data["data"]
        ["unread_count"]

      };

    }

    on DioException catch(e){

      return{

        "success":false,

        "message":

        e.response?.data["message"]

            ??

            "Gagal memuat notifikasi"

      };

    }

  }

  Future markAsRead(
      int id) async {

    await dio.patch(
      "/notifications/$id/read",
    );

  }

  Future markAllAsRead()
  async {

    await dio.patch(
      "/notifications/read-all",
    );

  }

  Future deleteNotification(
      int id) async {

    await dio.delete(
      "/notifications/$id",
    );

  }

  Future clearRead()
  async {

    await dio.delete(
      "/notifications/clear-read",
    );

  }

}