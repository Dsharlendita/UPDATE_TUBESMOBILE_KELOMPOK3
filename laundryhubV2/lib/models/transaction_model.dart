import 'transaction_detail_model.dart';
import 'transaction_fragrance_model.dart';

class TransactionModel {

  final int id;
  final String invoice;
  final String customerName;
  final String customerPhone;
  final double total;
  final double weight;
  final String status;
  final String paymentStatus;
  final String trackingCode;
  final String notes;
  final String createdAt;
  final String? estimatedCompletion;
  final String paymentMethod;
  final String initialPaymentMethod;
  final List<TransactionDetailModel> details;
  final List<TransactionFragranceModel> fragrances;
  final int progressPercentage;
  final String trackingUrl;
  final String formattedDate;

  TransactionModel({

    required this.id,
    required this.invoice,
    required this.customerName,
    required this.customerPhone,
    required this.total,
    required this.weight,
    required this.status,
    required this.paymentStatus,
    required this.trackingCode,
    required this.notes,
    required this.createdAt,
    required this.estimatedCompletion,
    required this.paymentMethod,
    required this.initialPaymentMethod,
    required this.details,
    required this.fragrances,

    required this.progressPercentage,
    required this.trackingUrl,
    required this.formattedDate,


  });

  factory TransactionModel.fromJson(
      Map<String,dynamic> json){

    return TransactionModel(

      id: json["id"],

      invoice:
      json["invoice_number"] ?? "",

      customerName:
      json["customer_name"] ?? "",

      customerPhone:
      json["customer_phone"] ?? "",

      total:
      double.tryParse(
        "${json["final_price"] ?? 0}",
      ) ?? 0,

      weight:
      double.tryParse(
        "${json["total_weight"] ?? 0}",
      ) ?? 0,

      status:
      json["status"] ?? "",

      paymentStatus:
      json["payment_status"] ?? "",

      trackingCode:
      json["tracking_code"] ?? "",

      notes:
      json["notes"] ?? "",

      createdAt:
      json["created_at"] ?? "",

      estimatedCompletion:
      json["estimated_completion"],

      paymentMethod:
      json["payment_method"] ?? "",

      initialPaymentMethod:
      json["initial_payment_method"] ?? "",

      details:
      (json["details"] as List?)
      ?.map(
        (e)=>
        TransactionDetailModel.fromJson(e),
      )
      .toList()

      ??

      [],

      fragrances:

      (json["fragrances"] as List?)

      ?.map(

        (e)=>

        TransactionFragranceModel.fromJson(e),

      )

      .toList()

      ??

      [],

      progressPercentage:
      json["progress_percentage"] ?? 0,

      trackingUrl:
      json["tracking_url"] ?? "",

      formattedDate:
      json["formatted_date"] ?? "",

    );

  }

}