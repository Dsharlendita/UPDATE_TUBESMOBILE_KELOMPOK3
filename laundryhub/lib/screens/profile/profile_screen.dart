import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/profile_model.dart';
import '../../services/profile_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService service = ProfileService();

  // 1. Kunci Utama Validasi Form
  final _formKey = GlobalKey<FormState>();

  bool loading = true;
  ProfileModel? profile;

  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final laundryNameC = TextEditingController();
  final laundryAddressC = TextEditingController();
  final laundryPhoneC = TextEditingController();
  final laundryEmailC = TextEditingController();
  final descriptionC = TextEditingController();

  String profileFileName = "No file chosen";
  String logoFileName = "No file chosen";
  PlatformFile? profileFileBytes;
  PlatformFile? logoFileBytes;
  // Tambahkan variabel ini untuk menampung hasil rekomendasi tempat
  List<dynamic> _addressSuggestions = [];
  final Dio _searchDio = Dio();

  // Fungsi memilih Foto Profil
  Future<void> pickProfileFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        profileFileBytes = result.files.first;
        profileFileName = result.files.first.name;
      });
    }
  }

  // Fungsi memilih Logo Laundry
  Future<void> pickLogoFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        logoFileBytes = result.files.first;
        logoFileName = result.files.first.name;
      });
    }
  }

  String formatTimeOnly(String value) {
    try {
      if (value.contains('T')) {
        final dt = DateTime.parse(value);
        return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      }

      if (value.length >= 5) {
        return value.substring(0, 5);
      }
    } catch (_) {}

    return value;
  }

  double radiusKm = 10;
  // Titik default koordinat (Jakarta sebagai contoh awal)
  LatLng currentLatLng = const LatLng(-6.2088, 106.8456);
  final MapController _mapController = MapController();
  final searchLocationC = TextEditingController();
  String openTime = "08:00";
  String closeTime = "20:00";
  List<String> selectedDays = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

Future loadData() async {
    final result = await service.getProfile();

    if (result["success"]) {
      profile = result["data"];
      final user = profile!.user;
      final laundry = profile!.laundry;
      
      nameC.text = user.name;
      phoneC.text = user.phone;
      laundryNameC.text = laundry.name;
      laundryAddressC.text = laundry.address;
      laundryPhoneC.text = laundry.phone;
      laundryEmailC.text = laundry.email;
      descriptionC.text = laundry.description;
      radiusKm = laundry.radiusKm;
      openTime = formatTimeOnly(laundry.openingTime);
      closeTime = formatTimeOnly(laundry.closingTime);

      selectedDays = laundry.operatingDays.map((e) => e.toString()).toList();
      
      if (laundry.latitude != 0 && laundry.longitude != 0) {
        currentLatLng = LatLng(laundry.latitude, laundry.longitude);
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(currentLatLng, 15.0);
      });
    }
  }

  // 1. Fungsi Mengambil Rekomendasi Alamat dari API OpenStreetMap
  Future<void> _fetchAddressSuggestions(String query) async {
    if (query.isEmpty || query.length < 3) {
      setState(() => _addressSuggestions = []);
      return;
    }

    try {
      final response = await _searchDio.get(
        "https://nominatim.openstreetmap.org/search",
        queryParameters: {
          "q": query,
          "format": "json",
          "limit": 5,
          "countrycodes": "id", // Mengunci pencarian hanya di area Indonesia
        },
        options: Options(headers: {"User-Agent": "LaundryHubApp"}),
      );

      setState(() {
        _addressSuggestions = response.data;
      });
    } catch (e) {
      debugPrint("Error fetching suggestions: $e");
    }
  }

  // 2. Widget Pembuat Label Status Buka/Tutup berbasis WIB (UTC+7)
