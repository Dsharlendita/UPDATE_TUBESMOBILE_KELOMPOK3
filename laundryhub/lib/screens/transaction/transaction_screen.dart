import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../services/transaction_service.dart';
import 'add_transaction_screen.dart';
import 'transaction_detail_screen.dart';
import '../tracking/tracking_screen.dart';
import '../../services/tracking_service.dart';
import '../../utils/invoice_pdf.dart';


class TransactionScreen extends StatefulWidget {

  const TransactionScreen({
    super.key,
  });

  @override
  State<TransactionScreen> createState() =>
      _TransactionScreenState();

}

class _TransactionScreenState
    extends State<TransactionScreen> {

  final TransactionService service =
      TransactionService();

String formatRupiah(dynamic value) {

  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  double amount = 0;

  if (value != null) {
    amount = double.tryParse(
      value.toString(),
    ) ?? 0;
  } 

  return formatter.format(amount);

}

  bool loading = true;

  List<TransactionModel>
  transactions = [];

  Map summary = {};

  final searchController =
      TextEditingController();

  DateTime? dateFrom;
  DateTime? dateTo;

  String selectedStatus =
      "Semua Status";

  String selectedPayment =
      "Semua";

  final statusMap = {

    "Semua Status": null,
    "Menunggu": "pending",
    "Dikonfirmasi": "confirmed",
    "Dicuci": "washing",
    "Dikeringkan": "drying",
    "Disetrika": "ironing",
    "Siap Diambil": "ready",
    "Selesai": "completed",
    "Dibatalkan": "cancelled",

  };

  final paymentMap = {

    "Semua": null,
    "Belum Dibayar": "unpaid",
    "Menunggu Konfirmasi": "pending",
    "Lunas": "paid",

  };

  @override
  void initState() {

    super.initState();
    loadData();

  }

  Future loadData() async {

    setState(() {
      loading = true;
    });

    final result =
    await service.getTransactions(

      status:
      statusMap[selectedStatus],

      paymentStatus:
      paymentMap[selectedPayment],

      search:
      searchController.text,

      dateFrom:
      dateFrom
          ?.toString()
          .split(" ")[0],

      dateTo:
      dateTo
          ?.toString()
          .split(" ")[0],

    );

    if(result["success"]) {

      transactions =
      result["transactions"];

      summary =
      result["summary"];

    }

    setState(() {
      loading = false;
    });

  }

  Future pickDate(bool from) async {

    DateTime? picked =
    await showDatePicker(

      context: context,

      initialDate:
      DateTime.now(),

      firstDate:
      DateTime(2020),

      lastDate:
      DateTime(2035),

      builder:
      (context, child){

        return Theme(

          data:
          ThemeData.light().copyWith(

            colorScheme:
            const ColorScheme.light(

              primary:
              Colors.indigo,

              surface:
              Colors.white,

            ),

            dialogBackgroundColor:
            Colors.white,

          ),

          child:
          child!,

        );

      },

    );

    if(picked != null){

      setState(() {

        if(from){

          dateFrom = picked;

        }else{

          dateTo = picked;

        }

      });

    }

  }

  Widget statCard(
    String title,
    String value,
    Color color){

  return Container(

      padding:
      const EdgeInsets.all(14),

      decoration:
      BoxDecoration(

        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(20),

      ),

      child:
      Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children:[

          Text(

            title,

            style:
            TextStyle(

              color:
              Colors.grey[600],

              fontSize: 15,

            ),

          ),

          const SizedBox(
            height: 8,
          ),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          )

        ],

      ),

    );

  }

  Widget buildDropdown({

    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required String label,

  }){

    return Container(

      width: double.infinity,

      padding:
      const EdgeInsets.symmetric(

        horizontal: 12,
        vertical: 0,

      ),

      decoration:
      BoxDecoration(

        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(16),

        border:
        Border.all(

          color:
          Colors.grey.shade300,

        ),

      ),

      child:
      DropdownButtonFormField<String>(

        value: value,

        isExpanded: true,

        decoration:
        InputDecoration(

          labelText: label,

          border:
          InputBorder.none,

        ),

        items:

        items.map((e){

          return DropdownMenuItem(

            value: e,

            child:
            Text(

              e,

              overflow:
              TextOverflow.ellipsis,

            ),

          );

        }).toList(),

        onChanged: onChanged,

      ),

    );

  }

  IconData getStatusIcon(
    String status,
  ){

    switch(status){

      case "pending":
        return Icons.schedule;

      case "confirmed":
        return Icons.check_circle_outline;

      case "washing":
        return Icons.local_laundry_service;

      case "drying":
        return Icons.wb_sunny_outlined;

      case "ironing":
        return Icons.local_laundry_service;

      case "ready":
        return Icons.inventory_2_outlined;

      case "completed":
        return Icons.task_alt;

      case "cancelled":
        return Icons.cancel_outlined;

      default:
        return Icons.info_outline;
    }
  }

  Widget statusBadge(String status){

    Color bg = Colors.orange.shade100;
    Color text = Colors.orange.shade800;

    String label = status;

    switch(status){

      case "pending":
        label = "Menunggu";
        break;

      case "confirmed":
        label = "Dikonfirmasi";
        bg = Colors.blue.shade100;
        text = Colors.blue.shade800;
        break;

      case "washing":
        label = "Dicuci";
        bg = Colors.indigo.shade100;
        text = Colors.indigo.shade800;
        break;

      case "drying":
        label = "Dikeringkan";
        bg = Colors.cyan.shade100;
        text = Colors.cyan.shade800;
        break;

      case "ironing":
        label = "Disetrika";
        bg = Colors.purple.shade100;
        text = Colors.purple.shade800;
        break;

      case "ready":
        label = "Siap Diambil";
        bg = Colors.teal.shade100;
        text = Colors.teal.shade800;
        break;

      case "completed":
        label = "Selesai";
        bg = Colors.green.shade100;
        text = Colors.green.shade800;
        break;

      case "cancelled":
        label = "Dibatalkan";
        bg = Colors.red.shade100;
        text = Colors.red.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: text.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            getStatusIcon(status),
            size: 14,
            color: text,
          ),

          const SizedBox(width: 4),

          Text(
            label,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentBadge(String payment){

    Color bg;
    Color text;
    String label;
    IconData icon;

    switch(payment){

      case "paid":

        bg = Colors.green.shade100;
        text = Colors.green.shade800;

        label = "Lunas";

        icon = Icons.check_circle;

        break;

      case "pending":

        bg = Colors.orange.shade100;
        text = Colors.orange.shade800;

        label = "Menunggu";

        icon = Icons.schedule;

        break;

      default:

        bg = Colors.red.shade100;
        text = Colors.red.shade800;

        label = "Belum Dibayar";

        icon = Icons.cancel;

        break;

    }

    return Container(

      padding:
      const EdgeInsets.symmetric(

        horizontal: 12,
        vertical: 6,

      ),

      decoration:
      BoxDecoration(

        color: bg,

        borderRadius:
        BorderRadius.circular(30),

        border:
        Border.all(

          color:
          text.withOpacity(0.2),

        ),

      ),

      child:
      Row(

        mainAxisSize:
        MainAxisSize.min,

        children:[

          Icon(

            icon,

            size: 14,

            color: text,

          ),

          const SizedBox(
            width: 4,
          ),

          Text(

            label,

            style:
            TextStyle(

              color: text,

              fontWeight:
              FontWeight.w600,

            ),

          ),

        ],

      ),

    );

  }

  Widget actionButton({

    required IconData icon,

    required Color color,

    required VoidCallback onTap,

  }){

    return InkWell(

      onTap: onTap,

      borderRadius:
      BorderRadius.circular(12),

      child:
      Container(

        padding:
        const EdgeInsets.all(8),

        decoration:
        BoxDecoration(

          color:
          color.withOpacity(0.08),

          borderRadius:
          BorderRadius.circular(12),

        ),

        child:
        Icon(

          icon,

          size: 20,

          color: color,

        ),

      ),

    );

  }

  Widget buildDateButton({

    required bool from,
    required DateTime? value,
    required String text,

  }){

    return InkWell(

      onTap:(){

        pickDate(from);

      },

      child:
      Container(

        width: double.infinity,

        padding:
        const EdgeInsets.symmetric(

          horizontal: 14,
          vertical: 14,

        ),

        decoration:
        BoxDecoration(

          color:
          Colors.white,

          borderRadius:
          BorderRadius.circular(16),

          border:
          Border.all(

            color:
            Colors.grey.shade300,

          ),

        ),

        child:
        Row(

          children:[

            const Icon(

              Icons.calendar_month,
              color: Colors.indigo,

            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(

              child:
              Text(

                value == null

                    ?

                text

                    :

                "${value.day}/${value.month}/${value.year}",

                overflow:
                TextOverflow.ellipsis,

                style:
                const TextStyle(

                  fontSize: 16,

                  fontWeight:
                  FontWeight.w500,

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      backgroundColor:
      const Color(0xfff5f7fb),

      appBar:
      AppBar(

        elevation: 0,

        backgroundColor:
        Colors.white,

        title:
        const Text(

          "Manajemen Transaksi",

          style:
          TextStyle(

            color:
            Colors.black,

            fontWeight:
            FontWeight.bold,

          ),

        ),

      ),

      body:

      loading

      ?

      const Center(
        child:
        CircularProgressIndicator(),
      )

      :

      RefreshIndicator(

        onRefresh: () async {

          await loadData();

        },

        child:

        SingleChildScrollView(

          physics:
          const AlwaysScrollableScrollPhysics(),

          padding:
          const EdgeInsets.all(16),

          child:
          Column(
            children:[

              GridView.count(

                shrinkWrap: true,

                physics:
                const NeverScrollableScrollPhysics(),

                crossAxisCount: 2,

                crossAxisSpacing: 12,

                mainAxisSpacing: 12,

                childAspectRatio: 1.4,

                children:[

                  statCard(
                    "Total Transaksi",
                    "${summary["total"] ?? 0}",
                    Colors.black,
                  ),

                  statCard(
                    "Total Nilai",
                    formatRupiah(
                      summary["total_amount"],
                    ),
                    Colors.black,
                  ),

                  statCard(
                    "Sudah Dibayar",
                    formatRupiah(
                      summary["paid_amount"],
                    ),
                    Colors.green,
                  ),

                  statCard(
                    "Total Berat",
                    "${summary["total_weight"] ?? 0} kg",
                    Colors.blue,
                  ),

                ],

              ),
              const SizedBox(
                height: 18,
              ),

              Container(

                width:
                double.infinity,

                padding:
                const EdgeInsets.all(14),

                decoration:
                BoxDecoration(

                  color:
                  Colors.white,

                  borderRadius:
                  BorderRadius.circular(22),

                ),

                child:
                Column(

                  children:[

                    buildDropdown(

                      value:
                      selectedStatus,

                      items:
                      statusMap.keys.toList(),

                      onChanged:(v){

                        setState(() {

                          selectedStatus =
                          v!;

                        });

                      },

                      label:
                      "Status Laundry",

                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    buildDropdown(

                      value:
                      selectedPayment,

                      items:
                      paymentMap.keys.toList(),

                      onChanged:(v){

                        setState(() {

                          selectedPayment =
                          v!;

                        });

                      },

                      label:
                      "Pembayaran",

                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    buildDateButton(

                      from: true,

                      value:
                      dateFrom,

                      text:
                      "Tanggal Dari",

                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    buildDateButton(

                      from: false,

                      value:
                      dateTo,

                      text:
                      "Tanggal Sampai",

                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    TextField(

                      controller:
                      searchController,

                      textInputAction:
                      TextInputAction.search,

                      onSubmitted: (_){

                        FocusScope.of(context).unfocus();

                        loadData();

                      },

                      decoration:
                      InputDecoration(

                        hintText:
                        "Cari invoice,nama pelanggan",

                        prefixIcon:
                        const Icon(
                          Icons.search,
                        ),

                        filled: true,

                        fillColor:
                        Colors.white,

                        border:
                        OutlineInputBorder(

                          borderRadius:
                          BorderRadius.circular(16),

                        ),

                      ),

                    ),
                  
                    const SizedBox(
                      height: 18,
                    ),

                    Column(

                      children: [

                        Row(

                          children: [

                            Expanded(

                              child: SizedBox(

                                height: 48,

                                child: OutlinedButton(

                                  style:
                                  OutlinedButton.styleFrom(

                                    shape:
                                    RoundedRectangleBorder(

                                      borderRadius:
                                      BorderRadius.circular(16),

                                    ),

                                  ),

                                  onPressed: () {

                                    setState(() {

                                      searchController.clear();

                                      dateFrom = null;

                                      dateTo = null;

                                      selectedStatus =
                                      "Semua Status";

                                      selectedPayment =
                                      "Semua";

                                    });

                                    loadData();

                                  },

                                  child:
                                  const Text(

                                    "Reset",

                                    style:
                                    TextStyle(

                                      fontWeight:
                                      FontWeight.bold,

                                    ),

                                  ),

                                ),

                              ),

                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(

                              child: SizedBox(

                                height: 48,

                                child:
                                ElevatedButton.icon(

                                  style:
                                  ElevatedButton.styleFrom(

                                    backgroundColor:
                                    Colors.indigo,

                                    shape:
                                    RoundedRectangleBorder(

                                      borderRadius:
                                      BorderRadius.circular(16),

                                    ),

                                  ),

                                  onPressed:
                                  loadData,

                                  icon:
                                  const Icon(

                                    Icons.filter_alt,

                                    color:
                                    Colors.white,

                                  ),

                                  label:
                                  const Text(

                                    "Filter",

                                    style:
                                    TextStyle(

                                      color:
                                      Colors.white,

                                      fontWeight:
                                      FontWeight.bold,

                                    ),

                                  ),

                                ),

                              ),

                            ),

                          ],

                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        SizedBox(

                          width:
                          double.infinity,

                          height: 52,

                          child:
                          ElevatedButton.icon(

                            style:
                            ElevatedButton.styleFrom(

                              backgroundColor:
                              Colors.green,

                              shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                BorderRadius.circular(18),

                              ),

                            ),

                            onPressed: () async {

                              final result =
                              await Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder:
                                  (_) =>

                                  const AddTransactionScreen(),

                                ),

                              );

                              if(result == true){

                                loadData();

                              }

                            },

                            icon:
                            const Icon(

                              Icons.add,

                              color:
                              Colors.white,

                            ),

                            label:
                            const Text(

                              "Transaksi Baru",

                              style:
                              TextStyle(

                                color:
                                Colors.white,

                                fontWeight:
                                FontWeight.bold,

                                fontSize: 16,

                              ),

                            ),

                          ),

                        ),

                      ],

                    )

                  ],

                ),

              ),

              const SizedBox(
                height: 18,
              ),

              Container(

                width:
                double.infinity,

                padding:
                const EdgeInsets.all(30),

                decoration:
                BoxDecoration(

                  color:
                  Colors.white,

                  borderRadius:
                  BorderRadius.circular(22),

                ),

                child:

                transactions.isEmpty

                ?

                Center(

                  child:
                  Column(

                    children:[

                      Icon(
                        Icons.receipt_outlined,
                        size: 72,
                        color: Colors.grey.shade300,
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      const Text(

                        "Belum ada transaksi",

                        style:
                        TextStyle(

                          fontSize: 20,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(

                        "Mulai buat transaksi pertama Anda",

                        textAlign:
                        TextAlign.center,

                        style:
                        TextStyle(

                          color:
                          Colors.grey[600],

                          fontSize: 14,

                        ),

                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      SizedBox(

                        width: 220,

                        height: 48,

                        child:
                        ElevatedButton.icon(

                          style:
                          ElevatedButton.styleFrom(

                            backgroundColor:
                            Colors.green,

                          ),

                          onPressed: () async {

                            final result =

                            await Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder:
                                (_) =>

                                const AddTransactionScreen(),

                              ),

                            );

                            if(result == true){

                              loadData();

                            }

                          },

                          icon:
                          const Icon(
                            Icons.add,
                          ),

                          label:
                          const Text(
                            "Transaksi Baru",
                          ),

                        ),

                      ),

                    ],

                  ),

                )

                :

                ListView.builder(

                  shrinkWrap: true,

                  physics:
                  const NeverScrollableScrollPhysics(),

                  itemCount:
                  transactions.length,

                  itemBuilder:
                      (context,index){

                    final trx =
                    transactions[index];

                    return Container(

                      margin:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),

                      padding:
                      const EdgeInsets.all(16),

                      decoration:
                      BoxDecoration(

                        color:
                        Colors.white,

                        borderRadius:
                        BorderRadius.circular(18),

                        boxShadow: [

                          BoxShadow(

                            color:
                            Colors.black12
                                .withOpacity(0.04),

                            blurRadius: 8,

                            offset:
                            const Offset(0, 2),

                          ),

                        ],

                      ),

                      child:
                      Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          /// Invoice
                          Text(

                            trx.invoice,

                            style:
                            const TextStyle(

                              fontSize: 16,

                              fontWeight:
                              FontWeight.bold,

                            ),

                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          /// Nama Pelanggan
                          Text(

                            trx.customerName,

                            style:
                            TextStyle(

                              color:
                              Colors.grey[700],

                              fontSize: 14,

                            ),

                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(

                            trx.customerPhone,

                            style:
                            TextStyle(

                              color:
                              Colors.grey[600],

                              fontSize: 13,

                            ),

                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          /// Berat + Total
                          Row(

                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                            children: [

                              Row(

                                children: [

                                  const Icon(

                                    Icons.scale,

                                    size: 18,

                                    color:
                                    Colors.blue,

                                  ),

                                  const SizedBox(
                                    width: 6,
                                  ),

                                  Text(

                                    "${trx.weight} kg",

                                    style:
                                    const TextStyle(

                                      fontWeight:
                                      FontWeight.w600,

                                    ),

                                  ),

                                ],

                              ),

                              Text(

                                formatRupiah(
                                  trx.total,
                                ),

                                style:
                                const TextStyle(

                                  color:
                                  Colors.indigo,

                                  fontWeight:
                                  FontWeight.bold,

                                  fontSize: 16,

                                ),

                              ),

                            ],

                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          /// Status
                          Column(

                            children: [

                              Wrap(

                                spacing: 8,

                                runSpacing: 8,

                                children: [

                                  statusBadge(
                                    trx.status,
                                  ),

                                  paymentBadge(
                                    trx.paymentStatus,
                                  ),

                                ],

                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              Row(

                                mainAxisAlignment:
                                MainAxisAlignment.end,

                                children: [

                                  actionButton(

                                    icon:
                                    Icons.visibility,

                                    color:
                                    Colors.blue,

                                    onTap: () async {

                                      final result = await Navigator.push(

                                        context,

                                        MaterialPageRoute(

                                          builder: (_) =>
                                              TransactionDetailScreen(
                                            transactionId: trx.id,
                                          ),

                                        ),

                                      );

                                      if (result == true) {

                                        loadData();

                                      }

                                    },

                                  ),

                                  const SizedBox(
                                    width: 10,
                                  ),

                                  actionButton(

                                    icon:
                                    Icons.qr_code_2,

                                    color:
                                    Colors.green,

                                    onTap: () {

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

                                  ),

                                  const SizedBox(
                                    width: 10,
                                  ),

                                  actionButton(

                                    icon: Icons.download,

                                    color: Colors.deepPurple,

                                    onTap: () async {

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

                                  ),

                                ],

                              ),

                            ],

                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ], // children Column
          ), // Column
        ), // SingleChildScrollView
      ), // RefreshIndicator
    ); // Scaffold
  }
}

             