class NotificationModel {

  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;

  final Map<String,dynamic>? data;

  NotificationModel({

    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,

    this.data,

  });

  factory NotificationModel.fromJson(
      Map<String,dynamic> json){

    return NotificationModel(

      id:
      json["id"] ?? 0,

      title:
      json["title"] ?? "",

      message:
      json["message"] ?? "",

      type:
      json["type"] ?? "system",

      isRead:
      json["is_read"] ?? false,

      createdAt:
      json["created_at"] ?? "",

      data:
      json["data"],

    );

  }

}