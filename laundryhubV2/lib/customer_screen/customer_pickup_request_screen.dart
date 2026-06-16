import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'customer_add_edit_address_screen.dart';

class CustomerPickupRequestScreen extends StatefulWidget {
  const CustomerPickupRequestScreen({super.key});

  @override
  State<CustomerPickupRequestScreen> createState() =>
      _CustomerPickupRequestScreenState();
}

class _CustomerPickupRequestScreenState
    extends State<CustomerPickupRequestScreen> {
  static const String baseUrl =
    'https://laundryhub.my.id/api';

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  final TextEditingController manualAddressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool loading = true;
  bool submitting = false;

  List<dynamic> laundries = [];
  List<dynamic> services = [];
  List<dynamic> fragrances = [];
  List<dynamic> customerAddresses = [];

  int? selectedCustomerAddressId;
  bool loadingAddresses = false;

  int? selectedLaundryId;
  DateTime? pickupDate;
  String paymentMethod = 'cash';

  final Map<int, double> selectedServiceWeights = {};
  final Set<int> selectedFragranceIds = {};

  double totalWeight = 0;
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();

    initializeDateFormatting('id_ID', null).then((_) {
      loadCreateData();
      loadCustomerAddresses();
    });
  }

  @override
  void dispose() {
    manualAddressController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Map<String, dynamic>? get selectedLaundry {
    if (selectedLaundryId == null) return null;

    try {
      return Map<String, dynamic>.from(
        laundries.firstWhere(
          (item) => int.tryParse(item['id'].toString()) == selectedLaundryId,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  List<dynamic> extractList(dynamic data, List<String> keys) {
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      for (final key in keys) {
        if (data[key] is List) {
          return List<dynamic>.from(data[key]);
        }

        if (data[key] is Map<String, dynamic> && data[key]['data'] is List) {
          return List<dynamic>.from(data[key]['data']);
        }
      }
    }

    return [];
  }

  Map<String, dynamic> asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  int getAddressId(dynamic address) {
    final item = asMap(address);
    return int.tryParse(item['id'].toString()) ?? 0;
  }

  bool isDefaultAddress(dynamic address) {
    final item = asMap(address);
    return item['is_default'] == true ||
        item['is_default'] == 1 ||
        item['is_default'].toString() == '1';
  }

  String getAddressLabel(dynamic address) {
    final item = asMap(address);

    return item['label']?.toString() ?? item['name']?.toString() ?? 'Alamat';
  }

  String getAddressText(dynamic address) {
    final item = asMap(address);

    final addressText =
        item['address']?.toString() ??
        item['full_address']?.toString() ??
        item['detail']?.toString() ??
        '';

    final city = item['city']?.toString() ?? '';
    final postalCode = item['postal_code']?.toString() ?? '';

    final parts = [
      addressText,
      city,
      postalCode,
    ].where((item) => item.trim().isNotEmpty).toList();

    return parts.join(', ');
  }

  void selectCustomerAddress(dynamic address) {
    final id = getAddressId(address);
    final text = getAddressText(address);

    setState(() {
      selectedCustomerAddressId = id;
      manualAddressController.text = text;
    });
  }

  Future<void> loadCustomerAddresses() async {
    setState(() {
      loadingAddresses = true;
    });

    try {
      final token = await getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/customer/addresses'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonBody = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final loadedAddresses = extractList(jsonBody, ['data', 'addresses']);

        dynamic selectedAddress;

        if (loadedAddresses.isNotEmpty) {
          selectedAddress = loadedAddresses.firstWhere(
            (item) => isDefaultAddress(item),
            orElse: () => loadedAddresses.first,
          );
        }

        setState(() {
          customerAddresses = loadedAddresses;

          if (selectedAddress != null) {
            selectedCustomerAddressId = getAddressId(selectedAddress);
            manualAddressController.text = getAddressText(selectedAddress);
          }

          loadingAddresses = false;
        });
      } else {
        setState(() {
          loadingAddresses = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingAddresses = false;
      });
    }
  }

  Future<void> openAddAddressScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CustomerAddEditAddressScreen()),
    );

    if (!mounted) return;

    if (result == true) {
      await loadCustomerAddresses();
    }
  }

  Future<void> loadCreateData() async {
    setState(() {
      loading = true;
    });

    try {
      final token = await getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/customer/pickups/create-data'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final jsonBody = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && jsonBody['success'] == true) {
        final data = jsonBody['data'];

        final loadedLaundries = extractList(data, [
          'laundries',
          'laundry',
          'nearby_laundries',
        ]);

        setState(() {
          laundries = loadedLaundries;

          if (laundries.isNotEmpty) {
            selectedLaundryId = int.tryParse(laundries.first['id'].toString());
            loadServicesAndFragrancesFromSelectedLaundry();
          }

          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });

        showMessage(jsonBody['message'] ?? 'Gagal mengambil data pickup');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage('Terjadi kesalahan saat mengambil data pickup');
    }
  }

  void loadServicesAndFragrancesFromSelectedLaundry() {
    final laundry = selectedLaundry;

    if (laundry == null) {
      services = [];
      fragrances = [];
      return;
    }

    services = [];

    for (final key in ['services', 'laundry_services', 'active_services']) {
      if (laundry[key] is List) {
        services = List<dynamic>.from(laundry[key]);
        break;
      }
    }

    fragrances = [];

    for (final key in ['fragrances', 'parfums', 'perfumes']) {
      if (laundry[key] is List) {
        fragrances = List<dynamic>.from(laundry[key]);
        break;
      }
    }
  }

  double parseDouble(dynamic value) {
    return double.tryParse(value.toString()) ?? 0;
  }

  int getServiceId(dynamic service) {
    if (service is! Map) return 0;
    return int.tryParse(service['id'].toString()) ?? 0;
  }

  String getServiceName(dynamic service) {
    if (service is! Map) return '-';

    return service['name']?.toString() ??
        service['service_name']?.toString() ??
        '-';
  }

  double getServicePrice(dynamic service) {
    if (service is! Map) return 0;

    return parseDouble(
      service['price_per_kg'] ??
          service['price'] ??
          service['amount'] ??
          service['tariff'] ??
          0,
    );
  }

  String formatCurrency(dynamic amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(double.tryParse(amount.toString()) ?? 0);
  }

  void calculateTotal() {
    double weightTotal = 0;
    double priceTotal = 0;

    for (final service in services) {
      final serviceId = getServiceId(service);

      if (selectedServiceWeights.containsKey(serviceId)) {
        final weight = selectedServiceWeights[serviceId] ?? 0;
        final price = getServicePrice(service);

        weightTotal += weight;
        priceTotal += price * weight;
      }
    }

    setState(() {
      totalWeight = weightTotal;
      totalPrice = priceTotal;
    });
  }

  Future<void> pickDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (time == null) return;

    setState(() {
      pickupDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String formattedPickupDate() {
    if (pickupDate == null) {
      return 'Pilih Tanggal Pickup';
    }

    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(pickupDate!);
  }

  Future<void> submitPickup() async {
    final manualAddress = manualAddressController.text.trim();

    if (selectedLaundryId == null) {
      showMessage('Pilih laundry terlebih dahulu');
      return;
    }

    if (selectedServiceWeights.isEmpty) {
      showMessage('Pilih minimal 1 layanan');
      return;
    }

    if (totalWeight <= 0 || totalPrice <= 0) {
      showMessage('Berat dan total harga belum valid');
      return;
    }

    if (manualAddress.isEmpty) {
      showMessage('Isi alamat penjemputan terlebih dahulu');
      return;
    }

    if (pickupDate == null) {
      showMessage('Pilih tanggal pickup terlebih dahulu');
      return;
    }

    setState(() {
      submitting = true;
    });

    try {
      final token = await getToken();

      final Map<String, dynamic> serviceWeightsPayload = {};

      selectedServiceWeights.forEach((serviceId, weight) {
        serviceWeightsPayload[serviceId.toString()] = weight;
      });

      final body = {
        'laundry_id': selectedLaundryId,
        'address_id': selectedCustomerAddressId,
        'pickup_address': manualAddress,
        'address': manualAddress,
        'pickup_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(pickupDate!),
        'notes': notesController.text.trim(),
        'payment_method': paymentMethod,
        'service_ids': selectedServiceWeights.keys.toList(),
        'service_weights': serviceWeightsPayload,
        'fragrance_ids': selectedFragranceIds.toList(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/customer/pickups'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final jsonBody = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          jsonBody['success'] == true) {
        showMessage('Request pickup berhasil dibuat');
        Navigator.pop(context, true);
      } else {
        showMessage(jsonBody['message'] ?? 'Gagal membuat request pickup');
      }
    } catch (e) {
      if (!mounted) return;

      showMessage('Terjadi kesalahan saat submit pickup');
    } finally {
      if (mounted) {
        setState(() {
          submitting = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget sectionCard({
    required int number,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: const Color(0xffE7F0FF),
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: Color(0xff2F80ED),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget laundryDropdown() {
    return DropdownButtonFormField<int>(
      value: selectedLaundryId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Pilih Laundry',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: laundries.map<DropdownMenuItem<int>>((item) {
        final laundry = Map<String, dynamic>.from(item);

        return DropdownMenuItem<int>(
          value: int.tryParse(laundry['id'].toString()),
          child: Text(
            laundry['name']?.toString() ?? '-',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedLaundryId = value;
          selectedServiceWeights.clear();
          selectedFragranceIds.clear();
          loadServicesAndFragrancesFromSelectedLaundry();
          totalWeight = 0;
          totalPrice = 0;
        });
      },
    );
  }

  Widget serviceList() {
    if (services.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'Layanan belum tersedia untuk laundry ini.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: services.map((service) {
        final serviceId = getServiceId(service);
        final serviceName = getServiceName(service);
        final servicePrice = getServicePrice(service);
        final isSelected = selectedServiceWeights.containsKey(serviceId);
        final currentWeight = selectedServiceWeights[serviceId] ?? 1;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.blue.shade200 : Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selectedServiceWeights[serviceId] = 1;
                        } else {
                          selectedServiceWeights.remove(serviceId);
                        }
                      });

                      calculateTotal();
                    },
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatCurrency(servicePrice)} / kg',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Text(
                      formatCurrency(servicePrice * currentWeight),
                      style: const TextStyle(
                        color: Color(0xff2F80ED),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: currentWeight.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Berat $serviceName (kg)',
                    hintText: 'Contoh: 2',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onChanged: (value) {
                    final weight = double.tryParse(value) ?? 0;

                    selectedServiceWeights[serviceId] = weight;
                    calculateTotal();
                  },
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget fragranceList() {
    if (fragrances.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'Parfum tidak tersedia atau opsional.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: fragrances.map((item) {
        final fragrance = Map<String, dynamic>.from(item);
        final id = int.tryParse(fragrance['id'].toString()) ?? 0;
        final name = fragrance['name']?.toString() ?? '-';
        final selected = selectedFragranceIds.contains(id);

        return CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: selected,
          title: Text(name),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                selectedFragranceIds.add(id);
              } else {
                selectedFragranceIds.remove(id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget addressOptionCard(dynamic address) {
    final id = getAddressId(address);
    final label = getAddressLabel(address);
    final fullAddress = getAddressText(address);
    final selected = selectedCustomerAddressId == id;
    final isDefault = isDefaultAddress(address);

    return InkWell(
      onTap: () => selectCustomerAddress(address),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? const Color(0xff2F80ED) : Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Utama',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    fullAddress.isEmpty ? '-' : fullAddress,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget addNewAddressButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: openAddAddressScreen,
        icon: const Icon(Icons.add_circle_outline, size: 18),
        label: const Text('Tambah Alamat Baru'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xff2F80ED),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget manualAddressField() {
    if (loadingAddresses) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text('Memuat alamat saya...'),
      );
    }

    if (customerAddresses.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Text(
              'Belum ada alamat dari menu Alamat Saya. Isi manual dulu atau tambahkan alamat di menu Alamat Saya.',
              style: TextStyle(color: Colors.orange.shade800, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          addNewAddressButton(),
          const SizedBox(height: 12),
          TextField(
            controller: manualAddressController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tulis alamat lengkap penjemputan...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Pilih alamat dari Alamat Saya',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ),
            TextButton.icon(
              onPressed: openAddAddressScreen,
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: const Text('Tambah'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff2F80ED),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...customerAddresses.map(addressOptionCard).toList(),
      ],
    );
  }

  Widget paymentDropdown() {
    return DropdownButtonFormField<String>(
      value: paymentMethod,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Metode Pembayaran',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: const [
        DropdownMenuItem(value: 'cash', child: Text('Bayar di Tempat / Cash')),
        DropdownMenuItem(value: 'transfer', child: Text('Transfer Bank')),
      ],
      onChanged: (value) {
        setState(() {
          paymentMethod = value ?? 'cash';
        });
      },
    );
  }

  Widget summaryBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffEEF5FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Berat',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              Text(
                '${totalWeight.toStringAsFixed(2)} Kg',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Harga',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              Text(
                formatCurrency(totalPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2F80ED),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: submitting ? null : submitPickup,
        icon: submitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.send),
        label: Text(
          submitting ? 'Memproses...' : 'Request Pickup',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff2F80ED),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8FC),
      appBar: AppBar(
        title: const Text(
          'Request Pickup',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await loadCreateData();
                await loadCustomerAddresses();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff2F80ED), Color(0xff12B5CB)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request Pickup Laundry',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 21,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Pilih laundry, layanan, dan jadwalkan penjemputan.',
                            style: TextStyle(color: Colors.white, height: 1.4),
                          ),
                        ],
                      ),
                    ),

                    sectionCard(
                      number: 1,
                      title: 'Pilih Laundry',
                      child: laundryDropdown(),
                    ),

                    sectionCard(
                      number: 2,
                      title: 'Pilih Layanan & Berat',
                      child: serviceList(),
                    ),

                    sectionCard(
                      number: 3,
                      title: 'Pilih Parfum',
                      child: fragranceList(),
                    ),

                    sectionCard(
                      number: 4,
                      title: 'Alamat Penjemputan',
                      child: manualAddressField(),
                    ),

                    sectionCard(
                      number: 5,
                      title: 'Jadwal Penjemputan',
                      child: OutlinedButton.icon(
                        onPressed: pickDate,
                        icon: const Icon(Icons.calendar_month),
                        label: Text(formattedPickupDate()),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    sectionCard(
                      number: 6,
                      title: 'Catatan',
                      child: TextField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Catatan tambahan...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    sectionCard(
                      number: 7,
                      title: 'Metode Pembayaran',
                      child: paymentDropdown(),
                    ),

                    summaryBox(),
                    submitButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
