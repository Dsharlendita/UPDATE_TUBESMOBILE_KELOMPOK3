import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/pickup_service.dart';

class PickupDetailScreen extends StatefulWidget {
  final int pickupId;

  const PickupDetailScreen({
    super.key,
    required this.pickupId,
  });

  @override
  State<PickupDetailScreen> createState() =>
      _PickupDetailScreenState();
}

class _PickupDetailScreenState
    extends State<PickupDetailScreen> {

  final PickupService pickupService =
      PickupService();

  bool loading = true;

  Map<String, dynamic>? pickup;
  Map<String, dynamic>? transaction;

  int displayNumber = 0;

  bool get isDelivery {

    if (pickup == null) {
      return false;
    }

    return pickup!["type"] == "delivery";
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

    final result =
        await pickupService.getPickupDetail(
      widget.pickupId,
    );

    if (result["success"] == true) {

      final detail =
          result["data"];

      setState(() {

        pickup =
            detail.pickup;

        transaction =
            detail.transaction;
        
        displayNumber =
            detail.displayNumber ?? 0;

        loading = false;

      });

    } else {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            result["message"] ??
                "Gagal memuat detail pickup",
          ),
        ),
      );

      Navigator.pop(context);
    }
  }

  Future<void> acceptPickup() async {

    final result =
        await pickupService.acceptPickup(
      widget.pickupId,
    );

    if (result["success"]) {

      await loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Pickup berhasil diterima",
          ),

          backgroundColor:
              Colors.green,

        ),

      );

    } else {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            result["message"],
          ),
        ),

      );

    }

  }

  Future<void> cancelPickup() async {

    final result =
        await pickupService.cancelPickup(
      widget.pickupId,
      "Ditolak owner",
    );

    if (result["success"]) {

      await loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Pickup berhasil ditolak",
          ),

          backgroundColor:
              Colors.red,

        ),

      );

    } else {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            result["message"],
          ),
        ),

      );

    }

  }

  @override
  Widget build(BuildContext context) {

    if (loading) {

      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      backgroundColor:
          const Color(0xffF5F7FB),

      appBar: AppBar(
        title: Text(
          isDelivery
              ? "Request Pengantaran #$requestNumber"
              : "Pickup #${pickup!["id"]}",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: isDelivery
          ? buildDeliveryLayout()
          : buildPickupLayout(),
      ),
    );
  }

  String get requestNumber {

    if (displayNumber > 0) {
      return displayNumber.toString();
    }

    return pickup!["id"].toString();
  }

  Widget buildDeliveryLayout() {

    return Column(
      children: [

        buildStatusCard(),

        const SizedBox(height: 16),

        buildCustomerCard(),

        const SizedBox(height: 16),

        buildScheduleCard(),

        const SizedBox(height: 16),

        buildDeliveryAddressCard(),

        const SizedBox(height: 16),

        buildNoteCard(),

        const SizedBox(height: 16),

        buildTransactionCard(),

        const SizedBox(height: 16),

        buildLaundryDetailCard(),

        const SizedBox(height: 16),

        buildFragranceCard(),

      ],
    );
  }

  Widget buildPickupLayout() {

    return Column(
      children: [

        buildStatusCard(),

        const SizedBox(height: 16),

        buildCustomerCard(),

        const SizedBox(height: 16),

        buildPickupCard(),

        const SizedBox(height: 16),

        buildNoteCard(),

        const SizedBox(height: 16),

        buildServiceCard(),

        const SizedBox(height: 16),

        buildFragranceCard(),

      ],
    );
  }

  Widget buildScheduleCard() {

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              "Jadwal Pengantaran",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(),

            buildInfoRow(
              "Tanggal",
              DateFormat("dd MMM yyyy")
                  .format(
                DateTime.parse(
                  pickup!["pickup_date"],
                ),
              ),
            ),

            buildInfoRow(
              "Waktu",
              DateFormat("HH:mm")
                  .format(
                DateTime.parse(
                  pickup!["pickup_date"],
                ),
              ),
            ),

            buildInfoRow(
              "Status",
              statusText(
                pickup!["status"],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildDeliveryAddressCard() {

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              "Alamat Pengantaran",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(),

            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(
                  0xffF7F8FA,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),

              child: Text(
                pickup!["pickup_address"] ??
                    "-",
              ),

            ),

          ],
        ),
      ),
    );
  }

  String transactionStatusText(
    dynamic status,
  ) {
    switch (
      (status ?? "")
          .toString()
          .toLowerCase()
    ) {

      case "ready":
        return "Ready";

      case "completed":
        return "Selesai";

      case "cancelled":
        return "Dibatalkan";

      default:
        return status?.toString() ?? "-";
    }
  }


  Widget buildTransactionCard() {

    Widget item(
      String title,
      dynamic value,
    ) {
      final text =
          value?.toString() ?? "-";

      final isUnpaid =
          text == "Belum Dibayar";

      return Padding(
        padding: const EdgeInsets.only(
          bottom: 14,
        ),
        child: Row(
          children: [

            SizedBox(
              width: 140,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight:
                      FontWeight.w600,
                  color: isUnpaid
                      ? Colors.red
                      : Colors.black,
                ),
              ),
            ),

          ],
        ),
      );
    }

    return Card(

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              "Informasi Transaksi",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const Divider(),

            item(
              "Invoice",
              transaction?[
                  "invoice_number"],
            ),

            item(
              "Kode Tracking",
              transaction?[
                  "tracking_code"],
            ),

            item(
              "Status Transaksi",
              transactionStatusText(
                transaction?["status"],
              ),
            ),

            item(
              "Status Pembayaran",
              paymentStatusText(
                transaction?["payment_status"],
              ),
            ),

            item(
              "Metode Pickup",
              transaction?[
                  "payment_method"],
            ),

            item(
              "Pelunasan",
              transaction?[
                  "payment_type"],
            ),

          ],
        ),
      ),
    );
  }

  Widget buildLaundryDetailCard() {

    final services =
        transaction?["details"] ?? [];

    final totalWeight =
        transaction?["total_weight"] ??
        pickup?["estimated_weight"] ??
        0;

    final totalPrice =
        transaction?["total_price"] ??
        transaction?["grand_total"] ??
        transaction?["total_amount"] ??
        pickup?["estimated_price"] ??
        0;

    return Card(

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              "Detail Layanan Laundry",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Divider(),

            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: Row(
                children: [

                  Expanded(
                    flex: 4,
                    child: Text(
                      "LAYANAN",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      "HARGA",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: Text(
                      "BERAT",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      "TOTAL",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                ],
              ),
            ),

            const Divider(),

            ...(services as List)
                .map<Widget>((item) {

              return Padding(

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 8,
                ),

                child: Row(

                  children: [

                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [

                          Container(
                            width: 36,
                            height: 36,
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xffEEF4FF,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                8,
                              ),
                            ),
                            child: const Icon(
                              Icons.local_laundry_service,
                              color:
                                  Color(
                                0xff4F6BED,
                              ),
                              size: 18,
                            ),
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Expanded(
                            child: Text(
                              item[
                                  "service_name"],
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),

                    Expanded(
                      child: Text(
                        "Rp ${formatRupiah(item["price_per_kg"])}",
                        textAlign:
                            TextAlign.center,
                      ),
                    ),

                    Expanded(
                      child: Text(
                        "${formatWeight(item["weight"])} kg",
                        textAlign:
                            TextAlign.center,
                      ),
                    ),

                    Expanded(
                      child: Text(
                        "Rp ${formatRupiah(item["subtotal"])}",
                        textAlign:
                            TextAlign.end,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                  ],
                ),
              );
            }),

            const Divider(),

            const SizedBox(height: 8),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment.end,

              children: [

                const Text(
                  "Total Berat: ",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                Text(
                  "${formatWeight(totalWeight)} kg",
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 12),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment.end,

              children: [

                const Text(
                  "Total Harga: ",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                Text(
                  "Rp ${formatRupiah(totalPrice)}",
                  style:
                      const TextStyle(
                    color:
                        Color(0xff4F6BED),
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget buildStatusCard() {

    return Card(

      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                Expanded(

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        isDelivery
                            ? "Request Pengantaran #$requestNumber"
                            : "Pickup #${pickup!["id"]}",


                        style:
                            const TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),

                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(

                        DateFormat(
                          "dd MMM yyyy, HH:mm",
                        ).format(
                          DateTime.parse(
                            pickup![
                                "pickup_date"],
                          ),
                        ),

                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                        ),

                      ),

                    ],
                  ),
                ),

                statusBadge(
                  pickup!["status"],
                ),

              ],
            ),

            if (pickup!["status"] ==
                "pending") ...[

              const SizedBox(height: 16),

              Row(

                children: [

                  Expanded(

                    child:
                        ElevatedButton.icon(

                      onPressed: () async {

                        final confirm =
                            await showDialog<bool>(

                          context: context,

                          builder: (_) => AlertDialog(

                            title: const Text(
                              "Terima Pickup",
                            ),

                            content: const Text(
                              "Apakah Anda yakin ingin menerima pickup ini?",
                            ),

                            actions: [

                              TextButton(

                                onPressed: () =>
                                    Navigator.pop(
                                  context,
                                  false,
                                ),

                                child: const Text(
                                  "Tidak",
                                ),

                              ),

                              ElevatedButton(

                                onPressed: () =>
                                    Navigator.pop(
                                  context,
                                  true,
                                ),

                                child: const Text(
                                  "Ya",
                                ),

                              ),

                            ],

                          ),

                        );

                        if (confirm == true) {
                          await acceptPickup();
                        }

                      },

                      icon: const Icon(
                        Icons.check,
                        size: 18,
                      ),

                      label: const Text(
                        "Terima",
                      ),

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            Colors.green,
                      ),

                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(

                    child:
                        ElevatedButton.icon(

                      onPressed: () =>
                          cancelPickup(),

                      icon: const Icon(
                        Icons.close,
                        size: 18,
                      ),

                      label: const Text(
                        "Tolak",
                      ),

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            Colors.red,
                      ),

                    ),
                  ),

                ],
              ),

            ],

          ],
        ),
      ),
    );
  }

  Widget buildNoteCard() {

    final note = pickup!["notes"];

    return Card(

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      child: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Row(
              children: [

                Icon(
                  Icons.sticky_note_2,
                  color: Colors.orange,
                ),

                SizedBox(width: 8),

                Text(
                  "Catatan",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 16),

            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color:
                    const Color(0xffFDF9E7),

                borderRadius:
                    BorderRadius.circular(12),

              ),

              child: Text(

                note == null ||
                        note.toString().isEmpty
                    ? "Tidak ada catatan dari pelanggan."
                    : note,

              ),

            ),

          ],
        ),
      ),
    );
  }

  String formatRupiah(dynamic value) {

    final number =
        double.tryParse(
          value.toString(),
        ) ??
        0;

    return NumberFormat(
      "#,###",
      "id_ID",
    ).format(number);

  }

  String formatWeight(dynamic value) {

    double weight =
        double.tryParse(
              value.toString(),
            ) ??
            0;

    if(weight == weight.toInt()) {
      return weight.toInt().toString();
    }

    return weight
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  Widget buildCustomerCard() {

    final customer =
        pickup!["customer"];

    return Card(

      elevation: 2,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              "Informasi Pelanggan",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const Divider(),

            ListTile(

              contentPadding:
                  EdgeInsets.zero,

              leading:
                  CircleAvatar(
                child: Text(
                  customer["name"]
                      .substring(0, 1)
                      .toUpperCase(),
                ),
              ),

              title:
                  Text(
                customer["name"],
              ),

              subtitle:
                  Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    customer["phone"] ??
                        "-",
                  ),

                  Text(
                    customer["email"] ??
                        "-",
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPickupCard() {

    return Card(

      elevation: 2,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              "Informasi Pickup",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const Divider(),

            buildInfoRow(
              "Alamat",
              pickup![
                  "pickup_address"],
            ),

            buildInfoRow(
              "Telepon",
              pickup!["customer"]?["phone"] ?? "-",
            ),

            buildInfoRow(
              "Tanggal",
              DateFormat(
                "dd MMM yyyy HH:mm",
              ).format(
                DateTime.parse(
                  pickup![
                      "pickup_date"],
                ),
              ),
            ),

            buildInfoRow(
              "Estimasi Berat",
              "${formatWeight(
                transaction?["total_weight"] ??
                pickup!["estimated_weight"],
              )} kg"
            ),

            buildInfoRow(
              "Estimasi Harga",
              "Rp ${formatRupiah(
                transaction?["total_amount"] ??
                pickup!["estimated_price"],
              )}",
            ),
          ],
        ),
      ),
    );
  }

  String paymentStatusText(dynamic status) {
    switch ((status ?? "").toString().toLowerCase()) {
      case "unpaid":
        return "Belum Dibayar";

      case "paid":
        return "Lunas";

      case "partial":
        return "Sebagian";

      default:
        return status?.toString() ?? "-";
    }
  }

  Widget buildServiceCard() {

    final services =
        transaction!["details"] ?? [];

    return Card(

      elevation: 2,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              "Layanan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const Divider(),

            const Padding(
              padding: EdgeInsets.only(
                bottom: 12,
              ),
              child: Row(
                children: [

                  Expanded(
                    flex: 4,
                    child: Text(
                      "LAYANAN",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      "HARGA",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: Text(
                      "BERAT",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      "TOTAL",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                ],
              ),
            ),

            ...(services as List)
                .map<Widget>((item) {

              return Padding(

                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),

                child: Row(

                  children: [

                    Expanded(
                      flex: 4,
                      child: Row(

                        children: [

                          Container(
                            width: 36,
                            height: 36,

                            decoration: BoxDecoration(
                              color:
                                  const Color(0xffEEF4FF),
                              borderRadius:
                                  BorderRadius.circular(
                                8,
                              ),
                            ),

                            child: Icon(
                              serviceIcon(
                                item["service_name"],
                              ),
                              color:
                                  const Color(0xff4F6BED),
                              size: 18,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              item["service_name"],
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: Text(
                        "Rp ${formatRupiah(item["price_per_kg"])}",
                        textAlign:
                            TextAlign.center,
                      ),
                    ),

                    Expanded(
                      flex: 1,
                      child: Text(
                        "${formatWeight(item["weight"])} kg",
                        textAlign:
                            TextAlign.center,
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: Text(
                        "Rp ${formatRupiah(item["subtotal"])}",
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                  ],
                ),
              );
            }),

            const Divider(),

            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color:
                    const Color(0xffF7F8FA),

                borderRadius:
                    BorderRadius.circular(12),

              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Row(
                    children: [

                      Icon(
                        Icons.payment,
                        color: Colors.green,
                        size: 18,
                      ),

                      SizedBox(width: 8),

                      Text(
                        "Metode Pembayaran",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    pickup!["payment_method"]
                        .toString(),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 16),

            const SizedBox(height: 10),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                const Text(
                  "Estimasi Berat Total",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                Text(
                  "${formatWeight(
                    transaction?["total_weight"] ??
                    pickup!["estimated_weight"],
                  )} kg",
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 10),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                const Text(
                  "Estimasi Harga Total",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                Text(
                  "Rp ${formatRupiah(
                    transaction?["total_amount"] ??
                    pickup!["estimated_price"],
                  )}",
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xff4F6BED),
                  ),
                ),

              ],
            ),

          ],
        ),
      ),
    );
  }

  

  Widget buildFragranceCard() {

    final fragrances =
        transaction![
                "fragrances"] ??
            [];

    return Card(

      elevation: 2,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              "Pewangi",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const Divider(),

            Wrap(

              spacing: 10,
              runSpacing: 10,

              children:

                  fragrances.map<Widget>(
                (item) {

                  return Container(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),

                    decoration:
                        BoxDecoration(

                      color:
                          const Color(
                              0xffF3ECFF),

                      borderRadius:
                          BorderRadius.circular(
                              12),

                      border: Border.all(
                        color:
                            const Color(
                                0xffD8C8FF),
                      ),

                    ),

                    child: Row(

                      mainAxisSize:
                          MainAxisSize.min,

                      children: [

                        const Icon(
                          Icons.spa,
                          size: 18,
                          color:
                              Color(0xff8A52E2),
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        Text(

                          item[
                              "fragrance_name"],

                          style:
                              const TextStyle(
                            color:
                                Color(
                                    0xff8A52E2),
                            fontWeight:
                                FontWeight.w600,
                          ),

                        ),

                      ],
                    ),
                  );
                },
              ).toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(
    String title,
    dynamic value,
  ) {

    return Padding(

      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),

      child: Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget statusBadge(
    String status,
  ) {

    Color bg =
        const Color(0xffFFF4DD);

    Color text =
        Colors.orange;

    String label =
        status;

    switch(status){

      case "pending":
        label = "Menunggu";
        break;

      case "accepted":
        label = "Diterima";
        bg =
            const Color(0xffE7F8EC);
        text =
            Colors.green;
        break;

      case "cancelled":
        label = "Ditolak";
        bg =
            const Color(0xffFDEAEA);
        text =
            Colors.red;
        break;
    }

    return Container(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      decoration: BoxDecoration(

        color: bg,

        borderRadius:
            BorderRadius.circular(20),

      ),

      child: Text(

        label,

        style: TextStyle(
          color: text,
          fontWeight:
              FontWeight.w600,
        ),

      ),

    );
  }

  String statusText(
    String status,
  ) {

    switch(status){

      case "pending":
        return "Menunggu";

      case "accepted":
        return "Diterima";

      case "completed":
        return "Selesai";

      case "cancelled":
        return "Ditolak";

      default:
        return status;
    }
  }

  IconData serviceIcon(
    String serviceName,
  ) {

    final name =
        serviceName.toLowerCase();

    if(name.contains("setrika")) {
      return Icons.iron;
    }

    if(name.contains("cuci")) {
      return Icons.local_laundry_service;
    }

    if(name.contains("karpet")) {
      return Icons.grid_view;
    }

    if(name.contains("sepatu")) {
      return Icons.hiking;
    }

    if(name.contains("boneka")) {
      return Icons.toys;
    }

    return Icons.checkroom;
  }


}