import 'package:flutter/material.dart';

import '../../models/pickup_model.dart';
import '../../services/pickup_service.dart';

class RequestDeliveryScreen extends StatefulWidget {
  const RequestDeliveryScreen({super.key});

  @override
  State<RequestDeliveryScreen> createState() => _RequestDeliveryScreenState();
}

class _RequestDeliveryScreenState extends State<RequestDeliveryScreen> {
  final PickupService pickupService = PickupService();

  final TextEditingController searchController = TextEditingController();

  List<PickupModel> deliveries = [];

  bool isLoading = true;

  Map<String, dynamic> stats = {};

  String selectedStatus = "";

  DateTime? dateFrom;
  DateTime? dateTo;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });

    final result = await pickupService.getPickups(
      type: "delivery",

      status: selectedStatus.isEmpty ? null : selectedStatus,

      search: searchController.text,

      dateFrom: dateFrom != null
          ? "${dateFrom!.year}-${dateFrom!.month.toString().padLeft(2, '0')}-${dateFrom!.day.toString().padLeft(2, '0')}"
          : null,

      dateTo: dateTo != null
          ? "${dateTo!.year}-${dateTo!.month.toString().padLeft(2, '0')}-${dateTo!.day.toString().padLeft(2, '0')}"
          : null,
    );

    if (result["success"]) {
      deliveries = result["pickups"];

      stats = result["stats"];
    }

    setState(() {
      isLoading = false;
    });
  }

  Future pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2023),

      lastDate: DateTime(2100),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff4F6EF7),

              onPrimary: Colors.white,

              surface: Colors.white,
            ),
          ),

          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          dateFrom = picked;
        } else {
          dateTo = picked;
        }
      });
    }
  }

  Widget statCard(String title, dynamic value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(14),

          border: Border.all(color: color.withOpacity(.2)),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(title, style: TextStyle(color: color, fontSize: 12)),

            const SizedBox(height: 5),

            Text(
              "$value",

              style: TextStyle(
                fontSize: 24,

                fontWeight: FontWeight.bold,

                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;

      case "accepted":
        return Colors.blue;

      case "on_the_way":
        return Colors.purple;

      case "completed":
        return Colors.green;

      case "cancelled":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  String statusText(String status) {
    switch (status) {
      case "pending":
        return "Menunggu";

      case "accepted":
        return "Diterima";

      case "on_the_way":
        return "Proses";

      case "completed":
        return "Selesai";

      case "cancelled":
        return "Batal";

      default:
        return status;
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> processDeliveryAction(PickupModel item, String action) async {
    Map<String, dynamic> result;

    setState(() {
      isLoading = true;
    });

    if (action == "accept") {
      result = await pickupService.acceptPickup(item.id);
    } else if (action == "on_the_way") {
      result = await pickupService.onTheWayPickup(item.id);
    } else if (action == "complete") {
      result = await pickupService.completePickup(item.id);
    } else {
      result = {"success": false, "message": "Aksi tidak valid"};
    }

    if (!mounted) return;

    showMessage(
      result["message"]?.toString() ??
          (result["success"] == true
              ? "Berhasil memperbarui status"
              : "Gagal memperbarui status"),
    );

    await loadData();
  }

  Future<void> showCancelDialog(PickupModel item) async {
    final TextEditingController reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Batalkan Pengantaran"),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Masukkan alasan pembatalan",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Tutup"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final reason = reasonController.text.trim();

                if (reason.isEmpty) {
                  showMessage("Alasan pembatalan wajib diisi");
                  return;
                }

                Navigator.pop(dialogContext);

                setState(() {
                  isLoading = true;
                });

                final result = await pickupService.cancelPickup(
                  item.id,
                  reason,
                );

                if (!mounted) return;

                showMessage(
                  result["message"]?.toString() ??
                      (result["success"] == true
                          ? "Pengantaran berhasil dibatalkan"
                          : "Gagal membatalkan pengantaran"),
                );

                await loadData();
              },
              child: const Text("Batalkan"),
            ),
          ],
        );
      },
    );

    reasonController.dispose();
  }

  Widget actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, textAlign: TextAlign.center),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget deliveryActionButtons(PickupModel item) {
    if (item.status == "pending") {
      return Row(
        children: [
          actionButton(
            label: "Terima",
            icon: Icons.check_circle_outline,
            color: Colors.blue,
            onPressed: () {
              processDeliveryAction(item, "accept");
            },
          ),
          const SizedBox(width: 10),
          actionButton(
            label: "Batalkan",
            icon: Icons.cancel_outlined,
            color: Colors.red,
            onPressed: () {
              showCancelDialog(item);
            },
          ),
        ],
      );
    }

    if (item.status == "accepted") {
      return Row(
        children: [
          actionButton(
            label: "Dalam Perjalanan",
            icon: Icons.local_shipping_outlined,
            color: Colors.purple,
            onPressed: () {
              processDeliveryAction(item, "on_the_way");
            },
          ),
          const SizedBox(width: 10),
          actionButton(
            label: "Batalkan",
            icon: Icons.cancel_outlined,
            color: Colors.red,
            onPressed: () {
              showCancelDialog(item);
            },
          ),
        ],
      );
    }

    if (item.status == "on_the_way") {
      return Row(
        children: [
          actionButton(
            label: "Selesai",
            icon: Icons.done_all,
            color: Colors.green,
            onPressed: () {
              processDeliveryAction(item, "complete");
            },
          ),
          const SizedBox(width: 10),
          actionButton(
            label: "Batalkan",
            icon: Icons.cancel_outlined,
            color: Colors.red,
            onPressed: () {
              showCancelDialog(item);
            },
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,

        title: const Text(
          "Request Pengantaran",

          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),

        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: RefreshIndicator(
        onRefresh: loadData,

        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            Row(
              children: [
                statCard("Total", stats["total"] ?? 0, Colors.black),

                const SizedBox(width: 10),

                statCard("Menunggu", stats["pending"] ?? 0, Colors.orange),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                statCard("Diterima", stats["accepted"] ?? 0, Colors.blue),

                const SizedBox(width: 10),

                statCard("Selesai", stats["completed"] ?? 0, Colors.green),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedStatus.isEmpty ? null : selectedStatus,

                    decoration: InputDecoration(
                      labelText: "Status",

                      filled: true,

                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    hint: const Text("Semua Status"),

                    items: [
                      const DropdownMenuItem(
                        value: "pending",
                        child: Text("Menunggu"),
                      ),

                      const DropdownMenuItem(
                        value: "accepted",
                        child: Text("Diterima"),
                      ),

                      const DropdownMenuItem(
                        value: "on_the_way",
                        child: Text("Proses"),
                      ),

                      const DropdownMenuItem(
                        value: "completed",
                        child: Text("Selesai"),
                      ),

                      const DropdownMenuItem(
                        value: "cancelled",
                        child: Text("Batal"),
                      ),
                    ],

                    onChanged: (v) {
                      setState(() {
                        selectedStatus = v ?? "";
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            pickDate(true);
                          },

                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),

                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),

                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  color: Color(0xff4F6EF7),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    dateFrom == null
                                        ? "Tanggal Dari"
                                        : "${dateFrom!.day}/${dateFrom!.month}/${dateFrom!.year}",

                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: InkWell(
                          onTap: () {
                            pickDate(false);
                          },

                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),

                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),

                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  color: Color(0xff4F6EF7),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    dateTo == null
                                        ? "Tanggal Sampai"
                                        : "${dateTo!.day}/${dateTo!.month}/${dateTo!.year}",

                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: searchController,

                    decoration: InputDecoration(
                      hintText: "Nama, telepon, atau invoice...",

                      prefixIcon: const Icon(Icons.search),

                      filled: true,

                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              selectedStatus = "";
                              searchController.clear();

                              dateFrom = null;
                              dateTo = null;
                            });

                            loadData();
                          },

                          child: const Text("Reset"),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            loadData();
                          },

                          icon: const Icon(Icons.filter_alt),

                          label: const Text("Filter"),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff4F6EF7),

                            foregroundColor: Colors.white,

                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (deliveries.isEmpty)
              Container(
                height: 320,

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Icon(
                      Icons.delivery_dining,

                      size: 80,

                      color: Colors.grey.shade300,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Belum Ada Request Pengantaran",

                      style: TextStyle(
                        fontSize: 20,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Request pengantaran dari pelanggan akan muncul di sini.",

                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            else
              ...deliveries.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 14),

                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Expanded(
                            child: Text(
                              item.customerName,

                              style: const TextStyle(
                                fontSize: 18,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color: statusColor(item.status).withOpacity(.1),

                              borderRadius: BorderRadius.circular(30),
                            ),

                            child: Text(
                              statusText(item.status),

                              style: TextStyle(
                                color: statusColor(item.status),

                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(item.phone),

                      const SizedBox(height: 4),

                      Text(item.address),

                      const SizedBox(height: 10),

                      Text("Invoice : ${item.invoice ?? '-'}"),
                      const SizedBox(height: 6),

                      Text(
                        "Jadwal : ${item.pickupDate.isEmpty ? '-' : item.pickupDate}",
                      ),

                      const SizedBox(height: 14),

                      deliveryActionButtons(item),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
