class PickupModel {
  final int id;
  final String customerName;
  final String phone;
  final String address;
  final String status;
  final String type;
  final String pickupDate;
  final String paymentMethod;
  final String settlementMethod;
  final String? invoice;

  PickupModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.status,
    required this.type,
    required this.pickupDate,
    required this.paymentMethod,
    required this.settlementMethod,
    this.invoice,
  });

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  factory PickupModel.fromJson(Map<String, dynamic> json) {
    final customer = _asMap(json['customer']);
    final transaction = _asMap(json['transaction']);

    return PickupModel(
      id: _toInt(json['id']),
      customerName: customer['name']?.toString() ?? '-',
      phone: customer['phone']?.toString() ?? json['phone']?.toString() ?? '-',
      address:
          json['pickup_address']?.toString() ??
          json['address']?.toString() ??
          json['full_address']?.toString() ??
          '-',
      status: json['status']?.toString() ?? '',
      type: json['type']?.toString() ?? 'pickup',
      pickupDate:
          json['pickup_date']?.toString() ??
          json['delivery_date']?.toString() ??
          '',
      paymentMethod: json['payment_method']?.toString() ?? '-',
      settlementMethod: transaction['payment_method']?.toString() ?? '-',
      invoice:
          transaction['invoice_number']?.toString() ??
          transaction['invoice']?.toString(),
    );
  }
}
