import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/transaction_service_model.dart';
import '../../services/transaction_service.dart';
import '../../models/fragrance_model.dart';
import '../../services/fragrance_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../models/customer_model.dart';

class AddTransactionScreen extends StatefulWidget {

  final CustomerModel? customer;

  const AddTransactionScreen({
    super.key,
    this.customer,
  });

  @override
  State<AddTransactionScreen>
      createState() =>
      _AddTransactionScreenState();
}

class AppCard extends StatelessWidget {
  final Widget child;

  const AppCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}


class _AddTransactionScreenState
    extends State<AddTransactionScreen> {

  final TransactionService
      transactionService =
      TransactionService();

  final FragranceService fragranceService =
    FragranceService();

  List<FragranceModel> fragrances = [];

  List<int> selectedFragranceIds = [];

  final TextEditingController
      customerNameController =
      TextEditingController();

  final TextEditingController
      customerPhoneController =
      TextEditingController();

  final TextEditingController
      customerEmailController =
      TextEditingController();

  final TextEditingController
      notesController =
      TextEditingController();
  
  bool customerFound = false;

  bool isSearchingCustomer = false;

  String? customerStatus;

  int? selectedCustomerId;

  List<TransactionServiceModel>
      services = [];

  Timer? _searchDebounce;

  List<Map<String,dynamic>>
    selectedServices = [

      {

        "service": null,

        "weightController":
        TextEditingController(),

        "subtotal": 0.0,

      }

    ];

  bool isLoading = false;

  String paymentMethod =
      "cash";
  
  double totalWeight = 0;
  double totalPrice = 0;

  String formatRupiah(dynamic value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return formatter.format(
      double.tryParse(
        value.toString(),
      ) ??
          0,
    );
  }

  @override
  void initState() {

    super.initState();

    if (widget.customer != null) {

      customerNameController.text =
          widget.customer!.name;

      customerPhoneController.text =
          widget.customer!.phone;

      customerEmailController.text =
          widget.customer!.email;

      customerFound = true;
      customerStatus = "member";

      selectedCustomerId =
          int.tryParse(
            widget.customer!.id,
          );
    }

    loadServices();

  }

  Future<void> loadServices() async {
    final result =
    await transactionService
        .createData();

    if(result["success"]) {

      services =
          result["services"];

      fragrances =

          (result["fragrances"]
                  as List)

              .map(

                (e) =>

                FragranceModel
                    .fromJson(e),

              )

              .toList();
    }

    setState(() {});
  }

  Future<void> findCustomerByPhone() async {

    final phone =
        formatPhone(
          customerPhoneController.text,
        );

    if(phone.length < 11){
      return;
    }

    setState(() {
      isSearchingCustomer = true;
      customerStatus = "searching";
    });

    final result =
        await transactionService
            .findCustomerByPhone(phone);

    print("RESULT CUSTOMER = $result");

    if(result["success"]){

      final customer =
          result["customer"];

      print(customer["name"]);
      print(customer["phone"]);

      customerFound = true;

      customerStatus = "member";

      selectedCustomerId =
          customer["id"];

      customerNameController.text =
          customer["name"] ?? "";

      customerEmailController.text =
          customer["email"] ?? "";
    }

    else {

      customerFound = false;

      customerStatus = "non_member";

      selectedCustomerId = null;

      customerNameController.clear();

      customerEmailController.clear();

    }

    setState(() {
      isSearchingCustomer = false;
    });
  }

  void calculateTotal(){

    totalWeight = 0;
    totalPrice = 0;

    for(final item
    in selectedServices){

      final service =
      item["service"]
      as TransactionServiceModel?;

      final weight =

      double.tryParse(

        item["weightController"]
            .text,

      ) ?? 0;

      if(service != null){

        item["subtotal"] =

        weight *
        service.pricePerKg;

        totalWeight += weight;

        totalPrice +=
        item["subtotal"];

      }

    }

    setState(() {});

  }

  void addServiceRow(){

    setState(() {

      selectedServices.add({

        "service": null,

        "weightController":
        TextEditingController(),

        "subtotal": 0.0,

      });

    });

  }
  @override
  void dispose() {

    customerNameController.dispose();
    customerPhoneController.dispose();
    customerEmailController.dispose();
    notesController.dispose();

    for (final item
        in selectedServices) {

      final controller =
          item["weightController"];

      if (controller
          is TextEditingController) {

        controller.dispose();

      }
    }

    super.dispose();
  }

  Future<void> saveTransaction() async {
      for(final item in selectedServices){

      if(item["service"] == null){

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content: Text(
              "Pilih semua layanan terlebih dahulu",
            ),

          ),

        );

        return;
      }

      final weight =

      double.tryParse(

        item["weightController"].text,

      ) ?? 0;

      if(weight <= 0){

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content: Text(
              "Berat harus lebih dari 0",
            ),

          ),

        );

        return;
      }
    }
    if (
      customerNameController.text.isEmpty ||
      customerPhoneController.text.isEmpty
    ) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Nama dan nomor telepon wajib diisi",
          ),
        ),
      );

      return;
    }

    if (selectedServices.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Tambahkan minimal 1 layanan",
          ),
        ),
      );

      return;
    }

    setState(() {

      isLoading = true;

    });

    final result =
    await transactionService
        .storeTransaction(

      customerName:
      customerNameController.text,

      customerPhone:
      formatPhone(
        customerPhoneController.text,
      ),

      customerEmail:
      customerEmailController.text,

      paymentMethod:
      paymentMethod,

      notes:
      notesController.text,

      fragrances:
      selectedFragranceIds,

      services:
      selectedServices.map((item){

        final service =
        item["service"]
        as TransactionServiceModel;

        return {

          "service_id":
          service.id,

          "weight":

          double.tryParse(

            item["weightController"]
                .text,

          ) ?? 0,

        };

      }).toList(),

    );

    setState(() {

      isLoading = false;

    });

    if(result["success"]){

      if(context.mounted){

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          const SnackBar(

            content: Text(
              "Transaksi berhasil dibuat",
            ),

          ),

        );

        Navigator.pop(
          context,
          true,
        );

      }

    }

    else{

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        SnackBar(

          content: Text(
            result["message"],
          ),

        ),

      );

    }

  }

  Widget infoField({

  required String label,

  required TextEditingController controller,

  TextInputType keyboardType =
      TextInputType.text,

}) {

  return Column(

    crossAxisAlignment:
        CrossAxisAlignment.start,

    children: [

      Text(

        label,

        style: GoogleFonts.poppins(

          fontWeight:
              FontWeight.w500,
        ),
      ),

      const SizedBox(
        height: 8,
      ),

      TextField(

        controller:
            controller,

        keyboardType:
            keyboardType,

        decoration:
            InputDecoration(

          filled: true,

          fillColor:
          const Color(0xfff8fafc),

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );
}

Widget buildServiceContainer() {
  return AppCard(
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        sectionTitle(
          Icons.local_laundry_service,
          "Layanan",
        ),

        const SizedBox(height: 20),

        ...List.generate(
          selectedServices.length,
          (index) => serviceRow(index),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: addServiceRow,
            icon: const Icon(Icons.add),
            label: const Text(
              "Tambah Layanan",
            ),
          ),
        ),

        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xff4f46e5),
                Color(0xff6366f1),
              ],
            ),
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Column(
            children: [

              Text(
                "TOTAL PEMBAYARAN",
                style:
                    GoogleFonts.poppins(
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                formatRupiah(totalPrice),
                style:
                    GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildFragranceContainer() {
  return AppCard(
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        sectionTitle(
          Icons.spa_outlined,
          "Pewangi",
        ),

        const SizedBox(height: 20),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: fragrances.map((item) {

            return FilterChip(

              label: Text(item.name),

              selected:
                  selectedFragranceIds
                      .contains(item.id),

              onSelected: (selected) {

                setState(() {

                  if (selected) {

                    selectedFragranceIds
                        .add(item.id);

                  } else {

                    selectedFragranceIds
                        .remove(item.id);

                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    ),
  );
}

Widget buildPaymentContainer() {
  return AppCard(
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        sectionTitle(
          Icons.payment,
          "Pembayaran",
        ),

        const SizedBox(height: 20),

        SegmentedButton<String>(
          segments: const [

            ButtonSegment(
              value: "cash",
              label: Text("Tunai"),
              icon: Icon(Icons.payments),
            ),

            ButtonSegment(
              value: "transfer",
              label: Text("Transfer"),
              icon: Icon(Icons.account_balance),
            ),
          ],

          selected: {paymentMethod},

          onSelectionChanged: (value) {

            setState(() {

              paymentMethod =
                  value.first;

            });
          },
        ),

        const SizedBox(height: 24),

        TextField(
          controller: notesController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText:
                "Catatan tambahan...",
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildCustomerContainer() {
  return AppCard(
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        sectionTitle(
          Icons.person_outline,
          "Informasi Pelanggan",
        ),

        const SizedBox(height: 20),

        infoField(
          label: "Nama Pelanggan",
          controller: customerNameController,
        ),

        const SizedBox(height: 16),

        phoneField(
          label: "Nomor Telepon",
          controller: customerPhoneController,
        ),

        if(isSearchingCustomer)

          const Padding(
            padding: EdgeInsets.only(
              top: 8,
            ),
            child: Text(
              "Mencari pelanggan...",
            ),
          ),

        if(customerFound)

        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),

          decoration: BoxDecoration(
            color: Colors.green.shade50,
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
                    Icons.verified_user,
                    color: Colors.green,
                  ),

                  SizedBox(width: 10),

                  Text(
                    "Member ditemukan",
                  ),

                ],
              ),

              const SizedBox(height: 6),

              Text(
                customerNameController.text,
              ),

            ],
          ),
        ),

        if(customerStatus == "non_member")

        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),

          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),

          child: const Row(
            children: [

              Icon(
                Icons.person_add_alt_1,
                color: Colors.orange,
              ),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  "Nomor telepon belum terdaftar. Pelanggan akan dibuat sebagai pelanggan baru.",
                ),
              ),

            ],
          ),
        ),

        const SizedBox(height: 16),

        infoField(
          label: "Email (Opsional)",
          controller: customerEmailController,
        ),
      ],
    ),
  );
}

Widget buildHeader() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xffeef2ff),
      borderRadius:
          BorderRadius.circular(16),
    ),
    child: Text(
      "Invoice : INV-${DateTime.now().millisecondsSinceEpoch}",
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget phoneField({

  required String label,

  required TextEditingController controller,

}) {

  return Column(

    crossAxisAlignment:
        CrossAxisAlignment.start,

    children: [

      Text(

        label,

        style: GoogleFonts.poppins(

          fontWeight:
              FontWeight.w500,
        ),
      ),

      const SizedBox(
        height: 8,
      ),

      Row(

        children: [

          Container(

            height: 58,

            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
            ),

            decoration:
                const BoxDecoration(

              gradient:
                  LinearGradient(

                colors: [

                  Color(0xff0ea5e9),

                  Color(0xff06b6d4),
                ],
              ),

              borderRadius:
                  BorderRadius.only(

                topLeft:
                    Radius.circular(12),

                bottomLeft:
                    Radius.circular(12),
              ),
            ),

            alignment:
                Alignment.center,

            child: Text(

              "62",

              style:
                  GoogleFonts.poppins(

                color:
                    Colors.white,

                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: TextField(

              controller: controller,

              keyboardType: TextInputType.phone,

              onChanged: (value) {

                if(value.length < 8){

                  setState(() {

                    customerFound = false;

                    customerStatus = null;

                    selectedCustomerId = null;

                    customerNameController.clear();

                    customerEmailController.clear();

                  });

                  return;
                }

              if(value.length >= 10){

                _searchDebounce?.cancel();

                _searchDebounce = Timer(
                  const Duration(milliseconds: 500),
                  () {
                    findCustomerByPhone();
                  },
                );
              }

              },

              decoration: const InputDecoration(

                hintText: "81234567890",

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(

                  borderRadius: BorderRadius.only(

                    topRight: Radius.circular(12),

                    bottomRight: Radius.circular(12),

                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

String formatPhone(
  String phone,
) {

  phone = phone.replaceAll(
    RegExp(r'[^0-9]'),
    '',
  );

  if (phone.startsWith('62')) {

    phone =
        phone.substring(2);

  }

  if (phone.startsWith('0')) {

    phone =
        phone.substring(1);

  }

  return '62$phone';
}

Widget serviceRow(int index) {
  final item = selectedServices[index];

  return Container(
    margin: const EdgeInsets.only(
      bottom: 12,
    ),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xfff8fafc),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: const Color(0xffe2e8f0),
      ),
    ),
    child: Column(
      children: [

        DropdownButtonFormField<TransactionServiceModel>(
          value: item["service"],
          decoration: const InputDecoration(
            labelText: "Layanan",
            border: OutlineInputBorder(),
          ),
          items: services.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(e.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              item["service"] = value;
            });

            calculateTotal();
          },
        ),

        const SizedBox(height: 12),

        Row(
          children: [

            Expanded(
              child: TextField(
                controller:
                    item["weightController"],
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                    const InputDecoration(
                  labelText: "Berat (kg)",
                  border:
                      OutlineInputBorder(),
                ),
                onChanged: (_) {
                  calculateTotal();
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Container(
                height: 56,
                alignment:
                    Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Text(
                  formatRupiah(
                    item["subtotal"] ?? 0,
                  ),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            IconButton(
              onPressed: () {

                if (selectedServices.length == 1) {
                  return;
                }

                setState(() {
                  selectedServices.removeAt(index);
                });

                calculateTotal();
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget sectionTitle(
  IconData icon,
  String title,
) {
  return Row(
    children: [
      CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xffeef2ff),
        child: Icon(
          icon,
          color: Color(0xff4f46e5),
          size: 18,
        ),
      ),
      const SizedBox(width: 12),
      Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

Widget summaryItem(
  IconData icon,
  String title,
  String value,
) {
  return Column(
    children: [

      Icon(
        icon,
        size: 30,
        color: const Color(
          0xff4f46e5,
        ),
      ),

      const SizedBox(
        height: 8,
      ),

      Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.grey,
        ),
      ),

      const SizedBox(
        height: 4,
      ),

      Text(
        value,
        style: GoogleFonts.poppins(
          fontWeight:
              FontWeight.bold,
          fontSize: 18,
        ),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(
        0xfff5f7fb,
      ),

      appBar: AppBar(

        backgroundColor:
        Colors.white,

        elevation:0,

        title: Text(

          "Buat Transaksi Baru",

          style:
          GoogleFonts.poppins(

            color: Colors.black,

            fontWeight:
            FontWeight.w600,

          ),

        ),

        iconTheme:
        const IconThemeData(

          color: Colors.black,

        ),

      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            buildHeader(),

            const SizedBox(
              height: 16,
            ),

            buildCustomerContainer(),

            const SizedBox(
              height: 16,
            ),

            buildServiceContainer(),

            const SizedBox(
              height: 16,
            ),

            buildFragranceContainer(),

            const SizedBox(
              height: 16,
            ),

            buildPaymentContainer(),

            const SizedBox(
              height: 100,),
          ],
        ),
      ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed:
                      isLoading
                          ? null
                          : saveTransaction,
                  icon:
                      isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                  label: Text(
                    isLoading
                        ? "Menyimpan..."
                        : "Simpan Transaksi",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xff4f46e5),
                    foregroundColor:
                        Colors.white,
                  ),
                ),
              ),
            ),
          );
        }
      }