Widget _buildStatusBadge() {
    // Mengambil waktu lokal HP saat ini (Otomatis mencocokkan WIB jika pengguna berada di zona WIB)
    DateTime now = DateTime.now();
    
    // Sinkronisasi index hari Flutter ke format string database Laravel
    List<String> weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    String todayStr = weekdays[now.weekday - 1];

    bool isOpenDay = selectedDays.contains(todayStr);
    bool isOpenTime = false;

    // Fungsi pembaca format jam pintar (Mendukung "08:00" maupun format ISO "2026-06-10T08:00:00")
    TimeOfDay? parseTimePintar(String timeStr) {
      if (timeStr.isEmpty) return null;
      try {
        if (timeStr.contains('T') || timeStr.contains('-')) {
          DateTime dt = DateTime.parse(timeStr);
          return TimeOfDay(hour: dt.hour, minute: dt.minute);
        }
        List<String> parts = timeStr.split(':');
        if (parts.length >= 2) {
          return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      } catch (e) {
        debugPrint("Gagal parse jam: $e");
      }
      return null;
    }

    TimeOfDay? buka = parseTimePintar(openTime);
    TimeOfDay? tutup = parseTimePintar(closeTime);

    if (buka != null && tutup != null) {
      int menitSekarang = (now.hour * 60) + now.minute;
      int menitBuka = (buka.hour * 60) + buka.minute;
      int menitTutup = (tutup.hour * 60) + tutup.minute;

      if (menitTutup >= menitBuka) {
        isOpenTime = menitSekarang >= menitBuka && menitSekarang <= menitTutup;
      } else {
        // Mengantisipasi jika toko buka melewati tengah malam (ex: 16:00 - 02:00)
        isOpenTime = menitSekarang >= menitBuka || menitSekarang <= menitTutup;
      }
    }

    bool isCurrentlyOpen = isOpenDay && isOpenTime;
    Color statusColor = isCurrentlyOpen ? Colors.green : Colors.red;

    // Desain kustom dengan ikon toko sesuai permintaanmu
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.storefront_rounded, // Ikon Toko/Laundry
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isCurrentlyOpen ? "Buka Sekarang" : "Tutup Sekarang",
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future saveProfile() async {
    // 1. Logika Validasi Tegas Langsung Menggunakan Teks Controller
    String errorMessage = "";

    if (nameC.text.trim().isEmpty) {
      errorMessage = "Nama Pemilik wajib diisi!";
    } else if (phoneC.text.trim().isEmpty) {
      errorMessage = "Nomor Telepon Pemilik tidak boleh kosong!";
    } else if (phoneC.text.trim().length < 10 ||
        phoneC.text.trim().length > 13) {
      errorMessage = "Nomor Telepon harus berukuran 10 hingga 13 digit!";
    } else if (laundryNameC.text.trim().isEmpty) {
      errorMessage = "Nama Toko Laundry tidak boleh kosong!";
    } else if (laundryAddressC.text.trim().isEmpty) {
      errorMessage = "Alamat Lengkap Laundry wajib diisi!";
    } else if (laundryPhoneC.text.trim().isEmpty) {
      errorMessage = "Nomor Telepon Laundry tidak boleh kosong!";
    } else if (laundryEmailC.text.trim().isEmpty) {
      errorMessage = "Email Laundry wajib diisi!";
    } else if (!laundryEmailC.text.contains('@') ||
        !laundryEmailC.text.contains('.')) {
      errorMessage =
          "Format penulisan Email Laundry salah (harus ada @ dan titik)!";
    } else if (descriptionC.text.trim().isEmpty) {
      errorMessage = "Deskripsi Laundry wajib diisi!";
    }

    // 2. Jika ada yang kosong/salah, langsung munculkan Pop-up Peringatan (Batalkan Simpan)
    if (errorMessage.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text(
                "Validasi Gagal",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Oke, Saya Perbaiki"),
            ),
          ],
        ),
      );
      return; // Menghentikan pengiriman ke API Laravel jika data tidak lolos validasi
    }

    // 3. Jika SEMUA KOLOM SUDAH VALID, baru jalankan proses kirim data ke Laravel
    setState(() => loading = true);

    final result = await service.updateProfile(
      name: nameC.text,
      phone: phoneC.text,
      laundryName: laundryNameC.text,
      laundryAddress: laundryAddressC.text,
      laundryPhone: laundryPhoneC.text,
      laundryEmail: laundryEmailC.text,
      description: descriptionC.text,
      latitude: currentLatLng.latitude, // Menggunakan koordinat peta baru
      longitude: currentLatLng.longitude, // Menggunakan koordinat peta baru
      radiusKm: radiusKm,
      avatarFile: profileFileBytes, // SEKARANG TERIKUT DIKIRIM KE API
      logoFile: logoFileBytes,
    );

    setState(() => loading = false);

