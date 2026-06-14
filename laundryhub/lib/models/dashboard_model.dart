class DashboardModel {
  final LaundryModel laundry;
  final StatsModel stats;
  final List<TransactionModel> recentTransactions;
  final List<PickupModel> recentPickups;
  final List<NotificationModel> notifications;

  DashboardModel({
    required this.laundry,
    required this.stats,
    required this.recentTransactions,
    required this.recentPickups,
    required this.notifications,
  });

  factory DashboardModel.fromJson(
      Map<String, dynamic> json) {

    return DashboardModel(
      laundry: LaundryModel.fromJson(
        json["laundry"] ?? {},
      ),

      stats: StatsModel.fromJson(
        json["stats"] ?? {},
      ),

      recentTransactions:
      (json["recent_transactions"] as List? ?? [])
          .map(
            (e) =>
            TransactionModel.fromJson(e),
      )
          .toList(),

      recentPickups:
      (json["recent_pickups"] as List? ?? [])
          .map(
            (e) =>
            PickupModel.fromJson(e),
      )
          .toList(),

      notifications:
      (json["notifications"] as List? ?? [])
          .map(
            (e)=>
            NotificationModel.fromJson(e),
      )
          .toList(),
    );
  }
}






class LaundryModel {

  final int id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String logoUrl;
  final String ownerName;
  final String openingTime;
  final String closingTime;
  final bool isOpen;

  LaundryModel({

    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.logoUrl,
    required this.ownerName,
    required this.openingTime,
    required this.closingTime,
    required this.isOpen,

  });

  factory LaundryModel.fromJson(
      Map<String,dynamic> json){

    return LaundryModel(

      id:
      json["id"] ?? 0,

      name:
      json["name"] ?? "Laundry",

      address:
      json["address"] ?? "-",

      phone:
      json["phone"] ?? "-",

      email:
      json["email"] ?? "",

      logoUrl:
      json["logo_url"] ?? "",

      ownerName:
      json["owner"]?["name"] ??
          json["owner_name"] ??
          "-",

      openingTime:
      json["formatted_opening_time"] ??
          "08:00",

      closingTime:
      json["formatted_closing_time"] ??
          "20:00",

      isOpen:
      json["is_open"] ?? false,
    );
  }
}






class StatsModel {

  final int totalTransactions;

  final int processing;

  final int completed;

  final int pendingPickups;

  final int services;

  final double todayIncome;

  StatsModel({

    required this.totalTransactions,

    required this.processing,

    required this.completed,

    required this.pendingPickups,

    required this.services,

    required this.todayIncome,

  });

  factory StatsModel.fromJson(
      Map<String,dynamic> json){

    return StatsModel(

      totalTransactions:

      json["total_transactions"]
          ?? 0,

      processing:
      json["processing"]
          ?? 0,

      completed:
      json["completed"]
          ?? 0,

      pendingPickups:
      json["pending_pickups"]
          ?? 0,

      services:
      json["services"]
          ?? 0,

      todayIncome:

      double.tryParse(
          json["today_income"]
              .toString()
      ) ??
          0,

    );
  }
}






class TransactionModel {

  final int id;
  final String invoice;
  final String customerName;
  final String status;
  final double total;

  TransactionModel({

    required this.id,
    required this.invoice,
    required this.customerName,
    required this.status,
    required this.total,

  });

  factory TransactionModel.fromJson(
      Map<String,dynamic> json){

    return TransactionModel(

      id:
      json["id"] ?? 0,

      invoice:
      json["invoice_number"]
          ?? "",

      customerName:
      json["customer"]?["name"]
          ?? "-",

      status:
      json["status"]
          ?? "",

      total:

      double.tryParse(
          json["final_price"]
              .toString()
      ) ??
          0,

    );
  }
}






class PickupModel {

  final int id;

  final String customerName;

  final String status;

  PickupModel({

    required this.id,

    required this.customerName,

    required this.status,

  });

  factory PickupModel.fromJson(
      Map<String,dynamic> json){

    return PickupModel(

      id:
      json["id"] ?? 0,

      customerName:
      json["customer"]?["name"]
          ?? "-",

      status:
      json["status"]
          ?? "",

    );
  }
}






class NotificationModel {

  final int id;

  final String title;

  final String message;

  NotificationModel({

    required this.id,

    required this.title,

    required this.message,

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

    );
  }
}