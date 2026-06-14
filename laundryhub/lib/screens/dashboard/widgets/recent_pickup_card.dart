import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../pickup/pickup_screen.dart';

class RecentPickupCard extends StatelessWidget {
  final List pickups;

  const RecentPickupCard({
    super.key,
    required this.pickups,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 320,
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    "Pickup Terbaru",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PickupScreen(),
                        ),
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
              child: pickups.isEmpty

                  ? Center(
                      child: Text(
                        "Belum ada pickup",
                        style: GoogleFonts.poppins(),
                      ),
                    )

                  : ListView.separated(

                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),

                      itemCount:
                          pickups.length > 4
                              ? 4
                              : pickups.length,

                      separatorBuilder:
                          (_, __) =>
                              const Divider(),

                      itemBuilder:
                          (context,index){

                        final pickup =
                            pickups[index];

                        debugPrint(
                          "PICKUP ITEM => $pickup",
                        );

                        debugPrint(
                          "CUSTOMER => ${pickup["customer"]}",
                        );

                        debugPrint(
                          "TRANSACTION => ${pickup["transaction"]}",
                        );

                        return ListTile(

                          dense: true,

                          leading:
                          CircleAvatar(
                            backgroundColor:
                                Colors.purple.shade50,
                            child: const Icon(
                              Icons.local_shipping,
                              color: Colors.purple,
                            ),
                          ),

                          title: Text(
                            pickup["customer"]?["name"] ?? "-",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          subtitle: Text(
                            pickup["transaction"]?["invoice_number"] ?? "-",
                          ),

                          trailing:

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration:
                            BoxDecoration(
                              color:
                              Colors.green.shade100,
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                            child: Text(
                              pickup["status"]
                                  ?? "",
                              style:
                              GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight:
                                FontWeight.w600,
                                color:
                                Colors.green.shade800,
                              ),
                            ),
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