import 'package:flutter/material.dart';
import '../../services/service_service.dart';
import '../../models/service_model.dart';
import 'package:intl/intl.dart';

class AddServiceScreen extends StatefulWidget {

  final ServiceModel? service;

  const AddServiceScreen({
    super.key,
    this.service,
  });

  bool get isEdit => service != null;

  @override
  State<AddServiceScreen> createState()
      => _AddServiceScreenState();
}

class _AddServiceScreenState
    extends State<AddServiceScreen> {

  final ServiceService service =
      ServiceService();

  final TextEditingController
  nameController =
      TextEditingController();

  final currencyFormatter =
    NumberFormat('#,##0', 'id_ID');

  final TextEditingController
  descriptionController =
      TextEditingController();

  final TextEditingController
  priceController =
      TextEditingController();

  final TextEditingController
  durationController =
      TextEditingController(
          text:"2");

  bool isLoading = false;

  String selectedIcon =
      "shirt";

  @override
  void initState() {

    super.initState();

    if(widget.isEdit){

      nameController.text =
          widget.service!.name;

      descriptionController.text =
          widget.service!.description;

      priceController.text =
          widget.service!.pricePerKg
              .toInt()
              .toString();

      durationController.text =
          widget.service!.estimatedDays
              .toString();

      selectedIcon =
          widget.service!.icon;
    }

  }
  final List<Map<String,dynamic>>
  icons=[

    {
      "key":"shirt",
      "icon":Icons.checkroom,
      "label":"Baju"
    },

    {
      "key":"wind",
      "icon":Icons.air,
      "label":"Angin"
    },

    {
      "key":"iron",
      "icon":Icons.iron,
      "label":"Setrika"
    },

    {
      "key":"bolt",
      "icon":Icons.flash_on,
      "label":"Kilat"
    },

    {
      "key":"clock",
      "icon":Icons.access_time,
      "label":"Jam"
    },

    {
      "key":"star",
      "icon":Icons.star,
      "label":"Bintang"
    },

    {
      "key":"water",
      "icon":Icons.water,
      "label":"Air"
    },

    {
      "key":"snow",
      "icon":Icons.ac_unit,
      "label":"Salju"
    },

    {
      "key":"fire",
      "icon":
      Icons.local_fire_department,
      "label":"Api"
    },

    {
      "key":"leaf",
      "icon":Icons.eco,
      "label":"Daun"
    },

  ];

  IconData currentPreviewIcon(){

    final item=
    icons.firstWhere(

      (e)=>
      e["key"]==
          selectedIcon,

    );

    return item["icon"];

  }

  Future<void> submitService() async {

    if(nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        durationController.text.isEmpty){

      return;
    }

    setState(() {
      isLoading = true;
    });

    Map<String,dynamic> result;

    if(widget.isEdit){

      result =
      await service.updateService(

        id:
        widget.service!.id,

        name:
        nameController.text,

        description:
        descriptionController.text,

        price: double.parse(
          priceController.text
              .replaceAll(".", "")
              .replaceAll(",", ""),
        ),

        estimatedDays:
        int.parse(
            durationController.text),

        icon:
        selectedIcon,

      );

    }else{

      result =
      await service.createService(

        name:
        nameController.text,

        description:
        descriptionController.text,

        price: double.parse(
          priceController.text
              .replaceAll(".", "")
              .replaceAll(",", ""),
        ),

        estimatedDays:
        int.parse(
            durationController.text),

        icon:
        selectedIcon,

      );

    }

    setState(() {
      isLoading = false;
    });

    if(result["success"]){

      Navigator.pop(context,true);

    }
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
        Text(

          widget.isEdit

              ?

          "Edit Layanan"

              :

          "Tambah Layanan Baru",

        ),

      ),

      body:
      SingleChildScrollView(

        padding:
        const EdgeInsets.all(16),

        child:
        Column(

          children:[

            /// INFORMASI
            Container(

              width:double.infinity,

              padding:
              const EdgeInsets.all(18),

              decoration:
              BoxDecoration(

                color:Colors.white,

                borderRadius:
                BorderRadius.circular(20),

              ),

              child:
              Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children:[

                  const Text(

                    "Informasi Layanan",

                    style:TextStyle(

                      fontWeight:
                      FontWeight.bold,

                      fontSize:18,

                    ),

                  ),

                  const SizedBox(height:18),

                  const Text(
                    "Nama Layanan *",
                  ),

                  const SizedBox(height:8),

                  TextField(

                    controller:
                    nameController,

                    onChanged:(_){
                      setState(() {});
                    },

                    decoration:
                    InputDecoration(

                      hintText:
                      "Contoh: Cuci Kering, Cuci Setrika, Express...",

                      filled:true,

                      fillColor:
                      Colors.grey[100],

                      border:
                      OutlineInputBorder(

                        borderRadius:
                        BorderRadius.circular(
                            14),

                        borderSide:
                        BorderSide.none,

                      ),

                    ),

                  ),

                  const SizedBox(height:18),

                  const Text(
                    "Deskripsi Layanan",
                  ),

                  const SizedBox(height:8),

                  TextField(

                    controller:
                    descriptionController,

                    maxLines:4,

                    decoration:
                    InputDecoration(

                      hintText:
                      "Jelaskan detail layanan ini...",

                      filled:true,

                      fillColor:
                      Colors.grey[100],

                      border:
                      OutlineInputBorder(

                        borderRadius:
                        BorderRadius.circular(
                            14),

                        borderSide:
                        BorderSide.none,

                      ),

                    ),

                  ),

                  const SizedBox(height:6),

                  Text(

                    "Maksimal 500 karakter",

                    style:TextStyle(

                      color:
                      Colors.grey[500],

                      fontSize:12,

                    ),

                  ),

                ],

              ),

            ),

            const SizedBox(height:18),

            /// HARGA
            Container(

              width:double.infinity,

              padding:
              const EdgeInsets.all(18),

              decoration:
              BoxDecoration(

                color:Colors.white,

                borderRadius:
                BorderRadius.circular(20),

              ),

              child:
              Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children:[

                  const Text(

                    "Harga & Durasi",

                    style:TextStyle(

                      fontWeight:
                      FontWeight.bold,

                      fontSize:18,

                    ),

                  ),

                  const SizedBox(height: 18),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// HARGA
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const SizedBox(
                              height: 80,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Harga per Kilogram\n(Rp) *",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                            TextField(
                              controller: priceController,

                              onChanged: (_) {
                                setState(() {});
                              },

                              keyboardType: TextInputType.number,

                              decoration: InputDecoration(

                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(
                                    left: 14,
                                    right: 8,
                                  ),
                                  child: Center(
                                    widthFactor: 1,
                                    child: Text(
                                      "Rp",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),

                                prefixIconConstraints:
                                    const BoxConstraints(
                                  minWidth: 50,
                                ),

                                hintText: "5000",

                                filled: true,
                                fillColor: Colors.grey.shade100,

                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            SizedBox(
                              height: 40,
                              child: Text(
                                "Masukkan harga dalam Rupiah per kilogram",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 14),

                      /// DURASI
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const SizedBox(
                              height: 80,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Estimasi Pengerjaan\n(hari) *",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                            TextField(
                              controller: durationController,

                              onChanged: (_) {
                                setState(() {});
                              },

                              keyboardType: TextInputType.number,

                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade100,

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            SizedBox(
                              height: 40,
                              child: Text(
                                "1-30 hari",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

              ),

            ),

            const SizedBox(height:18),

            /// ICON
            Container(

              width:double.infinity,

              padding:
              const EdgeInsets.all(18),

              decoration:
              BoxDecoration(

                color:Colors.white,

                borderRadius:
                BorderRadius.circular(20),

              ),

              child:
              Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children:[

                  const Text(

                    "Pilih Icon",

                    style:TextStyle(

                      fontWeight:
                      FontWeight.bold,

                      fontSize:18,

                    ),

                  ),

                  const SizedBox(height:18),

                  GridView.builder(

                    shrinkWrap:true,

                    physics:
                    const NeverScrollableScrollPhysics(),

                    itemCount:
                    icons.length,

                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(

                      crossAxisCount:5,

                      mainAxisSpacing:12,

                      crossAxisSpacing:12,

                      childAspectRatio:.65,

                    ),

                    itemBuilder:
                        (context,index){

                      final item =
                      icons[index];

                      final active =
                      selectedIcon ==
                          item["key"];

                      return GestureDetector(

                        onTap:(){

                          setState(() {

                            selectedIcon =
                            item["key"];

                          });

                        },

                        child:
                        Container(

                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),

                          decoration:
                          BoxDecoration(

                            color:

                            active

                                ?

                            Colors.indigo
                                .withOpacity(.08)

                                :

                            Colors.white,

                            borderRadius:
                            BorderRadius.circular(14),

                            border:
                            Border.all(

                              color:

                              active

                                  ?

                              Colors.indigo

                                  :

                              Colors.grey.shade300,

                              width:
                              active
                                  ? 2
                                  : 1,

                            ),

                          ),

                          child:
                          Column(

                            mainAxisAlignment:
                            MainAxisAlignment.center,

                            children:[

                              Container(

                                padding:
                                const EdgeInsets.all(10),

                                decoration:
                                BoxDecoration(

                                  color:
                                  Colors.indigo
                                      .withOpacity(.10),

                                  borderRadius:
                                  BorderRadius.circular(
                                      10),

                                ),

                                child:
                                Icon(

                                  item["icon"],

                                  color:
                                  Colors.indigo,

                                  size:20,

                                ),

                              ),

                              const SizedBox(height:6),

                              Flexible(

                                child:
                                Text(

                                  item["label"],

                                  textAlign:
                                  TextAlign.center,

                                  maxLines: 2,

                                  overflow:
                                  TextOverflow.ellipsis,

                                  style:
                                  const TextStyle(

                                    fontSize:11,

                                  ),

                                ),

                              ),

                            ],

                          ),

                        ),

                      );

                    },

                  ),

                ],

              ),

            ),

            const SizedBox(height:18),

            /// PREVIEW
            Container(

              width:double.infinity,

              padding:
              const EdgeInsets.all(18),

              decoration:
              BoxDecoration(

                color:Colors.white,

                borderRadius:
                BorderRadius.circular(20),

              ),

              child:
              Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children:[

                  const Text(

                    "Preview Layanan",

                    style:TextStyle(

                      fontWeight:
                      FontWeight.bold,

                      fontSize:18,

                    ),

                  ),

                  const SizedBox(height:18),

                  Container(

                    width:250,

                    padding:
                    const EdgeInsets.all(14),

                    decoration:
                    BoxDecoration(

                      color:
                      Colors.grey[100],

                      borderRadius:
                      BorderRadius.circular(16),

                    ),

                    child:
                    Row(

                      children:[

                        Container(

                          padding:
                          const EdgeInsets.all(10),

                          decoration:
                          BoxDecoration(

                            color:
                            Colors.indigo
                                .withOpacity(.10),

                            borderRadius:
                            BorderRadius.circular(
                                12),

                          ),

                          child:
                          Icon(

                            currentPreviewIcon(),

                            color:
                            Colors.indigo,

                          ),

                        ),

                        const SizedBox(width:12),

                        Expanded(

                          child:
                          Column(

                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children:[

                              Text(

                                nameController
                                    .text
                                    .isEmpty

                                    ?

                                "Nama Layanan"

                                    :

                                nameController.text,

                                style:
                                const TextStyle(

                                  fontWeight:
                                  FontWeight.bold,

                                ),

                              ),

                              const SizedBox(height:3),

                              Text(

                                "${durationController.text} hari",

                                style:
                                TextStyle(

                                  color:
                                  Colors.grey[600],

                                  fontSize:12,

                                ),

                              ),

                              const SizedBox(height:10),

                              Row(

                                children:[

                                  Text(

                                    "Rp ${currencyFormatter.format(
                                      num.tryParse(
                                        priceController.text
                                            .replaceAll(".", "")
                                            .replaceAll(",", "")
                                            .isEmpty
                                            ? "5000"
                                            : priceController.text
                                                .replaceAll(".", "")
                                                .replaceAll(",", ""),
                                      ) ?? 5000
                                    )}",

                                    style: const TextStyle(

                                      fontWeight: FontWeight.bold,

                                      fontSize: 24,

                                    ),

                                  ),

                                  const Text(
                                      "/kg"),

                                ],

                              ),

                            ],

                          ),

                        ),

                      ],

                    ),

                  ),

                ],

              ),

            ),

            const SizedBox(height:24),

            /// BUTTON
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
                          55),

                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(
                            14),

                      ),

                    ),

                    onPressed:(){

                      Navigator.pop(
                          context);

                    },

                    child:
                    const Text(
                      "Batal",
                    ),

                  ),

                ),

                const SizedBox(width:14),

                Expanded(

                  flex:2,

                  child:
                  ElevatedButton.icon(

                    style:
                    ElevatedButton.styleFrom(

                      backgroundColor:
                      Colors.indigo,

                      minimumSize:
                      const Size(
                          double.infinity,
                          55),

                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(
                            14),

                      ),

                    ),

                    onPressed:
                    isLoading
                        ? null
                        : submitService,

                    icon:

                    isLoading

                        ?

                    const SizedBox(

                      height:18,
                      width:18,

                      child:
                      CircularProgressIndicator(

                        color:Colors.white,
                        strokeWidth:2,

                      ),

                    )

                        :

                    const Icon(Icons.save),

                    label:
                    Text(

                      isLoading

                          ?

                      "Menyimpan..."

                          :

                      widget.isEdit
                        ? "Update Layanan"
                        : "Simpan Layanan"

                    ),

                  ),

                ),

              ],

            ),

            const SizedBox(height:30),

          ],

        ),

      ),

    );

  }

}