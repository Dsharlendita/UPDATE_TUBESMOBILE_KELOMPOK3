import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

String formatRupiah(dynamic value) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(
    double.tryParse(value.toString()) ?? 0,
  );
}


class RecentTransactionCard
    extends StatelessWidget {

  final List transactions;

  const RecentTransactionCard({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      color: Colors.white,

      elevation: 2,

      shape:
      RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(20),

      ),

      child: SizedBox(

        height:320,

        child:Column(

          children:[

            Padding(

              padding:
              const EdgeInsets.all(15),

              child:
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    "Transaksi Terbaru",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  TextButton(
                    onPressed: () {

                      Navigator.pushNamed(
                        context,
                        "/transactions",
                      );

                    },
                    child: const Text(
                      "Lihat Semua",
                    ),
                  ),
                ],
              ),
            ),

            Expanded(

              child:

              transactions.isEmpty

                  ?

              Center(

                child: Column(

                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    Icon(

                      Icons.receipt_long,

                      size: 45,

                      color:
                      Colors.grey.shade400,

                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(

                      "Belum ada transaksi",

                      style: TextStyle(

                        color:
                        Colors.grey.shade600,

                      ),

                    ),

                  ],

                ),

              )

                  :

              ListView.separated(

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                ),

                itemCount: transactions.length > 4
                    ? 4
                    : transactions.length,

                separatorBuilder:
                    (_, __) =>
                const Divider(),

                itemBuilder:
                    (context,index){

                  final trx =
                  transactions[index];

                  return ListTile(

                    dense: true,

                    leading:

                    CircleAvatar(

                      backgroundColor:
                      Colors.blue.shade50,

                      child: Text(

                        trx["customer"]?["name"]
                            ?.toString()
                            .substring(0,1)
                            .toUpperCase()

                            ??

                        "?",

                      ),

                    ),

                    title: Text(

                      trx["customer"]?["name"]
                          ?? "-",

                      maxLines: 1,

                      overflow:
                      TextOverflow.ellipsis,

                    ),

                    subtitle: Text(

                      trx["invoice_number"]
                          ?? "-",

                    ),

                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        Text(
                          formatRupiah(
                            trx["final_price"],
                          ),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            trx["status"] ?? "",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),

                      ],
                    ),

                  );

                },

              ),

            )

          ],

        ),

      ),

    );

  }

}