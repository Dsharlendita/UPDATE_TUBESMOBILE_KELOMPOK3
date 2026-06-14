import 'package:flutter/material.dart';

import '../../models/tracking_model.dart';
import '../../services/tracking_service.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'tracking_search_screen.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../../utils/invoice_pdf.dart';
import 'package:printing/printing.dart';

class TrackingScreen extends StatefulWidget {

  final String trackingCode;

  const TrackingScreen({

    super.key,

    required this.trackingCode,

  });

  @override
  State<TrackingScreen> createState() =>
      _TrackingScreenState();

}

class _TrackingScreenState
    extends State<TrackingScreen> {

  final TrackingService service =
      TrackingService();

  TrackingModel? tracking;

  bool isLoading = true;

  @override
  void initState() {

    super.initState();

    loadData();

  }

  Future<pw.Document> buildInvoiceDocument() async {

    final pdf = pw.Document();

    pdf.addPage(

      pw.Page(

        pageFormat: PdfPageFormat.a4,

        margin: const pw.EdgeInsets.all(15),

        build: (context) {

          return pw.Column(

            crossAxisAlignment:
                pw.CrossAxisAlignment.start,

            children: [

              // HEADER

              pw.Container(

                padding:
                    const pw.EdgeInsets.all(15),

                decoration: pw.BoxDecoration(

                  color: PdfColors.blue50,

                  borderRadius:
                      pw.BorderRadius.circular(12),

                ),

                child: pw.Row(

                  mainAxisAlignment:
                      pw.MainAxisAlignment.spaceBetween,

                  children: [

                    pw.Column(

                      crossAxisAlignment:
                          pw.CrossAxisAlignment.start,

                      children: [

                        pw.Text(

                          tracking!.laundryName,

                          style: pw.TextStyle(

                            fontSize: 20,

                            fontWeight:
                                pw.FontWeight.bold,

                          ),

                        ),

                        pw.SizedBox(height: 4),

                        pw.Text(
                          tracking!.laundryAddress,
                        ),

                        pw.SizedBox(height: 8),

                        pw.Container(

                          padding:
                              const pw.EdgeInsets.symmetric(

                            horizontal: 10,

                            vertical: 4,

                          ),

                          decoration: pw.BoxDecoration(

                            color:
                                PdfColors.green100,

                            borderRadius:
                                pw.BorderRadius.circular(
                              20,
                            ),

                          ),

                          child: pw.Text(
                            statusLabel(
                              tracking!.status,
                            ),
                          ),

                        ),

                      ],

                    ),

                    pw.Column(

                      crossAxisAlignment:
                          pw.CrossAxisAlignment.end,

                      children: [

                        pw.Text(

                          "INVOICE",

                          style: pw.TextStyle(

                            fontSize: 18,

                            fontWeight:
                                pw.FontWeight.bold,

                          ),

                        ),

                        pw.SizedBox(height: 6),

                        pw.Text(
                          tracking!.invoice,
                        ),

                      ],

                    ),

                  ],

                ),

              ),

              pw.SizedBox(height: 10),

              // CUSTOMER CARD

              pw.Row(

                children: [

                  pw.Expanded(

                    child: invoiceCard(
                      "Pelanggan",
                      tracking!.customerName,
                    ),

                  ),

                  pw.SizedBox(width: 8),

                  pw.Expanded(

                    child: invoiceCard(
                      "Telepon",
                      tracking!.customerPhone,
                    ),

                  ),

                ],

              ),

              pw.SizedBox(height: 8),

              pw.Row(

                children: [

                  pw.Expanded(

                    child: invoiceCard(
                      "Tanggal Masuk",
                      formatDate(
                        tracking!.createdAt,
                      ),
                    ),

                  ),

                  pw.SizedBox(width: 8),

                  pw.Expanded(

                    child: invoiceCard(
                      "Estimasi",
                      tracking!.estimatedCompletion
                              .isEmpty
                          ? "-"
                          : formatDate(
                              tracking!
                                  .estimatedCompletion,
                            ),
                    ),

                  ),

                ],

              ),

              pw.SizedBox(height: 12),

              pw.Text(

                "DETAIL TRANSAKSI",

                style: pw.TextStyle(

                  fontWeight:
                      pw.FontWeight.bold,

                  fontSize: 14,

                ),

              ),

              pw.SizedBox(height: 8),

              pw.Container(

                padding:
                    const pw.EdgeInsets.all(10),

                decoration: pw.BoxDecoration(

                  border:
                      pw.Border.all(),

                ),

                child: pw.Column(

                  children: [

                    invoiceRow(
                      "Pelanggan",
                      tracking!.customerName,
                    ),

                    invoiceRow(
                      "Telepon",
                      tracking!.customerPhone,
                    ),

                    invoiceRow(
                      "Status",
                      statusLabel(
                        tracking!.status,
                      ),
                    ),

                    invoiceRow(
                      "Pembayaran",
                      tracking!.paymentStatus
                                  .toLowerCase() ==
                              "paid"
                          ? "Lunas"
                          : "Belum Lunas",
                    ),

                    invoiceRow(

                      "Pewangi",

                      tracking!.fragrances.isEmpty

                          ? "-"

                          : tracking!.fragrances
                                .map(
                                  (e) =>
                                      e.fragranceName,
                                )
                                .join(", "),

                    ),

                  ],

                ),

              ),

              pw.SizedBox(height: 10),

              pw.Text(

                "LAYANAN",

                style: pw.TextStyle(

                  fontWeight:
                      pw.FontWeight.bold,

                ),

              ),

              pw.SizedBox(height: 8),

              pw.Table(

                border: pw.TableBorder.all(),

                children: [

                  pw.TableRow(

                    children: [

                      tableCell("Layanan"),
                      tableCell("Berat"),
                      tableCell("Harga"),
                      tableCell("Subtotal"),

                    ],

                  ),

                  ...tracking!.details.map(

                    (item) {

                      return pw.TableRow(

                        children: [

                          tableCell(
                            item.serviceName,
                          ),

                          tableCell(
                            "${item.weight} kg",
                          ),

                          tableCell(
                            formatRupiah(
                              item.pricePerKg,
                            ),
                          ),

                          tableCell(
                            formatRupiah(
                              item.subtotal,
                            ),
                          ),

                        ],

                      );

                    },

                  ),

                ],

              ),


              pw.SizedBox(height: 12),

              // TOTAL

              pw.Container(

                width: double.infinity,

                padding:
                    const pw.EdgeInsets.all(14),

                decoration: pw.BoxDecoration(

                  color:
                      PdfColors.blue600,

                  borderRadius:
                      pw.BorderRadius.circular(
                    12,
                  ),

                ),

                child: pw.Column(

                  children: [

                    pw.Text(

                      "TOTAL PEMBAYARAN",

                      style: pw.TextStyle(
                        color:
                            PdfColors.white,
                      ),

                    ),

                    pw.SizedBox(height: 6),

                    pw.Text(

                      formatRupiah(
                        tracking!.totalPrice,
                      ),

                      style: pw.TextStyle(

                        color:
                            PdfColors.white,

                        fontSize: 20,

                        fontWeight:
                            pw.FontWeight.bold,

                      ),

                    ),

                    pw.Text(

                      "${tracking!.totalWeight} Kg",

                      style: pw.TextStyle(
                        color:
                            PdfColors.white,
                      ),

                    ),

                  ],

                ),

              ),

              pw.SizedBox(height: 8),

              pw.Divider(),

              pw.SizedBox(height: 6),

              pw.Row(

                mainAxisAlignment:
                    pw.MainAxisAlignment.spaceBetween,

                crossAxisAlignment:
                    pw.CrossAxisAlignment.center,

                children: [

                  pw.Column(

                    crossAxisAlignment:
                        pw.CrossAxisAlignment.start,

                    children: [

                      pw.Text(
                        "Terima kasih telah mempercayakan",
                      ),

                      pw.Text(

                        tracking!.laundryName,

                        style: pw.TextStyle(
                          fontWeight:
                              pw.FontWeight.bold,
                        ),

                      ),

                      pw.SizedBox(height: 6),

                      pw.Text(
                        "Tracking Code",
                      ),

                      pw.Text(

                        tracking!.trackingCode,

                        style: pw.TextStyle(

                          fontWeight:
                              pw.FontWeight.bold,

                          fontSize: 14,

                        ),

                      ),

                    ],

                  ),

                  buildQrCode(
                    tracking!.trackingCode,
                  ),

                ],

              ),

            ],

          );

        },

      ),

    );

    return pdf;
  }
 

  pw.Widget invoiceCard(
    String title,
    String value,
  ) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey300,
        ),
        borderRadius:
            pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [

          pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 10,
            ),
          ),

          pw.SizedBox(height: 4),

          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),

        ],
      ),
    );
  }

  Future<void> loadData() async {

    tracking =
        await service.getTracking(
      widget.trackingCode,
    );

    print(
      "ESTIMASI => ${tracking?.estimatedCompletion}"
    );

    if(mounted){

      setState(() {

        isLoading = false;

      });

    }

  }

  @override
  Widget build(BuildContext context) {

    if(isLoading){

      return const Scaffold(

        body: Center(

          child:
              CircularProgressIndicator(),

        ),

      );

    }

    if(tracking == null){

      return Scaffold(

        appBar: AppBar(),

        body: const Center(

          child: Text(
            "Data tracking tidak ditemukan",
          ),

        ),

      );

    }

    return Scaffold(

      appBar: AppBar(

        title:
            const Text(
          "Tracking Laundry",
        ),

      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          children: [

            buildLaundryHeader(),

            const SizedBox(height: 16),

            buildTimelineCard(),

            const SizedBox(height: 16),

            buildTransactionCard(),

            const SizedBox(height: 16),

            buildBottomButtons(),

            const SizedBox(height: 30),

            buildFooter(),

          ],

        ),

      ),

    );

  }

  Widget buildTimelineCard() {
    final statuses =
    tracking!.timeline;

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(

              "Progress Laundry",

              style: TextStyle(

                fontWeight:
                    FontWeight.bold,

                fontSize: 18,

              ),

            ),

            const SizedBox(height: 16),

            Container(

              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),

              decoration: BoxDecoration(

                color: const Color(0xFFDDF4FF),

                borderRadius:
                    BorderRadius.circular(20),

              ),

              child: Text(

                tracking!.status,

                style: const TextStyle(

                  color: Color(0xFF3182CE),

                  fontWeight: FontWeight.w600,

                ),

              ),

            ),

            const SizedBox(height: 20),

            LinearProgressIndicator(

              value:
                  tracking!.progressPercentage / 100,

              minHeight: 8,

              backgroundColor:
                  const Color(0xFFE2E8F0),

              valueColor:
                  const AlwaysStoppedAnimation(
                Color(0xFF56B3E5),
              ),

            ),

            const SizedBox(height: 8),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                const Text(

                  "Progress",

                  style: TextStyle(
                    color: Color(0xFF64748B),
                  ),

                ),

                Text(

                  "${tracking!.progressPercentage}%",

                  style: const TextStyle(
                    color: Color(0xFF64748B),
                  ),

                ),

              ],

            ),

            const SizedBox(height: 20),

            ListView.builder(

              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              itemCount:
                  statuses.length,

              itemBuilder:
                  (context, index) {

                final done =
                    index <
                    tracking!.currentTimelineIndex;

                final current =
                    index ==
                    tracking!.currentTimelineIndex;

                return TimelineTile(

                  isFirst:
                      index == 0,

                  isLast:
                      index ==
                      statuses.length - 1,

                  beforeLineStyle:

                      LineStyle(

                    color:

                        done
                            ? Colors.green
                            : Colors.grey.shade300,

                  ),

                  indicatorStyle:

                      IndicatorStyle(

                    width: 24,

                    color:

                        done
                            ? Colors.green
                            : current
                                ? const Color(0xFF56B3E5)
                                : Colors.grey,

                  ),

                  endChild:

                      Padding(

                    padding:
                        const EdgeInsets.all(8),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(

                          statuses[index],

                          style: const TextStyle(

                            fontWeight:
                                FontWeight.bold,

                          ),

                        ),

                        Text(

                          done
                              ? "Selesai"
                              : current
                                  ? "Sedang Berlangsung"
                                  : "Menunggu",

                        ),

                      ],

                    ),

                  ),

                );

              },

            ),

          ],

        ),

      ),

    );
  }

  String statusLabel(String status) {

    switch(status.toLowerCase()) {

      case "pending":
        return "Menunggu Konfirmasi";

      case "confirmed":
        return "Dikonfirmasi";

      case "washing":
        return "Pencucian";

      case "drying":
        return "Pengeringan";

      case "ironing":
        return "Penyetrikaan";

      case "ready":
        return "Siap Diambil";

      case "completed":
        return "Selesai";

      default:
        return status;
    }
  }

  Widget buildLaundryHeader(){

    return Container(

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color: const Color(0xFFEFF8FB),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: const Color(0xFFD7EAF2),
        ),

      ),

      child: Row(

        children: [

          CircleAvatar(

            radius: 22,

            backgroundColor:
                const Color(0xFF5AA2E8),

            child: Text(

              tracking!.laundryName.length >= 2
                ? tracking!.laundryName
                    .substring(0, 2)
                    .toUpperCase()
                : tracking!.laundryName
                    .toUpperCase()

            ),

          ),

          const SizedBox(width: 12),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(

                  tracking!.laundryName,

                  style: const TextStyle(

                    fontWeight:
                        FontWeight.bold,
                    
                    fontSize: 18,

                  ),

                ),

                Text(
                  tracking!.laundryAddress,
                ),

              ],

            ),

          ),

          Container(

            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(12),

            ),

            child: Text(
              tracking!.invoice,
            ),

          ),

        ],

      ),

    );

  }

  Widget buildProgress(){

    return Card(

      child: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(

              "Progress Laundry",

              style: TextStyle(

                fontWeight:
                    FontWeight.bold,

              ),

            ),

            Container(

              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),

              decoration: BoxDecoration(

                color:
                    const Color(0xFFDDF4FF),

                borderRadius:
                    BorderRadius.circular(20),

              ),

              child: Text(

                statusLabel(tracking!.status),

                style: const TextStyle(

                  color: Color(0xFF3182CE),

                  fontWeight: FontWeight.w600,

                ),

              ),

            ),
            const SizedBox(height: 16),

            LinearProgressIndicator(

              value:

                  tracking!
                      .progressPercentage /

                  100,

            ),

            const SizedBox(height: 8),

            Text(

              "${tracking!.progressPercentage}%",

            ),

            const SizedBox(height: 8),

            Text(

              "Status Saat Ini: ${tracking!.status}",

              style: const TextStyle(

                fontWeight:
                    FontWeight.bold,

              ),

            ),

          ],

        ),

      ),

    );

  }

  Widget buildServices(){

    return Card(

      child: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(

              "Detail Layanan",

              style: TextStyle(

                fontWeight:
                    FontWeight.bold,

              ),

            ),

            const SizedBox(height: 12),

            if(tracking!.details.isEmpty)
              const Text(
                "Belum ada detail layanan",
              )
            else

            ...tracking!.details.map(

              (item){

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
                    "Rp ${item.subtotal}",
                  ),

                );

              },

            ),

            const Divider(height: 30),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                const Text(

                  "Total Berat",

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),

                ),

                Text(

                  "${tracking!.totalWeight} kg",

                  style: const TextStyle(

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),

              ],
  
            ),

            const SizedBox(height: 16),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                const Text(

                  "Total",

                  style: TextStyle(

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 18,

                  ),

                ),

                Text(

                  formatRupiah(tracking!.totalPrice),

                  style: const TextStyle(

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 18,

                  ),

                ),

              ],

            ),

          ],

        ),

      ),

    );

  }

  Widget buildFooter(){

    return Column(

      children: [

        const Text(

          "Simpan halaman ini untuk memantau status laundry Anda",

          textAlign: TextAlign.center,

          style: TextStyle(
            color: Color(0xFF94A3B8),
          ),

        ),

        const SizedBox(height: 12),

        GestureDetector(

          onTap: () async {

            final url = Uri.parse(
              "https://wa.me/${tracking!.laundryPhone}",
            );

            await launchUrl(
              url,
              mode: LaunchMode.externalApplication,
            );

          },

          child: Text(

            "Butuh bantuan? Hubungi ${tracking!.laundryName} di ${tracking!.laundryPhone}",

            textAlign: TextAlign.center,

            style: const TextStyle(

              color: Color(0xFF2563EB),

              decoration:
                  TextDecoration.underline,

            ),

          ),

        ),

        const SizedBox(height: 20),

        const Row(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              Icons.home,
              size: 16,
              color: Color(0xFF60A5FA),
            ),

            SizedBox(width: 6),

            Text(

              "LaundryHub",

              style: TextStyle(
                color: Color(0xFF60A5FA),
                fontWeight: FontWeight.w500,
              ),

            ),

          ],

        ),

      ],

    );
  }

  Widget buildNotes() {

    if(tracking!.notes.isEmpty){

      return const SizedBox();

    }

    return Card(

      child: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(

              "Catatan",

              style: TextStyle(

                fontWeight:
                    FontWeight.bold,

              ),

            ),

            const SizedBox(height: 10),

            Text(
              tracking!.notes,
            ),

          ],

        ),

      ),

    );

  }

  Widget buildBottomButtons() {

    return Wrap(

      spacing: 10,

      runSpacing: 10,

      children: [

        OutlinedButton.icon(

          onPressed: () async {

            final pdf = await InvoicePdf()
                .buildInvoiceDocument(tracking!);

            await InvoicePdf.openInvoice(
              pdf,
              tracking!.invoice,
            );

          },

          icon: const Icon(
            Icons.download,
          ),

          label: const Text(
            "Download Invoice",
          ),

        ),

        OutlinedButton.icon(

          onPressed: () async {

            final pdf = await InvoicePdf()
                .buildInvoiceDocument(tracking!);

            await Printing.layoutPdf(

              onLayout: (format) async {

                return pdf.save();

              },

            );

          },

          icon: const Icon(
            Icons.print,
          ),

          label: const Text(
            "Cetak",
          ),

        ),

        OutlinedButton.icon(

          onPressed: () {

            Navigator.pushReplacement(

              context,

              MaterialPageRoute(

                builder: (_) =>
                    const TrackingSearchScreen(),

              ),

            );

          },

          icon: const Icon(
            Icons.search,
          ),

          label: const Text(
            "Lacak Lagi",
          ),

        ),

      ],

    );

  }

 

  Widget infoRow(
    String title,
    String value,
  ){

    return Padding(

      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),

      child: Row(

        children: [

          SizedBox(
            width: 100,
            child: Text(title),
          ),

          const Text(": "),

          Expanded(
            child: Text(value),
          ),

        ],

      ),

    );

  }

  Widget buildInfoBox(
    String title,
    String value,
  ){

    return Container(

      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(

        color:
            const Color(
          0xFFF8FAFC,
        ),

        borderRadius:
            BorderRadius.circular(
          12,
        ),

      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Text(

            title,

            style: const TextStyle(

              fontSize: 11,

              color:
                  Color(
                0xFF94A3B8,
              ),

            ),

          ),

          const SizedBox(height: 8),

          Text(

            value,

            style: const TextStyle(

              fontWeight:
                  FontWeight.bold,

            ),

          ),

        ],

      ),

    );

  }

  String formatDate(String date){

    try{

      return DateFormat(
        "dd MMM yyyy, HH:mm",
      ).format(
        DateTime.parse(date),
      );

    }catch(_){

      return date;

    }

  }

  String formatRupiah(num value){

    return NumberFormat.currency(

      locale: 'id_ID',

      symbol: 'Rp ',

      decimalDigits: 0,

    ).format(value);

  }

  pw.Widget invoiceRow(
    String title,
    String value,
  ) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: pw.Row(
        children: [

          pw.SizedBox(
            width: 100,
            child: pw.Text(title),
          ),

          pw.Text(": "),

          pw.Expanded(
            child: pw.Text(value),
          ),

        ],
      ),
    );
  }

  pw.Widget tableCell(
    String text,
  ) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.all(8),
      child: pw.Text(text),
    );
  }

  pw.Widget buildQrCode(String data) {

    return pw.BarcodeWidget(

      barcode: pw.Barcode.qrCode(),

      data: data,

      width: 70,

      height: 70,

    );

  }

  Widget buildTransactionCard() {

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(

              "Detail Transaksi",

              style: TextStyle(

                fontWeight:
                    FontWeight.bold,

                fontSize: 18,

              ),

            ),

            const SizedBox(height: 20),

            GridView.count(

              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              crossAxisCount: 2,

              childAspectRatio: 1.4,

              crossAxisSpacing: 12,

              mainAxisSpacing: 12,

              children: [

                buildInfoBox(
                  "NAMA PELANGGAN",
                  tracking!.customerName,
                ),

                buildInfoBox(
                  "NOMOR TELEPON",
                  tracking!.customerPhone,
                ),

                buildInfoBox(

                  "ESTIMASI SELESAI",

                  tracking!.estimatedCompletion.isEmpty

                      ? "Belum Ditentukan"

                      : formatDate(
                          tracking!.estimatedCompletion,
                        ),

                ),

                buildInfoBox(
                  "TANGGAL MASUK",
                  formatDate(
                    tracking!.createdAt,
                  )
                ),

              ],

            ),

          
            const Divider(height: 30),

            const Text(

              "Detail Layanan",

              style: TextStyle(

                fontWeight:
                    FontWeight.bold,

              ),

            ),

            const SizedBox(height: 12),

            if (tracking!.details.isEmpty) ...[

              const Text(
                "Belum ada layanan",
              ),

            ] else ...[

              const SizedBox(height: 16),

              Table(

                columnWidths: const {

                  0: FlexColumnWidth(4),
                  1: FlexColumnWidth(3),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(3),

                },

                children: [

                  const TableRow(

                    children: [

                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          "LAYANAN",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          "HARGA/KG",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          "BERAT",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "SUBTOTAL",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),

                    ],

                  ),

                  ...tracking!.details.map((item) {

                    return TableRow(

                      children: [

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          child: Text(
                            item.serviceName,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          child: Text(
                            formatRupiah(item.pricePerKg),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          child: Text(
                            "${item.weight} kg",
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              formatRupiah(
                                item.subtotal,
                              ),
                            ),
                          ),
                        ),

                      ],

                    );

                  }),

                ],

              )

            ],
            
            const Divider(height: 30),

            if (tracking!.fragrances.isNotEmpty)

            Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Row(

                  children: [

                    const Text(

                      "Pewangi:",

                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                      ),

                    ),

                    const SizedBox(width: 8),

                    ...tracking!.fragrances.map(

                      (item) {

                        return Container(

                          margin:
                              const EdgeInsets.only(
                            right: 8,
                          ),

                          padding:
                              const EdgeInsets.symmetric(

                            horizontal: 12,
                            vertical: 6,

                          ),

                          decoration: BoxDecoration(

                            color:
                                const Color(
                              0xFFEDE9FE,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),

                          ),

                          child: Text(

                            item.fragranceName,

                            style: const TextStyle(

                              color:
                                  Color(
                                0xFF7C3AED,
                              ),

                            ),

                          ),

                        );

                      },

                    ),

                  ],

                ),

              ],

            ),
            const Divider(height: 30),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                const Text(
                  "Status Pembayaran",
                ),

                Container(

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(

                    color:
                        const Color(
                      0xFFD1FAE5,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),

                  ),

                  child: Text(

                    tracking!.paymentStatus
                            .toLowerCase() ==
                        "paid"

                        ? "Lunas"

                        : tracking!.paymentStatus,

                    style: const TextStyle(

                      color:
                          Color(
                        0xFF047857,
                      ),

                      fontWeight:
                          FontWeight.w600,

                    ),

                  ),

                ),

              ],

            ),
            const SizedBox(height: 20),

            if(tracking!.notes.isNotEmpty)

             Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(12),

              decoration: BoxDecoration(

                color:
                    const Color(
                  0xFFFFFBEB,
                ),

                borderRadius:
                    BorderRadius.circular(
                  12,
                ),

              ),

              child: Row(

                children: [

                  const Icon(

                    Icons.note_alt,

                    size: 18,

                    color:
                        Colors.brown,

                  ),

                  const SizedBox(width: 8),

                  Expanded(

                    child: Text(

                      "Catatan: ${tracking!.notes}",

                      style: const TextStyle(

                        color:
                            Colors.brown,

                      ),

                    ),

                  ),

                ],

              ),

            ),

            const SizedBox(height: 20),

          ],

        ),

      ),

    );

  }

}