if (mounted) {
      if (result["success"] == true) { // Tambahkan pengecekan ini
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil disimpan"),
            backgroundColor: Colors.green,
          ),
        );
        loadData(); // Supaya data terbaru langsung ter-refresh di layar
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? "Gagal memperbarui profil"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> selectOpenTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() {
        openTime =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> selectCloseTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
    );
    if (picked != null) {
      setState(() {
        closeTime =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future saveOperational() async {
    // Validasi Hari Operasional
    if (selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih minimal satu hari operasional laundry!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await service.updateOperational(
      openingTime: openTime,
      closingTime: closeTime,
      operatingDays: selectedDays,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Jam operasional berhasil diperbarui"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profil Laundry")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ), // Memberi jarak dari tepi layar browser
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= DATA PEMILIK =================
              const Text(
                "DATA PEMILIK",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16), // Jarak dari judul ke kolom pertama

              TextFormField(
                controller: nameC,
                decoration: const InputDecoration(
                  labelText: "Nama Pemilik",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Nama pemilik wajib diisi";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16), // Jarak antar kolom input

              TextFormField(
                controller: phoneC,
                decoration: const InputDecoration(
                  labelText: "Nomor Telepon",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Nomor telepon wajib diisi";
                  }
                  if (value.length < 10 || value.length > 13) {
                    return "Nomor telepon harus berukuran 10-13 digit";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16), // Jarak antar kolom input

              const Text(
                "Foto Profil",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: pickProfileFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Choose File"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        profileFileName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32), // Jarak renggang antar-seksi besar
              // ================= PROFIL TOKO LAUNDRY =================
              const Text(
                "PROFIL TOKO LAUNDRY",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                "Logo Laundry",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: pickLogoFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Choose File"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        logoFileName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: laundryNameC,
                decoration: const InputDecoration(
                  labelText: "Nama Laundry",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Nama toko laundry tidak boleh kosong";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Ganti susunan TextFormField Alamat milikmu lama menjadi struktur ini:
Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        controller: laundryAddressC,
        decoration: InputDecoration(
          labelText: "Alamat Lengkap Laundry",
          border: const OutlineInputBorder(),
          hintText: "Ketik nama jalan, komplek, atau tempat...",
          suffixIcon: laundryAddressC.text.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      laundryAddressC.clear();
                      _addressSuggestions = [];
                    });
                  },
                )
              : const Icon(Icons.map_rounded),
        ),
        maxLines: 2,
        onChanged: (value) {
          // Setiap user mengetik, cari rekomendasi tempat secara realtime
          _fetchAddressSuggestions(value);
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Alamat laundry wajib diisi";
          }
          return null;
        },
      ),
      
      // JIKA DAFTAR REKOMENDASI TERSEDIA, TAMPILKAN MENU DROP-DOWN
      if (_addressSuggestions.isNotEmpty)
        Card(
          elevation: 5,
          margin: const EdgeInsets.only(top: 4, bottom: 8),
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _addressSuggestions.length,
            itemBuilder: (context, index) {
              final item = _addressSuggestions[index];
              return ListTile(
                leading: const Icon(Icons.location_on, color: Colors.redAccent),
                title: Text(
                  item["display_name"] ?? "",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  // JIKA REKOMENDASI TEMPAT DIKLIK:
                  double lat = double.tryParse(item["lat"] ?? "0") ?? 0;
                  double lon = double.tryParse(item["lon"] ?? "0") ?? 0;

                  setState(() {
                    laundryAddressC.text = item["display_name"] ?? "";
                    currentLatLng = LatLng(lat, lon); // Update koordinat map
                    _addressSuggestions = []; // Sembunyikan drop-down kembali
                  });

                  // Geser kamera peta ke lokasi yang dipilih secara otomatis
                  _mapController.move(currentLatLng, 16.0);
                },
              );
            },
          ),
        ),
    ],
  ),
              const SizedBox(height: 16),

              TextFormField(
                controller: laundryPhoneC,
                decoration: const InputDecoration(
                  labelText: "Telepon Laundry",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Telepon operasional toko wajib diisi";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: laundryEmailC,
                decoration: const InputDecoration(
                  labelText: "Email Laundry",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Email laundry wajib diisi";
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return "Format penulisan email toko salah";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: descriptionC,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Deskripsi Laundry",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Berikan deskripsi singkat laundry kamu";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // ================= LOKASI LAUNDRY =================
              const Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    "Lokasi Laundry",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              const Text(
                "Cari Alamat Laundry *",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: searchLocationC,
                decoration: const InputDecoration(
                  hintText: "Ketik nama jalan, gedung, area, atau kota...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onFieldSubmitted: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Mencari lokasi: $value...")),
                  );
                },
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    bool serviceEnabled =
                        await Geolocator.isLocationServiceEnabled();

                    if (!serviceEnabled) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('GPS belum aktif'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    LocationPermission permission =
                        await Geolocator.checkPermission();

                    if (permission == LocationPermission.denied) {
                      permission = await Geolocator.requestPermission();
                    }

                    if (permission == LocationPermission.denied) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Izin lokasi ditolak'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (permission == LocationPermission.deniedForever) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Izin lokasi ditolak permanen, buka Settings'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high,
                    );

                    setState(() {
                      currentLatLng = LatLng(
                        position.latitude,
                        position.longitude,
                      );
                    });

                    _mapController.move(currentLatLng, 16);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lokasi berhasil didapat'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    debugPrint("GPS ERROR => $e");

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("GPS ERROR => $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[50],
                  foregroundColor: Colors.teal,
                  elevation: 0,
                  side: const BorderSide(color: Colors.teal),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text("Gunakan Lokasi Saya Saat Ini"),
              ),
              const SizedBox(height: 16),

              Container(
                height:
                    350, // Sedikit ditinggikan agar peta terlihat lebih lega
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: currentLatLng,
                      initialZoom: 15.0,
                      onTap: (tapPosition, point) {
                        setState(() {
                          currentLatLng = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                        userAgentPackageName: 'com.laundryhub.app',

                        errorTileCallback: (tile, error, stackTrace) {
                          debugPrint('====================');
                          debugPrint('TILE ERROR => $error');
                          debugPrint('====================');
                        },
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: currentLatLng,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "📍 Lokasi tersimpan: ${currentLatLng.latitude.toStringAsFixed(6)}, ${currentLatLng.longitude.toStringAsFixed(6)} | Klik atau seret marker untuk mengubah",
                        style: TextStyle(color: Colors.blue[900], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                "Radius Layanan (${radiusKm.toStringAsFixed(1)} KM)",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Slider(
                value: radiusKm,
                min: 1,
                max: 100,
                onChanged: (v) {
                  setState(() {
                    radiusKm = v;
                  });
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "Simpan Profil",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const Divider(height: 60),

              // ================= HARI OPERASIONAL TOKO =================
              const Text(
                "HARI OPERASIONAL TOKO",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatusBadge(),
              const SizedBox(height: 8),
              
              const Text(
                "Status buka/tutup dihitung otomatis mengikuti waktu Jakarta. Jika sudah lewat jam tutup, status otomatis menjadi tutup.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Jam Buka *",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: selectOpenTime,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                           child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    openTime,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.access_time,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Jam Tutup *",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: selectCloseTime,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  closeTime,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const Icon(
                                  Icons.access_time,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                "Hari Operasional *",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12, // Jarak renggang horizontal antar kotak hari
                runSpacing:
                    12, // Jarak renggang vertikal antar baris kotak hari
                children:
                    [
                      {"id": "monday", "nama": "Senin"},
                      {"id": "tuesday", "nama": "Selasa"},
                      {"id": "wednesday", "nama": "Rabu"},
                      {"id": "thursday", "nama": "Kamis"},
                      {"id": "friday", "nama": "Jumat"},
                      {"id": "saturday", "nama": "Sabtu"},
                      {"id": "sunday", "nama": "Minggu"},
                    ].map((hari) {
                      bool isSelected = selectedDays.contains(hari["id"]);
                      return Container(
                        width: 160,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: CheckboxListTile(
                          value: isSelected,
                          title: Text(
                            hari["nama"]!,
                            style: const TextStyle(fontSize: 13),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (v) {
                            setState(() {
                              if (v!) {
                                selectedDays.add(hari["id"]!);
                              } else {
                                selectedDays.remove(hari["id"]!);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 8),
              const Text(
                "Centang Minggu agar laundry tetap buka pada hari Minggu.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: saveOperational,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: const Icon(Icons.access_time, color: Colors.white),
                  label: const Text(
                    "Simpan Jam Operasional",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
