import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/transaction_model.dart';
import '../../services/transaction_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../tracking/tracking_screen.dart';
import '../../core/app_badges.dart';
import '../../services/tracking_service.dart';
import '../../utils/invoice_pdf.dart';

class TransactionDetailScreen
    extends StatefulWidget {

  final int transactionId;

  const TransactionDetailScreen({

    super.key,

    required this.transactionId,

  });

  @override
  State<TransactionDetailScreen>
      createState() =>
      _TransactionDetailScreenState();

}

class _TransactionDetailScreenState
    extends State<TransactionDetailScreen> {

  final TransactionService service =
      TransactionService();

  bool loading = true;

  TransactionModel? transaction;

  final TextEditingController
    weightController =
    TextEditingController();

  String formatRupiah(dynamic value) {

    return NumberFormat.currency(

      locale: 'id_ID',

      symbol: 'Rp ',

      decimalDigits: 0,

    ).format(value);

  }

  @override
  void initState() {

    super.initState();

    loadData();

  }

  Future<void> openWhatsapp() async {

  final trx = transaction!;

  final message = '''
  Halo ${trx.customerName} 👋

  Berikut informasi laundry Anda:

  📄 Invoice : ${trx.invoice}
  🔍 Tracking : ${trx.trackingCode}
  📦 Status : ${statusLabel(trx.status)}
  💳 Pembayaran : ${paymentLabel(trx.paymentStatus)}

  ⚖️ Berat : ${trx.weight} kg
  💰 Total : ${formatRupiah(trx.total)}

  🔗 Link Tracking:
  ${trx.trackingUrl}

  Terima kasih telah menggunakan layanan LaundryHub 🙏
  ''';

    final whatsappUrl = Uri.parse(
      "whatsapp://send"
      "?phone=${trx.customerPhone}"
      "&text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(whatsappUrl)) {

      await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );

    } else {

      final webUrl = Uri.parse(
        "https://wa.me/${trx.customerPhone}"
        "?text=${Uri.encodeComponent(message)}",
      );

      await launchUrl(
        webUrl,
        mode: LaunchMode.externalApplication,
      );

    }

  }

  bool hasEstimatedCompletion() {

    return transaction?.estimatedCompletion != null &&
        transaction!.estimatedCompletion!.trim().isNotEmpty &&
        transaction!.estimatedCompletion != "null";

  }

  bool canUpdateStatus() {

    return hasEstimatedCompletion() &&
        transaction != null &&
        transaction!.weight > 0;

  }

  String statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'washing':
        return 'Pencucian';
      case 'drying':
        return 'Pengeringan';
      case 'ironing':
        return 'Penyetrikaan';
      case 'ready':
        return 'Siap Diambil';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  String paymentLabel(String status) {

    switch(status.toLowerCase()) {

      case "paid":
        return "Lunas";

      case "unpaid":
        return "Belum Dibayar";

      case "pending":
        return "Menunggu Konfirmasi";

      default:
        return status;
    }

  }

  Future<void> launchTracking() async {

    final trx = transaction!;

    final uri =
        Uri.parse(
      trx.trackingUrl,
    );

    if(await canLaunchUrl(uri)) {

      await launchUrl(uri);

    }

  }

  Future<void> showUpdateStatusDialog() async {

    String selectedStatus =
        transaction!.status;

    await showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          title: const Text(

            "Update Status Laundry",

            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),

          ),

          content: StatefulBuilder(

            builder: (context, setModal) {

              return DropdownButtonFormField<String>(

                value: selectedStatus,

                decoration: InputDecoration(

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),

                ),

                items: const [

                  DropdownMenuItem(
                    value: "pending",
                    child: Text("Menunggu"),
                  ),

                  DropdownMenuItem(
                    value: "confirmed",
                    child: Text("Dikonfirmasi"),
                  ),

                  DropdownMenuItem(
                    value: "washing",
                    child: Text("Dicuci"),
                  ),

                  DropdownMenuItem(
                    value: "drying",
                    child: Text("Dikeringkan"),
                  ),

                  DropdownMenuItem(
                    value: "ironing",
                    child: Text("Disetrika"),
                  ),

                  DropdownMenuItem(
                    value: "ready",
                    child: Text("Siap"),
                  ),

                  DropdownMenuItem(
                    value: "completed",
                    child: Text("Selesai"),
                  ),

                ],

                onChanged: (value) {

                  setModal(() {

                    selectedStatus =
                        value!;

                  });

                },

              );

            },

          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);

              },

              child: const Text(
                "Batal",
              ),

            ),

            ElevatedButton(

              style:
                  ElevatedButton.styleFrom(

                backgroundColor:
                    const Color(
                  0xFF4361EE,
                ),

                foregroundColor:
                    Colors.white,

              ),

              onPressed: () async {

                final success =

                    await service
                        .updateStatus(

                  id:
                      transaction!.id,

                  status:
                      selectedStatus,

                );

                if (success) {

                  loadData();

                }

              },

              child: const Text(
                "Simpan",
              ),

            ),

          ],

        );

      },

    );

  }
  Future<void> showUpdatePaymentDialog() async {

    String paymentStatus =
        transaction!.paymentStatus;

    await showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          title: const Text(

            "Update Pembayaran",

            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),

          ),

          content: StatefulBuilder(

            builder: (context, setModal) {

              return SizedBox(

                width: 420,

                child: Column(

                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Status Pembayaran",
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(

                      value: paymentStatus,

                      decoration: InputDecoration(

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),

                      ),

                      items: const [

                        DropdownMenuItem(
                          value: "unpaid",
                          child: Text("Belum Dibayar"),
                        ),

                        DropdownMenuItem(
                          value: "pending",
                          child: Text("Menunggu Konfirmasi"),
                        ),

                        DropdownMenuItem(
                          value: "paid",
                          child: Text("Lunas"),
                        ),

                      ],

                      onChanged: (value) {

                        setModal(() {

                          paymentStatus =
                              value!;

                        });

                      },

                    ),

                    const SizedBox(height: 16),

                    Container(

                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(

                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),

                        borderRadius:
                            BorderRadius.circular(12),

                        color: Colors.grey.shade50,

                      ),

                      child: Column(

                        children: [

                          Row(

                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,

                            children: [

                              const Text(
                                "Metode Dipilih Saat Pickup",
                              ),

                              Text(

                                transaction!
                                    .initialPaymentMethod,

                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),

                              ),

                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(

                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,

                            children: [

                              const Text(
                                "Metode Pelunasan",
                              ),

                              Text(

                                transaction!
                                        .paymentMethod
                                        .isEmpty
                                    ? "-"
                                    : transaction!
                                        .paymentMethod,

                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),

                              ),

                            ],
                          ),

                        ],

                      ),

                    ),

                    const SizedBox(height: 16),

                    Container(

                      padding:
                          const EdgeInsets.all(12),

                      decoration: BoxDecoration(

                        color:
                            const Color(0xFFFFFBEB),

                        border: Border.all(
                          color:
                              const Color(
                            0xFFFCD34D,
                          ),
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),

                      ),

                      child: const Text(

                        "Owner hanya perlu mengubah status pembayaran.\n"
                        "Metode pelunasan mengikuti pilihan customer secara otomatis.",

                        style: TextStyle(
                          color: Color(0xFF92400E),
                        ),

                      ),

                    ),

                  ],

                ),

              );

            },

          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);

              },

              child: const Text(
                "Batal",
              ),

            ),

            ElevatedButton(

              style:
                  ElevatedButton.styleFrom(

                backgroundColor:
                    const Color(
                  0xFF4361EE,
                ),

                foregroundColor:
                    Colors.white,

                shape:
                    RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),

                ),

              ),

              onPressed: () async {

                final success =

                    await service
                        .updatePaymentStatus(

                  id:
                      transaction!.id,

                  status:
                      paymentStatus,

                );

                if (success) {

                  AppBadges.pendingPaymentCount.value =
                      (AppBadges.pendingPaymentCount.value - 1)
                          .clamp(0, 999);

                  loadData();

                }

                if (context.mounted) {

                  Navigator.pop(context);

                }

              },

              child: const Text(
                "Simpan Pembayaran",
              ),

            ),

          ],

        );

      },

    );

  }
  Future<void> loadData() async {

    final result =
        await service.getTransactionDetail(
      widget.transactionId,
    );

    if (!mounted) return;

    if (result == null) {

      setState(() {

        loading = false;

      });

      return;
    }

    setState(() {

      transaction = result;

      weightController.text =
          result.weight.toString();

      loading = false;

    });

  }

  @override
    void dispose() {
      weightController.dispose();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {

    if(loading){

      return const Scaffold(

        body:
        Center(

          child:
          CircularProgressIndicator(),

        ),

      );

    }

    if(transaction == null){

      return const Scaffold(

        body:
        Center(

          child:
          Text(
            "Data tidak ditemukan",
          ),

        ),

      );

    }

    return Scaffold(

      backgroundColor:
        const Color(0xFFF8FAFC),

      appBar: AppBar(

        title:
        const Text(
          "Detail Transaksi",
        ),

      ),

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(16),

        child:

        Column(

          children: [

            buildHeaderCard(),

            const SizedBox(height: 16),

            buildProgressCard(),

            const SizedBox(height: 16),

            buildOrderCard(),

            const SizedBox(height: 16),

            buildPaymentCard(),

            const SizedBox(height: 16),

            buildTrackingCard(),

          ],

        ),

      ),
    
    );

  }
  

  Widget statusBadge(
    String text,
    Color color,
  ) {

    return Container(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),

      decoration: BoxDecoration(

        color:
            color.withOpacity(0.12),

        borderRadius:
            BorderRadius.circular(30),

      ),

      child: Text(

        text.toUpperCase(),

        style: TextStyle(

          color: color,

          fontWeight:
              FontWeight.w700,

          fontSize: 12,

        ),
      ),
    );
  }

  Widget paymentRow(

    String title,

    String value, {

    bool isBold = false,

  }) {

    return Padding(

      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),

      child: Row(

        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [

          Text(
            title,
          ),

          Text(

            value,

            style: TextStyle(

              fontWeight:
                  isBold
                      ? FontWeight.bold
                      : FontWeight.w500,

            ),
          ),

        ],
      ),
    );
  }

  Widget buildHeaderCard() {

    final trx = transaction!;

    return Card(

      elevation: 2,

      color: Colors.white,

      shadowColor:
          Colors.black12,

      shape:
          RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(20)
      ),

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(

              trx.invoice,

              style: const TextStyle(

                fontSize: 18,

                fontWeight:
                    FontWeight.bold,

              ),
            ),

            const SizedBox(height: 10),

            Row(

              children: [

                statusBadge(
                  trx.status,
                  const Color(0xFF2563EB),
                ),

                const SizedBox(width: 8),

                statusBadge(
                  trx.paymentStatus,
                  const Color(0xFF22C55E),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(

              children: [

                const Icon(
                  Icons.calendar_today,
                  size: 16,
                ),

                const SizedBox(width: 8),

                Text(
                  trx.formattedDate,
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (trx.estimatedCompletion != null &&
              trx.estimatedCompletion!.isNotEmpty) ...[

            const SizedBox(height: 8),

            Row(

              children: [

                const Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.orange,
                ),

                const SizedBox(width: 8),

                Expanded(

                  child: Text(

                    "Estimasi Selesai: ${DateFormat(
                      'dd MMM yyyy',
                    ).format(
                      DateTime.parse(
                        trx.estimatedCompletion!,
                      ),
                    )}",

                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),

                  ),

                ),

              ],

            ),

          ],

            const SizedBox(height: 16),

            Wrap(

              spacing: 8,

              runSpacing: 8,

              alignment: WrapAlignment.start,

              children: [

                SizedBox(

                  width: 130,

                  height: 44,

                  child: ElevatedButton.icon(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) => TrackingScreen(

                            trackingCode:
                                trx.trackingCode,

                          ),

                        ),

                      );

                    },

                    icon: const Icon(Icons.qr_code_2),

                    label: const Text("Tracking"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                    ),

                  ),

                ),

                SizedBox(

                  width: 130,

                  height: 44,

                  child: ElevatedButton.icon(

                    onPressed: () async {

                      final trackingService =
                          TrackingService();

                      final tracking =
                          await trackingService.getTracking(
                        trx.trackingCode,
                      );

                      if (tracking == null) {
                        return;
                      }

                      final pdf = await InvoicePdf()
                          .buildInvoiceDocument(tracking);

                      await InvoicePdf.openInvoice(
                        pdf,
                        tracking.invoice,
                      );

                    },

                    icon: const Icon(Icons.download),

                    label: const Text("Invoice"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                    ),

                  ),

                ),

                SizedBox(
                  width: 130,
                  height: 44,
                  child: ElevatedButton.icon(

                    onPressed: openWhatsapp,

                    icon: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      size: 16,
                    ),

                    label: const Text(
                      "WhatsApp",
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(

                      backgroundColor:
                          const Color(0xFF22C55E),

                      foregroundColor:
                          Colors.white,

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),

                    ),

                  ),
                )
              ],

            )
          ],
        ),
      ),
    );
  }

  Widget buildProgressCard() {

    final trx = transaction!;

    return Card(

      elevation: 2,

      color: Colors.white,

      shadowColor:
          Colors.black12,

      shape:
          RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(20),

      ),

      child: Padding(

        padding:
        const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Text(

              "Progress Laundry",

              style:

              TextStyle(
                fontWeight:
                FontWeight.bold,
              ),

            ),

            const SizedBox(height: 15),

            LinearProgressIndicator(

              value:
                  trx.progressPercentage / 100,

              backgroundColor:
                  Colors.grey.shade200,

              color:
                  const Color(
                0xFF2563EB,
              ),
            ),

            const SizedBox(height: 10),

            Align(

              alignment:
                  Alignment.centerRight,

              child: Text(

                "${trx.progressPercentage}%",

                style:
                    const TextStyle(

                  fontWeight:
                      FontWeight.bold,

                ),
              ),
            ),
            const Divider(),

            if (!canUpdateStatus())

            Container(

              width: double.infinity,

              margin: const EdgeInsets.only(
                top: 12,
              ),

              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(

                color: const Color(0xFFFFFBEB),

                borderRadius:
                    BorderRadius.circular(12),

                border: Border.all(
                  color: const Color(0xFFFCD34D),
                ),

              ),

              child: const Row(

                children: [

                  Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFD97706),
                  ),

                  SizedBox(width: 8),

                  Expanded(

                    child: Text(

                      "Update berat terlebih dahulu untuk melanjutkan proses laundry.",

                      style: TextStyle(
                        color: Color(0xFF92400E),
                      ),

                    ),

                  ),

                ],

              ),

            ),

            TextButton.icon(

              onPressed: canUpdateStatus()

              ? () {

                  showUpdateStatusDialog();

                }

              : null,

              icon:
                  const Icon(
                Icons.edit,
              ),

              label:
                  const Text(
                "Update Status",
              ),
            ),



          ],

        ),

      ),

    );

  }

  Widget buildOrderCard() {

    final trx = transaction!;

    return Card(

      elevation: 2,

      color: Colors.white,

      shadowColor:
          Colors.black12,

      shape:
          RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(20),

      ),

      child: Padding(

        padding:
        const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Text(

              "Detail Pesanan",

              style:

              TextStyle(

                fontWeight:
                FontWeight.bold,

              ),

            ),

            const SizedBox(height: 16),

            ListTile(

              contentPadding:
                  EdgeInsets.zero,

              leading:
                  const CircleAvatar(

                child:
                    Icon(
                  Icons.person,
                ),
              ),

              title:
                  Text(
                trx.customerName,
              ),

              subtitle:
                  Text(
                trx.customerPhone,
              ),
            ),
            const Divider(),

            ListView.builder(

              shrinkWrap: true,

              physics:
              const NeverScrollableScrollPhysics(),

              itemCount:
              trx.details.length,

              itemBuilder:
              (_, index){

                final item =
                trx.details[index];

                return ListTile(

                  contentPadding:
                  EdgeInsets.zero,

                  title:
                  Text(
                    item.serviceName,
                  ),

                  subtitle:
                  Text(
                    "${item.weight} kg",
                  ),

                  trailing:
                  Text(
                    formatRupiah(
                      item.subtotal,
                    ),
                  ),

                );

              },

            ),

            const Divider(),

              const SizedBox(height: 8),

              Container(

                padding:
                    const EdgeInsets.all(12),

                decoration: BoxDecoration(

                  color: const Color(
                    0xFFE0F2FE,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),

                ),

                child: Row(

                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [

                    const Text(
                      "Total Berat",
                    ),

                    Text(
                      "${trx.weight} kg",
                    ),

                  ],
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              Container(

                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(

                  color: const Color(
                    0xFFDCFCE7,
                  ),

                  borderRadius:
                      BorderRadius.circular(12),

                ),

                child: Row(

                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [

                    const Text(
                      "Total Harga",
                    ),

                    Text(

                      formatRupiah(
                        trx.total,
                      ),

                      style: const TextStyle(

                        fontWeight:
                            FontWeight.bold,

                        fontSize: 18,

                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Divider(),

              const SizedBox(height: 10),

              const Text(

                "Update Berat Laundry",

                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(

                children: [

                  Expanded(

                    child: TextField(

                      controller:
                          weightController,

                      keyboardType:
                          TextInputType.number,

                      decoration:
                          const InputDecoration(

                        border:
                            OutlineInputBorder(),

                        hintText:
                            "Berat",

                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton(

                    onPressed: () async {

                      final success =

                          await service
                              .updateWeight(

                        id: trx.id,

                        weight:

                            double.tryParse(
                                  weightController.text,
                                ) ??
                                0,

                      );

                      if (success) {

                        loadData();

                        if (context.mounted) {

                          ScaffoldMessenger.of(context)
                              .showSnackBar(

                            const SnackBar(

                              content: Text(
                                "Berat berhasil diperbarui",
                              ),

                            ),
                          );
                        }

                      }

                    },

                     style:
                      ElevatedButton.styleFrom(

                        backgroundColor:
                            const Color(
                          0xFF2563EB,
                        ),

                        foregroundColor:
                            Colors.white,

                      ),


                    child:
                        const Text(
                      "Update Berat",
                    ),
                  ),
                ],
              ),
            
            if(trx.fragrances.isNotEmpty)
            ...[

              const SizedBox(height: 15),

              const Text(

                "Pewangi",

                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),

              ),

              const SizedBox(height: 8),

              Wrap(

                spacing: 8,

                children:

                trx.fragrances.map((e){

                  return Chip(

                    backgroundColor:
                        const Color(
                      0xFFEEF2FF,
                    ),

                    labelStyle:
                        const TextStyle(

                      color:
                          Color(
                        0xFF4F46E5,
                      ),

                      fontWeight:
                          FontWeight.w600,

                    ),

                    label:
                    Text(
                      e.fragranceName,
                    ),
                  );

                }).toList(),

              ),

            ],

            if(trx.notes.isNotEmpty)
            ...[

              const SizedBox(height: 15),

              const Text(

                "Catatan",

                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),

              ),

              const SizedBox(height: 8),

              Container(

                width:
                double.infinity,

                padding:
                const EdgeInsets.all(12),

                decoration:

                BoxDecoration(

                  color:
                  Colors.grey.shade100,

                  borderRadius:
                  BorderRadius.circular(12),

                ),

                child:
                Text(
                  trx.notes,
                ),

              ),

            ]

          ],

        ),

      ),

    );

  }

  Widget buildPaymentCard() {

    final trx = transaction!;

    return Card(

      elevation: 2,

      color: Colors.white,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(

              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                const Text(

                  "Pembayaran",

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),

                ),

                TextButton(

                  onPressed: () {

                    showUpdatePaymentDialog();

                  },

                  child: const Text(
                    "Update",
                  ),

                ),

              ],
            ),

            const SizedBox(height: 12),

            paymentRow(
              "Status",
              trx.paymentStatus,
            ),

            paymentRow(
              "Metode Dipilih Saat Pickup",
              trx.initialPaymentMethod,
            ),

            paymentRow(
              "Metode Pelunasan",
              trx.paymentMethod.isEmpty
                  ? "-"
                  : trx.paymentMethod,
            ),

            const Divider(),

            paymentRow(
              "Total",
              formatRupiah(trx.total),
              isBold: true,
            ),

          ],
        ),
      ),
    );
  }

  Widget buildTrackingCard() {

    final trx = transaction!;

    return Card(

      elevation: 2,

      color: Colors.white,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(

              "Tracking",

              style: TextStyle(

                fontWeight:
                    FontWeight.bold,

                fontSize: 16,

              ),

            ),

            const SizedBox(height: 16),

            const Text(

              "Kode Tracking",

              style: TextStyle(

                color: Colors.grey,

                fontSize: 12,

              ),

            ),

            const SizedBox(height: 4),

            Text(

              trx.trackingCode,

              style: const TextStyle(

                fontWeight:
                    FontWeight.bold,

                fontSize: 18,

              ),

            ),

            const SizedBox(height: 20),

            Center(

              child: Container(

                padding:
                    const EdgeInsets.all(16),

                decoration:
                    BoxDecoration(

                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),

                  borderRadius:
                      BorderRadius.circular(16),

                ),

                child: QrImageView(

                  data: trx.trackingUrl,

                  size: 220,

                ),

              ),

            ),

            const SizedBox(height: 20),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton.icon(

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      const Color(0xFF16A34A),

                  foregroundColor:
                      Colors.white,

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                  ),

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),

                  ),

                ),

                onPressed: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) => TrackingScreen(

                        trackingCode:
                            trx.trackingCode,

                      ),

                    ),

                  );

                },

                icon: const Icon(
                  Icons.open_in_new,
                ),

                label: const Text(
                  "Buka Tracking",
                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}