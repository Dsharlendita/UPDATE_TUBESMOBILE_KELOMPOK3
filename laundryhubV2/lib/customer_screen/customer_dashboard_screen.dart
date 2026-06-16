import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../services/api_service.dart';
import 'customer_address_screen.dart';
import 'customer_pickup_request_screen.dart';
import 'customer_transaction_screen.dart';
import 'customer_profile_screen.dart';
import 'customer_tracking_screen.dart';
import 'customer_notification_screen.dart';
import 'customer_laundry_screen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool loading = true;

  Map<String, dynamic>? user;
  Map<String, dynamic> stats = {};

  List<dynamic> addresses = [];
  List<dynamic> pickups = [];
  List<dynamic> transactions = [];
  List<dynamic> laundries = [];

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<Map<String, dynamic>?> getJson(String endpoint) async {
    final token = await storage.read(key: 'token');

    if (token == null) {
      print('TOKEN NULL');
      return null;
    }

    final url = '${ApiService.baseUrl}$endpoint';

    print('========================');
    print('REQUEST URL : $url');
    print('TOKEN : $token');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('STATUS : ${response.statusCode}');
    print('BODY : ${response.body}');
    print('========================');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  List<dynamic> extractList(dynamic value) {
    if (value == null) {
      return [];
    }

    if (value is List) {
      return value;
    }

    if (value is Map<String, dynamic>) {
      if (value['data'] is List) {
        return value['data'];
      }
    }

    return [];
  }

  Future<void> loadDashboardData() async {
    setState(() {
      loading = true;
    });

    final profileResponse =
        await getJson('/customer/profile');

    final dashboardResponse =
        await getJson('/customer/dashboard');

    print("PROFILE RESPONSE");
    print(profileResponse);

    print("DASHBOARD RESPONSE");
    print(dashboardResponse);
    final addressResponse = await getJson('/customer/addresses');
    final pickupResponse = await getJson('/customer/pickups');
    final transactionResponse = await getJson('/customer/transactions');
    final createPickupResponse = await getJson('/customer/pickups/create-data');

    if (!mounted) {
      return;
    }

    setState(() {
      user = profileResponse?['data'];

      final dashboardData = dashboardResponse?['data'];

      if (dashboardData is Map<String, dynamic>) {
        stats = dashboardData['stats'] ?? {};
      }

      addresses = extractList(addressResponse?['data']);
      pickups = extractList(pickupResponse?['data']);
      transactions = extractList(transactionResponse?['data']);

      final laundriesData =
          createPickupResponse?['data']?['laundries'];

      laundries = extractList(laundriesData);

      loading = false;
    });
  }

  String rupiah(dynamic value) {
    if (value == null) {
      return 'Rp 0';
    }

    final number = double.tryParse(value.toString()) ?? 0;

    return 'Rp ${number.toStringAsFixed(0)}';
  }

  String statusLabel(String? status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'accepted':
        return 'Diterima';
      case 'on_the_way':
        return 'Dalam Perjalanan';
      case 'picked_up':
        return 'Sudah Dijemput';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      case 'processing':
        return 'Diproses';
      case 'finished':
        return 'Selesai';
      default:
        return status ?? '-';
    }
  }

  Color statusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'on_the_way':
        return Colors.blue;
      case 'picked_up':
        return Colors.purple;
      case 'completed':
      case 'finished':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic> mapOf(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  bool isCompletedOrCancelledStatus(String? status) {
    final value = status?.toLowerCase();

    return value == 'completed' ||
        value == 'finished' ||
        value == 'selesai' ||
        value == 'cancelled' ||
        value == 'canceled';
  }

  int activeTransactionCount() {
    return transactions.where((item) {
      final transaction = mapOf(item);
      final status = transaction['status']?.toString();

      if (status == null || status.isEmpty) {
        return false;
      }

      return !isCompletedOrCancelledStatus(status);
    }).length;
  }

  int activePickupCount() {
    return pickups.where((item) {
      final pickup = mapOf(item);
      final status = pickup['status']?.toString();

      return status == 'pending' ||
          status == 'accepted' ||
          status == 'on_the_way';
    }).length;
  }

  Map<String, dynamic> findTransactionForPickup(dynamic pickup) {
    final pickupMap = mapOf(pickup);

    final embeddedTransaction = mapOf(
      pickupMap['transaction'] ?? pickupMap['transaction_by_pickup_id'],
    );

    final pickupTransactionId =
        (pickupMap['transaction_id'] ?? embeddedTransaction['id'])?.toString();

    final pickupInvoice =
        (embeddedTransaction['invoice_number'] ??
                pickupMap['invoice_number'] ??
                pickupMap['invoice'])
            ?.toString();

    for (final item in transactions) {
      final transaction = mapOf(item);

      final transactionId = transaction['id']?.toString();
      final transactionInvoice =
          (transaction['invoice_number'] ?? transaction['invoice'])?.toString();

      if (pickupTransactionId != null &&
          pickupTransactionId.isNotEmpty &&
          pickupTransactionId != 'null' &&
          transactionId == pickupTransactionId) {
        return transaction;
      }

      if (pickupInvoice != null &&
          pickupInvoice.isNotEmpty &&
          pickupInvoice != '-' &&
          pickupInvoice != 'null' &&
          transactionInvoice == pickupInvoice) {
        return transaction;
      }
    }

    return embeddedTransaction;
  }

  List<dynamic> uniquePickupOrders() {
    final uniqueOrders = <String, dynamic>{};

    for (int i = 0; i < pickups.length; i++) {
      final pickup = pickups[i];
      final pickupMap = mapOf(pickup);

      final transaction = mapOf(
        pickupMap['transaction'] ?? pickupMap['transaction_by_pickup_id'],
      );

      final transactionId = transaction['id']?.toString();
      final invoice = transaction['invoice_number']?.toString();
      final pickupId = pickupMap['id']?.toString();

      String key;

      if (transactionId != null &&
          transactionId.isNotEmpty &&
          transactionId != 'null') {
        key = 'transaction_$transactionId';
      } else if (invoice != null &&
          invoice.isNotEmpty &&
          invoice != '-' &&
          invoice != 'null') {
        key = 'invoice_$invoice';
      } else {
        key = 'pickup_${pickupId ?? i}';
      }

      if (!uniqueOrders.containsKey(key)) {
        uniqueOrders[key] = pickup;
      }
    }

    return uniqueOrders.values.toList();
  }

  Widget greetingCard() {
    final name = user?['name'] ?? 'Customer';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff2F80ED), Color(0xff18B7C9)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang, $name!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pantau laundry Anda dengan mudah dan cepat',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomerTransactionScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xff2F80ED),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.receipt_long, size: 18),
                  label: const Text(
                    'Pesanan Saya',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomerPickupRequestScreen(),
                      ),
                    ).then((_) => loadDashboardData());
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.18),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.local_shipping, size: 18),
                  label: const Text(
                    'Request Pickup',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xff2F80ED), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (actionText != null && onAction != null)
                TextButton(onPressed: onAction, child: Text(actionText)),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget quickAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget activeOrdersSection() {
    final previewOrders = transactions.take(4).toList();

    if (previewOrders.isEmpty) {
      return sectionCard(
        title: 'Pesanan Aktif',
        icon: Icons.access_time_filled,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Belum ada pesanan',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      );
    }

    return sectionCard(
      title: 'Pesanan Aktif',
      icon: Icons.access_time_filled,
      actionText: '${previewOrders.length} pesanan',
      onAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomerTransactionScreen()),
        );
      },
      children: previewOrders.map((item) {
        final transaction = mapOf(item);
        final laundry = mapOf(transaction['laundry']);

        final laundryName =
            laundry['name']?.toString() ??
            transaction['laundry_name']?.toString() ??
            'Laundry';

        final invoice = transaction['invoice_number']?.toString() ?? '-';

        final price =
            transaction['final_price'] ??
            transaction['total_price'] ??
            transaction['total_amount'] ??
            transaction['total'];

        final status = transaction['status']?.toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xff19A7CE),
                child: Text(
                  laundryName.isNotEmpty
                      ? laundryName.substring(0, 1).toUpperCase()
                      : 'L',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      laundryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      invoice,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    rupiah(price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor(status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel(status),
                      style: TextStyle(
                        color: statusColor(status),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget quickActionsSection() {
    return sectionCard(
      title: 'Aksi Cepat',
      icon: Icons.flash_on,
      children: [
        quickAction(
          title: 'Request Pickup',
          subtitle: 'Jadwalkan penjemputan',
          icon: Icons.local_shipping,
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CustomerPickupRequestScreen(),
              ),
            ).then((_) => loadDashboardData());
          },
        ),
        quickAction(
          title: 'Lacak Laundry',
          subtitle: 'Cek status laundry Anda',
          icon: Icons.search,
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerTrackingScreen()),
            );
          },
        ),
        quickAction(
          title: 'Pesanan Saya',
          subtitle: 'Lihat riwayat dan detail pesanan',
          icon: Icons.receipt_long,
          color: Colors.deepPurple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CustomerTransactionScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget addressesSection() {
    final previewAddresses = addresses.take(2).toList();

    return sectionCard(
      title: 'Alamat Tersimpan',
      icon: Icons.location_on,
      actionText: 'Kelola',
      onAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomerAddressScreen()),
        ).then((_) => loadDashboardData());
      },
      children: [
        if (previewAddresses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Text(
                  'Belum ada alamat tersimpan',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomerAddressScreen(),
                      ),
                    ).then((_) => loadDashboardData());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Alamat'),
                ),
              ],
            ),
          )
        else
          ...previewAddresses.map((address) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: const Icon(Icons.location_on, color: Colors.red),
              ),
              title: Text(
                address['label'] ?? 'Alamat',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${address['address'] ?? '-'}, ${address['city'] ?? '-'}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: address['is_default'] == true
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Utama',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            );
          }),
      ],
    );
  }

  Widget laundriesSection() {
    final previewLaundries = laundries.take(3).toList();

    return sectionCard(
      title: 'Laundry Terdekat',
      icon: Icons.store,
      actionText: 'Lihat Semua',
      onAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomerLaundryScreen()),
        );
      },
      children: [
        if (previewLaundries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              'Belum ada data laundry',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
        else
          ...previewLaundries.map((laundry) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: const Color(0xff19A7CE),
                child: Text(
                  (laundry['name'] ?? 'L').toString().substring(0, 1),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                laundry['name'] ?? 'Laundry',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${laundry['services_count'] ?? laundry['services']?.length ?? 0} layanan',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 9, color: Colors.green.shade500),
                  const SizedBox(width: 4),
                  const Text('Buka', style: TextStyle(fontSize: 12)),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget historySection() {
    final previewTransactions = transactions.take(4).toList();

    return sectionCard(
      title: 'Riwayat Pesanan',
      icon: Icons.history,
      actionText: 'Lihat Semua',
      onAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomerTransactionScreen()),
        );
      },
      children: [
        if (previewTransactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              'Belum ada riwayat pesanan',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
        else
          ...previewTransactions.map((transaction) {
            final laundry = transaction['laundry'];
            final status = transaction['status']?.toString();

            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                transaction['invoice_number'] ?? '-',
                style: const TextStyle(
                  color: Color(0xff2F80ED),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              subtitle: Text(
                laundry?['name'] ?? transaction['laundry_name'] ?? 'Laundry',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    rupiah(
                      transaction['final_price'] ??
                          transaction['total_price'] ??
                          transaction['total'],
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusLabel(status),
                    style: TextStyle(
                      color: statusColor(status),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalTransactions =
      stats['total_transactions'] ?? transactions.length;

    final activeTransactions =
      stats['active_transactions'] ?? activeTransactionCount();

    final totalSpent = stats['total_spent'] ?? 0;

    final pendingPickups =
      stats['pending_pickups'] ?? activePickupCount();

    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xffF8F8FC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF8F8FC),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff2F80ED), Color(0xff18B7C9)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage: user?['avatar'] != null
                        ? NetworkImage(
                            'https://laundryhub.my.id/storage/${user!['avatar']}',
                          )
                        : null,
                    child: user?['avatar'] == null
                        ? Text(
                            (user?['name'] ?? 'C').substring(0, 1),
                            style: const TextStyle(
                              color: Color(0xff2F80ED),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?['name'] ?? 'Customer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?['email'] ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Pesanan Saya'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerTransactionScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: const Text('Request Pickup'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerPickupRequestScreen(),
                  ),
                ).then((_) => loadDashboardData());
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Alamat Saya'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerAddressScreen(),
                  ),
                ).then((_) => loadDashboardData());
              },
            ),
            ListTile(
              leading: const Icon(Icons.store_outlined),
              title: const Text('Laundry Terdekat'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerLaundryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes_outlined),
              title: const Text('Tracking'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerTrackingScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_none),
              title: const Text('Notifikasi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerNotificationScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profil Saya'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerProfileScreen(),
                  ),
                ).then((_) => loadDashboardData());
              },
            ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh Dashboard'),
              onTap: () {
                Navigator.pop(context);
                loadDashboardData();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xffEAF3FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.shirt,
                  color: Color(0xff2F80ED),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'LaundryHub',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CustomerNotificationScreen(),
                ),
              );
            },
            icon: const Icon(Icons.notifications_none, color: Colors.black54),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: CircleAvatar(
              backgroundColor: const Color(0xff168AC0),
              backgroundImage: user?['avatar'] != null
                  ? NetworkImage(
                      'http://10.0.2.2:8000/storage/${user!['avatar']}',
                    )
                  : null,
              child: user?['avatar'] == null
                  ? Text(
                      (user?['name'] ?? 'C').toString().substring(0, 1),
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              greetingCard(),
              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.65,
                children: [
                  statCard(
                    title: 'Total Pesanan',
                    value: totalTransactions.toString(),
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                  ),
                  statCard(
                    title: 'Sedang Diproses',
                    value: activeTransactions.toString(),
                    icon: Icons.autorenew,
                    color: Colors.orange,
                  ),
                  statCard(
                    title: 'Total Belanja',
                    value: rupiah(totalSpent),
                    icon: Icons.account_balance_wallet,
                    color: Colors.green,
                  ),
                  statCard(
                    title: 'Pickup Aktif',
                    value: pendingPickups.toString(),
                    icon: Icons.local_shipping,
                    color: Colors.deepPurple,
                  ),
                ],
              ),

              activeOrdersSection(),
              quickActionsSection(),
              addressesSection(),
              laundriesSection(),
              historySection(),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff19A7CE),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CustomerPickupRequestScreen(),
            ),
          ).then((_) => loadDashboardData());
        },
        icon: const Icon(Icons.local_shipping),
        label: const Text('Pickup'),
      ),
    );
  }
}
