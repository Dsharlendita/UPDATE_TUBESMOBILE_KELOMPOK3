import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'customer_transaction_detail_screen.dart';

class CustomerTrackingScreen extends StatefulWidget {
  const CustomerTrackingScreen({super.key});

  @override
  State<CustomerTrackingScreen> createState() => _CustomerTrackingScreenState();
}

class _CustomerTrackingScreenState extends State<CustomerTrackingScreen> {
  static const String baseUrl = 'https://laundryhub.my.id/api';

  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final TextEditingController trackingController = TextEditingController();

  bool loading = false;
  String? errorMessage;
  Map<String, dynamic>? foundTransaction;

  @override
  void dispose() {
    trackingController.dispose();
    super.dispose();
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  String safeText(dynamic value) {
    if (value == null) return '-';

    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
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

  String formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return '-';
    }

    try {
      final date = DateTime.parse(value.toString());
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return value.toString();
    }
  }

  String getLaundryName(Map<String, dynamic> transaction) {
    if (transaction['laundry'] is Map) {
      return transaction['laundry']['name']?.toString() ?? '-';
    }

    return transaction['laundry_name']?.toString() ?? '-';
  }

  List<dynamic> extractTransactions(Map<String, dynamic> responseBody) {
    final data = responseBody['data'];

    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      if (data['data'] is List) {
        return List<dynamic>.from(data['data']);
      }

      if (data['transactions'] is List) {
        return List<dynamic>.from(data['transactions']);
      }
    }

    return [];
  }

  Future<void> searchTracking() async {
    final code = trackingController.text.trim();

    if (code.isEmpty) {
      setState(() {
        errorMessage = 'Masukkan kode tracking terlebih dahulu';
        foundTransaction = null;
      });
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
      foundTransaction = null;
    });

    try {
      final token = await getToken();

      print("TRACKING CODE = $code");
      print("TRACKING URL = $baseUrl/customer/transactions");
      print("TOKEN = $token");
      final response = await http.get(
        Uri.parse('$baseUrl/customer/transactions'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("STATUS = ${response.statusCode}");
      print("BODY = ${response.body}");

      final body = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && body['success'] == true) {
        final transactions = extractTransactions(body);

        Map<String, dynamic>? matched;

        for (final item in transactions) {
          final transaction = Map<String, dynamic>.from(item);
          final trackingCode = safeText(transaction['tracking_code']);

          if (trackingCode.toLowerCase() == code.toLowerCase()) {
            matched = transaction;
            break;
          }
        }

        if (matched == null) {
          setState(() {
            loading = false;
            errorMessage = 'Kode tracking tidak ditemukan pada transaksi Anda';
            foundTransaction = null;
          });
          return;
        }

        final detail = await fetchTransactionDetail(matched);

        if (!mounted) return;

        setState(() {
          loading = false;
          foundTransaction = detail;
        });
      } else {
        setState(() {
          loading = false;
          errorMessage = body['message'] ?? 'Gagal mengambil data tracking';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = 'Terjadi kesalahan saat mencari tracking';
      });
    }
  }

  Future<Map<String, dynamic>> fetchTransactionDetail(
    Map<String, dynamic> transaction,
  ) async {
    final id = transaction['id'];

    if (id == null) {
      return transaction;
    }

    try {
      final token = await getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/customer/transactions/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("STATUS = ${response.statusCode}");
      print("BODY = ${response.body}");

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];

        if (data is Map<String, dynamic>) {
          if (data['data'] is Map<String, dynamic>) {
            return Map<String, dynamic>.from(data['data']);
          }

          if (data['transaction'] is Map<String, dynamic>) {
            return Map<String, dynamic>.from(data['transaction']);
          }

          return Map<String, dynamic>.from(data);
        }
      }
    } catch (e) {
      return transaction;
    }

    return transaction;
  }

  Widget progressStep({
    required String title,
    required bool active,
    required bool done,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: done || active
                  ? const Color(0xff2F80ED)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? const Color(0xff2F80ED) : Colors.grey.shade600,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  int statusIndex(String status) {
    switch (status) {
      case 'pending':
        return 0;
      case 'confirmed':
      case 'washing':
      case 'drying':
      case 'ironing':
        return 1;
      case 'ready':
        return 2;
      case 'completed':
        return 3;
      default:
        return 0;
    }
  }

  Widget trackingResult() {
    final transaction = foundTransaction;

    if (transaction == null) {
      return const SizedBox();
    }

    final status = safeText(transaction['status']);
    final trackingCode = safeText(transaction['tracking_code']);
    final invoice = safeText(transaction['invoice_number']);
    final laundryName = getLaundryName(transaction);
    final currentIndex = statusIndex(status);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xffEAF3FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.track_changes,
              color: Color(0xff2F80ED),
              size: 30,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            invoice,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 4),
          Text(
            laundryName,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: statusColor(status).withOpacity(0.12),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: statusColor(status).withOpacity(0.25)),
            ),
            child: Text(
              statusText(status),
              style: TextStyle(
                color: statusColor(status),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              progressStep(
                title: 'Menunggu',
                active: currentIndex == 0,
                done: currentIndex > 0,
              ),
              const SizedBox(width: 5),
              progressStep(
                title: 'Diproses',
                active: currentIndex == 1,
                done: currentIndex > 1,
              ),
              const SizedBox(width: 5),
              progressStep(
                title: 'Siap',
                active: currentIndex == 2,
                done: currentIndex > 2,
              ),
              const SizedBox(width: 5),
              progressStep(
                title: 'Selesai',
                active: currentIndex == 3,
                done: currentIndex >= 3,
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffEEF5FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kode Tracking',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  trackingCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tanggal transaksi: ${formatDate(transaction['created_at'])}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomerTransactionDetailScreen(
                      transaction: transaction,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.receipt_long),
              label: const Text(
                'Lihat Detail Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2F80ED),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.manage_search, color: Colors.grey.shade400, size: 52),
          const SizedBox(height: 12),
          const Text(
            'Lacak Pesanan Laundry',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Masukkan kode tracking dari detail transaksi untuk melihat status laundry Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget errorBox() {
    if (errorMessage == null) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red.shade600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget searchCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff2F80ED), Color(0xff12B5CB)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tracking Laundry',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Masukkan kode tracking untuk melihat status pesanan laundry Anda.',
            style: TextStyle(color: Colors.white, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: trackingController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Contoh: JOQONQ6F',
              prefixIcon: const Icon(Icons.qr_code_2),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: loading ? null : searchTracking,
              icon: loading
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(
                loading ? 'Mencari...' : 'Lacak Sekarang',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xff2F80ED),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8FC),
      appBar: AppBar(
        title: const Text(
          'Tracking',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (trackingController.text.trim().isNotEmpty) {
            await searchTracking();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              searchCard(),
              errorBox(),
              foundTransaction == null ? emptyState() : trackingResult(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
