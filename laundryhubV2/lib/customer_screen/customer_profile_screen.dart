import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'customer_edit_profile_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  static const String baseUrl =
    'https://laundryhub.my.id/api';

  static const String storageBaseUrl =
      'https://laundryhub.my.id/storage/';

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool loading = true;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<void> loadProfile() async {
    setState(() {
      loading = true;
    });

    try {
      final token = await getToken();

      print("========== PROFILE ==========");
      print("TOKEN = $token");
      print("URL = $baseUrl/customer/profile");

      final response = await http.get(
        Uri.parse('$baseUrl/customer/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("STATUS = ${response.statusCode}");
      print("BODY = ${response.body}");

      final body = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 &&
          body['success'] == true &&
          body['data'] != null) {

        print("DATA PROFILE = ${body['data']}");

        setState(() {
          user = Map<String, dynamic>.from(body['data']);
          loading = false;
        });

      } else {

        print("PROFILE GAGAL");
        print(body);

        setState(() {
          loading = false;
        });

        showMessage(
          body['message']?.toString() ??
          'Gagal mengambil data profil',
        );
      }
    } catch (e, stackTrace) {

      print("PROFILE ERROR = $e");
      print("STACKTRACE = $stackTrace");

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage(
        'Terjadi kesalahan saat mengambil profil',
      );
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'user');

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String safeText(dynamic value) {
    if (value == null) return '-';

    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  String getAvatarUrl() {
    final avatar = user?['avatar'];

    if (avatar == null || avatar.toString().isEmpty) {
      return '';
    }

    final avatarString = avatar.toString();

    if (avatarString.startsWith('http')) {
      return avatarString;
    }

    return '$storageBaseUrl$avatarString';
  }

  Widget profileAvatar() {
    final avatarUrl = getAvatarUrl();

    return Container(
      width: 96,
      height: 96,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.45), width: 2),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
        child: avatarUrl.isEmpty
            ? const Icon(Icons.person, size: 48, color: Color(0xff2F80ED))
            : null,
      ),
    );
  }

  Widget profileHeader() {
    final name = safeText(user?['name']);
    final email = safeText(user?['email']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff2F80ED), Color(0xff12B5CB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff2F80ED).withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          profileAvatar(),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(15),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xffEAF3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xff2F80ED), size: 23),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget editButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: user == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomerEditProfileScreen(user: user!),
                  ),
                ).then((_) => loadProfile());
              },
        icon: const Icon(Icons.edit, size: 18),
        label: const Text(
          'Edit Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff2F80ED),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }

  Widget logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: logout,
        icon: const Icon(Icons.logout, size: 18),
        label: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffFF443A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }

  Widget profileContent() {
    return RefreshIndicator(
      onRefresh: loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            profileHeader(),
            const SizedBox(height: 22),

            infoCard(
              icon: Icons.email_outlined,
              label: 'Email',
              value: safeText(user?['email']),
            ),

            infoCard(
              icon: Icons.phone_outlined,
              label: 'Telepon',
              value: safeText(user?['phone']),
            ),

            infoCard(
              icon: Icons.location_on_outlined,
              label: 'Alamat Utama',
              value: safeText(
                user?['default_address'] ??
                    user?['address'] ??
                    user?['alamat'] ??
                    '-',
              ),
            ),

            const SizedBox(height: 16),
            editButton(),
            const SizedBox(height: 12),
            logoutButton(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget errorContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              color: Colors.grey.shade400,
              size: 64,
            ),
            const SizedBox(height: 14),
            const Text(
              'Profil tidak tersedia',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Data profil customer belum berhasil dimuat.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2F80ED),
                foregroundColor: Colors.white,
              ),
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
        title: const Text(
          'Profil Saya',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? errorContent()
          : profileContent(),
    );
  }
}
