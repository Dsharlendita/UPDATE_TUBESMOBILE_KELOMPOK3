import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import 'customer_add_edit_address_screen.dart';

class CustomerAddressScreen extends StatefulWidget {
  const CustomerAddressScreen({super.key});

  @override
  State<CustomerAddressScreen> createState() => _CustomerAddressScreenState();
}

class _CustomerAddressScreenState extends State<CustomerAddressScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  List<dynamic> addresses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAddresses();
  }

  Future<String?> getToken() async => storage.read(key: 'token');

  Future<void> loadAddresses() async {
    final token = await getToken();
    if (token == null) return;

    setState(() => loading = true);

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/customer/addresses'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          addresses = json['data'] ?? [];
          loading = false;
        });
      } else {
        setState(() => loading = false);
        showMessage('Gagal memuat alamat');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      showMessage('Terjadi kesalahan saat memuat alamat');
    }
  }

  Future<void> deleteAddress(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Alamat'),
        content: const Text('Yakin ingin menghapus alamat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final token = await getToken();
    if (token == null) return;

    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/customer/addresses/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      showMessage('Alamat berhasil dihapus');
      loadAddresses();
    } else {
      showMessage('Gagal menghapus alamat');
    }
  }

  Future<void> setDefaultAddress(int id) async {
    final token = await getToken();
    if (token == null) return;

    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/customer/addresses/$id/default'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      showMessage('Alamat utama berhasil diubah');
      loadAddresses();
    } else {
      showMessage('Gagal mengubah alamat utama');
    }
  }

  void showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> openAddAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomerAddEditAddressScreen()),
    );

    if (result == true) loadAddresses();
  }

  Future<void> openEditAddress(Map<String, dynamic> address) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerAddEditAddressScreen(address: address),
      ),
    );

    if (result == true) loadAddresses();
  }

  Widget emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off,
              color: Colors.blue.shade400,
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Belum Ada Alamat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan alamat penjemputan agar request pickup bisa dilakukan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: openAddAddress,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Alamat Pertama'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2F80ED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget addressCard(Map<String, dynamic> address) {
    final isDefault =
        address['is_default'] == true || address['is_default'] == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDefault ? Colors.blue.shade200 : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: isDefault
                ? Colors.blue.shade50
                : Colors.grey.shade100,
            child: Icon(
              Icons.location_on,
              color: isDefault ? Colors.blue : Colors.grey,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        address['label'] ?? 'Alamat',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Utama',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${address['address'] ?? '-'}, ${address['city'] ?? '-'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                openEditAddress(Map<String, dynamic>.from(address));
              } else if (value == 'default') {
                setDefaultAddress(address['id']);
              } else if (value == 'delete') {
                deleteAddress(address['id']);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              if (!isDefault)
                const PopupMenuItem(
                  value: 'default',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 18),
                      SizedBox(width: 8),
                      Text('Jadikan Utama'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Hapus'),
                  ],
                ),
              ),
            ],
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
        title: const Text('Alamat Saya'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: RefreshIndicator(
        onRefresh: loadAddresses,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : addresses.isEmpty
            ? ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.72,
                    child: emptyState(),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Kelola alamat penjemputan laundry Anda.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ...addresses.map(
                    (addr) => addressCard(Map<String, dynamic>.from(addr)),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddAddress,
        backgroundColor: const Color(0xff2F80ED),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}
