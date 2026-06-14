import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';

import '../../dashboard/owner_dashboard.dart';

import '../../transaction/transaction_screen.dart';
import '../../service/service_screen.dart';

import '../../pickup/pickup_screen.dart';

import '../../customer/customer_screen.dart';
import '../../fragrance/fragrance_screen.dart';

import '../../report/report_screen.dart';
import '../../profile/profile_screen.dart';
import '../../notification/notification_screen.dart';
import '../../../core/app_badges.dart';


class OwnerDrawer extends StatelessWidget {

  final Map laundry;
  final List notifications;
  final Map stats;

  const OwnerDrawer({

    super.key,

    required this.laundry,
    required this.notifications,
    required this.stats,

  });

  @override
  Widget build(BuildContext context) {

    final String laundryName =

        laundry["name"] ??
            "LaundryHub";

    final String ownerName =

        laundry["owner"]?["name"] ??
            "Pemilik Laundry";

    final String address =

        laundry["address"] ??
            "-";
    
    debugPrint(
      "pending_pickups => ${stats["pending_pickups"]}",
    );

    debugPrint(
      "processing => ${stats["processing"]}",
    );

    debugPrint(
      "pending_deliveries => ${stats["pending_deliveries"]}",
    );

    debugPrint(
      "DRAWER STATS => $stats",
    );

    /// Badge Drawer = Task Bisnis
/// BUKAN Notification Read/Unread

    final pickupCount =

    int.tryParse(
      stats["pending_pickups"]
          .toString(),
    ) ?? 0;

    /// Jika backend belum punya pending delivery
    /// sementara pakai 0

    final deliveryCount =

    int.tryParse(
      stats["pending_deliveries"]
          ?.toString() ?? "0",
    ) ?? 0;

    /// Transaksi yang masih perlu diproses

    final transactionCount =

    int.tryParse(
      stats["pending_payments"]
          ?.toString() ?? "0",
    ) ?? 0;

    AppBadges.pendingPaymentCount.value =
    transactionCount;

    /// Badge lonceng tetap unread

    final unreadCount =
    notifications.where((n) {

      try {

        return !n.isRead;

      } catch (_) {

        return false;

      }

    }).length;
    
    for (final n in notifications) {
      debugPrint(
        "TYPE => ${n.type} | READ => ${n.isRead}",
      );
    }

    return Drawer(

      backgroundColor: Colors.white,

      child: Column(

        children: [

          //////////////////////////////////////////////////////
          /// HEADER
          //////////////////////////////////////////////////////

          Container(

            width: double.infinity,

            padding: const EdgeInsets.only(

              top: 60,
              left: 20,
              right: 20,
              bottom: 25,

            ),

            decoration: const BoxDecoration(

              gradient: LinearGradient(

                colors: [

                  Color(0xff5B8DEF),
                  Color(0xff58CFFB),

                ],

                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

              ),

            ),

            child: Row(

              children: [

                CircleAvatar(

                  radius: 30,

                  backgroundColor:
                  Colors.white,

                  child: Text(

                    laundryName
                        .substring(0,1)
                        .toUpperCase(),

                    style:
                    const TextStyle(

                      fontSize: 24,

                      fontWeight:
                      FontWeight.bold,

                      color: Colors.blue,

                    ),

                  ),

                ),

                const SizedBox(width: 15),

                Expanded(

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(

                        laundryName,

                        overflow:
                        TextOverflow.ellipsis,

                        style:
                        const TextStyle(

                          color:
                          Colors.white,

                          fontWeight:
                          FontWeight.bold,

                          fontSize: 20,

                        ),

                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(

                        ownerName,

                        style:
                        const TextStyle(

                          color:
                          Colors.white70,

                        ),

                      ),

                      Text(

                        address,

                        overflow:
                        TextOverflow.ellipsis,

                        style:
                        const TextStyle(

                          color:
                          Colors.white70,

                          fontSize: 12,

                        ),

                      ),

                    ],

                  ),

                ),

              ],

            ),

          ),

          //////////////////////////////////////////////////////
          /// MENU
          //////////////////////////////////////////////////////

          Expanded(

            child: ListView(

              padding:
              EdgeInsets.zero,

              children: [

                _menuItem(

                  context,

                  Icons.dashboard,

                  "Dashboard",

                  () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const OwnerDashboard(),

                      ),

                    );

                  },

                ),

                _menuItem(

                  context,

                  Icons.receipt_long,

                  "Transaksi",

                  () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                        const TransactionScreen(),

                      ),

                    );

                  },

                  badgeCount:
                  transactionCount,

                ),

