import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../services/api_service.dart';

class CustomerAddEditAddressScreen extends StatefulWidget {
  final Map<String, dynamic>? address;

  const CustomerAddEditAddressScreen({super.key, this.address});

  @override
  State<CustomerAddEditAddressScreen> createState() =>
      _CustomerAddEditAddressScreenState();
}

class _CustomerAddEditAddressScreenState
    extends State<CustomerAddEditAddressScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController labelController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool isEdit = false;
  bool isDefault = false;
  bool isSaving = false;

  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState() {
    super.initState();

    if (widget.address != null) {
      isEdit = true;

      labelController.text = widget.address!['label']?.toString() ?? '';
      addressController.text = widget.address!['address']?.toString() ?? '';
      cityController.text = widget.address!['city']?.toString() ?? '';
      postalCodeController.text =
          widget.address!['postal_code']?.toString() ?? '';
      notesController.text = widget.address!['notes']?.toString() ?? '';

      isDefault =
          widget.address!['is_default'] == true ||
          widget.address!['is_default'] == 1 ||
          widget.address!['is_default'].toString() == '1';

      latitude =
          double.tryParse(widget.address!['latitude']?.toString() ?? '') ?? 0.0;

      longitude =
          double.tryParse(widget.address!['longitude']?.toString() ?? '') ??
          0.0;
    }
  }

  Future<String?> getToken() async {
    return storage.read(key: 'token');
  }

  Future<void> saveAddress() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final token = await getToken();

    if (token == null) {
      showMessage('Token tidak ditemukan. Silakan login ulang.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    final Map<String, dynamic> body = {
      'label': labelController.text.trim(),
      'address': addressController.text.trim(),
      'city': cityController.text.trim(),
      'postal_code': postalCodeController.text.trim(),
      'notes': notesController.text.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };

    try {
      final Uri url = isEdit
          ? Uri.parse(
              '${ApiService.baseUrl}/customer/addresses/${widget.address!['id']}',
            )
          : Uri.parse('${ApiService.baseUrl}/customer/addresses');

      final Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response response = isEdit
          ? await http.put(url, headers: headers, body: jsonEncode(body))
          : await http.post(url, headers: headers, body: jsonEncode(body));

      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        showMessage(
          isEdit ? 'Alamat berhasil diperbarui' : 'Alamat berhasil ditambahkan',
        );

        Navigator.pop(context, true);
      } else {
        showMessage('Gagal menyimpan alamat. Periksa kembali data alamat.');
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      showMessage('Terjadi kesalahan saat menyimpan alamat.');
    }
  }

  void showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xff2F80ED), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }

    return null;
  }

  Widget formHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff2F80ED), Color(0xff18B7C9)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.location_on, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Edit Alamat' : 'Tambah Alamat',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Alamat ini dipakai untuk penjemputan laundry.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    labelController.dispose();
    addressController.dispose();
    cityController.dispose();
    postalCodeController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          isEdit ? 'Edit Alamat' : 'Tambah Alamat',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              formHeader(),
              const SizedBox(height: 18),

              TextFormField(
                controller: labelController,
                textInputAction: TextInputAction.next,
                decoration: inputDecoration(
                  label: 'Label Alamat',
                  icon: Icons.bookmark,
                  hint: 'Contoh: Rumah, Kos, Kantor',
                ),
                validator: requiredValidator,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: addressController,
                minLines: 2,
                maxLines: 4,
                textInputAction: TextInputAction.next,
                decoration: inputDecoration(
                  label: 'Alamat Lengkap',
                  icon: Icons.home,
                  hint: 'Masukkan alamat lengkap',
                ),
                validator: requiredValidator,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: cityController,
                textInputAction: TextInputAction.next,
                decoration: inputDecoration(
                  label: 'Kota',
                  icon: Icons.location_city,
                  hint: 'Contoh: Medan',
                ),
                validator: requiredValidator,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: postalCodeController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: inputDecoration(
                  label: 'Kode Pos',
                  icon: Icons.markunread_mailbox,
                  hint: 'Opsional',
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: notesController,
                minLines: 2,
                maxLines: 4,
                decoration: inputDecoration(
                  label: 'Catatan',
                  icon: Icons.notes,
                  hint: 'Contoh: Rumah pagar hitam, dekat minimarket',
                ),
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isDefault,
                  activeThumbColor: const Color(0xff2F80ED),
                  title: const Text(
                    'Jadikan alamat utama',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Alamat utama akan diprioritaskan saat request pickup.',
                    style: TextStyle(fontSize: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      isDefault = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 26),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : saveAddress,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    isSaving
                        ? 'Menyimpan...'
                        : isEdit
                        ? 'Simpan Perubahan'
                        : 'Tambah Alamat',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2F80ED),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Catatan: fitur peta/GPS bisa ditambahkan nanti. Untuk saat ini sistem menyimpan koordinat default agar sinkron dengan database backend.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
