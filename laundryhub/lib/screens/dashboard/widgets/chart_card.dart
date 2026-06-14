import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class ChartCard extends StatefulWidget {

  final int totalTransactions;
  final double totalIncome;

  const ChartCard({
    super.key,
    required this.totalTransactions,
    required this.totalIncome,
  });

  @override
  State<ChartCard> createState() =>
      _ChartCardState();
}



class _ChartCardState extends State<ChartCard> {
  bool showIncome = false;

  @override
  Widget build(BuildContext context) {

    final currentMonth = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ][DateTime.now().month - 1];

    final currentYear = DateTime.now().year;

    final incomeValue =
        widget.totalIncome / 1000;

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TITLE
          Text(
            "Analitik Bulanan",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          /// SEGMENT BUTTON
          SegmentedButton<bool>(
            segments: const [

              ButtonSegment(
                value: false,
                icon: Icon(Icons.receipt_long),
                label: Text("Transaksi"),
              ),

              ButtonSegment(
                value: true,
                icon: Icon(Icons.payments),
                label: Text("Pendapatan"),
              ),
            ],

            selected: {showIncome},

            onSelectionChanged: (value) {
              setState(() {
                showIncome = value.first;
              });
            },
          ),

          const SizedBox(height: 24),

          /// GRAFIK
          SizedBox(
            height: 260,

            child: showIncome

                /// PENDAPATAN = BAR CHART
                ? BarChart(
                    BarChartData(

                      minY: 0,

                      maxY:
                          incomeValue <= 100
                              ? 100
                              : incomeValue + 20,

                      borderData:
                          FlBorderData(show: false),

                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: 20,
                      ),

                      titlesData: FlTitlesData(

                        topTitles: const AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false),
                        ),

                        rightTitles: const AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false),
                        ),

                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(

                            showTitles: true,

                            reservedSize: 35,

                            interval: 20,

                            getTitlesWidget:
                                (value, meta) {

                              return Text(
                                value.toInt().toString(),
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 10,
                                ),
                              );

                            },

                          ),
                        ),

                        bottomTitles: AxisTitles(

                          sideTitles: SideTitles(

                            showTitles: true,

                            reservedSize: 40,

                            getTitlesWidget:
                                (value, meta) {

                              const months = [

                                "Jan",
                                "Feb",
                                "Mar",
                                "Apr",
                                "Mei",
                                "Jun",
                                "Jul",
                                "Agu",
                                "Sep",
                                "Okt",
                                "Nov",
                                "Des",

                              ];

                              if (value.toInt() >=
                                  months.length) {
                                return const SizedBox();
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.only(
                                  top: 12,
                                ),
                                child: Text(
                                  months[value.toInt()],
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                              );

                            },

                          ),
                        ),
                      ),

                      barGroups: [

                        for (int i = 0; i < 12; i++)

                          BarChartGroupData(

                            x: i,

                            barRods: [

                              BarChartRodData(

                                toY:
                                    i == DateTime.now().month - 1
                                        ? incomeValue
                                        : 0,

                                width: 32,

                                borderRadius:
                                    BorderRadius.circular(8),

                                color: const Color(
                                  0xff62B7D1,
                                ),
                              ),
                            ],
                          ),
                      ],
                  ),
                )

                /// TRANSAKSI = LINE CHART
                : LineChart(

                    LineChartData(

                      minX: 0,
                      maxX: 11,

                      minY: 0,
                      maxY:
                        widget.totalTransactions <= 10
                            ? 10
                            : (widget.totalTransactions + 5)
                                .toDouble(),

                      borderData:
                          FlBorderData(show: false),

                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                      ),

                      titlesData: FlTitlesData(

                        topTitles: const AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false),
                        ),

                        rightTitles: const AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false),
                        ),

                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: showIncome ? 20 : 2,

                            getTitlesWidget: (value, meta) {

                              return Text(
                                value.toInt().toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                ),
                              );

                            },
                          ),
                        ),

                        bottomTitles: AxisTitles(

                          sideTitles: SideTitles(

                            showTitles: true,
                            reservedSize: 50,

                            getTitlesWidget:
                                (value, meta) {

                              const months = [

                                "Jan",
                                "Feb",
                                "Mar",
                                "Apr",
                                "Mei",
                                "Jun",
                                "Jul",
                                "Agu",
                                "Sep",
                                "Okt",
                                "Nov",
                                "Des",

                              ];

                              if (value.toInt() >=
                                  months.length) {
                                return const SizedBox();
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.only(
                                  top: 16,
                                ),
                                child: Text(
                                  months[value.toInt()],
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      lineBarsData: [

                        LineChartBarData(

                          spots: [

                            for (int i = 0; i < 12; i++)

                              FlSpot(
                                i.toDouble(),
                                i == DateTime.now().month - 1
                                    ? widget.totalTransactions.toDouble()
                                    : 0,
                              ),

                          ],

                          isCurved: false,

                          color:
                              const Color(
                            0xff5B7FFF,
                          ),

                          barWidth: 3,

                          dotData:
                              const FlDotData(
                            show: true,
                          ),

                          belowBarData:
                              BarAreaData(
                            show: true,
                            color: const Color(
                              0xff5B7FFF,
                            ).withOpacity(0.12),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          const SizedBox(height: 20),

          /// SUMMARY
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: const Color(0xffEEF5FF),
              borderRadius: BorderRadius.circular(18),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      "Ringkasan Bulan Ini",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$currentMonth $currentYear",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  showIncome
                      ? formatRupiah(
                          widget.totalIncome.toInt(),
                        )
                      : "${widget.totalTransactions} Transaksi",

                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  showIncome
                      ? "Pendapatan bulan berjalan"
                      : "Transaksi bulan berjalan",

                  style: GoogleFonts.poppins(
                    color: Colors.grey,
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
  String formatRupiah(int value) {
    return "Rp ${value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}";
  }
}