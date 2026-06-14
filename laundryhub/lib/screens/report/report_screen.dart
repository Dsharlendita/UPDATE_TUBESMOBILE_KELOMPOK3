import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import 'revenue_report_screen.dart';
import 'service_report_screen.dart';
import 'transaction_report_screen.dart';
import 'package:open_filex/open_filex.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportService service = ReportService();
  bool loading = true;
  ReportOverviewModel? overview;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    setState(() => loading = true);
    final result = await service.getOverview();
    
    if (result["success"]) {
      overview = result["data"];
    }
    
    setState(() {
      loading = false;
    });
  }

  // Tambahkan import open_filex di bagian paling atas file (dibawah import flutter)
  // import 'package:open_filex/open_filex.dart';

  Future<void> _handleDownload(String type) async {
    // Tampilkan popup dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Sedang mengunduh PDF..."),
              ],
            ),
          ),
        ),
      ),
    );

    // Panggil API untuk download
    final result = await service.downloadPdf(type, year: DateTime.now().year);

    // Tutup popup loading
    if (mounted) Navigator.pop(context);

    if (result['success']) {
      // Buka file PDF yang berhasil didownload
      final String filePath = result['path'];
      await OpenFilex.open(filePath);
    } else {
      // Tampilkan error jika gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message']
                  .toString(),
            ),
            backgroundColor: Colors.red,
          )
        );
      }
    }
  }

  final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Sesuai background web
      appBar: AppBar(
        title: const Text(
          "Laporan",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : RefreshIndicator(
              onRefresh: loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. OVERVIEW STATS (Sesuai Grid di web) ---
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          title: "Transaksi Hari Ini",
                          value: "${overview?.todayTransactions ?? 0}",
                          valueColor: Colors.black87,
                        ),
                        _buildStatCard(
                          title: "Pendapatan Hari Ini",
                          value: overview != null ? currency.format(overview!.todayRevenue) : "Rp 0",
                          valueColor: Colors.green.shade600,
                        ),
                        _buildStatCard(
                          title: "Transaksi Bulan Ini",
                          value: "${overview?.monthTransactions ?? 0}",
                          valueColor: Colors.black87,
                        ),
                        _buildStatCard(
                          title: "Pendapatan Bulan Ini",
                          value: overview != null ? currency.format(overview!.monthRevenue) : "Rp 0",
                          valueColor: Colors.blue.shade600,
                        ),
                        _buildStatCard(
                          title: "Total Pelanggan",
                          value: "${overview?.totalCustomers ?? 0}",
                          valueColor: Colors.black87,
                        ),
                        _buildStatCard(
                          title: "Rata-rata Transaksi",
                          value: overview != null ? currency.format(overview!.avgTransaction) : "Rp 0",
                          valueColor: Colors.purple.shade600,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- 2. REPORT CARDS (Sesuai Laporan Detail di web) ---
                    _buildReportMenu(
                      icon: Icons.receipt_long,
                      color: Colors.blue,
                      title: "Laporan Transaksi",
                      subtitle: "Detail transaksi laundry",
                      features: [
                        "Filter by status & tanggal",
                        "Ringkasan pendapatan",
                        "Export PDF",
                      ],
                      onTap: () {
                        // TODO: Navigator.push ke halaman Transactions Report
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionsReportScreen(),
                        ),
                      );
                        print("Navigasi ke Transaksi");
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildReportMenu(
                      icon: Icons.show_chart,
                      color: Colors.green,
                      title: "Laporan Pendapatan",
                      subtitle: "Analisis pendapatan",
                      features: [
                        "Grafik pendapatan",
                        "Pendapatan per layanan",
                        "Export PDF",
                      ],
                      onTap: () {
                        // TODO: Navigator.push ke halaman Revenue Report
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RevenueReportScreen(),
                        ),
                      );
                        print("Navigasi ke Pendapatan");
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildReportMenu(
                      icon: Icons.local_laundry_service,
                      color: Colors.purple,
                      title: "Laporan Layanan",
                      subtitle: "Performa layanan",
                      features: [
                        "Layanan terpopuler",
                        "Pendapatan per layanan",
                        "Total penggunaan",
                      ],
                      onTap: () {
                        // TODO: Navigator.push ke halaman Services Report
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ServicesReportScreen(),
                        ),
                      );
                        print("Navigasi ke Layanan");
                      },
                    ),

                    const SizedBox(height: 32),

                    // --- 3. QUICK EXPORT (Sesuai Quick Export di web) ---
                    const Text(
                      "Export Cepat",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildExportCard(
                      title: "Export Transaksi (PDF)",
                      subtitle: "Laporan transaksi bulan ini",
                      color: Colors.red,
                      icon: Icons.picture_as_pdf,
                      onTap: () {
                        // TODO: Panggil fungsi download PDF Transaksi
                        _handleDownload('transactions');
                        print("Download PDF Transaksi");
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildExportCard(
                      title: "Export Pendapatan (PDF)",
                      subtitle: "Laporan pendapatan tahun ini",
                      color: Colors.green,
                      icon: Icons.picture_as_pdf,
                      onTap: () {
                        // TODO: Panggil fungsi download PDF Pendapatan
                        _handleDownload('revenue');
                        print("Download PDF Pendapatan");
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildStatCard({required String title, required String value, required Color valueColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportMenu({
    required IconData icon,
    required MaterialColor color,
    required String title,
    required String subtitle,
    required List<String> features,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color.shade600, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
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
            const SizedBox(height: 16),
            ...features.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: Colors.green.shade500),
                    const SizedBox(width: 10),
                    Text(
                      e,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildExportCard({
    required String title,
    required String subtitle,
    required MaterialColor color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: color.shade600, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.download, color: color.shade400),
          ],
        ),
      ),
    );
  }
}