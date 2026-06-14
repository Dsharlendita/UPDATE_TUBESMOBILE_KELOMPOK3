import 'package:flutter/material.dart';

import '../../models/pickup_model.dart';
import '../../services/pickup_service.dart';
import 'pickup_detail_screen.dart';
import '../../core/app_badges.dart';

class PickupScreen extends StatefulWidget {

  final String initialType;

  const PickupScreen({
    super.key,
    this.initialType = "pickup",
  });

  @override
  State<PickupScreen>
  createState() =>
      _PickupScreenState();

}

class _PickupScreenState
    extends State<PickupScreen> {

  final PickupService
  pickupService =
  PickupService();

  final TextEditingController
  searchController =
  TextEditingController();

  final TextEditingController
  startDateController =
  TextEditingController();

  final TextEditingController
  endDateController =
  TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  List<PickupModel>
  pickups = [];

  bool isLoading = true;

  Map<String,dynamic>
  stats = {};

  String selectedStatus =
      "";

  late String selectedType;

  @override
void initState() {

  super.initState();

  selectedType =
      widget.initialType;

  loadData();

}

  Future pickStartDate() async {

    final picked =
        await showDatePicker(
      context: context,
      initialDate:
          startDate ??
          DateTime.now(),
      firstDate:
          DateTime(2020),
      lastDate:
          DateTime(2100),
    );

    if (picked != null) {

      startDate = picked;

      startDateController.text =
          "${picked.day}/${picked.month}/${picked.year}";

      setState(() {});
    }
  }

  Future pickEndDate() async {

    final picked =
        await showDatePicker(
      context: context,
      initialDate:
          endDate ??
          DateTime.now(),
      firstDate:
          DateTime(2020),
      lastDate:
          DateTime(2100),
    );

    if (picked != null) {

      endDate = picked;

      endDateController.text =
          "${picked.day}/${picked.month}/${picked.year}";

      setState(() {});
    }
  }

  Future loadData() async {

    setState(() {
      isLoading = true;
    });

    final result =
    await pickupService.getPickups(
      status: selectedStatus.isEmpty
          ? null
          : selectedStatus,

      type: selectedType,

      search: searchController.text,

      dateFrom: startDate == null
          ? null
          : startDate!
                .toIso8601String()
                .split('T')[0],

      dateTo: endDate == null
          ? null
          : endDate!
                .toIso8601String()
                .split('T')[0],
    );

    if(result["success"]){

      pickups =
      result["pickups"];

      for (final p in pickups) {
        print(
          "PICKUP => id=${p.id}, invoice=${p.invoice}"
        );
      }

      stats =
      result["stats"];

    }

    setState(() {
      isLoading = false;
    });

  }

  Future<void> acceptPickup(
    PickupModel item,
  ) async {

    final result =
        await pickupService
            .acceptPickup(item.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(result["message"]),
      ),
    );

    if (result["success"]) {

      await loadData();

      if (AppBadges
              .pendingPickupCount
              .value >
          0) {

        AppBadges
            .pendingPickupCount
            .value--;

      }

    }
  }


  Future<void> cancelPickup(
    PickupModel item,
  ) async {

    final controller =
        TextEditingController();

    final reason =
        await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text("Alasan Pembatalan"),
          content: TextField(
            controller: controller,
            decoration:
                const InputDecoration(
              hintText:
                  "Masukkan alasan",
            ),
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text("Batal"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text,
                );
              },
              child:
                  const Text("Kirim"),
            ),

          ],
        );
      },
    );

    if (reason == null ||
        reason.isEmpty) {
      return;
    }

    final result =
        await pickupService
            .cancelPickup(
      item.id,
      reason,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(result["message"]),
      ),
    );

    if (result["success"]) {
      loadData();
    }
  }

  Future<void> onTheWayPickup(
    PickupModel item,
  ) async {

    final result =
        await pickupService
            .onTheWayPickup(
      item.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(result["message"]),
      ),
    );

    if (result["success"]) {
      loadData();
    }

  }

  Future<void> completePickup(
    PickupModel item,
  ) async {

    final result =
        await pickupService
            .completePickup(
      item.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(result["message"]),
      ),
    );

    if (result["success"]) {
      loadData();
    }

  }

  Color statusColor(
      String status){

    switch(status){

      case "pending":
        return Colors.orange;

      case "accepted":
        return Colors.blue;

      case "in_progress":
        return const Color(0xff6F42C1);

      case "picked_up":
        return Colors.indigo;

      case "on_the_way":
        return const Color(0xff6F42C1);

      case "completed":
        return Colors.green;

      case "cancelled":
        return Colors.red;

      default:
        return Colors.grey;

    }

  }

  String statusText(String status) {

    switch(status){

      case "pending":
        return "Menunggu";

      case "accepted":
        return "Diterima";

      case "on_the_way":
      case "in_progress":
        return "Dalam Perjalanan";

      case "picked_up":
        return "Sudah Dijemput";

      case "completed":
        return "Selesai";

      case "cancelled":
        return "Dibatalkan";

      default:
        return status;
    }
  }

  Widget infoRow(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
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

    Color bgColor;
    Color textColor;

    switch(status){

      case "pending":
        bgColor = const Color(0xffFFF4DD);
        textColor = Colors.orange;
        break;

      case "accepted":
        bgColor = const Color(0xffE8F1FF);
        textColor = Colors.blue;
        break;

      case "on_the_way":
      case "in_progress":
        bgColor = const Color(0xffF1E8FF);
        textColor = const Color(0xff6F42C1);
        break;
      
      case "picked_up":
        bgColor = const Color(0xffE8F1FF);
        textColor = Colors.indigo;
        break;

      case "completed":
        bgColor = const Color(0xffE8F8EA);
        textColor = Colors.green;
        break;

      case "cancelled":
        bgColor = const Color(0xffFFEAEA);
        textColor = Colors.red;
        break;

      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        statusText(status),
        style: TextStyle(
          color: textColor,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }

Widget typeBadge(
    String text,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xffEEF4FF),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.blue,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }

  Widget detailButton(
    PickupModel item,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {

          final refresh =
              await Navigator.push(

            context,

            MaterialPageRoute(
              builder: (_) =>
                  PickupDetailScreen(
                pickupId: item.id,
              ),
            ),

          );

          if (refresh == true) {
            loadData();
          }

        },
        icon: const Icon(
          Icons.visibility,
        ),
        label: const Text(
          "Detail",
        ),
      ),
    );
  }

  String formatPickupDate(
    String date,
  ) {

    try {

      final dt =
          DateTime.parse(date);

      return
          "${dt.day.toString().padLeft(2, '0')} "
          "${_monthName(dt.month)} "
          "${dt.year}, "
          "${dt.hour.toString().padLeft(2, '0')}:"
          "${dt.minute.toString().padLeft(2, '0')}";

    } catch (_) {

      return date;

    }

  }

