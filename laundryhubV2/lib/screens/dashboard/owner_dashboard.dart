import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../services/dashboard_service.dart';

import 'widgets/chart_card.dart';
import 'widgets/owner_drawer.dart';
import 'widgets/quick_action_card.dart';
import '../transaction/add_transaction_screen.dart';
import '../service/service_screen.dart';
import '../fragrance/fragrance_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/recent_transaction_card.dart';
import 'widgets/recent_pickup_card.dart';
import '../../services/notification_service.dart';
import '../notification/notification_screen.dart';
import '../pickup/pickup_detail_screen.dart';
import '../pickup/pickup_screen.dart';
import '../transaction/transaction_detail_screen.dart';
import '../../models/notification_model.dart';
import '../../core/app_badges.dart';
import '../tracking/tracking_search_screen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() =>
      _OwnerDashboardState();
}

class _OwnerDashboardState
    extends State<OwnerDashboard> {

  Map<String,dynamic>? dashboardData;

  List<dynamic> notifications = [];

  int unreadCount = 0;

  bool isLoading=true;

  @override
  void initState() {
    super.initState();

    getData();
    loadNotifications();
  }

  Future<void> getData() async {

    try {

      final dashboardResult =
          await DashboardService()
              .getOwnerDashboard();

      final notifResult =
          await NotificationService()
              .getNotifications();

      if (!mounted) return;

      setState(() {

        if (dashboardResult["success"]) {

          dashboardData =
              dashboardResult["data"]["data"];

          final stats =
              dashboardData?["stats"] ?? {};

          AppBadges.pendingPickupCount.value =
              int.tryParse(
                stats["pending_pickups"]
                    .toString(),
              ) ??
              0;

        }

        if (notifResult["success"]) {

          notifications =
              List<dynamic>.from(
                notifResult["notifications"] ?? [],
              );

          for (final n in notifications) {

            if (n is NotificationModel) {

              debugPrint(
                "NOTIF => ${n.title}",
              );

              debugPrint(
                "TYPE => ${n.type}",
              );

              debugPrint(
                "DATA => ${n.data}",
              );

            }

          }

          unreadCount =
              notifResult["unreadCount"] ?? 0;

        }

        isLoading = false;

      });

    } catch (e) {

      debugPrint(
        "Dashboard error => $e",
      );

      if (mounted) {

        setState(() {
          isLoading = false;
        });

      }

    }

  }

  Future<void> loadNotifications() async {

    try {

      final result =
          await NotificationService()
              .getNotifications();

      if (!mounted) return;

      if (result["success"]) {

        setState(() {

          notifications =
              List<dynamic>.from(
                result["notifications"] ?? [],
              );

          unreadCount =
              result["unreadCount"] ?? 0;

        });

      }

    } catch (e) {

      debugPrint(
        "Notification error => $e",
      );

    }

  }
  
  @override
  Widget build(BuildContext context){

    if(isLoading){

      return const Scaffold(

        body: Center(
          child:
          CircularProgressIndicator(),
        ),

      );

    }

    final laundry=
    dashboardData?["laundry"] ?? {};

    final stats=
    dashboardData?["stats"] ?? {};

    final totalTransactions =
        int.tryParse(
          stats["total_transactions"]
              .toString(),
        ) ??
        0;

    final totalIncome =
        double.tryParse(
          stats["total_income"]
              .toString(),
        ) ??
        0;

    final recentTransactions =
    dashboardData?["recent_transactions"] ?? [];

    final recentPickups =
    dashboardData?["recent_pickups"] ?? [];

    if (recentPickups.isNotEmpty) {
      debugPrint(
        "FIRST PICKUP => ${recentPickups.first}",
      );
    }

    final laundryName=
        laundry["name"] ??
            "Laundry";

    final ownerName=
        laundry["owner"]?["name"] ??
            "-";

    final phone=
        laundry["phone"] ??
            "-";

    final address=
        laundry["address"] ??
            "-";


    bool isOpen = false;

    try {

      final now = DateTime.now();

      final weekdays = [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ];

      final today =
          weekdays[now.weekday - 1];

      final operatingDays =
          List<String>.from(
            laundry["operating_days"] ?? [],
          );

      final openTime =
          (laundry["opening_time"] ?? "08:00")
              .toString()
              .substring(0, 5);

      final closeTime =
          (laundry["closing_time"] ?? "20:00")
              .toString()
              .substring(0, 5);

      final openParts =
          openTime.split(":");

      final closeParts =
          closeTime.split(":");

      final openMinutes =
          int.parse(openParts[0]) * 60 +
          int.parse(openParts[1]);

      final closeMinutes =
          int.parse(closeParts[0]) * 60 +
          int.parse(closeParts[1]);

      final currentMinutes =
          now.hour * 60 +
          now.minute;

      final isOperatingDay =
          operatingDays.contains(today);

      bool isOperatingTime;

      if (closeMinutes >= openMinutes) {

        isOperatingTime =
            currentMinutes >= openMinutes &&
            currentMinutes <= closeMinutes;

      } else {

        isOperatingTime =
            currentMinutes >= openMinutes ||
            currentMinutes <= closeMinutes;

      }

      isOpen =
          isOperatingDay &&
          isOperatingTime;

    } catch (e) {

      isOpen = false;

    }


    return Scaffold(

      backgroundColor:
      const Color(
          0xffF5F7FB),

      drawer:

      OwnerDrawer(

        laundry:laundry,

        notifications:
        notifications,

        stats: stats,

      ),

      floatingActionButton: FloatingActionButton.extended(

      backgroundColor: const Color(0xff5B8DEF),

      elevation: 8,

      icon: const Icon(
        Icons.add,
        color: Colors.white,
      ),

      label: const Text(
        "Buat Transaksi",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

      onPressed: () async {

        final result =
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
            const AddTransactionScreen(),
          ),
        );

        if(result == true){
          getData();
        }

      },

    ),

      appBar: AppBar(

        backgroundColor:
        Colors.white,

        elevation:1,

        leading:

        Builder(

          builder:(context){

            return IconButton(

              icon:
              const Icon(
                  Icons.menu,
                  color:Colors.black
              ),

              onPressed:(){

                Scaffold.of(
                    context)
                    .openDrawer();

              },

            );

          },

        ),

        title:

        Row(

          children:[

            Container(

              height:50,
              width:50,

              decoration:
              BoxDecoration(

                color:
                Colors.blue.shade50,

                borderRadius:
                BorderRadius.circular(
                    14
                ),

              ),

              child:

              const Center(

                child:

                FaIcon(

                  FontAwesomeIcons.shirt,

                  color:
                  Color(
                      0xff5B8DEF
                  ),

                  size:22,

                ),

              ),

            ),

            const SizedBox(
              width:14,
            ),

            Text(

              "LaundryHub",

              style:
              GoogleFonts.poppins(

                fontSize:22,

                fontWeight:
                FontWeight.w700,

              ),

            ),

          ],

        ),

        actions: [

          IconButton(

            tooltip: "Cari Tracking",

            icon: const Icon(
              Icons.search,
              color: Colors.black,
            ),

            onPressed: () {

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) =>
                      const TrackingSearchScreen(),

                ),

              );

            },

          ),

          Stack(
            children: [

              PopupMenuButton<dynamic>(

                tooltip: "Notifikasi",

                offset: const Offset(0, 55),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                onSelected: (value) async {

                  if (value == "__see_all__") {

                    await Navigator.push(

                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                        const NotificationScreen(),
                      ),

                    );

                    await loadNotifications();

                    return;
                  }

                  final notif = value;

                  try {

                    if (notif is NotificationModel &&
                        !notif.isRead) {

                      await NotificationService()
                          .markAsRead(
                            notif.id,
                          );

                      await loadNotifications();
                    }

                  } catch (e) {

                    debugPrint(
                      "Mark notification error => $e",
                    );

                  }

                  await _handleNotificationClick(
                    notif,
                  );

                },

                itemBuilder: (context) {

                  final popupNotifications =
                      notifications.take(3).toList();

                  if (popupNotifications.isEmpty) {

                    return [

                      const PopupMenuItem(

                        enabled: false,

                        child: SizedBox(

                          width: 280,

                          child: Center(

                            child: Padding(

                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),

                              child: Text(
                                "Belum ada notifikasi",
                              ),

                            ),

                          ),

                        ),

                      ),

                    ];

                  }

                  return [

                    ...popupNotifications.map<PopupMenuEntry<dynamic>>(

                      (notif) {

                        final bool isRead =

                        notif is NotificationModel
                            ? notif.isRead
                            : (notif["is_read"] ?? false);

                        final String title =

                        notif is NotificationModel
                            ? notif.title
                            : (notif["title"] ?? "");

                        final String message =

                        notif is NotificationModel
                            ? notif.message
                            : (notif["message"] ?? "");

                        return PopupMenuItem<dynamic>(

                          value: notif,

                          child: SizedBox(

                            width: 300,

                            child: Row(

                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                Container(

                                  width: 42,

                                  height: 42,

                                  decoration: BoxDecoration(

                                    color:
                                    Colors.green.shade100,

                                    shape:
                                    BoxShape.circle,

                                  ),

                                  child: const Icon(

                                    Icons.notifications,

                                    color: Colors.green,

                                  ),

                                ),

                                const SizedBox(width: 10),

                                Expanded(

                                  child: Column(

                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                    children: [

                                      Text(

                                        title,

                                        maxLines: 1,

                                        overflow:
                                        TextOverflow.ellipsis,

                                        style:
                                        const TextStyle(

                                          fontWeight:
                                          FontWeight.bold,

                                          fontSize: 15,

                                        ),

                                      ),

                                      const SizedBox(height: 4),

                                      Text(

                                        message,

                                        maxLines: 2,

                                        overflow:
                                        TextOverflow.ellipsis,

                                        style:
                                        const TextStyle(

                                          fontSize: 12,

                                          color: Colors.grey,

                                        ),

                                      ),

                                    ],

                                  ),

                                ),

                                if (!isRead)

                                  Container(

                                    width: 10,

                                    height: 10,

                                    margin:
                                    const EdgeInsets.only(

                                      left: 8,

                                      top: 6,

                                    ),

                                    decoration:
                                    const BoxDecoration(

                                      color: Colors.red,

                                      shape:
                                      BoxShape.circle,

                                    ),

                                  ),

                              ],

                            ),

                          ),

                        );

                      },

                    ),

                    const PopupMenuDivider(),

                    const PopupMenuItem<String>(

                      value: "__see_all__",

                      child: Center(

                        child: Text(

                          "Lihat Semua",

                          style: TextStyle(

                            fontWeight:
                            FontWeight.bold,

                            color: Colors.blue,

                          ),

                        ),

                      ),

                    ),

                  ];

                },

                child: const Padding(

                  padding: EdgeInsets.all(12),

                  child: Icon(

                    Icons.notifications_outlined,

                    color: Colors.black,

                  ),

                ),

              ),

              if (unreadCount > 0)

                Positioned(

                  right: 6,
                  top: 6,

                  child: Container(

                    padding:
                    const EdgeInsets.all(5),

                    decoration:
                    const BoxDecoration(

                      color: Colors.red,

                      shape: BoxShape.circle,

                    ),

                    constraints:
                    const BoxConstraints(

                      minWidth: 18,
                      minHeight: 18,

                    ),

                    child: Text(

                      unreadCount > 99
                            ? "99+"
                            : "$unreadCount",

                      textAlign:
                      TextAlign.center,

                      style:
                      const TextStyle(

                        color: Colors.white,

                        fontSize: 10,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),

                  ),

                ),

            ],

          ),

        ],

      ),

      body:

      RefreshIndicator(

        onRefresh:getData,

        child:

        SingleChildScrollView(

          physics:
          const AlwaysScrollableScrollPhysics(),

          padding:
          const EdgeInsets.all(16),

          child:

          Column(

            children:[

              /////////////////////////////
              /// HEADER CARD
              /////////////////////////////

              Container(

                width:
                double.infinity,

                padding:
                const EdgeInsets.all(22),

                decoration:
                BoxDecoration(

                  borderRadius:
                  BorderRadius.circular(
                      35
                  ),

                  gradient:
                  const LinearGradient(

                    colors:[

                      Color(
                          0xff5B8DEF
                      ),

                      Color(
                          0xff58CFFB
                      ),

                    ],

                  ),

                ),

                child:

                Column(

                  children:[

                    Row(

                      children:[

                        CircleAvatar(

                          radius:38,

                          backgroundColor:
                          Colors.white,

                          child:

                          Text(

                            laundryName
                                .substring(
                                0,
                                1
                            )
                                .toUpperCase(),

                            style:
                            const TextStyle(

                              fontSize:35,

                              fontWeight:
                              FontWeight.bold,

                              color:
                              Colors.blue,

                            ),

                          ),

                        ),

                        const SizedBox(
                          width:15,
                        ),

                        Expanded(

                          child:

                          Column(

                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children:[

                              Text(

                                laundryName,

                                maxLines:1,

                                overflow:
                                TextOverflow
                                    .ellipsis,

                                style:

                                GoogleFonts.poppins(

                                  fontWeight:
                                  FontWeight.bold,

                                  fontSize:24,

                                  color:
                                  Colors.white,

                                ),

                              ),

                              const SizedBox(
                                  height:5),

                              Text(

                                address,

                                maxLines:1,

                                overflow:
                                TextOverflow
                                    .ellipsis,

                                style:
                                const TextStyle(

                                  color:
                                  Colors.white70,

                                ),

                              ),

                            ],

                          ),

                        )

                      ],

                    ),

                    const SizedBox(
                      height:20,
                    ),

                    Row(

                      children:[

                        const Icon(
                          Icons.phone,
                          color:
                          Colors.white,
                          size:18,
                        ),

                        const SizedBox(
                            width:5),

                        Text(

                          phone,

                          style:
                          const TextStyle(

                            color:
                            Colors.white,

                          ),

                        ),

                        const Spacer(),

                        Row(
                          children: [

                            Icon(
                              isOpen
                                  ? Icons.door_front_door_outlined
                                  : Icons.door_front_door,
                              color: Colors.white,
                              size: 20,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              isOpen
                                  ? "Buka"
                                  : "Tutup",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )

                      ],

                    ),

                    const SizedBox(
                      height:10,
                    ),

                    Align(

                      alignment:
                      Alignment.centerLeft,

                      child:

                      Text(

                        ownerName,

                        style:
                        const TextStyle(

                          color:
                          Colors.white70,

                          fontSize:18,

                        ),

                      ),

                    ),

                    const SizedBox(
                        height:20),

                    Align(

                      alignment:
                      Alignment.centerRight,

                      child:

                      Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.end,

                        children:[

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [

                              const Text(
                                "Pendapatan Hari Ini",
                                style: TextStyle(
                                  color: Colors.white70,
                                ),
                              ),

                              Text(
                                formatRupiah(
                                  stats["today_income"] ?? 0,
                                ),
                                style: GoogleFonts.poppins(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Container(
                                width: 120,
                                height: 1,
                                color: Colors.white24,
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                "Total Pendapatan",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),

                              Text(
                                formatRupiah(
                                  stats["total_income"] ?? 0,
                                ),
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),

                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [

                              Expanded(
                                child: _miniInfo(
                                  "Transaksi",
                                  "${stats["total_transactions"] ?? 0}",
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: _miniInfo(
                                  "Diproses",
                                  "${stats["processing"] ?? 0}",
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: _miniInfo(
                                  "Pickup",
                                  "${stats["pending_pickups"] ?? 0}",
                                ),
                              ),
                            ],
                          )

                        ],

                      ),

                    )

                  ],

                ),

              ),

              const SizedBox(
                height:20,
              ),

              sectionTitle(
                "Analitik",
                Icons.analytics,
              ),

              const SizedBox(height:10),

              ChartCard(
                totalTransactions:
                    totalTransactions,

                totalIncome:
                    totalIncome,
              ),

              const SizedBox(
                  height:20),


              RecentTransactionCard(
                transactions: recentTransactions,
              ),

              const SizedBox(height: 20),

              RecentPickupCard(
                pickups: recentPickups,
              ),

              const SizedBox(height: 20),

              sectionTitle(
                "Aksi Cepat",
                Icons.flash_on,
              ),

              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ServiceScreen(),
                        ),
                      );
                    },
                    child: const QuickActionCard(
                      title: "Kelola\nLayanan",
                      icon: Icons.local_laundry_service,
                      color: Colors.green,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FragranceScreen(),
                        ),
                      );
                    },
                    child: const QuickActionCard(
                      title: "Kelola\nPewangi",
                      icon: Icons.spa,
                      color: Colors.purple,
                    ),
                  ),

                  GestureDetector(
                    onTap: () async {

                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );

                      if (result == true) {
                        await getData();
                      }
                    },
                    child: const QuickActionCard(
                      title: "Profil\nLaundry",
                      icon: Icons.store,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 100),

            ],

          ),

        ),

      ),

    );

  }

  Widget _miniInfo(
    String title,
    String value,
  ){
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Column(
        children: [

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(
    String title,
    IconData icon,
  ){

    return Row(

      children:[

        Icon(
          icon,
          size:20,
        ),

        const SizedBox(
          width:8,
        ),

        Text(

          title,

          style:
          const TextStyle(

            fontSize:18,

            fontWeight:
            FontWeight.bold,

          ),

        ),

      ],

    );

  }
  
  
  Future<void> _handleNotificationClick(
    dynamic notif,
  ) async {

    if (notif is! NotificationModel) {
      return;
    }

    final data =
        notif.data ?? {};

    // REQUEST DELIVERY
    // REQUEST DELIVERY
    if (
        notif.title
            .toLowerCase()
            .contains("pengantaran")
    ) {

      await Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) =>
              const PickupScreen(
                initialType: "delivery",
              ),

        ),

      );

      await loadNotifications();

      return;
    }

    final pickupId =
        data["pickup_id"];

    final transactionId =
        data["transaction_id"];

    /// Pickup / Delivery
    if (pickupId != null) {


      // NOTIF PICKUP
      await Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) =>
              PickupDetailScreen(
                pickupId: pickupId,
              ),

        ),

      );

      await loadNotifications();

      return;
    }

    /// Laundry Update / Transaction
    /// Laundry Update / Transaction
    if (transactionId != null) {

      await Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) =>
              TransactionDetailScreen(

            transactionId:
                int.parse(
                  transactionId.toString(),
                ),

          ),

        ),

      );

      await loadNotifications();

      return;

    }

    /// Default
    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            const NotificationScreen(),

      ),

    );

    await loadNotifications();

  }


}