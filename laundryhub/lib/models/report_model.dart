class ReportOverviewModel {

  final int todayTransactions;
  final double todayRevenue;

  final int monthTransactions;
  final double monthRevenue;

  final int totalCustomers;
  final double avgTransaction;

  ReportOverviewModel({

    required this.todayTransactions,
    required this.todayRevenue,

    required this.monthTransactions,
    required this.monthRevenue,

    required this.totalCustomers,
    required this.avgTransaction,

  });

  factory ReportOverviewModel.fromJson(
      Map<String,dynamic> json){

    return ReportOverviewModel(

      todayTransactions:
      json["today_transactions"] ?? 0,

      todayRevenue:
      double.parse(
        "${json["today_revenue"] ?? 0}",
      ),

      monthTransactions:
      json["month_transactions"] ?? 0,

      monthRevenue:
      double.parse(
        "${json["month_revenue"] ?? 0}",
      ),

      totalCustomers:
      json["total_customers"] ?? 0,

      avgTransaction:
      double.parse(
        "${json["avg_transaction"] ?? 0}",
      ),

    );

  }

}