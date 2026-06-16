import 'package:flutter/material.dart';

import '../../models/customer_model.dart';
import '../../services/customer_service.dart';

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

  String sortBy = "name";
  String orderBy = "asc";

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

    if(result["success"]){

      customers =
      result["customers"];

      stats =
      result["stats"];

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

        padding:
        const EdgeInsets.all(16),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
          BorderRadius.circular(16),

        ),

        child: Row(

          children:[

            Container(

              padding:
              const EdgeInsets.all(12),

              decoration: BoxDecoration(

                color:
                color.withOpacity(.1),

                borderRadius:
                BorderRadius.circular(12),

              ),

              child: Icon(
                icon,
                color: color,
              ),

            ),

            const SizedBox(width: 12),

            Expanded(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children:[

                  Text(

                    title,

                    style: TextStyle(

                      color:
                      Colors.grey.shade600,

                      fontSize: 12,

                    ),

                  ),

                  const SizedBox(height: 4),

                  Text(

                    "$value",

                    style: TextStyle(

                      fontSize: 22,

                      fontWeight:
                      FontWeight.bold,

                      color: color,

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

  @override
  Widget build(BuildContext context) {

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

                    controller:
                    searchController,

                    decoration:
                    InputDecoration(

                      hintText:
                      "Cari nama, telepon, atau email pelanggan...",

                      prefixIcon:
                      const Icon(Icons.search),

                      filled:true,

                      fillColor:
                      Colors.white,

                      border:
                      OutlineInputBorder(

                        borderRadius:
                        BorderRadius.circular(14),

                      ),

                    ),

                  ),

                  const SizedBox(height: 14),

                  Row(

                    children:[

                      Expanded(

                        child:
                        DropdownButtonFormField(

                          value: sortBy,

                          decoration:
                          InputDecoration(

                            filled:true,

                            fillColor:
                            Colors.white,

                            border:
                            OutlineInputBorder(

                              borderRadius:
                              BorderRadius.circular(14),

                            ),

                          ),

                          items:[

                            const DropdownMenuItem(

                              value:"name",

                              child:
                              Text("Nama"),

                            ),

                            const DropdownMenuItem(

                              value:"created_at",

                              child:
                              Text("Terbaru"),

                            ),

                          ],

                          onChanged:(v){

                            setState(() {
                              sortBy = v!;
                            });

                          },

                        ),

                      ),

                      const SizedBox(width: 10),

                      IconButton(

                        onPressed:(){

                          setState(() {

                            orderBy =
                            orderBy == "asc"
                                ? "desc"
                                : "asc";

                          });

                        },

                        icon: Icon(

                          orderBy == "asc"

                              ?

                          Icons.sort_by_alpha

                              :

                          Icons.sort,

                        ),

                      ),

                      ElevatedButton.icon(

                        onPressed:(){
                          loadCustomers();
                        },

                        icon:
                        const Icon(Icons.filter_alt),

                        label:
                        const Text("Filter"),

                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          const Color(0xff4F6EF7),

                          foregroundColor:
                          Colors.white,

                          padding:
                          const EdgeInsets.symmetric(

                            horizontal:18,
                            vertical:16,

                          ),

                        ),

                      ),

                      const SizedBox(width: 10),

                      OutlinedButton(

                        onPressed:(){

                          searchController.clear();

                          sortBy = "name";
                          orderBy = "asc";

                          loadCustomers();

                        },

                        child:
                        const Text("Reset"),

                      )

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

            else if(customers.isEmpty)

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

              ...customers.map(

                    (item)=>

                    Container(

                      margin:
                      const EdgeInsets.only(
                        bottom: 14,
                      ),

                      padding:
                      const EdgeInsets.all(16),

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius:
                        BorderRadius.circular(18),

                      ),

                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children:[

                          Row(

                            children:[

                              CircleAvatar(

                                radius: 28,

                                backgroundColor:
                                Colors.blue.shade100,

                                child: Text(

                                  item.name
                                      .substring(0,1)
                                      .toUpperCase(),

                                  style:
                                  const TextStyle(

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

                                  children:[

                                    Text(

                                      item.name,

                                      style:
                                      const TextStyle(

                                        fontSize: 18,

                                        fontWeight:
                                        FontWeight.bold,

                                      ),

                                    ),

                                    const SizedBox(height: 4),

                                    Text(item.phone),

                                    Text(item.email),

                                  ],

                                ),

                              ),

                            ],

                          ),

                          const SizedBox(height: 14),

                          Container(

                            padding:
                            const EdgeInsets.all(14),

                            decoration: BoxDecoration(

                              color:
                              const Color(0xffF5F7FB),

                              borderRadius:
                              BorderRadius.circular(14),

                            ),

                            child: Row(

                              children:[

                                Expanded(

                                  child: Column(

                                    children:[

                                      const Text(
                                        "Transaksi",
                                      ),

                                      const SizedBox(height: 4),

                                      Text(

                                        "${item.transactionCount}",

                                        style:
                                        const TextStyle(

                                          fontSize: 18,

                                          fontWeight:
                                          FontWeight.bold,

                                        ),

                                      ),

                                    ],

                                  ),

                                ),

                                Expanded(

                                  child: Column(

                                    children:[

                                      const Text(
                                        "Total Belanja",
                                      ),

                                      const SizedBox(height: 4),

                                      Text(

                                        "Rp ${item.totalSpent.toStringAsFixed(0)}",

                                        style:
                                        const TextStyle(

                                          fontSize: 18,

                                          fontWeight:
                                          FontWeight.bold,

                                        ),

                                      ),

                                    ],

                                  ),

                                ),

                                Expanded(

                                  child: Column(

                                    children:[

                                      const Text(
                                        "Pickup Pending",
                                      ),

                                      const SizedBox(height: 4),

                                      Text(

                                        "${item.pendingPickups}",

                                        style:
                                        const TextStyle(

                                          fontSize: 18,

                                          fontWeight:
                                          FontWeight.bold,

                                        ),

                                      ),

                                    ],

                                  ),

                                ),

                              ],

                            ),

                          )

                        ],

                      ),

                    ),

              )

          ],

        ),

      ),

    );

  }

}