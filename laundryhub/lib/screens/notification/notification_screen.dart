import 'package:flutter/material.dart';

import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

class NotificationScreen
    extends StatefulWidget {

  const NotificationScreen({
    super.key,
  });

  @override
  State<NotificationScreen>
  createState() =>
      _NotificationScreenState();

}

class _NotificationScreenState
    extends State<NotificationScreen> {

  final NotificationService
  service =
  NotificationService();

  bool loading = true;

  List<NotificationModel>
  notifications = [];

  String type =
      "all";

  String status =
      "all";

  int unreadCount = 0;

  @override
  void initState() {

    super.initState();

    loadData();

  }

  Future loadData() async {

    setState(() {
      loading = true;
    });

    final result =

    await service
        .getNotifications(

      type:
      type == "all"
          ? null
          : type,

      status:
      status == "all"
          ? null
          : status,

    );

    if(result["success"]){

      notifications =
      result["notifications"];

      unreadCount =
      result["unreadCount"];

    }

    setState(() {
      loading = false;
    });

  }

  IconData getIcon(
      String type){

    switch(type){

      case "transaction":
        return Icons.receipt_long;

      case "pickup":
        return Icons.local_shipping;

      case "payment":
        return Icons.payments;

      case "laundry":
        return Icons.store;

      default:
        return Icons.notifications;

    }

  }

  Color getColor(
      String type){

    switch(type){

      case "transaction":
        return Colors.blue;

      case "pickup":
        return Colors.green;

      case "payment":
        return Colors.orange;

      case "laundry":
        return Colors.indigo;

      default:
        return Colors.purple;

    }

  }

  Future deleteItem(int id)
  async {

    await service
        .deleteNotification(id);

    loadData();

  }

  Future readAll() async {

    await service
        .markAllAsRead();

    loadData();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title:
        const Text(
          "Notifikasi",
        ),

        actions:[

          if(unreadCount > 0)

            Padding(

              padding:
              const EdgeInsets.only(
                  right: 16),

              child: Center(

                child: Container(

                  padding:
                  const EdgeInsets
                      .symmetric(

                    horizontal:10,
                    vertical:4,

                  ),

                  decoration:
                  BoxDecoration(

                    color: Colors.red,

                    borderRadius:
                    BorderRadius.circular(
                        20),

                  ),

                  child: Text(

                    "$unreadCount",

                    style:
                    const TextStyle(

                      color:
                      Colors.white,

                    ),

                  ),

                ),

              ),

            )

        ],

      ),

      body:

      loading

          ?

      const Center(
        child:
        CircularProgressIndicator(),
      )

          :

      Column(

        children:[

          Padding(

            padding:
            const EdgeInsets.all(16),

            child: Row(

              children:[

                Expanded(

                  child:
                  DropdownButtonFormField(

                    value:type,

                    items:[

                      "all",
                      "transaction",
                      "pickup",
                      "payment",
                      "laundry",

                    ].map(

                          (e)=>

                          DropdownMenuItem(

                            value:e,

                            child: Text(e),

                          ),

                    ).toList(),

                    onChanged:(v){

                      type = v!;

                    },

                  ),

                ),

                const SizedBox(
                  width:10,
                ),

                Expanded(

                  child:
                  DropdownButtonFormField(

                    value:status,

                    items:[

                      "all",
                      "read",
                      "unread",

                    ].map(

                          (e)=>

                          DropdownMenuItem(

                            value:e,

                            child: Text(e),

                          ),

                    ).toList(),

                    onChanged:(v){

                      status = v!;

                    },

                  ),

                ),

              ],

            ),

          ),

          Padding(

            padding:
            const EdgeInsets.symmetric(
                horizontal:16),

            child: Row(

              children:[

                Expanded(

                  child:
                  OutlinedButton(

                    onPressed:
                    loadData,

                    child:
                    const Text(
                      "Filter",
                    ),

                  ),

                ),

                const SizedBox(
                  width:10,
                ),

                Expanded(

                  child:
                  ElevatedButton(

                    onPressed:
                    readAll,

                    child:
                    const Text(
                      "Tandai Semua Dibaca",
                    ),

                  ),

                ),

              ],

            ),

          ),

          const SizedBox(
            height:10,
          ),

          Expanded(

            child:

            notifications.isEmpty

                ?

            const Center(

              child: Text(
                "Belum ada notifikasi",
              ),

            )

                :

            ListView.builder(

              itemCount:
              notifications.length,

              itemBuilder:
                  (_,i){

                final item =
                notifications[i];

                return Card(

                  margin:
                  const EdgeInsets
                      .symmetric(

                    horizontal:16,
                    vertical:6,

                  ),

                  color:

                  item.isRead

                      ?

                  Colors.white

                      :

                  Colors.blue.shade50,

                  child: ListTile(

                    leading:

                    CircleAvatar(

                      backgroundColor:

                      getColor(
                          item.type)

                          .withOpacity(
                          .15),

                      child: Icon(

                        getIcon(
                            item.type),

                        color:
                        getColor(
                            item.type),

                      ),

                    ),

                    title: Text(

                      item.title,

                      style:
                      const TextStyle(

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),

                    subtitle:
                    Column(

                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children:[

                        const SizedBox(
                            height:4),

                        Text(
                          item.message,
                        ),

                        const SizedBox(
                            height:6),

                        Text(

                          item.createdAt,

                          style:
                          TextStyle(

                            fontSize:12,

                            color:
                            Colors.grey
                                .shade600,

                          ),

                        )

                      ],

                    ),

                    trailing:
                    PopupMenuButton(

                      itemBuilder:
                          (_)=>[

                        PopupMenuItem(

                          onTap: () async {

                            await service
                                .markAsRead(
                                  item.id,
                                );

                            await loadData();

                          },

                          child: const Text(
                            "Tandai Dibaca",
                          ),

                        ),

                        PopupMenuItem(

                          onTap:(){

                            deleteItem(
                                item.id);

                          },

                          child:
                          const Text(
                            "Hapus",
                          ),

                        ),

                      ],

                    ),

                  ),

                );

              },

            ),

          )

        ],

      ),

    );

  }

}