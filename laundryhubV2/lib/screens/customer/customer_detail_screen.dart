import 'package:flutter/material.dart';
import '../../services/customer_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../transaction/add_transaction_screen.dart';
import 'customer_transaction_history_screen.dart';


class CustomerDetailScreen extends StatefulWidget {
  final dynamic customer;

  const CustomerDetailScreen({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState
    extends State<CustomerDetailScreen> {

  final CustomerService service =
      CustomerService();

  bool isLoading = true;

  Map<String, dynamic> stats = {};

  List transactions = [];
  List pickups = [];

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  Future<void> loadDetail() async {

    final customerId =
        int.tryParse(
              widget.customer.id.toString(),
            ) ??
            0;

    final result =
        await service.getCustomerDetail(
      customerId,
    );

    if (result["success"] == true) {

      final data = result["data"];

      stats = data["stats"] ?? {};

      transactions =
          ((data["transactions"]?["data"]) ?? [])
              .toList();

      pickups =
          data["pickups"] ?? [];
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String get avatarText {

    final name =
        widget.customer.name.toString();

    if (name.length >= 2) {
      return name
          .substring(0, 2)
          .toUpperCase();
    }

    return name.toUpperCase();
  }

  String formatDate(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return "-";
    }

    try {

      final date =
          DateTime.parse(value);

      return DateFormat(
        "dd MMM yyyy",
      ).format(date);

    } catch (e) {

      return "-";

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xffF5F7FB),

      appBar: AppBar(
        title:
            const Text("Detail Pelanggan"),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                children: [

                  _buildHeader(),

                  const SizedBox(height: 16),

                  _buildStatsCards(),

                  const SizedBox(height: 16),

                  _buildTransactions(),

                  const SizedBox(height: 16),

                  _buildSummary(),

                  const SizedBox(height: 16),

                  _buildFavoriteServices(),

                  const SizedBox(height: 16),

                  _buildPickupHistory(),

                  const SizedBox(height: 16),

                  _buildQuickActions(),

                ],
              ),
            ),
    );
  }

  Future<void> openWhatsapp() async {
    String phone = widget.customer.phone.toString();

    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    }

    final Uri url = Uri.parse(
      'https://wa.me/$phone',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Widget _buildHeader() {

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          CircleAvatar(
            radius: 32,
            backgroundColor:
                Colors.blue,
            child: Text(
              avatarText,
              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Row(
                  children: [

                    Expanded(
                      child: Text(
                        widget.customer.name,
                        style:
                            const TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .blue
                            .shade100,
                        borderRadius:
                            BorderRadius.circular(
                                20),
                      ),
                      child:
                          const Text(
                        "Member",
                      ),
                    ),

                  ],
                ),
              
                
                const SizedBox(height: 16),

                Column(
                  children: [

                    _headerInfo(
                      "Email",
                      widget.customer.email.toString(),
                    ),

                    const SizedBox(height: 12),

                    _headerInfo(
                      "Telepon",
                      widget.customer.phone.toString(),
                    ),

                    const SizedBox(height: 12),

                    _headerInfo(
                      "Bergabung",
                      stats["first_transaction"] != null
                          ? formatDate(
                              stats["first_transaction"]
                                  ["created_at"]
                                  ?.toString(),
                            )
                          : "-",
                    ),

                  ],
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildStatsCards() {

    final totalWeight =
      double.tryParse(
        stats["total_weight"]
            ?.toString() ??
            "0",
      ) ??
      0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      primary: false,
      physics:
          const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [

        _statCard(
          "Total Transaksi",
          "${stats["total_transactions"] ?? 0}",
          Colors.black,
        ),

        _statCard(
          "Total Pembayaran",
          NumberFormat.currency(
            locale: "id_ID",
            symbol: "Rp ",
            decimalDigits: 0,
          ).format(
            double.tryParse(
              stats["total_spent"]
                  ?.toString() ??
                  "0",
            ) ??
                0,
          ),
          Colors.green,
        ),

        _statCard(
          "Total Berat",
          totalWeight % 1 == 0
              ? "${totalWeight.toInt()} kg"
              : "${totalWeight.toStringAsFixed(1)} kg",
          Colors.blue,
        ),

        _statCard(
          "Pickup",
          "${stats["total_pickups"] ?? 0}",
          Colors.purple,
        ),

      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    Color color,
  ) {

    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [

          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            textAlign:
                TextAlign.center,
          ),

        ],
      ),
    );
  }

  Widget _buildTransactions() {
    final recentTransactions = transactions.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER
          Row(
            children: [

              const Text(
                "Riwayat Transaksi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CustomerTransactionHistoryScreen(
                        transactions: transactions,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Lihat Semua",
                ),
              ),

            ],
          ),

          const SizedBox(height: 12),

          if (recentTransactions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: Text(
                  "Belum ada transaksi",
                ),
              ),
            ),

          ...recentTransactions.map((trx) {

            final invoice =
                trx["invoice_number"]?.toString() ??
                    "-";

            final date =
                formatDate(
                  trx["created_at"]
                      ?.toString(),
                );

            final weight =
                double.tryParse(
                      trx["total_weight"]
                              ?.toString() ??
                          "0",
                    ) ??
                    0;

            final total =
                double.tryParse(
                      trx["final_price"]
                              ?.toString() ??
                          "0",
                    ) ??
                    0;

            final status =
                trx["status"]
                        ?.toString() ??
                    "-";

            final payment =
                trx["payment_status"]
                        ?.toString() ??
                    "-";

            /// layanan
            String layanan = "-";

            if (trx["details"] != null &&
                trx["details"] is List &&
                (trx["details"] as List).isNotEmpty) {

              layanan = (trx["details"] as List)
                  .map(
                    (e) =>
                        e["service_name"]
                            ?.toString() ??
                        "",
                  )
                  .where(
                    (e) => e.isNotEmpty,
                  )
                  .join(", ");
            }

            return Container(
              margin: const EdgeInsets.only(
                bottom: 12,
              ),
              padding: const EdgeInsets.all(
                14,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    invoice,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    date,
                    style: TextStyle(
                      color:
                          Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _trxInfo(
                    "Layanan",
                    layanan,
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  _trxInfo(
                    "Berat",
                    weight % 1 == 0
                        ? "${weight.toInt()} kg"
                        : "${weight.toStringAsFixed(1)} kg",
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  _trxInfo(
                    "Total",
                    NumberFormat.currency(
                      locale: "id_ID",
                      symbol: "Rp ",
                      decimalDigits: 0,
                    ).format(total),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Row(
                    children: [

                      const SizedBox(
                        width: 70,
                        child: Text(
                          "Status",
                        ),
                      ),

                      const Text(": "),

                      _statusChip(
                        status,
                      ),

                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Row(
                    children: [

                      const SizedBox(
                        width: 70,
                        child: Text(
                          "Bayar",
                        ),
                      ),

                      const Text(": "),

                      _paymentChip(
                        payment,
                      ),

                    ],
                  ),

                ],
              ),
            );
          }).toList(),

        ],
      ),
    );
  }

  Widget _paymentChip(
    String payment,
  ) {

    Color bg;
    Color fg;

    if (payment == "paid") {

      bg = Colors.green.shade100;
      fg = Colors.green.shade800;

    } else {

      bg = Colors.red.shade100;
      fg = Colors.red.shade800;

    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: 
      Text(
        payment == "paid"
            ? "Lunas"
            : "Belum",
        style: TextStyle(
          color: fg,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _trxInfo(
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ),

        const SizedBox(
          width: 15,
          child: Text(":"),
        ),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

      ],
    );
  }

  Widget _statusChip(
    String status,
  ) {

    Color bg =
        Colors.grey.shade200;

    Color fg =
        Colors.grey.shade800;

    switch (status) {

      case "pending":
        bg = Colors.yellow.shade100;
        fg = Colors.orange.shade800;
        break;

      case "confirmed":
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade800;
        break;

      case "washing":
        bg = Colors.cyan.shade100;
        fg = Colors.cyan.shade800;
        break;

      case "drying":
        bg = Colors.indigo.shade100;
        fg = Colors.indigo.shade800;
        break;

      case "ironing":
        bg = Colors.purple.shade100;
        fg = Colors.purple.shade800;
        break;

      case "ready":
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        break;

      case "completed":
        bg = Colors.grey.shade300;
        fg = Colors.black87;
        break;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSummary() {

    return _section(
      "Ringkasan Pelanggan",
      Column(
        children: [

          _summaryRow(
            "Transaksi Pertama",
            stats["first_transaction"] != null
                ? formatDate(
                    stats["first_transaction"]
                            ["created_at"]
                        ?.toString(),
                  )
                : "-",
          ),

          const Divider(),

          _summaryRow(
            "Transaksi Terakhir",
            stats["last_transaction"] != null
                ? formatDate(
                    stats["last_transaction"]
                            ["created_at"]
                        ?.toString(),
                  )
                : "-",
          ),

          const Divider(),

          _summaryRow(
            "Transaksi Selesai",
            "${stats["completed_transactions"] ?? 0}/${stats["total_transactions"] ?? 0}",
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [

          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),

        ],
      ),
    );
  }

  String formatDateTime(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return "-";
    }

    try {

      final date =
          DateTime.parse(value);

      return DateFormat(
        "dd/MM/yyyy HH:mm",
      ).format(date);

    } catch (e) {

      return "-";

    }
  }

  Widget _buildFavoriteServices() {

    final favorites =
        stats["favorite_services"] ?? [];

    if (favorites.isEmpty) {

      return _section(
        "Layanan Favorit",
        const Text("-"),
      );
    }

    return _section(
      "Layanan Favorit",
      Column(
        children:
            favorites.map<Widget>((item) {

          return Padding(
            padding:
                const EdgeInsets.only(
              bottom: 10,
            ),
            child: Row(
              children: [

                Expanded(
                  child: Text(
                    item["service_name"]
                            ?.toString() ??
                        "-",
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors
                        .blue.shade100,
                    borderRadius:
                        BorderRadius.circular(
                            20),
                  ),
                  child: Text(
                    "${item["count"] ?? 0}x",
                  ),
                ),

              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPickupHistory() {

    if (pickups.isEmpty) {
      return _section(
        "Riwayat Pickup",
        const Text("-"),
      );
    }

    return _section(
      "Riwayat Pickup",
      Column(
        children:
            pickups.map<Widget>((p) {

          final status =
              p["status"]
                      ?.toString() ??
                  "";

          return Padding(
            padding:
                const EdgeInsets.only(
              bottom: 12,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [

                      Text(
                        formatDateTime(
                          p["pickup_date"]
                              ?.toString(),
                        ),
                      ),

                      const SizedBox(
                          height: 4),

                      Text(
                        p["pickup_address"]
                                ?.toString() ??
                            "-",
                        style:
                            TextStyle(
                          color: Colors
                              .grey.shade600,
                          fontSize: 12,
                        ),
                      ),

                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration:
                      BoxDecoration(
                    color: status ==
                            "completed"
                        ? Colors.green
                            .shade100
                        : Colors.orange
                            .shade100,
                    borderRadius:
                        BorderRadius.circular(
                            20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status ==
                              "completed"
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),

              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickActions() {

    return _section(
      "Aksi Cepat",
      Column(
        children: [

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTransactionScreen(
                      customer: widget.customer,
                    ),
                  ),
                );

                if (result == true) {
                  loadDetail();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text(
                "Buat Transaksi Baru",
              ),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                String phone =
                    widget.customer.phone.toString();

                phone = phone.replaceAll(
                  RegExp(r'[^0-9]'),
                  '',
                );

                if (phone.startsWith('0')) {
                  phone = '62${phone.substring(1)}';
                }

                final Uri url = Uri.parse(
                  'https://wa.me/$phone',
                );

                await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                );
              },
              icon: const Icon(
                Icons.chat,
              ),
              label: const Text(
                "Hubungi WhatsApp",
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _section(
    String title,
    Widget child,
  ) {

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style:
                const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
              height: 12),

          child,

        ],
      ),
    );
  }

  Widget _headerInfo(
    String title,
    String value,
  ) {
    return Row(
      children: [

        SizedBox(
          width: 90,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

      ],
    );
  }
}