                _menuItem(

                  context,

                  Icons.local_laundry_service,

                  "Layanan",

                      () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                        const ServiceScreen(),

                      ),

                    );

                  },

                ),

                _menuItem(

                  context,

                  Icons.local_shipping,

                  "Pickup",

                  () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            const PickupScreen(),
                      ),

                    );

                  },

                  badgeCount: pickupCount,

                ),

                _menuItem(

                  context,

                  Icons.delivery_dining,

                  "Request Pengantaran",

                  () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const PickupScreen(
                              initialType: "delivery",
                            ),

                      ),

                    );

                  },

                  badgeCount: deliveryCount,

                ),

                _menuItem(

                  context,

                  Icons.people,

                  "Pelanggan",

                      () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                        const CustomerScreen(),

                      ),

                    );

                  },

                ),

                _menuItem(

                  context,

                  Icons.spa,

                  "Pewangi",

                      () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                        const FragranceScreen(),

                      ),

                    );

                  },

                ),

                _menuItem(

                  context,

                  Icons.bar_chart,

                  "Laporan",

                      () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                        const ReportScreen(),

                      ),

                    );

                  },

                ),

                _menuItem(

                  context,

                  Icons.store,

                  "Profil Laundry",

                      () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                        const ProfileScreen(),

                      ),

                    );

                  },

                ),

                _menuItem(

                  context,

                  Icons.notifications,

                  "Notifikasi",

                  () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const NotificationScreen(),

                      ),

                    );

                  },

                  badgeCount: unreadCount,

                ),

              ],

            ),

          ),

          const Divider(),

          //////////////////////////////////////////////////////
          /// FOOTER USER
          //////////////////////////////////////////////////////

          Padding(

            padding:
            const EdgeInsets.symmetric(

              horizontal: 15,
              vertical: 10,

            ),

            child: Row(

              children: [

                CircleAvatar(

                  radius: 22,

                  backgroundColor:
                  Colors.blue.shade200,

                  child: Text(

                    ownerName
                        .substring(0,1)
                        .toUpperCase(),

                    style:
                    const TextStyle(

                      color:
                      Colors.white,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),

                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(

                        ownerName,

                        style:
                        const TextStyle(

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),

                      const SizedBox(
                        height: 2,
                      ),

                      Text(

                        "Pemilik Laundry",

                        style: TextStyle(

                          color:
                          Colors.grey.shade600,

                          fontSize: 12,

                        ),

                      ),

                    ],

                  ),

                ),

                IconButton(

                  icon: const Icon(

                    Icons.logout,

                    color: Colors.red,

                  ),

                  onPressed: () async {

                    await AuthService().logout();

                    if (context.mounted) {

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        "/",
                        (route) => false,
                      );

                    }

                  },

                ),

              ],

            ),

          ),

          const SizedBox(
            height: 10,
          ),

        ],

      ),

    );

  }

  Widget _menuItem(

    BuildContext context,

    IconData icon,

    String title,

    VoidCallback onTap, {

    int badgeCount = 0,

  }) {

    return InkWell(

      onTap: onTap,

      child: Padding(

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        child: Row(

          children: [

            Icon(
              icon,
              color: Colors.grey.shade700,
              size: 24,
            ),

            const SizedBox(width: 16),

            Expanded(

              child: Text(

                title,

                style: const TextStyle(

                  fontSize: 16,

                  fontWeight:
                      FontWeight.w500,

                ),

              ),

            ),

            if (badgeCount > 0)

              Container(

                width: 20,

                height: 20,

                alignment:
                    Alignment.center,

                decoration:
                    const BoxDecoration(

                  color: Colors.red,

                  shape:
                      BoxShape.circle,

                ),

                child: Text(

                  badgeCount > 99
                      ? "99+"
                      : "$badgeCount",

                  style:
                      const TextStyle(

                    color: Colors.white,

                    fontSize: 10,

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),

              ),

          ],

        ),

      ),

    );

  }

}