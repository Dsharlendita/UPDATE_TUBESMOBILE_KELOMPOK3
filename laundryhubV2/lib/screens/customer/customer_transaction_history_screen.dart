import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerTransactionHistoryScreen extends StatelessWidget {
  final List transactions;

  const CustomerTransactionHistoryScreen({
    super.key,
    required this.transactions,
  });

  String formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return "-";
    }

    try {
      return DateFormat(
        "dd MMM yyyy",
      ).format(
        DateTime.parse(value),
      );
    } catch (_) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Semua Transaksi",
        ),
      ),
      body: transactions.isEmpty
    ? const Center(
        child: Text(
          "Belum ada transaksi",
        ),
      )
    : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {

          final trx = transactions[index];

          final invoice =
              trx["invoice_number"]
                      ?.toString() ??
                  "-";

          final date = formatDate(
            trx["created_at"]
                ?.toString(),
          );

          final total =
              double.tryParse(
                    trx["final_price"]
                            ?.toString() ??
                        "0",
                  ) ??
                  0;

          final weight =
              double.tryParse(
                    trx["total_weight"]
                            ?.toString() ??
                        "0",
                  ) ??
                  0;

          final status =
              trx["status"]
                      ?.toString() ??
                  "-";

          return Container(
            margin: const EdgeInsets.only(
              bottom: 16,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Row(
                  children: [

                    Expanded(
                      child: Text(
                        invoice,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    _statusChip(status),

                  ],
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  date,
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                const Divider(
                  height: 24,
                ),

                _infoRow(
                  "Berat",
                  "${weight.toStringAsFixed(1)} kg",
                ),

                const SizedBox(
                  height: 8,
                ),

                _infoRow(
                  "Total",
                  NumberFormat.currency(
                    locale: "id_ID",
                    symbol: "Rp ",
                    decimalDigits: 0,
                  ).format(total),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
  ) {
    return Row(
      children: [

        SizedBox(
          width: 70,
          child: Text(
            label,
          ),
        ),

        const Text(": "),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight:
                  FontWeight.w600,
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
        Colors.black87;

    switch (status) {

      case "pending":
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade800;
        break;

      case "washing":
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade800;
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
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }
}