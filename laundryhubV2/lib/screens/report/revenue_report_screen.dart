import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
// Pastikan path import ini sesuai dengan foldermu:
import '../../services/report_service.dart';

class RevenueReportScreen extends StatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  State<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen> {
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final ReportService _reportService = ReportService();
  
  int selectedYear = DateTime.now().year;
  
  // --- STATE VARIABLES ---
  bool isLoading = true;
  String? errorMessage;
  double yearlyTotal = 0;
  List<double> monthlyRevenue = List.generate(12, (index) => 0); // Default 12 bulan

  final List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  @override
  void initState() {
    super.initState();
    _loadRevenueData();
  }

  // --- FUNGSI MENGAMBIL DATA DARI API ---
  Future<void> _loadRevenueData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await _reportService.getRevenue(year: selectedYear);

    if (result['success']) {
      setState(() {
        // Parsing Total Setahun
        yearlyTotal = double.tryParse(result['data']['yearly_total'].toString()) ?? 0;
        
        // Parsing Array Bulanan
        List<dynamic> rawMonthly = result['data']['monthly_revenue'] ?? [];
        monthlyRevenue = rawMonthly.map((e) => double.tryParse(e.toString()) ?? 0).toList();

        // Antisipasi jika API mengembalikan data kurang dari 12 bulan
        while (monthlyRevenue.length < 12) {
          monthlyRevenue.add(0);
        }

        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = result['message'];
        isLoading = false;
      });
    }
  }

  // Fungsi untuk mendapatkan nilai tertinggi agar grafik menyesuaikan
  double _getMaxY() {
    double max = 1000000; // Minimal 1 Juta agar grafik tidak gepeng jika kosong
    for (var val in monthlyRevenue) {
      if (val > max) max = val;
    }
    return max * 1.2; // Tambah ruang 20% di atas bar tertinggi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "Laporan Pendapatan",
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
    return RefreshIndicator(
      onRefresh: _loadRevenueData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            // --- 1. FILTER TAHUN ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Pilih Tahun",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  DropdownButton<int>(
                    value: selectedYear,
                    underline: const SizedBox(),
                    items: List.generate(5, (index) {
                      int year = DateTime.now().year - index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null && val != selectedYear) {
                        setState(() {
                          selectedYear = val;
                        });
                        // Panggil API ulang setiap kali tahun diubah!
                        _loadRevenueData();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Jika sedang loading, tampilkan indikator di tengah layar
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: Colors.blue)),
              )
            // Jika error, tampilkan pesan error
            else if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadRevenueData,
                      child: const Text("Coba Lagi"),
                    )
                  ],
                ),
              )
            // Jika sukses, tampilkan konten
            else ...[
              // --- 2. TOTAL PENDAPATAN TAHUNAN ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF0891B2)], // blue-600 to cyan-600
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Pendapatan Tahun $selectedYear",
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currency.format(yearlyTotal),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 3. GRAFIK PENDAPATAN BULANAN (BAR CHART) ---
              const Text(
                "Grafik Pendapatan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                height: 300,
                padding: const EdgeInsets.only(top: 24, bottom: 12, left: 12, right: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxY(), // Maksimal Y Dinamis!
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${monthNames[group.x]}\n',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: currency.format(rod.toY),
                                style: const TextStyle(color: Colors.yellow, fontSize: 12),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < monthNames.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  monthNames[value.toInt()],
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const Text('');
                            // Menampilkan format jutaan (M)
                            return Text(
                              '${(value / 1000000).toInt()}M',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      // Garis bantu horizontal setiap (max/5)
                      horizontalInterval: _getMaxY() / 5,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(monthlyRevenue.length, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: monthlyRevenue[index],
                            color: const Color(0xFF06B6D4), // Cyan-500
                            width: 16,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // --- 4. LIST RINCIAN BULANAN ---
              const Text(
                "Rincian Bulanan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: monthlyRevenue.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    // Reverse index agar bulan Desember di atas
                    int reversedIndex = (monthlyRevenue.length - 1) - index;
                    return ListTile(
                      title: Text(
                        "${monthNames[reversedIndex]} $selectedYear",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Text(
                        currency.format(monthlyRevenue[reversedIndex]),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}