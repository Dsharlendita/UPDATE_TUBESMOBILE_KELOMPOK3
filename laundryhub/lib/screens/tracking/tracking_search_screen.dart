import 'package:flutter/material.dart';

import 'tracking_screen.dart';


class TrackingSearchScreen extends StatefulWidget {

  const TrackingSearchScreen({
    super.key,
  });

  @override
  State<TrackingSearchScreen> createState() =>
      _TrackingSearchScreenState();

}

class _TrackingSearchScreenState
    extends State<TrackingSearchScreen> {

  final TextEditingController
      trackingController =
          TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Lacak Laundry",
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(24),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 20),

            const Text(

              "Masukkan Kode Tracking",

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                    FontWeight.bold,

              ),

            ),

            const SizedBox(height: 8),

            const Text(
              "Masukkan kode tracking yang diberikan oleh laundry.",
            ),

            const SizedBox(height: 24),

            TextField(

              controller:
                  trackingController,

              textCapitalization:
                  TextCapitalization.characters,

              decoration:
                  InputDecoration(

                hintText:
                    "Contoh: 9A262985",

                prefixIcon:
                    const Icon(
                  Icons.search,
                ),

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),

                ),

              ),

            ),

            const SizedBox(height: 24),

            SizedBox(

              width: double.infinity,

              height: 52,

              child: ElevatedButton(

                onPressed: () {

                  final code =
                      trackingController.text
                          .trim();

                  if (code.isEmpty) {

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(

                      const SnackBar(

                        content: Text(
                          "Masukkan kode tracking",
                        ),

                      ),

                    );

                    return;

                  }

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          TrackingScreen(
                        trackingCode:
                            code,
                      ),

                    ),

                  );

                },

                child: const Text(
                  "Lacak Sekarang",
                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}