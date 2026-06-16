import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Pastikan path import ini sesuai dengan struktur folder kamu ya:
import '../../services/report_service.dart';

class ServicesReportScreen extends StatefulWidget {
  const ServicesReportScreen({super.key});

  @override
  State<ServicesReportScreen> createState() => _ServicesReportScreenState();
}

class _ServicesReportScreenState extends State<ServicesReportScreen> {
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final ReportService _reportService = ReportService();

  // --- STATE VARIABLES ---
  List<Map<String, dynamic>> services = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServicesData();
  }

  // --- FUNGSI MENGAMBIL DATA DARI API ---
  Future<void> _loadServicesData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await _reportService.getServices();

    if (result['success']) {
      setState(() {
        services = result['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = result['message'];
        isLoading = false;
      });
    }
  }

  // --- FUNGSI BANTUAN UNTUK ICON ---
  // Di Laravel, icon disimpan dalam bentuk teks (misal: 'tshirt', 'iron').
  // Di Flutter, kita perlu menerjemahkannya menjadi IconData.
  IconData _getIconData(String? iconName) {
    if (iconName == null) return Icons.local_laundry_service;
    
    switch (iconName.toLowerCase()) {
      case 'iron':
      case 'setrika':
        return Icons.iron;
      case 'bolt':
      case 'flash':
        return Icons.bolt;
      case 'bed':
      case 'blanket':
        return Icons.bed;
      case 'tshirt':
      default:
        return Icons.local_laundry_service;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "Laporan Layanan",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. Kondisi saat sedang memuat data (Loading)
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    // 2. Kondisi jika API gagal memuat data / Error
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadServicesData,
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      );
    }

    // 3. Kondisi jika data kosong
    if (services.isEmpty) {
      return Center(
        child: Text("Belum ada data layanan.", style: TextStyle(color: Colors.grey.shade600)),
      );
    }

    // 4. Kondisi Sukses menampilkan list data
    return RefreshIndicator(
      onRefresh: _loadServicesData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceCard(service);
        },
      ),
    );
  }

  // --- WIDGET BUILDER UNTUK KARTU LAYANAN ---
  Widget _buildServiceCard(Map<String, dynamic> service) {
    // Mengubah String menjadi int/double dengan aman
    final double price = double.tryParse(service['price_per_kg'].toString()) ?? 0;
    final int used = int.tryParse(service['total_used'].toString()) ?? 0;
    final double revenue = double.tryParse(service['total_revenue'].toString()) ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIconData(service['icon']), color: Colors.blue.shade600),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['name'] ?? 'Layanan',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${currency.format(price)}/kg",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Digunakan",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${used}x",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Pendapatan",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          currency.format(revenue),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}