String _monthName(
    int month,
  ) {

    const months = [

      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',

    ];

    return months[month];

  }

  Widget statCard(
    String title,
    dynamic value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 13,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$value",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {

    searchController.dispose();
    startDateController.dispose();
    endDateController.dispose();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xffF5F7FB),

      appBar: AppBar(

        title: const Text(
          "Manajemen Pickup",
        ),

        backgroundColor:
        Colors.white,

      ),

      body: RefreshIndicator(

        onRefresh: loadData,

        child: ListView(

          padding: const EdgeInsets.all(24),

          children: [

            Text(
              "Manajemen Pickup",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "Dashboard / Pickup",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.3,

              crossAxisSpacing: 12,

              mainAxisSpacing: 12,

              children: [

                statCard(
                  "Total",
                  stats["total"] ?? 0,
                  Colors.black,
                ),

                statCard(
                  "Menunggu",
                  stats["pending"] ?? 0,
                  Colors.orange,
                ),

                statCard(
                  "Diterima",
                  stats["accepted"] ?? 0,
                  Colors.blue,
                ),

                statCard(
                  "Dalam Perjalanan",
                  stats["on_the_way"] ??
                      stats["in_progress"] ??
                      0,
                  const Color(0xff6F42C1),
                ),

                statCard(
                  "Selesai",
                  stats["completed"] ?? 0,
                  Colors.green,
                ),

                statCard(
                  "Batal",
                  stats["cancelled"] ?? 0,
                  Colors.red,
                ),

              ],

            ),

            const SizedBox(height: 20),

            Container(

              height: 50,

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(10),

                border: Border.all(
                  color: Colors.grey.shade300,
                ),

              ),

              child: Row(

                children: [

                  Expanded(

                    child: InkWell(

                      onTap: () {

                        setState(() {
                          selectedType =
                              "pickup";
                        });

                        loadData();
                      },

                      child: Container(

                        decoration: BoxDecoration(

                          color: selectedType ==
                                  "pickup"
                              ? const Color(
                                  0xff3B5BDB)
                              : Colors.transparent,

                          borderRadius:
                              BorderRadius.circular(
                                  10),

                        ),

                        alignment:
                            Alignment.center,

                        child: Text(

                          "Permintaan Pickup",

                          style: TextStyle(

                            color: selectedType ==
                                    "pickup"
                                ? Colors.white
                                : Colors.black54,

                            fontWeight:
                                FontWeight.w600,

                          ),

                        ),

                      ),

                    ),

                  ),

                  Expanded(

                    child: InkWell(

                      onTap: () {

                        setState(() {
                          selectedType = "delivery";
                        });

                        loadData();
                      },

                      child: Container(

                        decoration: BoxDecoration(

                          color: selectedType == "delivery"
                              ? const Color(0xff3B5BDB)
                              : Colors.transparent,

                          borderRadius:
                              BorderRadius.circular(10),

                        ),

                        alignment: Alignment.center,

                        child: Text(

                          "Request Pengantaran",

                          style: TextStyle(

                            color: selectedType == "delivery"
                                ? Colors.white
                                : Colors.black54,

                            fontWeight:
                                FontWeight.w600,

                          ),

                        ),

                      ),

                    ),

                  ),

                ],

              ),

            ),
            const SizedBox(height: 20),

            Container(

              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(12),

                border: Border.all(
                  color: Colors.grey.shade200,
                ),

              ),

              child: Column(

                children: [

                  DropdownButtonFormField<String>(

                    value:
                        selectedStatus.isEmpty
                            ? null
                            : selectedStatus,

                    decoration:
                        const InputDecoration(
                      labelText: "Status",
                    ),

                    items: const [

                      DropdownMenuItem(
                        value: "pending",
                        child: Text("Menunggu"),
                      ),

                      DropdownMenuItem(
                        value: "accepted",
                        child: Text("Diterima"),
                      ),

                      DropdownMenuItem(
                        value: "in_progress",
                        child: Text("Proses"),
                      ),

                      DropdownMenuItem(
                        value: "completed",
                        child: Text("Selesai"),
                      ),

                      DropdownMenuItem(
                        value: "cancelled",
                        child: Text("Batal"),
                      ),

                    ],

                    onChanged: (value) {

                      setState(() {

                        selectedStatus =
                            value ?? "";

                      });

                    },

                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: startDateController,
                    readOnly: true,
                    onTap: pickStartDate,
                    decoration: const InputDecoration(
                      labelText: "Tanggal Dari",
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: endDateController,
                    readOnly: true,
                    onTap: pickEndDate,
                    decoration: const InputDecoration(
                      labelText: "Tanggal Sampai",
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      TextField(
                        controller: searchController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              "Cari Pelanggan",
                          hintText:
                              "Nama, telepon, atau invoice",
                          prefixIcon:
                              Icon(Icons.search),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Pencarian berdasarkan nama pelanggan, nomor telepon, atau nomor invoice",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [

                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {

                            setState(() {
                              selectedStatus = "";
                            });

                            searchController.clear();
                            startDateController.clear();
                            endDateController.clear();
                            startDate = null;
                            endDate = null;

                            loadData();

                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh),
                              SizedBox(width: 8),
                              Text("Reset"),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: loadData,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.filter_alt),
                              SizedBox(width: 8),
                              Text("Filter"),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ],

              ),
            ),

            const SizedBox(height: 20),

            if(isLoading)

              const Center(
                child:
                CircularProgressIndicator(),
              )

            else if(pickups.isEmpty)

              Container(

                height: 300,

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(20),

                ),

                child: Column(

                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children:[

                    Icon(

                      Icons.local_shipping,

                      size: 70,

                      color:
                      Colors.grey.shade300,

                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    const Text(

                      "Belum Ada Permintaan Pickup",

                      style: TextStyle(

                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),

                  ],

                ),

              )

            else

              ...pickups.map(

                    (item)=>

                    Container(

                      margin:
                      const EdgeInsets.only(
                        bottom: 14,
                      ),

                      padding:
                      const EdgeInsets.all(16),

                      decoration:
                      BoxDecoration(

                        color: Colors.white,

                        boxShadow: [

                          BoxShadow(

                            color:
                                Colors.black.withOpacity(
                                    0.05),

                            blurRadius: 10,

                            offset:
                                const Offset(0, 4),

                          ),

                        ],

                        borderRadius:
                        BorderRadius.circular(14),

                      ),

                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children:[

                          Row(
                            children: [

                              CircleAvatar(
                                radius: 26,
                                backgroundColor:
                                    const Color(0xffE8F1FF),
                                child: Text(
                                  (item.customerName.isNotEmpty
                                    ? item.customerName[0]
                                    : "?")
                                    .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      item.customerName,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style:
                                          const TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [

                                        statusBadge(
                                          item.status,
                                        ),

                                        typeBadge(
                                          item.type,
                                        ),

                                      ],
                                    ),

                                  ],
                                ),
                              ),

                            ],
                          ),

                          const SizedBox(height: 10),

                          infoRow(
                            Icons.phone,
                            item.phone,
                          ),

                          if (item.type == "pickup")

                            infoRow(
                              Icons.credit_card,
                              "Pilihan Pembayaran: "
                              "${item.paymentMethod}",
                            )

                          else

                            infoRow(
                              Icons.credit_card,
                              "Metode Pelunasan: "
                              "${item.settlementMethod}",
                            ),

                          infoRow(
                            Icons.location_on,
                            "Alamat Penjemputan: ${item.address}",
                          ),

                          const SizedBox(height: 4),

                          infoRow(
                            Icons.calendar_month,
                            formatPickupDate(
                              item.pickupDate,
                            ),
                          ),

                          const Divider(),

                          const SizedBox(height: 10),

                          infoRow(
                            Icons.receipt_long,
                            "Invoice : ${item.invoice ?? '-'}",
                          ),

                          const SizedBox(height: 15),

                          if (item.status == "pending")

                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [

                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          acceptPickup(item),

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xff4CAF50),
                                        foregroundColor:
                                            Colors.white,
                                        elevation: 0,
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),

                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [

                                          Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.white,
                                          ),

                                          SizedBox(width: 4),

                                          Text(
                                            "Terima",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 6),

                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          cancelPickup(item),

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xffFF4D3A),
                                        foregroundColor:
                                            Colors.white,
                                        elevation: 0,
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),

                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [

                                          Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),

                                          SizedBox(width: 4),

                                          Text(
                                            "Tolak",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 6),

                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: OutlinedButton(
                                      onPressed: () async {

                                        final result =
                                            await Navigator.push(

                                          context,

                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PickupDetailScreen(
                                              pickupId: item.id,
                                            ),
                                          ),

                                        );

                                        if (result == true) {
                                          loadData();
                                        }

                                      },

                                      style:
                                          OutlinedButton.styleFrom(
                                        foregroundColor:
                                            const Color(0xff3461FF),

                                        side: const BorderSide(
                                          color:
                                              Color(0xffD7DCE5),
                                        ),

                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),

                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),

                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [

                                          Icon(
                                            Icons.visibility,
                                            size: 14,
                                          ),

                                          SizedBox(width: 4),

                                          Text(
                                            "Detail",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          )

                          else if(item.status == "accepted")

                          Column(
                            children: [

                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      onTheWayPickup(item),

                                  icon: const Icon(
                                    Icons.local_shipping,
                                    color: Colors.white,
                                  ),

                                  label: const Text(
                                    "Berangkat ke Lokasi",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xff6F42C1),
                                    foregroundColor:
                                        Colors.white,
                                    elevation: 0,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                children: [

                                  Expanded(
                                    child: SizedBox(
                                      height: 50,
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            completePickup(item),

                                        icon: const Icon(
                                          Icons.flag,
                                          size: 18,
                                        ),

                                        label: const Text(
                                          "Selesai",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),

                                        style:
                                            ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(
                                                  0xff2196F3),
                                          foregroundColor:
                                              Colors.white,
                                          elevation: 0,
                                          shape:
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    14),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: SizedBox(
                                      height: 50,
                                      child: OutlinedButton.icon(
                                        onPressed: () async {

                                          final result =
                                              await Navigator.push(

                                            context,

                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  PickupDetailScreen(
                                                pickupId: item.id,
                                              ),
                                            ),

                                          );

                                          if (result == true) {
                                            loadData();
                                          }

                                        },

                                        icon: const Icon(
                                          Icons.visibility,
                                          size: 18,
                                        ),

                                        label: const Text(
                                          "Detail",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),

                                        style:
                                            OutlinedButton.styleFrom(
                                          foregroundColor:
                                              const Color(
                                                  0xff3461FF),

                                          side: const BorderSide(
                                            color:
                                                Color(
                                                    0xffD7DCE5),
                                          ),

                                          shape:
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    14),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                ],
                              ),

                            ],
                          )
                          
                          else if(
                            item.status == "in_progress" ||
                            item.status == "on_the_way"
                          )

                          Row(
                            children: [

                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        completePickup(item),

                                    icon: const Icon(
                                      Icons.check_circle,
                                      size: 18,
                                    ),

                                    label: const Text(
                                      "Selesai",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),

                                    style:
                                        ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(
                                              0xff2196F3),
                                      foregroundColor:
                                          Colors.white,
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                14),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {

                                      final result =
                                          await Navigator.push(

                                        context,

                                        MaterialPageRoute(
                                          builder: (_) =>
                                              PickupDetailScreen(
                                            pickupId: item.id,
                                          ),
                                        ),

                                      );

                                      if (result == true) {
                                        loadData();
                                      }

                                    },

                                    icon: const Icon(
                                      Icons.visibility,
                                      size: 18,
                                    ),

                                    label: const Text(
                                      "Detail",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),

                                    style:
                                        OutlinedButton.styleFrom(
                                      foregroundColor:
                                          const Color(
                                              0xff3461FF),
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          )

                          else if(item.status == "picked_up")

                          Row(
                            children: [

                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton.icon(

                                    onPressed: () =>
                                        completePickup(item),

                                    icon: const Icon(
                                      Icons.check_circle,
                                      size: 18,
                                    ),

                                    label: const Text(
                                      "Selesai",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xff2196F3),
                                      foregroundColor:
                                          Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                    ),

                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton.icon(

                                    onPressed: () async {

                                      final result =
                                          await Navigator.push(

                                        context,

                                        MaterialPageRoute(
                                          builder: (_) =>
                                              PickupDetailScreen(
                                            pickupId: item.id,
                                          ),
                                        ),

                                      );

                                      if (result == true) {
                                        loadData();
                                      }

                                    },

                                    icon: const Icon(
                                      Icons.visibility,
                                      size: 18,
                                    ),

                                    label: const Text(
                                      "Detail",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          const Color(0xff3461FF),
                                    ),

                                  ),
                                ),
                              ),

                            ],
                          )

                          else if(item.status == "completed")

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(

                              onPressed: () async {

                                final result =
                                    await Navigator.push(

                                  context,

                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PickupDetailScreen(
                                      pickupId: item.id,
                                    ),
                                  ),

                                );

                                if (result == true) {
                                  loadData();
                                }

                              },

                              icon: const Icon(
                                Icons.visibility,
                                size: 18,
                              ),

                              label: const Text(
                                "Lihat Detail",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),

                              style: OutlinedButton.styleFrom(

                                foregroundColor:
                                    const Color(0xff3461FF),

                                side: const BorderSide(
                                  color:
                                      Color(0xffD7DCE5),
                                ),

                                minimumSize:
                                    const Size(
                                  double.infinity,
                                  50,
                                ),

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          14),
                                ),

                              ),

                            ),
                          )
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