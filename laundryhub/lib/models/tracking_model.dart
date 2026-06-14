import 'transaction_detail_model.dart';
import 'transaction_fragrance_model.dart';

class TrackingModel {

  final String invoice;
  final String customerName;
  final String customerPhone;

  final String status;
  final String paymentStatus;

  final String trackingCode;

  final String estimatedCompletion;
  final String createdAt;

  final double totalWeight;
  final double totalPrice;

  final String notes;

  final String laundryName;
  final String laundryAddress;

  final List<TransactionDetailModel> details;
  final List<TransactionFragranceModel> fragrances;

  final int progressPercentage;
  final int currentStatusIndex;

  final String laundryPhone;

  final bool isPickup;
  final bool isDelivery;

  final List<String> timeline;

  final int currentTimelineIndex;

  TrackingModel({

    required this.invoice,
    required this.customerName,
    required this.customerPhone,

    required this.status,
    required this.paymentStatus,

    required this.trackingCode,

    required this.estimatedCompletion,
    required this.createdAt,

    required this.totalWeight,
    required this.totalPrice,

    required this.notes,

    required this.laundryName,
    required this.laundryAddress,

    required this.details,
    required this.fragrances,

    required this.progressPercentage,
    required this.currentStatusIndex,

    required this.laundryPhone,
    required this.isPickup,
    required this.isDelivery, 

    required this.timeline,

    required this.currentTimelineIndex,

  });

}