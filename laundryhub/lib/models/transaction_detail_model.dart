class TransactionDetailModel {

  final int id;

  final String serviceName;

  final double pricePerKg;

  final double weight;

  final double subtotal;

  TransactionDetailModel({

    required this.id,

    required this.serviceName,

    required this.pricePerKg,

    required this.weight,

    required this.subtotal,

  });

  factory TransactionDetailModel.fromJson(
      Map<String,dynamic> json){

    return TransactionDetailModel(

      id: json["id"],

      serviceName:
      json["service_name"] ?? "",

      pricePerKg:
      double.tryParse(
          "${json["price_per_kg"] ?? 0}"
      ) ?? 0,

      weight:
      double.tryParse(
          "${json["weight"] ?? 0}"
      ) ?? 0,

      subtotal:
      double.tryParse(
          "${json["subtotal"] ?? 0}"
      ) ?? 0,

    );

  }

}