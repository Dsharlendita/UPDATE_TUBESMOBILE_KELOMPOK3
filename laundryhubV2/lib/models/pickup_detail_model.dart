class PickupDetailModel {

  final Map<String,dynamic> pickup;

  final Map<String,dynamic>? transaction;

  final int displayNumber;

  final bool isDelivery;

  final List services;

  final List fragrances;

  PickupDetailModel({

    required this.pickup,
    required this.transaction,
    required this.displayNumber,
    required this.isDelivery,
    required this.services,
    required this.fragrances,

  });

  factory PickupDetailModel.fromJson(
    Map<String,dynamic> json,
  ){

    final pickup =
        json["pickup"] ?? {};

    return PickupDetailModel(

      pickup: pickup,

      transaction:
          json["transaction"],

      displayNumber:
          json["display_number"] ?? 0,

      isDelivery:
          json["is_delivery"] ?? false,

      services:
          pickup["selected_services"] ?? [],

      fragrances:
          pickup["selected_fragrances"] ?? [],

    );

  }

}