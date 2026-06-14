class CustomerDetailModel {
  final dynamic customer;
  final List transactions;
  final List pickups;
  final Map<String, dynamic> stats;

  CustomerDetailModel({
    required this.customer,
    required this.transactions,
    required this.pickups,
    required this.stats,
  });

  factory CustomerDetailModel.fromJson(
      Map<String, dynamic> json) {
    return CustomerDetailModel(
      customer: json["customer"],
      transactions: json["transactions"]["data"] ?? [],
      pickups: json["pickups"] ?? [],
      stats: json["stats"] ?? {},
    );
  }
}