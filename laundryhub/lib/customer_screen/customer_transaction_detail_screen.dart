import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'customer_add_edit_address_screen.dart';

class CustomerTransactionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const CustomerTransactionDetailScreen({super.key, required this.transaction});

  @override
  State<CustomerTransactionDetailScreen> createState() =>
      _CustomerTransactionDetailScreenState();
}

class _CustomerTransactionDetailScreenState
    extends State<CustomerTransactionDetailScreen> {
  final ApiService apiService = ApiService();

  late Map<String, dynamic> transaction;
  bool isLoadingDetail = false;
  bool isSubmittingDelivery = false;

  @override
  void initState() {
    super.initState();
    transaction = Map<String, dynamic>.from(widget.transaction);
    loadTransactionDetail();
  }

  dynamic get transactionId =>
      transaction['id'] ?? transaction['transaction_id'];

  Map<String, dynamic> asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  Future<void> loadTransactionDetail() async {
    if (transactionId == null) {
      return;
    }

    setState(() {
      isLoadingDetail = true;
    });

    try {
      final detail = await apiService.getCustomerTransactionDetail(
        transactionId,
      );

      if (!mounted) return;

      setState(() {
        transaction = detail;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiService.getErrorMessage(e))));
    } finally {
      if (!mounted) return;

      setState(() {
        isLoadingDetail = false;
      });
    }
  }

  String formatCurrency(dynamic amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(double.tryParse(amount.toString()) ?? 0);
  }

  String formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) {
      return '-';
    }

    try {
      final parsed = DateTime.parse(date.toString());
      return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(parsed);
    } catch (e) {
      return date.toString();
    }
  }

  String statusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'washing':
        return 'Sedang Dicuci';
      case 'drying':
        return 'Pengeringan';
      case 'ironing':
        return 'Disetrika';
      case 'ready':
        return 'Siap Diantar/Diambil';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status.isEmpty ? '-' : status;
    }
  }

  String deliveryStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Konfirmasi Owner';
      case 'accepted':
      case 'confirmed':
        return 'Dikonfirmasi Owner';
      case 'on_the_way':
        return 'Sedang Diantar';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status.isEmpty ? '-' : status;
    }
  }

  String paymentText(String status) {
    switch (status) {
      case 'unpaid':
        return 'Belum Dibayar';
      case 'pending':
        return 'Menunggu Verifikasi';
      case 'paid':
        return 'Lunas';
      default:
        return status.isEmpty ? '-' : status;
    }
  }

  String fragranceText() {
    final List<String> names = [];

    void addFragrance(dynamic item) {
      if (item == null) return;

      if (item is Map) {
        final dynamic nestedFragrance = item['fragrance'];

        final String? name =
            item['fragrance_name']?.toString() ??
            item['name']?.toString() ??
            item['nama']?.toString() ??
            item['fragranceName']?.toString() ??
            (nestedFragrance is Map
                ? nestedFragrance['name']?.toString()
                : null);

        if (name != null && name.trim().isNotEmpty) {
          names.add(name.trim());
        }
      } else {
        final value = item.toString();

        if (value.trim().isNotEmpty) {
          names.add(value.trim());
        }
      }
    }

    dynamic normalize(dynamic value) {
      if (value is String) {
        final trimmed = value.trim();

        if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
          try {
            return jsonDecode(trimmed);
          } catch (_) {
            return value;
          }
        }
      }

      return value;
    }

    final dynamic fragrances = normalize(transaction['fragrances']);

    if (fragrances is List) {
      for (final item in fragrances) {
        addFragrance(item);
      }
    }

    final dynamic transactionFragrances = normalize(
      transaction['transaction_fragrances'],
    );

    if (transactionFragrances is List) {
      for (final item in transactionFragrances) {
        addFragrance(item);
      }
    }

    final pickup = transaction['pickup'] is Map
        ? transaction['pickup'] as Map
        : {};

    final dynamic selectedFragrances = normalize(
      pickup['selected_fragrances'] ?? transaction['selected_fragrances'],
    );

    if (selectedFragrances is List) {
      for (final item in selectedFragrances) {
        addFragrance(item);
      }
    }

    final uniqueNames = names.toSet().toList();

    if (uniqueNames.isEmpty) {
      return '-';
    }

    return uniqueNames.join(', ');
  }

  Color statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      case 'washing':
      case 'drying':
      case 'ironing':
        return Colors.deepPurple;
      case 'ready':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  dynamic firstValue(List<String> keys) {
    for (final key in keys) {
      if (transaction[key] != null) {
        return transaction[key];
      }
    }

    return null;
  }

  List<dynamic> getDetails() {
    final possibleKeys = [
      'details',
      'transaction_details',
      'items',
      'services',
    ];

    for (final key in possibleKeys) {
      final value = transaction[key];

      if (value is List) {
        return value;
      }
    }

    return [];
  }

  String getServiceName(dynamic item) {
    if (item is! Map) {
      return '-';
    }

    if (item['service'] is Map) {
      return item['service']['name']?.toString() ?? '-';
    }

    return item['service_name']?.toString() ??
        item['name']?.toString() ??
        item['laundry_service_name']?.toString() ??
        '-';
  }

  dynamic getServiceWeight(dynamic item) {
    if (item is! Map) {
      return '-';
    }

    return item['weight'] ??
        item['total_weight'] ??
        item['quantity'] ??
        item['qty'] ??
        '-';
  }

  dynamic getServicePrice(dynamic item) {
    if (item is! Map) {
      return 0;
    }
    final computedSubtotal = item['computed_subtotal'];
    if (computedSubtotal != null) {
      return computedSubtotal;
    }

    final double weight =
        double.tryParse(getServiceWeight(item).toString()) ?? 0;

    double pricePerKg = 0;

    if (item['service'] is Map) {
      pricePerKg =
          double.tryParse(item['service']['price_per_kg']?.toString() ?? '') ??
          0;
    }

    if (pricePerKg == 0) {
      pricePerKg = double.tryParse(item['price_per_kg']?.toString() ?? '') ?? 0;
    }

    if (pricePerKg > 0 && weight > 0) {
      return pricePerKg * weight;
    }

    return item['subtotal'] ??
        item['price'] ??
        item['total_price'] ??
        item['amount'] ??
        0;
  }

  Widget statusBadge(String status, {bool isDelivery = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: statusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: statusColor(status).withOpacity(0.22)),
      ),
      child: Text(
        isDelivery ? deliveryStatusText(status) : statusText(status),
        style: TextStyle(
          color: statusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
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
              Icon(icon, size: 20, color: const Color(0xff2F80ED)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget progressStatus(String status) {
    final steps = [
      {'key': 'pending', 'label': 'Menunggu'},
      {'key': 'washing', 'label': 'Diproses'},
      {'key': 'ready', 'label': 'Siap'},
      {'key': 'completed', 'label': 'Selesai'},
    ];

    int activeIndex = 0;

    if (status == 'confirmed') {
      activeIndex = 0;
    } else if (['washing', 'drying', 'ironing'].contains(status)) {
      activeIndex = 1;
    } else if (status == 'ready') {
      activeIndex = 2;
    } else if (status == 'completed') {
      activeIndex = 3;
    }

    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (index) {
            final bool active = index <= activeIndex;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xff2F80ED)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  if (index != steps.length - 1) const SizedBox(width: 4),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.map((step) {
            return Text(
              step['label']!,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 11,
                fontWeight: step['key'] == status
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool hasDeliveryRequest() {
    final delivery = transaction['delivery'];
    if (delivery == null) return false;
    if (delivery is Map && delivery.isEmpty) return false;
    return true;
  }

  Widget serviceDetailsTable() {
    final details = getDetails();

    if (details.isEmpty) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Detail layanan belum tersedia dari API.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: const [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text(
                    'Layanan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Berat',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Text(
                    'Harga',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ...details.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    getServiceName(item),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${getServiceWeight(item)} kg',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    formatCurrency(getServicePrice(item)),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String addressTitle(dynamic item) {
    final address = asMap(item);

    return address['label']?.toString() ??
        address['name']?.toString() ??
        address['address_name']?.toString() ??
        'Alamat';
  }

  String addressDescription(dynamic item) {
    final address = asMap(item);

    return address['address']?.toString() ??
        address['full_address']?.toString() ??
        address['detail']?.toString() ??
        '-';
  }

  String deliveryScheduleText(dynamic date, dynamic time) {
    if (date == null || date.toString().isEmpty) {
      return '-';
    }

    try {
      final parsedDate = DateTime.parse(date.toString());

      const monthNames = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];

      final day = parsedDate.day.toString().padLeft(2, '0');
      final month = monthNames[parsedDate.month];
      final year = parsedDate.year.toString();

      String timeText = '';

      if (time != null &&
          time.toString().isNotEmpty &&
          time.toString() != '-') {
        timeText = time.toString();

        if (timeText.contains('T')) {
          final parsedTime = DateTime.parse(timeText);
          timeText =
              '${parsedTime.hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')}';
        } else if (timeText.length >= 5) {
          timeText = timeText.substring(0, 5);
        }
      } else {
        timeText =
            '${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
      }

      return '$day $month $year, $timeText';
    } catch (_) {
      return date.toString();
    }
  }

  String formatDateManual(DateTime date) {
    const monthNames = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final day = date.day.toString().padLeft(2, '0');
    final month = monthNames[date.month];
    final year = date.year.toString();

    return '$day $month $year';
  }

  Future<bool> openAddAddressScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CustomerAddEditAddressScreen()),
    );

    if (!mounted) return false;

    return result == true;
  }

  Future<void> showDeliveryRequestSheet() async {
    if (transactionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID transaksi tidak ditemukan')),
      );
      return;
    }

    List<dynamic> addresses = [];

    try {
      addresses = await apiService.getTransactionDeliveryAddresses(
        transactionId,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiService.getErrorMessage(e))));
      return;
    }

    if (!mounted) return;

    dynamic selectedAddressId;

    if (addresses.isNotEmpty) {
      for (final item in addresses) {
        final address = asMap(item);

        if (address['is_default'] == true || address['is_default'] == 1) {
          selectedAddressId = address['id'];
          break;
        }
      }

      selectedAddressId ??= asMap(addresses.first)['id'];
    }

    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    final notesController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setSheetState) {
            Future<void> addAddressFromSheet() async {
              final added = await openAddAddressScreen();

              if (!mounted) return;

              if (added == true) {
                try {
                  final newAddresses = await apiService
                      .getTransactionDeliveryAddresses(transactionId);

                  if (!mounted) return;

                  dynamic newSelectedAddressId;

                  if (newAddresses.isNotEmpty) {
                    for (final item in newAddresses) {
                      final address = asMap(item);

                      if (address['is_default'] == true ||
                          address['is_default'] == 1) {
                        newSelectedAddressId = address['id'];
                        break;
                      }
                    }

                    newSelectedAddressId ??= asMap(newAddresses.first)['id'];
                  }

                  setSheetState(() {
                    addresses = newAddresses;
                    selectedAddressId = newSelectedAddressId;
                  });
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(apiService.getErrorMessage(e))),
                  );
                }
              }
            }

            final dateText = selectedDate == null
                ? 'Pilih Tanggal Pengantaran'
                : formatDateManual(selectedDate!);

            final timeText = selectedTime == null
                ? 'Pilih jam pengantaran'
                : selectedTime!.format(modalContext);

            Future<void> submitDelivery() async {
              if (selectedAddressId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pilih alamat pengantaran dulu'),
                  ),
                );
                return;
              }

              if (selectedDate == null || selectedTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pilih tanggal dan jam pengantaran dulu'),
                  ),
                );
                return;
              }

              setSheetState(() {
                isSubmittingDelivery = true;
              });

              try {
                final deliveryDate = DateFormat(
                  'yyyy-MM-dd',
                ).format(selectedDate!);

                final deliveryTime =
                    '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';

                await apiService.storeTransactionDelivery(
                  transactionId: transactionId,
                  addressId: selectedAddressId,
                  deliveryDate: deliveryDate,
                  deliveryTime: deliveryTime,
                  notes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                );

                if (!mounted) return;

                FocusScope.of(modalContext).unfocus();

                if (Navigator.of(sheetContext).canPop()) {
                  Navigator.of(sheetContext).pop();
                }

                if (!mounted) return;

                setState(() {
                  isSubmittingDelivery = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request pengantaran berhasil dikirim'),
                  ),
                );

                await loadTransactionDetail();
              } catch (e) {
                if (!mounted) return;

                setSheetState(() {
                  isSubmittingDelivery = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(apiService.getErrorMessage(e))),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),

                      const Text(
                        'Request Pengantaran',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Pilih alamat, tanggal, dan jam pengantaran laundry.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Alamat Pengantaran',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: isSubmittingDelivery
                                ? null
                                : addAddressFromSheet,
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 16,
                            ),
                            label: const Text('Tambah'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xff2F80ED),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      if (addresses.isEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.orange.shade100),
                          ),
                          child: Text(
                            'Belum ada alamat. Klik Tambah untuk menambahkan alamat pengantaran.',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        )
                      else
                        ...addresses.map((item) {
                          final address = asMap(item);
                          final id = address['id'];
                          final selected = selectedAddressId == id;

                          return InkWell(
                            onTap: isSubmittingDelivery
                                ? null
                                : () {
                                    setSheetState(() {
                                      selectedAddressId = id;
                                    });
                                  },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.blue.shade50
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xff2F80ED)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    selected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: selected
                                        ? const Color(0xff2F80ED)
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          addressTitle(address),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          addressDescription(address),
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                          ),
                          label: Text(dateText),
                          onPressed: isSubmittingDelivery
                              ? null
                              : () async {
                                  final picked = await showDatePicker(
                                    context: modalContext,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 30),
                                    ),
                                  );

                                  if (picked != null) {
                                    setSheetState(() {
                                      selectedDate = picked;
                                    });
                                  }
                                },
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time, size: 18),
                          label: Text(timeText),
                          onPressed: isSubmittingDelivery
                              ? null
                              : () async {
                                  final picked = await showTimePicker(
                                    context: modalContext,
                                    initialTime: TimeOfDay.now(),
                                  );

                                  if (picked != null) {
                                    setSheetState(() {
                                      selectedTime = picked;
                                    });
                                  }
                                },
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Catatan opsional',
                          hintText: 'Contoh: hubungi dulu sebelum diantar',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff2F80ED),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: isSubmittingDelivery
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.local_shipping_outlined),
                          label: Text(
                            isSubmittingDelivery
                                ? 'Mengirim...'
                                : 'Kirim Request Pengantaran',
                          ),
                          onPressed: isSubmittingDelivery
                              ? null
                              : submitDelivery,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget deliveryActionSection(String status) {
    final delivery = asMap(transaction['delivery']);
    final bool hasDelivery = hasDeliveryRequest();

    if (hasDelivery) {
      final deliveryStatus = delivery['status']?.toString() ?? '-';

      final deliveryAddress =
          delivery['pickup_address']?.toString() ??
          delivery['address']?.toString() ??
          delivery['full_address']?.toString() ??
          '-';

      final deliveryDate =
          delivery['pickup_date'] ??
          delivery['delivery_date'] ??
          delivery['date'];

      final deliveryTime =
          delivery['pickup_time'] ??
          delivery['delivery_time'] ??
          delivery['time'];

      final deliveryNotes = delivery['notes']?.toString() ?? '-';

      return sectionCard(
        title: 'Request Pengantaran',
        icon: Icons.local_shipping_outlined,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: statusBadge(deliveryStatus, isDelivery: true),
          ),

          const SizedBox(height: 14),

          infoRow('Jadwal', deliveryScheduleText(deliveryDate, deliveryTime)),
          infoRow('Alamat', deliveryAddress),
          infoRow('Catatan', deliveryNotes.isEmpty ? '-' : deliveryNotes),
        ],
      );
    }

    if (status != 'ready') {
      return const SizedBox.shrink();
    }

    return sectionCard(
      title: 'Request Pengantaran',
      icon: Icons.local_shipping_outlined,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.teal.shade100),
          ),
          child: Text(
            'Laundry sudah siap. Anda dapat meminta pengantaran ke alamat yang tersimpan.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2F80ED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.local_shipping_outlined),
            label: const Text('Request Pengantaran'),
            onPressed: showDeliveryRequestSheet,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String status = transaction['status']?.toString() ?? '-';
    final String invoice = transaction['invoice_number']?.toString() ?? '-';

    final laundry = transaction['laundry'] is Map
        ? transaction['laundry'] as Map
        : {};

    final String laundryName =
        laundry['name']?.toString() ??
        transaction['laundry_name']?.toString() ??
        '-';

    final String laundryPhone =
        laundry['phone']?.toString() ??
        transaction['laundry_phone']?.toString() ??
        '-';

    final List<dynamic> transactionDetails = getDetails();

    final double calculatedTotalPrice = transactionDetails.fold(0, (sum, item) {
      final value = double.tryParse(getServicePrice(item).toString()) ?? 0;

      return sum + value;
    });

    final dynamic totalPrice = calculatedTotalPrice > 0
        ? calculatedTotalPrice
        : firstValue(['final_price', 'total_price', 'total', 'amount']);

    final dynamic totalWeight = firstValue([
      'total_weight',
      'weight',
      'estimated_weight',
    ]);

    final String paymentStatus =
        transaction['payment_status']?.toString() ?? 'unpaid';

    final String paymentMethod =
        transaction['payment_method']?.toString() ?? '-';

    final String trackingCode =
        transaction['tracking_code']?.toString() ??
        transaction['tracking']?.toString() ??
        '-';

    final String notes = transaction['notes']?.toString() ?? '-';

    final String fragrance = fragranceText();

    return Scaffold(
      backgroundColor: const Color(0xffF8F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Detail Transaksi',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadTransactionDetail,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
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
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xffEEE7FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        size: 34,
                        color: Color(0xff6F3CC3),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      invoice,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      laundryName,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    statusBadge(status),
                    const SizedBox(height: 18),
                    progressStatus(status),
                  ],
                ),
              ),

              sectionCard(
                title: 'Detail Pesanan',
                icon: Icons.local_laundry_service_outlined,
                children: [
                  serviceDetailsTable(),
                  const Divider(height: 28),
                  infoRow('Parfum', fragrance),
                  infoRow('Total Berat', '${totalWeight ?? 0} Kg'),
                  infoRow('Total Harga', formatCurrency(totalPrice)),
                ],
              ),

              sectionCard(
                title: 'Informasi Pembayaran',
                icon: Icons.payments_outlined,
                children: [
                  infoRow('Status Pembayaran', paymentText(paymentStatus)),
                  infoRow('Metode Pembayaran', paymentMethod),
                ],
              ),

              sectionCard(
                title: 'Informasi Laundry',
                icon: Icons.store_outlined,
                children: [
                  infoRow('Laundry', laundryName),
                  infoRow('Telepon Laundry', laundryPhone),
                ],
              ),

              deliveryActionSection(status),

              sectionCard(
                title: 'Tracking',
                icon: Icons.track_changes_outlined,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kode Tracking',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                trackingCode,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),

                            IconButton(
                              tooltip: 'Salin kode tracking',
                              icon: const Icon(
                                Icons.copy_rounded,
                                size: 20,
                                color: Color(0xff2F80ED),
                              ),
                              onPressed: trackingCode == '-'
                                  ? null
                                  : () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: trackingCode),
                                      );

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Kode tracking berhasil disalin',
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Gunakan kode ini pada menu Tracking untuk melihat status laundry.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              sectionCard(
                title: 'Catatan',
                icon: Icons.notes_outlined,
                children: [
                  Text(
                    notes == '' ? '-' : notes,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
