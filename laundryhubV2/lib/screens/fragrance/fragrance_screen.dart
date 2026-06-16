import 'package:flutter/material.dart';

import '../../models/fragrance_model.dart';
import '../../services/fragrance_service.dart';
import 'add_fragrance_screen.dart';
import 'edit_fragrance_screen.dart';

class FragranceScreen extends StatefulWidget {
  const FragranceScreen({super.key});

  @override
  State<FragranceScreen> createState() =>
      _FragranceScreenState();
}

class _FragranceScreenState
    extends State<FragranceScreen> {

  final FragranceService
  fragranceService =
      FragranceService();

  bool isLoading = true;

  List<FragranceModel>
  fragrances = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

    setState(() {
      isLoading = true;
    });

    final result =
        await fragranceService
            .getFragrances();

    if(result["success"]){

      fragrances =
      result["fragrances"];

    }

    setState(() {
      isLoading = false;
    });

  }

  Color getColor(String color){

    switch(color){

      case "green":
        return Colors.green;

      case "yellow":
        return Colors.orange;

      case "red":
        return Colors.red;

      case "purple":
        return Colors.purple;

      case "pink":
        return Colors.pink;

      case "indigo":
        return Colors.indigo;

      case "gray":
        return Colors.grey;

      default:
        return Colors.blue;

    }

  }

  Future<void> deleteFragrance(
      FragranceModel item) async {

    final confirm =
    await showDialog<bool>(

      context: context,

      builder: (_) {

        return AlertDialog(

          title:
          const Text(
            "Hapus Pewangi",
          ),

          content:
          Text(
            "Yakin ingin menghapus '${item.name}' ?",
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                  context,
                  false,
                );

              },

              child:
              const Text(
                "Batal",
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

              child:
              const Text(
                "Hapus",
              ),

            ),

          ],

        );

      },

    );

    if(confirm != true){
      return;
    }

    try{

      await fragranceService
          .deleteFragrance(
        item.id,
      );

      if(mounted){

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content:
            Text(
              "${item.name} berhasil dihapus",
            ),

            backgroundColor:
            Colors.red,

          ),

        );

      }

      loadData();

    }catch(e){

      if(mounted){

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content:
            Text(
              "Gagal menghapus pewangi",
            ),

          ),

        );

      }

    }

  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xffF5F7FB),

      appBar: AppBar(

        backgroundColor:
        Colors.white,

        elevation: 0,

        centerTitle: true,

        title: const Text(

          "Manajemen Pewangi",

          style: TextStyle(

            color: Colors.black,

            fontWeight:
            FontWeight.bold,

          ),

        ),

      ),

      floatingActionButton:

      FloatingActionButton.extended(

        backgroundColor:
        const Color(0xff4CAF50),

        onPressed: () async {

          final result =

          await Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
              const AddFragranceScreen(),

            ),

          );

          if(result == true){

            loadData();

            if(mounted){

              ScaffoldMessenger.of(context)
                  .showSnackBar(

                const SnackBar(

                  content:
                  Text(
                    "Pewangi berhasil ditambahkan",
                  ),

                  backgroundColor:
                  Colors.green,

                ),

              );

            }

          }

        },

        icon:
        const Icon(Icons.add),

        label:
        const Text(
          "Tambah Pewangi",
        ),

      ),

      body:

      isLoading

          ?

      const Center(
        child:
        CircularProgressIndicator(),
      )

          :

      fragrances.isEmpty

          ?

      Center(

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Icon(

              Icons.spa,

              size: 90,

              color:
              Colors.grey.shade300,

            ),

            const SizedBox(
              height: 15,
            ),

            const Text(

              "Belum Ada Pewangi",

              style: TextStyle(

                fontSize: 20,

                fontWeight:
                FontWeight.bold,

              ),

            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              "Tambahkan pewangi pertama",
            )

          ],

        ),

      )

          :

      RefreshIndicator(

        onRefresh: loadData,

        child: LayoutBuilder(

          builder:
              (context,constraints){

            final crossAxisCount =

            constraints.maxWidth > 900

                ?

            3

                :

            constraints.maxWidth > 600

                ?

            2

                :

            1;

            return GridView.builder(

              padding:
              const EdgeInsets.all(16),

              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(

                crossAxisCount:
                crossAxisCount,

                crossAxisSpacing:
                16,

                mainAxisSpacing:
                16,

                childAspectRatio:
                2.2,

              ),

              itemCount:
              fragrances.length,

              itemBuilder:
                  (context,index){

                final item =
                fragrances[index];

                return Container(

                  padding:
                  const EdgeInsets.all(16),

                  decoration:
                  BoxDecoration(

                    color:
                    Colors.white,

                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),

                    boxShadow:[

                      BoxShadow(

                        color:
                        Colors.black
                            .withOpacity(
                          .05,
                        ),

                        blurRadius:10,

                      )

                    ],

                  ),

                  child: Column(

                    children:[

                      Row(

                        children:[

                          Container(

                            width:55,
                            height:55,

                            decoration:
                            BoxDecoration(

                              color:

                              getColor(
                                item.color,
                              ).withOpacity(
                                .1,
                              ),

                              borderRadius:
                              BorderRadius.circular(
                                15,
                              ),

                            ),

                            child: Icon(

                              Icons.spa,

                              color:
                              getColor(
                                item.color,
                              ),

                            ),

                          ),

                          const SizedBox(
                            width:12,
                          ),

                          Expanded(

                            child: Column(

                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children:[

                                Text(

                                  item.name,

                                  maxLines:1,

                                  overflow:
                                  TextOverflow
                                      .ellipsis,

                                  style:
                                  const TextStyle(

                                    fontSize:18,

                                    fontWeight:
                                    FontWeight.bold,

                                  ),

                                ),

                                const SizedBox(
                                  height:4,
                                ),

                                Text(
                                  item.color,
                                ),

                              ],

                            ),

                          ),

                          Container(

                            padding:
                            const EdgeInsets.symmetric(

                              horizontal:10,
                              vertical:4,

                            ),

                            decoration:
                            BoxDecoration(

                              color:

                              item.isActive

                                  ?

                              Colors.green
                                  .shade100

                                  :

                              Colors.grey
                                  .shade200,

                              borderRadius:
                              BorderRadius.circular(
                                20,
                              ),

                            ),

                            child: Text(

                              item.isActive

                                  ?

                              "Aktif"

                                  :

                              "Nonaktif",

                              style:
                              TextStyle(

                                color:

                                item.isActive

                                    ?

                                Colors.green

                                    :

                                Colors.black54,

                                fontSize:12,

                              ),

                            ),

                          )

                        ],

                      ),

                      const Spacer(),

                      Row(

                        children:[

                          Switch(

                            value:
                            item.isActive,

                            activeColor:
                            Colors.green,

                            onChanged:
                                (_) async {

                              await fragranceService
                                  .toggleFragrance(
                                item.id,
                              );

                              loadData();

                            },

                          ),

                          const Spacer(),

                          IconButton(

                            onPressed:
                                () async {

                              final result =

                              await Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder: (_) =>

                                      EditFragranceScreen(
                                        fragrance:item,
                                      ),

                                ),

                              );

                              if(result == true){

                                loadData();

                              }

                            },

                            icon:
                            const Icon(

                              Icons.edit,

                              color:
                              Colors.blue,

                            ),

                          ),

                          IconButton(

                            onPressed:(){

                              deleteFragrance(
                                item,
                              );

                            },

                            icon:
                            const Icon(

                              Icons.delete,

                              color:
                              Colors.red,

                            ),

                          ),

                        ],

                      )

                    ],

                  ),

                );

              },

            );

          },

        ),

      ),

    );

  }

}