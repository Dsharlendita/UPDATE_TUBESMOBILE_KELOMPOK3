class ProfileModel {
  final UserProfile user;
  final LaundryProfile laundry;
  final ProfileStats stats; // Tambahkan stats dari backend

  ProfileModel({
    required this.user,
    required this.laundry,
    required this.stats,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      user: UserProfile.fromJson(json["user"] ?? {}),
      laundry: LaundryProfile.fromJson(json["laundry"] ?? {}),
      stats: ProfileStats.fromJson(json["stats"] ?? {}), // Petakan stats
    );
  }
}

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String avatar;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      avatar: json["avatar"] ?? "",
    );
  }
}

class LaundryProfile {
  final String name;
  final String address;
  final String phone;
  final String email;
  final String description;
  final String logo; // Tambahkan field logo

  final double latitude;
  final double longitude;
  final double radiusKm;

  final String openingTime;
  final String closingTime;

  final List<dynamic> operatingDays;

  LaundryProfile({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.description,
    required this.logo, // Tambahkan constructor logo
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    required this.openingTime,
    required this.closingTime,
    required this.operatingDays,
  });

  factory LaundryProfile.fromJson(Map<String, dynamic> json) {
    return LaundryProfile(
      name: json["name"] ?? "",
      address: json["address"] ?? "",
      phone: json["phone"] ?? "",
      email: json["email"] ?? "",
      description: json["description"] ?? "",
      logo: json["logo"] ?? "", // Ambil data logo dari backend
      latitude: double.tryParse("${json["latitude"] ?? 0}") ?? 0,
      longitude: double.tryParse("${json["longitude"] ?? 0}") ?? 0,
      radiusKm: double.tryParse("${json["radius_km"] ?? 10}") ?? 10,
      openingTime: json["opening_time"] ?? "08:00",
      closingTime: json["closing_time"] ?? "20:00",
      operatingDays: json["operating_days"] ?? [],
    );
  }
}

// Tambahkan class baru untuk menampung statistik laundry
class ProfileStats {
  final int totalServices;
  final int activeServices;
  final int totalFragrances;
  final int activeFragrances;
  final int totalTransactions;
  final double totalRevenue;

  ProfileStats({
    required this.totalServices,
    required this.activeServices,
    required this.totalFragrances,
    required this.activeFragrances,
    required this.totalTransactions,
    required this.totalRevenue,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      totalServices: json['total_services'] ?? 0,
      activeServices: json['active_services'] ?? 0,
      totalFragrances: json['total_fragrances'] ?? 0,
      activeFragrances: json['active_fragrances'] ?? 0,
      totalTransactions: json['total_transactions'] ?? 0,
      totalRevenue: double.tryParse(json['total_revenue']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}