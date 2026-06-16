import 'package:flutter/material.dart';

import '../../models/customer_model.dart';
import '../../services/customer_service.dart';
import 'customer_detail_screen.dart';

class CustomerScreen
    extends StatefulWidget {

  const CustomerScreen({
    super.key,
  });

  @override
  State<CustomerScreen>
  createState() =>
      _CustomerScreenState();

}

class _CustomerScreenState
    extends State<CustomerScreen> {

  final CustomerService
  customerService =
  CustomerService();

  final TextEditingController
  searchController =
  TextEditingController();

  List<CustomerModel>
  customers = [];

  bool isLoading = true;

  Map<String,dynamic>
  stats = {};

  Map<String,dynamic> owner = {};

  String sortBy = "name";
  String orderBy = "asc";
  String customerFilter = "all";

  @override
  void initState() {

    super.initState();

    loadCustomers();

  }

  Future loadCustomers() async {

    setState(() {
      isLoading = true;
    });

    final result =
    await customerService
        .getCustomers(

      search:
      searchController.text,

      sort: sortBy,
      order: orderBy,

    );

    print("RESULT API:");
    print(result);

    if(result["success"]){

      customers =
          result["customers"];

      print("CUSTOMERS LENGTH = ${customers.length}");

      for (var c in customers) {
        print(
          "${c.name} | ${c.phone} | guest=${c.isGuest}"
        );
      }

      owner =
          result["owner"] ?? {};

      stats =
          result["stats"];

      print(
        "TOTAL CUSTOMER: ${customers.length}"
      );

      print(
        "STATS: $stats"
      );

    }
    else{

      print(
        "ERROR CUSTOMER: ${result["message"]}"
      );

    }

    setState(() {
      isLoading = false;
    });

  }

  Widget statCard({

    required String title,
    required dynamic value,
    required Color color,
    required IconData icon,

  }){

    return Expanded(

      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
          BorderRadius.circular(16),

        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,

          children: [

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(.1),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    title,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "$value",
                    style: TextStyle(
                      color: color,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
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

  Widget ownerCard() {

    if(owner.isEmpty){
      return const SizedBox();
    }

    return Container(

      margin: const EdgeInsets.only(
        bottom: 20,
      ),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: 
      Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  owner["laundry_name"] ?? "-",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(owner["name"] ?? ""),

                Text(owner["email"] ?? ""),

                Text(owner["phone"] ?? ""),

              ],
            ),
          ),

          Column(
            children: [

              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerDetailScreen(
                        customer: CustomerModel(
                          id: "${owner["id"] ?? ""}",
                          name: owner["name"] ?? "",
                          email: owner["email"] ?? "",
                          phone: owner["phone"] ?? "",
                          address: owner["address"] ?? "",
                          transactionCount: 0,
                          totalSpent: 0,
                          pendingPickups: 0,
                          isGuest: false,
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: Color(0xff4F6EF7),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: const Text(
                  "OWNER",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

            ],
          ),

        ],
      )
    );
  }

  Widget _buildStat(
    String title,
    String value,
  ) {
    return Column(
      children: [

        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    final filteredCustomers =
    customers.where((customer) {

      if (customerFilter == "member") {

        return !customer.isGuest;

      }

      if (customerFilter == "non_member") {

        return customer.isGuest;

      }

      return true;

    }).toList();

    return Scaffold(

      backgroundColor:
      const Color(0xffF5F7FB),

      appBar: AppBar(

        backgroundColor:
        Colors.white,

        elevation: 0,

        title: const Text(

          "Manajemen Pelanggan",

          style: TextStyle(

            color: Colors.black,
            fontWeight: FontWeight.bold,

          ),

        ),

      ),

      body: RefreshIndicator(

        onRefresh: loadCustomers,

        child: ListView(

          padding:
          const EdgeInsets.all(16),

          children:[

            ownerCard(),

            Row(

              children:[

                statCard(

                  title:
                  "Pelanggan Terdaftar",

                  value:
                  stats["total_registered"] ?? 0,

                  color:
                  Colors.blue,

                  icon:
                  Icons.people,

                ),

                const SizedBox(width: 10),

                statCard(

                  title:
                  "Non Member",

                  value:
                  stats["total_non_member"] ?? 0,

                  color:
                  Colors.orange,

                  icon:
                  Icons.person,

                ),

              ],

            ),

            const SizedBox(height: 10),

            Row(

              children:[

                statCard(

                  title:
                  "Total Transaksi",

                  value:
                  stats["total_transactions"] ?? 0,

                  color:
                  Colors.green,

                  icon:
                  Icons.receipt_long,

                ),

                const SizedBox(width: 10),

                statCard(

                  title:
                  "Aktif Bulan Ini",

                  value:
                  stats["active_this_month"] ?? 0,

                  color:
                  Colors.purple,

                  icon:
                  Icons.calendar_month,

                ),

              ],

            ),

            const SizedBox(height: 20),

            Container(

              padding:
              const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                BorderRadius.circular(20),

              ),

              child: Column(

                children:[

                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Cari pelanggan...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xffF5F7FB),

                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: customerFilter,

                    decoration: InputDecoration(

                      filled: true,

                      fillColor:
                          const Color(0xffF5F7FB),

                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),

                    items: const [

                      DropdownMenuItem(
                        value: "all",
                        child: Text(
                          "Semua Pelanggan",
                        ),
                      ),

                      DropdownMenuItem(
                        value: "member",
                        child: Text(
                          "Member",
                        ),
                      ),

                      DropdownMenuItem(
                        value: "non_member",
                        child: Text(
                          "Non Member",
                        ),
                      ),

                    ],

                    onChanged: (value) {

                      setState(() {

                        customerFilter = value!;

                      });

                    },

                  ),

                  const SizedBox(height: 14),

                  Column(
                    children: [

                      Row(
                        children: [

                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: sortBy,

                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xffF5F7FB),

                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),

                              items: const [

                                DropdownMenuItem(
                                  value: "name",
                                  child: Text("Nama"),
                                ),

                                DropdownMenuItem(
                                  value: "created_at",
                                  child: Text("Terbaru"),
                                ),

                              ],

                              onChanged: (v) {
                                setState(() {
                                  sortBy = v!;
                                });
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          Container(
                            width: 72,
                            height: 52,

                            decoration: BoxDecoration(
                              color: const Color(0xffF5F7FB),
                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: Material(
                              color: Colors.transparent,

                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),

                                onTap: () {

                                  setState(() {
                                    orderBy =
                                        orderBy == "asc"
                                            ? "desc"
                                            : "asc";
                                  });

                                  loadCustomers(); // optional langsung refresh
                                },

                                child: Center(
                                  child: Text(
                                    orderBy == "asc"
                                        ? "A  Z"
                                        : "Z  A",

                                    style: const TextStyle(
                                      color: Color(0xff4F6EF7),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [

                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {

                                searchController.clear();

                                setState(() {
                                  sortBy = "name";
                                  orderBy = "asc";
                                  customerFilter = "all";
                                });

                                loadCustomers();
                              },

                              child: const Text(
                                "Reset",
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton.icon(

                              onPressed: loadCustomers,

                              icon: const Icon(
                                Icons.filter_alt,
                              ),

                              label: const Text(
                                "Filter",
                              ),

                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(
                                  0xff4F6EF7,
                                ),
                                foregroundColor:
                                    Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),

                    ],
                  )

                ],

              ),

            ),

            const SizedBox(height: 20),

            if(isLoading)

              const Center(
                child:
                CircularProgressIndicator(),
              )

            else if(filteredCustomers.isEmpty)

              Container(

                height: 350,

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(20),

                ),

                child: Column(

                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children:[

                    Icon(

                      Icons.people,

                      size: 80,

                      color:
                      Colors.blue.shade100,

                    ),

                    const SizedBox(height: 16),

                    const Text(

                      "Belum Ada Pelanggan",

                      style: TextStyle(

                        fontSize: 22,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),

                    const SizedBox(height: 8),

                    Text(

                      "Pelanggan akan muncul setelah mereka melakukan transaksi.",

                      style: TextStyle(
                        color:
                        Colors.grey.shade600,
                      ),

                    )

                  ],

                ),

              )

            else

            ...filteredCustomers.map(
              (item) => Container(
              margin: const EdgeInsets.only(
                bottom: 14,
              ),

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // HEADER CUSTOMER
                  Row(
                    children: [

                      CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            Colors.blue.shade100,
                        child: Text(
                          item.name
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Row(
                              children: [

                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),

                                  decoration: BoxDecoration(

                                    color: !item.isGuest
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,

                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),

                                  child: Text(

                                    !item.isGuest
                                        ? "MEMBER"
                                        : "NON MEMBER",

                                    style: TextStyle(

                                      fontSize: 11,

                                      fontWeight:
                                          FontWeight.bold,

                                      color:
                                          !item.isGuest
                                              ? Colors.green
                                              : Colors.orange,

                                    ),
                                  ),
                                ),

                              ],
                            ),
                            const SizedBox(height: 4),

                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item.phone,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Row(
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item.email,
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CustomerDetailScreen(
                                customer: item,
                              ),
                            ),
                          );

                        },
                        icon: const Icon(
                          Icons.visibility_outlined,
                          color: Color(0xff4F6EF7),
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 16),

                  // STATISTIK
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 10,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xffF5F7FB),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),

                    child: Row(
                      children: [

                        Expanded(
                          child: _buildStat(
                            "Transaksi",
                            "${item.transactionCount}",
                          ),
                        ),

                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),

                        Expanded(
                          child: _buildStat(
                            "Belanja",
                            "Rp ${item.totalSpent.round()}",
                          ),
                        ),

                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),

                        Expanded(
                          child: _buildStat(
                            "Pending",
                            "${item.pendingPickups}",
                          ),
                        ),

                      ],
                    ),
                  ),

                ],
              ),
            ),
            ),
          ],

        ),

      ),

    );

  }

}