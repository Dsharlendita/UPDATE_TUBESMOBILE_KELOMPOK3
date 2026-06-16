import 'package:flutter/material.dart';

import '../../models/fragrance_model.dart';
import '../../services/fragrance_service.dart';

class EditFragranceScreen
    extends StatefulWidget {

  final FragranceModel fragrance;

  const EditFragranceScreen({

    super.key,

    required this.fragrance,

  });

  @override
  State<EditFragranceScreen>
  createState() =>
      _EditFragranceScreenState();

}

class _EditFragranceScreenState
    extends State<EditFragranceScreen> {

  late TextEditingController
  nameController;

  final FragranceService
  fragranceService =
  FragranceService();

  late String selectedColor;

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

  @override
  void initState() {

    super.initState();

    nameController =
        TextEditingController(

      text:
      widget.fragrance.name,

    );

    selectedColor =
        widget.fragrance.color;

  }

  Future update() async {

    setState(() {
      loading = true;
    });

    final result =

    await fragranceService
        .updateFragrance(

      id:
      widget.fragrance.id,

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
          "Edit Pewangi",
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

                update,

                child:
                const Text(
                  "Update",
                ),

              ),

            )

          ],

        ),

      ),

    );

  }

}