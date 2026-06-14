import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../models/tracking_model.dart';

class InvoicePdf {

  Future<pw.Document> buildInvoiceDocument(
  TrackingModel tracking,
  ) async{

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

                          tracking.laundryName,

                          style: pw.TextStyle(

                            fontSize: 20,

                            fontWeight:
                                pw.FontWeight.bold,

                          ),

                        ),

                        pw.SizedBox(height: 4),

                        pw.Text(
                          tracking.laundryAddress,
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
                              tracking.status,
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
                          tracking.invoice,
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
                      tracking.customerName,
                    ),

                  ),

                  pw.SizedBox(width: 8),

                  pw.Expanded(

                    child: invoiceCard(
                      "Telepon",
                      tracking.customerPhone,
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
                        tracking.createdAt,
                      ),
                    ),

                  ),

                  pw.SizedBox(width: 8),

                  pw.Expanded(

                    child: invoiceCard(
                      "Estimasi",
                      tracking.estimatedCompletion
                              .isEmpty
                          ? "-"
                          : formatDate(
                              tracking
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
                      tracking.customerName,
                    ),

                    invoiceRow(
                      "Telepon",
                      tracking.customerPhone,
                    ),

                    invoiceRow(
                      "Status",
                      statusLabel(
                        tracking.status,
                      ),
                    ),

                    invoiceRow(
                      "Pembayaran",
                      tracking.paymentStatus
                                  .toLowerCase() ==
                              "paid"
                          ? "Lunas"
                          : "Belum Lunas",
                    ),

                    invoiceRow(

                      "Pewangi",

                      tracking.fragrances.isEmpty

                          ? "-"

                          : tracking.fragrances
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

                  ...tracking.details.map(

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
                        tracking.totalPrice,
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

                      "${tracking.totalWeight} Kg",

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

                        tracking.laundryName,

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

                        tracking.trackingCode,

                        style: pw.TextStyle(

                          fontWeight:
                              pw.FontWeight.bold,

                          fontSize: 14,

                        ),

                      ),

                    ],

                  ),

                  buildQrCode(
                    tracking.trackingCode,
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

  static Future<void> openInvoice(
    pw.Document pdf,
    String invoiceNumber,
  ) async {

    final dir = await getTemporaryDirectory();

    final file = File(
      '${dir.path}/$invoiceNumber.pdf',
    );

    await file.writeAsBytes(
      await pdf.save(),
    );

    await OpenFilex.open(
      file.path,
    );
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





}