import 'package:flutter/material.dart';
import '../../service_customer/customer_order_service.dart';

class CustomerCreateOrderScreen extends StatefulWidget {
  const CustomerCreateOrderScreen({super.key});

  @override
  State<CustomerCreateOrderScreen> createState() =>
      _CustomerCreateOrderScreenState();
}

class _CustomerCreateOrderScreenState extends State<CustomerCreateOrderScreen> {
  final CustomerOrderService service = CustomerOrderService();

  List services = [];

  bool loading = true;
  String? selectedService;
  int? selectedServiceId;
  final TextEditingController weightController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    final result = await service.getServices();

    if (result["success"]) {
      setState(() {
        services = result["data"];
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: const Color(0xffF8F8FC),

      appBar: AppBar(title: const Text("Buat Pesanan"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Layanan Laundry",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Pilih Layanan",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              value: selectedService,

              items: services.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item["name"],

                  child: Text("${item["name"]} - ${item["formatted_price"]}"),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedService = value;

                  final service = services.firstWhere(
                    (e) => e["name"] == value,
                  );

                  selectedServiceId = service["id"];
                  print("SERVICE ID: $selectedServiceId");
                  print("SERVICE NAME: $selectedService");
                });
              },
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Berat Laundry (Kg)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Catatan",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: () async {
                  print("TOMBOL BUAT PESANAN DIKLIK");
                  if (selectedServiceId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Pilih layanan terlebih dahulu"),
                      ),
                    );

                    return;
                  }

                  if (weightController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Masukkan berat laundry")),
                    );

                    return;
                  }

                  final result = await service.createOrder(
                    serviceId: selectedServiceId!,

                    weight: double.parse(weightController.text),

                    notes: notesController.text,
                  );

                  if (result["success"]) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pesanan berhasil dibuat")),
                    );

                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(result["message"])));
                  }
                },

                icon: const Icon(Icons.save),

                label: const Text("Buat Pesanan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
