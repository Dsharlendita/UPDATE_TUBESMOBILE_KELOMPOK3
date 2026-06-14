import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../service_customer/customer_transaction_service.dart';
import 'customer_transaction_detail_screen.dart';

class CustomerTransactionScreen extends StatefulWidget {
  final String? statusFilter;

  const CustomerTransactionScreen({super.key, this.statusFilter});

  @override
  State<CustomerTransactionScreen> createState() =>
      _CustomerTransactionScreenState();
}

class _CustomerTransactionScreenState extends State<CustomerTransactionScreen> {
  bool loading = true;
  List<dynamic> transactions = [];
  String? error;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await CustomerTransactionService().getTransactions();

      if (!mounted) {
        return;
      }

      if (result['success'] == true) {
        final allTransactions = extractTransactions(result);

        setState(() {
          transactions = applyStatusFilter(allTransactions);
          loading = false;
        });
      } else {
        setState(() {
          error = result['message'] ?? 'Gagal mengambil transaksi';
          loading = false;
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        error = 'Terjadi kesalahan saat mengambil transaksi';
        loading = false;
      });
    }
  }

  List<dynamic> extractTransactions(Map<String, dynamic> result) {
    final responseData = result['data'];

    if (responseData is List) {
      return responseData;
    }

    if (responseData is Map<String, dynamic>) {
      if (responseData['data'] is List) {
        return List<dynamic>.from(responseData['data']);
      }

      if (responseData['data'] is Map<String, dynamic> &&
          responseData['data']['data'] is List) {
        return List<dynamic>.from(responseData['data']['data']);
      }

      if (responseData['transactions'] is List) {
        return List<dynamic>.from(responseData['transactions']);
      }
    }

    return [];
  }

  List<dynamic> applyStatusFilter(List<dynamic> allTransactions) {
    if (widget.statusFilter == null) {
      return allTransactions;
    }

    return allTransactions.where((transaction) {
      final status = transaction['status']?.toString() ?? '';

      if (widget.statusFilter == 'active') {
        return [
          'pending',
          'confirmed',
          'washing',
          'drying',
          'ironing',
          'ready',
        ].contains(status);
      }

      if (widget.statusFilter == 'pickup') {
        return status == 'pending_pickup';
      }

      if (widget.statusFilter == 'completed') {
        return status == 'completed';
      }

      return true;
    }).toList();
  }

  Map<String, dynamic> extractTransactionDetail(
    Map<String, dynamic> result,
    Map<String, dynamic> fallbackTransaction,
  ) {
    final responseData = result['data'];

    if (responseData is Map<String, dynamic>) {
      if (responseData['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(responseData['data']);
      }

      if (responseData['transaction'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(responseData['transaction']);
      }

      if (responseData['id'] != null ||
          responseData['invoice_number'] != null ||
          responseData['status'] != null) {
        return Map<String, dynamic>.from(responseData);
      }
    }

    return fallbackTransaction;
  }

  Future<void> openTransactionDetail(Map<String, dynamic> transaction) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final result = await CustomerTransactionService().getTransactionDetail(
        transaction['id'],
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      if (result['success'] == true) {
        final detailTransaction = extractTransactionDetail(result, transaction);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CustomerTransactionDetailScreen(transaction: detailTransaction),
          ),
        );
      } else {
        showMessage(result['message'] ?? 'Gagal mengambil detail transaksi');
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      Navigator.pop(context);
      showMessage('Terjadi kesalahan saat mengambil detail transaksi');
    }
  }

  void showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String statusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'washing':
        return 'Sedang Dicuci';
      case 'drying':
        return 'Pengeringan';
      case 'ironing':
        return 'Disetrika';
      case 'ready':
        return 'Siap Diambil';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status.isEmpty ? '-' : status;
    }
  }

  String formatCurrency(dynamic amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(double.tryParse(amount.toString()) ?? 0);
  }

  String formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) {
      return '-';
    }

    try {
      final parsed = DateTime.parse(date.toString());
      return DateFormat('dd MMM yyyy', 'id_ID').format(parsed);
    } catch (e) {
      return date.toString();
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      case 'washing':
      case 'drying':
      case 'ironing':
        return Colors.deepPurple;
      case 'ready':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText(status),
        style: TextStyle(
          color: statusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  dynamic firstValue(Map<String, dynamic> transaction, List<String> keys) {
    for (final key in keys) {
      if (transaction[key] != null) {
        return transaction[key];
      }
    }

    return null;
  }

  List<dynamic> getDetails(Map<String, dynamic> transaction) {
    final possibleKeys = [
      'details',
      'transaction_details',
      'items',
      'services',
    ];

    for (final key in possibleKeys) {
      final value = transaction[key];

      if (value is List) {
        return value;
      }
    }

    return [];
  }

  double getServiceWeight(dynamic item) {
    if (item is! Map) {
      return 0;
    }

    return double.tryParse(
          (item['weight'] ??
                  item['total_weight'] ??
                  item['quantity'] ??
                  item['qty'] ??
                  0)
              .toString(),
        ) ??
        0;
  }

  double getServiceSubtotal(dynamic item) {
    if (item is! Map) {
      return 0;
    }

    final double weight = getServiceWeight(item);

    // Prioritas 1: harga yang tersimpan saat transaksi dibuat.
    // Ini penting supaya transaksi lama tidak berubah kalau owner mengganti harga layanan.
    double pricePerKg =
        double.tryParse(item['price_per_kg']?.toString() ?? '') ?? 0;

    // Prioritas 2: kalau transaksi lama belum punya price_per_kg,
    // baru pakai harga dari relasi service.
    if (pricePerKg == 0 && item['service'] is Map) {
      pricePerKg =
          double.tryParse(item['service']['price_per_kg']?.toString() ?? '') ??
          0;
    }

    if (pricePerKg > 0 && weight > 0) {
      return pricePerKg * weight;
    }

    return double.tryParse(
          (item['computed_subtotal'] ??
                  item['subtotal'] ??
                  item['total_price'] ??
                  item['price'] ??
                  item['amount'] ??
                  0)
              .toString(),
        ) ??
        0;
  }

  double calculateTotalFromDetails(Map<String, dynamic> transaction) {
    final details = getDetails(transaction);

    if (details.isEmpty) {
      return 0;
    }

    double total = 0;

    for (final item in details) {
      total += getServiceSubtotal(item);
    }

    return total;
  }

  dynamic getDisplayTotalPrice(Map<String, dynamic> transaction) {
    final calculatedFromDetails = calculateTotalFromDetails(transaction);

    if (calculatedFromDetails > 0) {
      return calculatedFromDetails;
    }

    return firstValue(transaction, [
      'display_total_price',
      'computed_total_price',
      'final_price',
      'total_price',
      'total',
      'amount',
    ]);
  }

  String getLaundryName(Map<String, dynamic> transaction) {
    if (transaction['laundry'] is Map) {
      return transaction['laundry']['name']?.toString() ?? 'Laundry';
    }

    return transaction['laundry_name']?.toString() ?? 'Laundry';
  }

  Widget transactionCard(Map<String, dynamic> transaction) {
    final status = transaction['status']?.toString() ?? '-';

    final invoice = transaction['invoice_number']?.toString() ?? 'No Invoice';

    final totalPrice = getDisplayTotalPrice(transaction);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        openTransactionDetail(transaction);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xffEEE7FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.receipt_long, color: Color(0xff6F3CC3)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    getLaundryName(transaction),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatDate(transaction['created_at']),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                  const SizedBox(height: 7),
                  statusBadge(status),
                  const SizedBox(height: 7),
                  Text(
                    formatCurrency(totalPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: Colors.blue.shade400,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Belum Ada Transaksi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Transaksi laundry Anda akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 52),
            const SizedBox(height: 12),
            Text(
              error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: loadTransactions,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Transaksi Saya',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? errorState()
          : transactions.isEmpty
          ? RefreshIndicator(
              onRefresh: loadTransactions,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.72,
                    child: emptyState(),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadTransactions,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  return transactionCard(
                    Map<String, dynamic>.from(transactions[index]),
                  );
                },
              ),
            ),
    );
  }
}
