class TransactionServiceModel {

  final int id;
  final String name;
  final double pricePerKg;

  TransactionServiceModel({

    required this.id,
    required this.name,
    required this.pricePerKg,

  });

  factory TransactionServiceModel.fromJson(
      Map<String,dynamic> json){

    return TransactionServiceModel(

      id:
      json["id"],

      name:
      json["name"] ?? "",

      pricePerKg:
      double.parse(
        "${json["price_per_kg"] ?? 0}",
      ),

    );

  }

}