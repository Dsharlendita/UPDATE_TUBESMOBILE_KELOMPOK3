import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../services/api_service.dart';
import 'customer_transaction_detail_screen.dart';

class CustomerNotificationScreen extends StatefulWidget {
  const CustomerNotificationScreen({super.key});

  @override
  State<CustomerNotificationScreen> createState() =>
      _CustomerNotificationScreenState();
}

class _CustomerNotificationScreenState
    extends State<CustomerNotificationScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool loading = true;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<void> loadNotifications() async {
    setState(() {
      loading = true;
    });

    try {
      final token = await getToken();

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/customer/transactions'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && body['success'] == true) {
        final transactions = extractTransactions(body);

        setState(() {
          notifications = transactions
              .map((item) {
                final transaction = Map<String, dynamic>.from(item);
                return buildNotificationFromTransaction(transaction);
              })
              .whereType<Map<String, dynamic>>()
              .toList();

          loading = false;
        });
      } else {
        setState(() {
          notifications = [];
          loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        notifications = [];
        loading = false;
      });
    }
  }

  List<dynamic> extractTransactions(Map<String, dynamic> body) {
    final data = body['data'];

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

  Map<String, dynamic>? buildNotificationFromTransaction(
    Map<String, dynamic> transaction,
  ) {
    final invoice = safeText(transaction['invoice_number']);
    final status = safeText(transaction['status']);
    final laundryName = getLaundryName(transaction);
    final trackingCode = safeText(transaction['tracking_code']);

    IconData icon = Icons.receipt_long;
    Color color = Colors.orange;
    String title = 'Pesanan Menunggu Konfirmasi';
    String message =
        'Pesanan $invoice di $laundryName sedang menunggu konfirmasi.';

    switch (status) {
      case 'pending':
        title = 'Pesanan Menunggu Konfirmasi';
        message = 'Pesanan $invoice sedang menunggu konfirmasi dari laundry.';
        icon = Icons.hourglass_bottom;
        color = Colors.orange;
        break;

      case 'confirmed':
      case 'accepted':
        title = 'Pesanan Dikonfirmasi';
        message = 'Pesanan $invoice sudah dikonfirmasi oleh $laundryName.';
        icon = Icons.check_circle;
        color = Colors.blue;
        break;

      case 'processing':
      case 'washing':
      case 'drying':
      case 'ironing':
        title = 'Laundry Sedang Diproses';
        message = 'Pesanan $invoice sedang diproses oleh $laundryName.';
        icon = Icons.local_laundry_service;
        color = Colors.deepPurple;
        break;

      case 'ready':
      case 'finished':
        title = 'Laundry Siap';
        message = 'Pesanan $invoice sudah siap. Kode tracking: $trackingCode.';
        icon = Icons.inventory_2_outlined;
        color = Colors.teal;
        break;

      case 'completed':
        title = 'Pesanan Selesai';
        message = 'Pesanan $invoice sudah selesai. Terima kasih.';
        icon = Icons.done_all;
        color = Colors.green;
        break;

      case 'cancelled':
        title = 'Pesanan Dibatalkan';
        message = 'Pesanan $invoice telah dibatalkan.';
        icon = Icons.cancel;
        color = Colors.red;
        break;
    }

    return {
      'title': title,
      'message': message,
      'time': formatDate(transaction['created_at']),
      'icon': icon,
      'color': color,
      'transaction': transaction,
    };
  }

  String safeText(dynamic value) {
    if (value == null) return '-';

    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  String getLaundryName(Map<String, dynamic> transaction) {
    if (transaction['laundry'] is Map) {
      return transaction['laundry']['name']?.toString() ?? 'Laundry';
    }

    return transaction['laundry_name']?.toString() ?? 'Laundry';
  }

  String formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return '-';
    }

    try {
      final date = DateTime.parse(value.toString());
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return value.toString();
    }
  }

  Widget emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Notifikasi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifikasi pesanan laundry Anda akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget notificationCard(Map<String, dynamic> item) {
    final color = item['color'] as Color;
    final icon = item['icon'] as IconData;
    final transaction = item['transaction'] as Map<String, dynamic>;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CustomerTransactionDetailScreen(transaction: transaction),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']?.toString() ?? '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item['message']?.toString() ?? '-',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.35,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 13,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['time']?.toString() ?? '-',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget headerCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff2F80ED), Color(0xff12B5CB)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifikasi Pesanan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pantau update terbaru dari pesanan laundry Anda.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
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
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadNotifications,
              child: notifications.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        headerCard(),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.48,
                          child: emptyState(),
                        ),
                      ],
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        headerCard(),
                        ...notifications.map(notificationCard),
                        const SizedBox(height: 18),
                      ],
                    ),
            ),
    );
  }
}
