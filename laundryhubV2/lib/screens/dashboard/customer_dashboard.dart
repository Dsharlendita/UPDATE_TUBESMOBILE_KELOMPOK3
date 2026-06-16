import 'package:flutter/material.dart';
import '../../services/dashboard_service.dart';

class CustomerDashboard
    extends StatefulWidget {

  const CustomerDashboard({
    super.key,
  });

  @override
  State<CustomerDashboard>
  createState() =>
      _CustomerDashboardState();

}

class _CustomerDashboardState
    extends State<CustomerDashboard>{

  bool loading=true;

  Map<String,dynamic> data={};

  @override
  void initState() {

    super.initState();

    loadDashboard();

  }

  Future<void>
  loadDashboard() async {

    final result=
    await DashboardService()
        .getCustomerDashboard();

    if(result["success"]){

      setState(() {

        data=
        result["data"]["data"];

        loading=false;

      });

    }

  }

  Widget card({

    required String title,
    required dynamic value,
    required IconData icon,
    required Color color,

  }){

    return Container(

      padding:
      const EdgeInsets.all(
          16
      ),

      decoration:
      BoxDecoration(

        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
            20
        ),

        boxShadow:[

          BoxShadow(

            color:
            Colors.black12,

            blurRadius:5,

          )

        ],

      ),

      child:

      Column(

        children:[

          Icon(

            icon,

            color:
            color,

            size:30,

          ),

          const SizedBox(
            height:10,
          ),

          Text(
            title,
          ),

          const SizedBox(
            height:10,
          ),

          Text(

            value.toString(),

            style:
            const TextStyle(

              fontSize:22,

              fontWeight:
              FontWeight.bold,

            ),

          )

        ],

      ),

    );

  }

  @override
  Widget build(
      BuildContext context
      ){

    if(loading){

      return const Scaffold(

        body:
        Center(

          child:
          CircularProgressIndicator(),

        ),

      );

    }

    final stats=
    data["stats"];

    return Scaffold(

      appBar: AppBar(

        title:
        const Text(
          "Dashboard Customer",
        ),

      ),

      body:

      Padding(

        padding:
        const EdgeInsets.all(
            20
        ),

        child:

        GridView.count(

          crossAxisCount:2,

          crossAxisSpacing:15,

          mainAxisSpacing:15,

          children:[

            card(

              title:
              "Total Pesanan",

              value:
              stats["total_transactions"],

              icon:
              Icons.receipt,

              color:
              Colors.blue,

            ),

            card(

              title:
              "Diproses",

              value:
              stats["active_transactions"],

              icon:
              Icons.local_laundry_service,

              color:
              Colors.orange,

            ),

            card(

              title:
              "Total Belanja",

              value:
              "Rp ${stats["total_spent"]}",

              icon:
              Icons.payments,

              color:
              Colors.green,

            ),

            card(

              title:
              "Pickup",

              value:
              stats["pending_pickups"],

              icon:
              Icons.local_shipping,

              color:
              Colors.purple,

            ),

          ],

        ),

      ),

    );

  }

}