import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../services/api_service.dart';
import 'customer_pickup_request_screen.dart';

class CustomerLaundryScreen extends StatefulWidget {
  const CustomerLaundryScreen({super.key});

  @override
  State<CustomerLaundryScreen> createState() => _CustomerLaundryScreenState();
}

class _CustomerLaundryScreenState extends State<CustomerLaundryScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool loading = true;
  List<dynamic> laundries = [];
  List<dynamic> filteredLaundries = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadLaundries();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<void> loadLaundries() async {
    setState(() {
      loading = true;
    });

    try {
      final token = await getToken();

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/customer/pickups/create-data'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];

        final loadedLaundries = extractLaundries(data, body);

        setState(() {
          laundries = loadedLaundries;
          filteredLaundries = loadedLaundries;
          loading = false;
        });
      } else {
        setState(() {
          laundries = [];
          filteredLaundries = [];
          loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        laundries = [];
        filteredLaundries = [];
        loading = false;
      });
    }
  }

  List<dynamic> extractLaundries(dynamic data, Map<String, dynamic> body) {
    if (data is Map<String, dynamic>) {
      if (data['laundries'] is List) {
        return List<dynamic>.from(data['laundries']);
      }

      if (data['laundry'] is List) {
        return List<dynamic>.from(data['laundry']);
      }

      if (data['nearby_laundries'] is List) {
        return List<dynamic>.from(data['nearby_laundries']);
      }
    }

    if (body['laundries'] is List) {
      return List<dynamic>.from(body['laundries']);
    }

    return [];
  }

  String safeText(dynamic value) {
    if (value == null) return '-';

    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  String getLaundryName(Map<String, dynamic> laundry) {
    return safeText(laundry['name']);
  }

  String getAddress(Map<String, dynamic> laundry) {
    return safeText(
      laundry['formatted_address'] ??
          laundry['address'] ??
          laundry['full_address'] ??
          laundry['location'],
    );
  }

  String getPhone(Map<String, dynamic> laundry) {
    return safeText(laundry['phone'] ?? laundry['phone_number']);
  }

  bool isOpen(Map<String, dynamic> laundry) {
    final value = laundry['is_open'];

    if (value is bool) return value;

    final status = safeText(laundry['status']).toLowerCase();

    if (status == 'open' || status == 'buka' || status == 'approved') {
      return true;
    }

    return false;
  }

  List<dynamic> getServices(Map<String, dynamic> laundry) {
    final possibleKeys = ['services', 'laundry_services', 'active_services'];

    for (final key in possibleKeys) {
      if (laundry[key] is List) {
        return List<dynamic>.from(laundry[key]);
      }
    }

    return [];
  }

  String formatPrice(dynamic value) {
    final number = double.tryParse(value.toString()) ?? 0;

    return 'Rp ${number.toStringAsFixed(0)}';
  }

  void searchLaundry(String keyword) {
    final query = keyword.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredLaundries = laundries;
      } else {
        filteredLaundries = laundries.where((item) {
          final laundry = Map<String, dynamic>.from(item);
          final name = getLaundryName(laundry).toLowerCase();
          final address = getAddress(laundry).toLowerCase();

          return name.contains(query) || address.contains(query);
        }).toList();
      }
    });
  }

  Widget headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff2F80ED), Color(0xff12B5CB)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.storefront, color: Colors.white),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laundry Terdekat',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pilih laundry aktif dan lihat layanan yang tersedia.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.35,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget searchBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: searchController,
        onChanged: searchLaundry,
        decoration: InputDecoration(
          hintText: 'Cari laundry atau alamat...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.shade100),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.shade100),
          ),
        ),
      ),
    );
  }

  Widget serviceChip(dynamic service) {
    if (service is! Map) {
      return const SizedBox();
    }

    final name = safeText(service['name'] ?? service['service_name']);
    final price = service['price_per_kg'] ?? service['price'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xffEAF3FF),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Text(
        '$name • ${formatPrice(price)}/kg',
        style: const TextStyle(
          color: Color(0xff2F80ED),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget laundryCard(dynamic item) {
    final laundry = Map<String, dynamic>.from(item);
    final services = getServices(laundry);
    final open = isOpen(laundry);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xff19A7CE),
                child: Text(
                  getLaundryName(laundry).substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getLaundryName(laundry),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${services.length} layanan tersedia',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: open ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: open ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      open ? 'Buka' : 'Tutup',
                      style: TextStyle(
                        color: open ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  getAddress(laundry),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.phone_outlined, size: 17, color: Colors.grey.shade500),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  getPhone(laundry),
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (services.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Belum ada layanan aktif.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            )
          else
            Wrap(children: services.map(serviceChip).toList()),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: open
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerPickupRequestScreen(),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.local_shipping),
              label: const Text(
                'Request Pickup',
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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum Ada Laundry',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(
            'Laundry yang tersedia dari owner akan tampil di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
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
          'Laundry Terdekat',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadLaundries,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  headerCard(),
                  searchBox(),
                  if (filteredLaundries.isEmpty)
                    emptyState()
                  else
                    ...filteredLaundries.map(laundryCard),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
