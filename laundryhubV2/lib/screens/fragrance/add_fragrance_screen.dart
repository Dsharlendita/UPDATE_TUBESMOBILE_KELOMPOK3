import 'package:flutter/material.dart';

import '../../services/fragrance_service.dart';

class AddFragranceScreen
    extends StatefulWidget {

  const AddFragranceScreen({
    super.key,
  });

  @override
  State<AddFragranceScreen>
  createState() =>
      _AddFragranceScreenState();

}

class _AddFragranceScreenState
    extends State<AddFragranceScreen> {

  final TextEditingController
  nameController =
  TextEditingController();

  final FragranceService
  fragranceService =
  FragranceService();

  String selectedColor =
      "blue";

  bool loading = false;

  final List<String> colors = [

    "blue",
    "green",
    "yellow",
    "red",
    "purple",
    "pink",
    "indigo",
    "gray",

  ];

  Future save() async {

    if(nameController.text.isEmpty){
      return;
    }

    setState(() {
      loading = true;
    });

    final result =

    await fragranceService
        .createFragrance(

      name:
      nameController.text,

      color:
      selectedColor,

    );

    setState(() {
      loading = false;
    });

    if(result["success"]){

      if(mounted){
        Navigator.pop(
          context,
          true,
        );
      }

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
        const Text(
          "Tambah Pewangi",
        ),
      ),

      body: Padding(

        padding:
        const EdgeInsets.all(20),

        child: Column(

          children:[

            TextField(

              controller:
              nameController,

              decoration:
              const InputDecoration(

                labelText:
                "Nama Pewangi",

              ),

            ),

            const SizedBox(
              height:20,
            ),

            DropdownButtonFormField(

              value:
              selectedColor,

              items:

              colors.map(

                (e)=>

                DropdownMenuItem(

                  value:e,

                  child: Text(e),

                ),

              ).toList(),

              onChanged:(v){

                setState(() {

                  selectedColor =
                  v!;

                });

              },

            ),

            const SizedBox(
              height:30,
            ),

            SizedBox(

              width:
              double.infinity,

              child:
              ElevatedButton(

                onPressed:
                loading

                    ?

                null

                    :

                save,

                child:
                const Text(
                  "Simpan",
                ),

              ),

            )

          ],

        ),

      ),

    );

  }

}