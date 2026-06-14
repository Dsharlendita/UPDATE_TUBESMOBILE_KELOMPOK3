import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';

class TestDashboard extends StatefulWidget {
  const TestDashboard({super.key});

  @override
  State<TestDashboard> createState() =>
      _TestDashboardState();
}

class _TestDashboardState
    extends State<TestDashboard> {

  Map<String,dynamic>? dashboard;

  bool loading=true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {

    final result=
    await DashboardService()
    .getCustomerDashboard();

    if(result["success"]){

      setState(() {

        dashboard=
        result["data"]["data"];

        loading=false;

      });

    }

  }

  @override
  Widget build(BuildContext context){

    if(loading){

      return const Scaffold(

        body: Center(
          child:
          CircularProgressIndicator(),
        ),

      );
    }

    final stats=
    dashboard!["stats"];

    return Scaffold(

      backgroundColor:
      const Color(
        0xffF8FAFC,
      ),

      appBar: AppBar(

        title:
        const Text(
          "Dashboard Customer",
        ),

      ),

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(
          20,
        ),

        child: Column(

          children: [

            Row(

              children: [

                Expanded(

                  child: card(

                    "Total Pesanan",

                    stats[
                    "total_transactions"
                    ].toString(),

                    Icons.receipt,

                    Colors.blue,

                  ),

                ),

                const SizedBox(
                  width:15,
                ),

                Expanded(

                  child: card(

                    "Diproses",

                    stats[
                    "active_transactions"
                    ].toString(),

                    Icons.local_laundry_service,

                    Colors.orange,

                  ),

                ),

              ],

            ),

            const SizedBox(
              height:15,
            ),

            Row(

              children: [

                Expanded(

                  child: card(

                    "Total Belanja",

                    "Rp ${stats["total_spent"]}",

                    Icons.wallet,

                    Colors.green,

                  ),

                ),

                const SizedBox(
                  width:15,
                ),

                Expanded(

                  child: card(

                    "Pickup",

                    stats[
                    "pending_pickups"
                    ].toString(),

                    Icons.local_shipping,

                    Colors.purple,

                  ),

                ),

              ],

            ),

          ],

        ),
      ),
    );
  }

  Widget card(

      String title,
      String value,
      IconData icon,
      Color color){

    return Container(

      padding:
      const EdgeInsets.all(
        15,
      ),

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
            Colors.grey
            .shade200,

            blurRadius:10,

          )

        ],

      ),

      child: Column(

        children: [

          Icon(

            icon,

            size:30,

            color:color,

          ),

          const SizedBox(
            height:10,
          ),

          Text(

            title,

            style:
            const TextStyle(

              fontSize:14,

            ),
          ),

          const SizedBox(
            height:10,
          ),

          Text(

            value,

            style:
            const TextStyle(

              fontSize:20,
              fontWeight:
              FontWeight.bold,

            ),
          ),

        ],

      ),
    );
  }
}