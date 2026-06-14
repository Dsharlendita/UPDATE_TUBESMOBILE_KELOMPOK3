class CustomerModel {

  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;

  final int transactionCount;
  final double totalSpent;
  final int pendingPickups;
  final bool isGuest;

  CustomerModel({

    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,

    required this.transactionCount,
    required this.totalSpent,
    required this.pendingPickups,
    required this.isGuest,

  });

  factory CustomerModel.fromJson(
      Map<String,dynamic> json){

    return CustomerModel(

      id: "${json["id"]}",

      name:
      json["name"] ?? "",

      email:
      json["email"] ?? "",

      phone:
      json["phone"] ?? "",

      address:
      json["address"] ?? "",

      transactionCount:
      json["transaction_count"] ?? 0,

      totalSpent:
      double.parse(
          "${json["total_spent"] ?? 0}"
      ),

      pendingPickups:
      json["pending_pickups"] ?? 0,

      isGuest:
      json["is_guest"] ?? false,

    );

  }

}