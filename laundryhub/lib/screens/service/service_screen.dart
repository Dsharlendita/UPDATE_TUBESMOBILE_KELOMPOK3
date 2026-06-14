import 'package:flutter/material.dart';

import '../../models/service_model.dart';
import '../../services/service_service.dart';
import 'add_service_screen.dart';
import 'package:intl/intl.dart';

class ServiceScreen extends StatefulWidget {

  const ServiceScreen({
    super.key,
  });

  @override
  State<ServiceScreen> createState() =>
      _ServiceScreenState();

}

class _ServiceScreenState
    extends State<ServiceScreen> {

  final ServiceService service =
      ServiceService();

  final TextEditingController
  searchController =
      TextEditingController();

  final currencyFormatter =
    NumberFormat('#,##0', 'id_ID');

  bool loading = true;

  List<ServiceModel>
  services = [];

  Map stats = {};

  String selectedStatus =
      "Semua Status";

  @override
  void initState() {

    super.initState();

    loadData();

  }

  Future loadData() async {

    setState(() {
      loading = true;
    });

    String? status;

    if(selectedStatus ==
        "Aktif"){

      status = "active";

    }else if(selectedStatus ==
        "Nonaktif"){

      status = "inactive";

    }

    final result =
    await service.getServices(

      search:
      searchController.text,

      status:
      status,

    );

    if (result["success"]) {

      services = result["services"] ?? [];

      stats = result["stats"] ?? {
        "total": 0,
        "active": 0,
        "inactive": 0,
        "avg_price": 0,
      };

    }

    setState(() {
      loading = false;
    });

  }

  Color getStatusColor(bool active){

    return active
        ? Colors.green
        : Colors.orange;

  }

  String getStatusText(bool active){

    return active
        ? "Aktif"
        : "Nonaktif";

  }

  IconData getIcon(String icon){

    switch(icon){

      case "bolt":
        return Icons.flash_on;

      case "wind":
        return Icons.air;

      case "water":
        return Icons.water_drop;

      case "temperature-high":
        return Icons.local_fire_department;

      case "clock":
        return Icons.access_time;

      case "star":
        return Icons.star;

      default:
        return Icons.checkroom;

    }

  }

  Widget statCard({

    required String title,
    required String value,
    required Color color,
    required IconData icon,

  }){

    return Container(

      padding:
      const EdgeInsets.all(18),

      decoration:
      BoxDecoration(

        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(20),

      ),

      child:
      Row(

        children:[

          Container(

            padding:
            const EdgeInsets.all(14),

            decoration:
            BoxDecoration(

              color:
              color.withOpacity(.12),

              borderRadius:
              BorderRadius.circular(16),

            ),

            child:
            Icon(

              icon,

              color:
              color,

              size:24,

            ),

          ),

          const SizedBox(width:14),

          Expanded(

            child:
            Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              mainAxisAlignment:
              MainAxisAlignment.center,

              children:[

                Text(

                  title,

                  style:
                  TextStyle(

                    color:
                    Colors.grey[600],

                    fontSize:13,

                  ),

                ),

                const SizedBox(height:5),

                FittedBox(

                  fit: BoxFit.scaleDown,

                  alignment: Alignment.centerLeft,

                  child:
                  Text(

                    value,

                    maxLines: 1,

                    style:
                    TextStyle(

                      fontSize: 22,

                      fontWeight:
                      FontWeight.bold,

                      color: color,

                    ),

                  ),

                ),

              ],

            ),

          )

        ],

      ),

    );

  }

  Widget serviceCard(
      ServiceModel item){

    return Container(

      margin:
      const EdgeInsets.only(
          bottom:16),

      decoration:
      BoxDecoration(

        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(22),

      ),

      child:
      Column(

        children:[

          Padding(

            padding:
            const EdgeInsets.all(18),

            child:
            Row(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children:[

                Container(

                  padding:
                  const EdgeInsets.all(14),

                  decoration:
                  BoxDecoration(

                    color:
                    Colors.indigo
                        .withOpacity(.12),

                    borderRadius:
                    BorderRadius.circular(16),

                  ),

                  child:
                  Icon(

                    getIcon(item.icon),

                    color:
                    Colors.indigo,

                  ),

                ),

                const SizedBox(width:14),

                Expanded(

                  child:
                  Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children:[

                      Row(

                        children:[

                          Expanded(

                            child:
                            Text(

                              item.name,

                              style:
                              const TextStyle(

                                fontSize:18,

                                fontWeight:
                                FontWeight.bold,

                              ),

                            ),

                          ),

                          Container(

                            padding:
                            const EdgeInsets.symmetric(

                              horizontal:12,
                              vertical:6,

                            ),

                            decoration:
                            BoxDecoration(

                              color:
                              getStatusColor(
                                  item.isActive
                              ).withOpacity(.12),

                              borderRadius:
                              BorderRadius.circular(
                                  20),

                            ),

                            child:
                            Text(

                              getStatusText(
                                  item.isActive
                              ),

                              style:
                              TextStyle(

                                color:
                                getStatusColor(
                                    item.isActive
                                ),

                                fontWeight:
                                FontWeight.w600,

                                fontSize:12,

                              ),

                            ),

                          ),

                        ],

                      ),

                      const SizedBox(height:5),

                      Text(

                        "${item.estimatedDays} hari pengerjaan",

                        style:
                        TextStyle(

                          color:
                          Colors.grey[600],

                          fontSize:13,

                        ),

                      ),

                      const SizedBox(height:14),

                      Text(

                        "Rp ${item.pricePerKg.toStringAsFixed(0)} /kg",

                        style:
                        const TextStyle(

                          fontSize:24,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),

                      const SizedBox(height:10),

                      Text(

                        item.description
                            .isEmpty

                            ?

                        "Tidak ada deskripsi"

                            :

                        item.description,

                        style:
                        TextStyle(

                          color:
                          Colors.grey[600],

                        ),

                      ),

                    ],

                  ),

                ),

              ],

            ),

          ),

          Divider(
            color:
            Colors.grey.shade200,
            height:1,
          ),

          Padding(

            padding:
            const EdgeInsets.symmetric(

              horizontal:18,
              vertical:14,

            ),

            child:
            Row(

              children:[

                InkWell(

                  onTap:() async {

                    await service
                        .toggleService(
                        item.id);

                    loadData();

                  },

                  child:
                  Row(

                    children:[

                      Icon(

                        Icons
                            .radio_button_checked,

                        size:14,

                        color:
                        Colors.orange,

                      ),

                      const SizedBox(width:5),

                      Text(

                        item.isActive

                            ?

                        "Nonaktifkan"

                            :

                        "Aktifkan",

                        style:
                        const TextStyle(

                          color:
                          Colors.orange,

                        ),

                      ),

                    ],

                  ),

                ),

                const Spacer(),

                IconButton(

                  onPressed: () async {

                    final result = await Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) => AddServiceScreen(
                          service: item,
                        ),

                      ),

                    );

                    if(result == true){
                      loadData();
                    }

                  },

                  icon: const Icon(
                    Icons.edit,
                    color: Colors.indigo,
                  ),

                ),

                IconButton(

                  onPressed: () async {

                    final confirm =
                        await showDialog<bool>(

                      context: context,

                      builder: (context) {

                        return AlertDialog(

                          shape:
                              RoundedRectangleBorder(

                            borderRadius:
                                BorderRadius.circular(20),

                          ),

                          title: const Text(
                            "Konfirmasi Hapus",
                          ),

                          content: Text(
                            "Apakah Anda yakin ingin menghapus layanan \"${item.name}\" ?",
                          ),

                          actions: [

                            TextButton(

                              onPressed: () {

                                Navigator.pop(
                                  context,
                                  false,
                                );

                              },

                              child: const Text(
                                "Tidak",
                              ),

                            ),

                            ElevatedButton(

                              style:
                                  ElevatedButton.styleFrom(

                                backgroundColor:
                                    Colors.red,

                                foregroundColor:
                                    Colors.white,

                              ),

                              onPressed: () {

                                Navigator.pop(
                                  context,
                                  true,
                                );

                              },

                              child: const Text(
                                "Iya",
                              ),

                            ),

                          ],

                        );

                      },

                    );

                    if (confirm != true) {
                      return;
                    }

                    await service.deleteService(
                      item.id,
                    );

                    loadData();

                    if (context.mounted) {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(

                        SnackBar(

                          content: Text(
                            "Layanan \"${item.name}\" berhasil dihapus",
                          ),

                        ),

                      );

                    }

                  },

                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),

                ),

              ],

            ),

          )

        ],

      ),

    );

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      backgroundColor:
      const Color(0xfff5f7fb),

      appBar:
      AppBar(

        backgroundColor:
        Colors.white,

        elevation:0,

        leading:
        IconButton(

          onPressed:(){

            Navigator.pop(context);

          },

          icon:
          const Icon(

            Icons.arrow_back,

            color:Colors.black,

          ),

        ),

        title:
        const Text(

          "Manajemen Layanan",

          style:
          TextStyle(

            color:
            Colors.black,

            fontWeight:
            FontWeight.bold,

          ),

        ),

      ),

      floatingActionButton:
      FloatingActionButton.extended(

        backgroundColor:
        Colors.green,

        onPressed:() async {

          await Navigator.push(

            context,

            MaterialPageRoute(

              builder:(_)=>
              const AddServiceScreen(),

            ),

          );

          loadData();

        },

        icon:
        const Icon(Icons.add),

        label:
        const Text("Tambah"),

      ),

      body:

      loading

      ?

      const Center(
        child:
        CircularProgressIndicator(),
      )

      :

      RefreshIndicator(

        onRefresh:() async {

          loadData();

        },

        child:
        SingleChildScrollView(

          physics:
          const AlwaysScrollableScrollPhysics(),

          padding:
          const EdgeInsets.all(16),

          child:
          Column(

            children:[
              

              /// STATS
              GridView.count(

                shrinkWrap:true,

                physics:
                const NeverScrollableScrollPhysics(),

                crossAxisCount:2,

                childAspectRatio:1.15,

                crossAxisSpacing:14,

                mainAxisSpacing:14,

                children:[

                  statCard(

                    title:
                    "Total Layanan",

                    value:
                    "${stats["total"] ?? 0}",

                    color:
                    Colors.indigo,

                    icon:
                    Icons.checkroom,

                  ),

                  statCard(

                    title:
                    "Aktif",

                    value:
                    "${stats["active"] ?? 0}",

                    color:
                    Colors.green,

                    icon:
                    Icons.check_circle,

                  ),

                  statCard(

                    title:
                    "Nonaktif",

                    value:
                    "${stats["inactive"] ?? 0}",

                    color:
                    Colors.black54,

                    icon:
                    Icons.pause_circle,

                  ),

                  statCard(

                    title: "Rata-rata Harga",

                    value:
                    "Rp ${currencyFormatter.format(
                      num.tryParse(
                        stats["avg_price"]?.toString() ?? "0",
                      ) ?? 0,
                    )}",

                    color: Colors.deepPurple,

                    icon: Icons.sell,

                  ),

                ],

              ),

              const SizedBox(height:20),

              /// FILTER
              Container(

                padding:
                const EdgeInsets.all(16),

                decoration:
                BoxDecoration(

                  color:
                  Colors.white,

                  borderRadius:
                  BorderRadius.circular(22),

                ),

                child:
                Column(

                  children:[

                    TextField(

                      controller:
                      searchController,

                      decoration:
                      InputDecoration(

                        hintText:
                        "Cari layanan...",

                        prefixIcon:
                        const Icon(Icons.search),

                        filled:true,

                        fillColor:
                        Colors.grey[100],

                        border:
                        OutlineInputBorder(

                          borderRadius:
                          BorderRadius.circular(16),

                          borderSide:
                          BorderSide.none,

                        ),

                      ),

                    ),

                    const SizedBox(height:16),

                    DropdownButtonFormField<String>(

                      value:
                      selectedStatus,

                      decoration:
                      InputDecoration(

                        filled:true,

                        fillColor:
                        Colors.grey[100],

                        border:
                        OutlineInputBorder(

                          borderRadius:
                          BorderRadius.circular(16),

                          borderSide:
                          BorderSide.none,

                        ),

                      ),

                      items:[

                        "Semua Status",
                        "Aktif",
                        "Nonaktif",

                      ].map((e){

                        return DropdownMenuItem(

                          value:e,

                          child:Text(e),

                        );

                      }).toList(),

                      onChanged:(v){

                        setState(() {

                          selectedStatus =
                          v!;

                        });

                      },

                    ),

                    const SizedBox(height:16),

                    Row(

                      children:[

                        Expanded(

                          child:
                          OutlinedButton(

                            style:
                            OutlinedButton.styleFrom(

                              minimumSize:
                              const Size(
                                double.infinity,
                                52,
                              ),

                              shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                BorderRadius.circular(
                                    16),

                              ),

                            ),

                            onPressed:(){

                              searchController.clear();

                              setState(() {

                                selectedStatus =
                                "Semua Status";

                              });

                              loadData();

                            },

                            child:
                            const Text(

                              "Reset",

                              style:
                              TextStyle(
                                fontSize:16,
                              ),

                            ),

                          ),

                        ),

                        const SizedBox(width:12),

                        Expanded(

                          child:
                          ElevatedButton.icon(

                            style:
                            ElevatedButton.styleFrom(

                              backgroundColor:
                              Colors.indigo,

                              minimumSize:
                              const Size(
                                double.infinity,
                                52,
                              ),

                              shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                BorderRadius.circular(
                                    16),

                              ),

                            ),

                            onPressed:
                            loadData,

                            icon:
                            const Icon(
                                Icons.filter_alt),

                            label:
                            const Text(

                              "Filter",

                              style:
                              TextStyle(
                                fontSize:16,
                              ),

                            ),

                          ),

                        ),

                      ],

                    ),

                  ],

                ),

              ),

              const SizedBox(height:20),

              services.isEmpty

                  ?

              Container(

                width: double.infinity,

                padding:
                const EdgeInsets.symmetric(
                  vertical:80,
                ),

                decoration:
                BoxDecoration(

                  color:
                  Colors.white,

                  borderRadius:
                  BorderRadius.circular(24),

                ),

                child:
                Column(

                  children:[

                    Icon(

                      Icons.inventory_2_outlined,

                      size:70,

                      color:
                      Colors.grey.shade300,

                    ),

                    const SizedBox(height:18),

                    const Text(

                      "Belum ada layanan",

                      style:
                      TextStyle(

                        fontSize:20,

                        fontWeight:
                        FontWeight.w600,

                      ),

                    ),

                  ],

                ),

              )

                  :

              ListView.builder(

                shrinkWrap:true,

                physics:
                const NeverScrollableScrollPhysics(),

                itemCount:
                services.length,

                itemBuilder:
                    (context,index){

                  return serviceCard(
                      services[index]);

                },

              ),

              const SizedBox(height:90),

            ],

          ),

        ),

      ),

    );

  }

}