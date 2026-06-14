class ServiceModel {

  final int id;

  final String name;

  final String description;

  final double pricePerKg;

  final int estimatedDays;

  final bool isActive;

  final String icon;

  ServiceModel({

    required this.id,

    required this.name,

    required this.description,

    required this.pricePerKg,

    required this.estimatedDays,

    required this.isActive,

    required this.icon,

  });

  factory ServiceModel.fromJson(
      Map<String,dynamic> json){

    return ServiceModel(

      id:
      json["id"],

      name:
      json["name"] ?? "",

      description:
      json["description"] ?? "",

      pricePerKg:
      double.tryParse(

        "${json["price_per_kg"] ?? 0}"

      ) ?? 0,

      estimatedDays:
      json["estimated_days"] ?? 0,

      isActive:
      json["is_active"] == true,

      icon:
      json["icon"] ?? "shirt",

    );
  
  }

}