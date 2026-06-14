import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Sesuaikan path import ini dengan struktur foldermu:
import '../../services/report_service.dart';

class TransactionsReportScreen extends StatefulWidget {
  const TransactionsReportScreen({super.key});

  @override
  State<TransactionsReportScreen> createState() => _TransactionsReportScreenState();
}

class _TransactionsReportScreenState extends State<TransactionsReportScreen> {
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final ReportService _reportService = ReportService();

  // --- STATE VARIABLES ---
  Map<String, dynamic>? summary;
  List<dynamic> transactions = []; // List dinamis karena dari JSON
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactionsData();
  }

  // --- FUNGSI MENGAMBIL DATA DARI API ---
  Future<void> _loadTransactionsData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await _reportService.getTransactions();

    if (result['success']) {
      setState(() {
        // API mengembalikan { data: { summary: {...}, transactions: [...] } }
        summary = result['data']['summary'];
        transactions = result['data']['transactions'];
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = result['message'];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "Laporan Transaksi",
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
    // 1. Loading State
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    // 2. Error State
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
              onPressed: _loadTransactionsData,
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      );
    }

    // 3. Success State
    return RefreshIndicator(
      onRefresh: _loadTransactionsData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- KARTU RINGKASAN (SUMMARY) ---
            if (summary != null)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.0,
                children: [
                  _buildSummaryCard("Total Transaksi", "${summary!['total']}", Colors.black87),
                  _buildSummaryCard("Total Pendapatan", currency.format(double.tryParse(summary!['total_revenue'].toString()) ?? 0), 
                                   Colors.green.shade600),
                  _buildSummaryCard("Selesai / Batal", "${summary!['completed']} / ${summary!['cancelled']}", Colors.black87),
                  _buildSummaryCard("Belum Dibayar", "${summary!['unpaid']}", Colors.red.shade600),
                ],
              ),

            const SizedBox(height: 24),
            
            // --- HEADER DAFTAR TRANSAKSI ---
            const Text(
              "Daftar Transaksi",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // --- LIST TRANSAKSI ---
            if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Center(
                  child: Text("Belum ada riwayat transaksi.", style: TextStyle(color: Colors.grey.shade600)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final trx = transactions[index];
                  return _buildTransactionCard(trx);
                },
              ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---
  Widget _buildSummaryCard(String title, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(dynamic trx) {
    // Parsing data dengan aman
    final String status = trx['status']?.toString() ?? 'pending';
    final String paymentStatus = trx['payment_status']?.toString() ?? 'unpaid';
    final double price = double.tryParse(trx['price']?.toString() ?? '0') ?? 0;

    // Menentukan warna badge status cucian
    Color statusColor;
    Color statusBg;
    if (status == 'completed') {
      statusColor = Colors.green.shade700;
      statusBg = Colors.green.shade50;
    } else if (status == 'cancelled') {
      statusColor = Colors.red.shade700;
      statusBg = Colors.red.shade50;
    } else {
      statusColor = Colors.blue.shade700;
      statusBg = Colors.blue.shade50;
    }

    // Menentukan warna badge pembayaran
    bool isPaid = paymentStatus == 'paid';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trx['invoice'] ?? 'INV-UNKNOWN',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              Text(
                trx['date'] ?? '-',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.person, size: 16, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    trx['customer'] ?? 'Guest',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                currency.format(price),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPaid ? 'LUNAS' : 'BELUM BAYAR',
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold, 
                    color: isPaid ? Colors.green.shade700 : Colors.red.shade700
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}